{ pkgs ? import <nixpkgs> {}
, prefix ? "/var/lib/cgisysinfo"
, listenAddress ? "localhost"
, listenPort ? "9999"
, user ? "user"
, password ? "password"
, templatesFile ? "${prefix}/templates.nix"
, extraNginxConf ? "" }:
let

  nginxconf = pkgs.writeText "nginx.conf" ''
  pid ${prefix}/nginx.pid;
  worker_processes 1;
  events {
    worker_connections 128;
  }
  http {
    server {
      access_log ${prefix}/cgi.access.log;
      error_log ${prefix}/cgi.error.log;

      ssl on;
      ssl_certificate     ${prefix}/ssl/selfsigned.crt;
      ssl_certificate_key ${prefix}/ssl/selfsigned.key;

      root ${scripts}/www;
      index index.sh index.pl index.py;
      listen ${listenAddress}:${listenPort};

      location ~ .(py|pl|sh)$ {
        expires -1;

        auth_basic "closed site";
        auth_basic_user_file ${htpasswd};

        gzip           off;
        fastcgi_pass   unix:${prefix}/fcgiwrap.socket;

        # include      fastcgi_params;
        fastcgi_param  QUERY_STRING       $query_string;
        fastcgi_param  REQUEST_METHOD     $request_method;
        fastcgi_param  CONTENT_TYPE       $content_type;
        fastcgi_param  CONTENT_LENGTH     $content_length;

        fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name;
        fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
        fastcgi_param  REQUEST_URI        $request_uri;
        fastcgi_param  DOCUMENT_URI       $document_uri;
        fastcgi_param  DOCUMENT_ROOT      $document_root;
        fastcgi_param  SERVER_PROTOCOL    $server_protocol;

        fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
        fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

        fastcgi_param  REMOTE_ADDR        $remote_addr;
        fastcgi_param  REMOTE_PORT        $remote_port;
        fastcgi_param  SERVER_ADDR        $server_addr;
        fastcgi_param  SERVER_PORT        $server_port;
        fastcgi_param  SERVER_NAME        $server_name;
      }

      ${extraNginxConf}
    }
  }
  '';
  socketPath = "${prefix}/fcgiwrap.socket";

  htpasswd = pkgs.stdenv.mkDerivation {
    name = "${user}-htpasswd";
    phases = "installPhase";
    installPhase = ''
      export PATH="${pkgs.openssl}/bin:$PATH"
      printf "${user}:$(openssl passwd -crypt ${password})\n" >> $out
    '';
  };

  scripts =
    let
      templates = import templatesFile {inherit pkgs prefix;};
      paths = map (template:
        pkgs.writeTextFile rec {
          name = "cgisysinfo-${template.name}";
          text = template.text;
          executable = true;
          destination = "/www/${template.name}";
        }) templates;
    in
      pkgs.buildEnv {
        name = "cgisysinfo-scripts";
        inherit paths;
        pathsToLink = [ "/www" ];
      };

  run = pkgs.writeScriptBin "cgisysinfo-run" ''
  #!${pkgs.bash}/bin/bash

  function stopall() {
    kill -QUIT $( cat ${prefix}/nginx.pid )
    exit
  }
  trap "stopall" INT

  export PATH="${pkgs.fcgiwrap}/sbin:${pkgs.nginx}/bin:${pkgs.openssl}/bin:$PATH"

  # generate self-signed cert for nginx (if folder 'ssl' does not exist yet)
  test -d ${prefix}/ssl || \
    { mkdir -p ${prefix}/ssl && \
    openssl req -new -x509 -nodes -keyout ${prefix}/ssl/selfsigned.key -out ${prefix}/ssl/selfsigned.crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.xyz"; }

  test -S ${socketPath} && unlink ${socketPath}

  echo -e "\nExample usage:"
  echo "$ notify-send \"\`curl --user ${user}:<your-password> -k https://${listenAddress}:${listenPort}/\`\""
  echo -e "\nPress Ctrl+C to stop ..."

  # start nginx as daemon
  mkdir -p ${prefix}/var/logs
  nginx -c ${nginxconf} -p ${prefix}/var

  # start fcgiwrap (this one blocks)
  fcgiwrap -c 1 -s unix:${socketPath}
  '';

  cgisysinfo = pkgs.stdenv.mkDerivation rec {
    name = "cgisysinfo-${version}";
    version = "0.2";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/bin
      ln -s ${run}/bin/* $out/bin
    '';
    shellHook = ''
      ${run}/bin/cgisysinfo-run
    '';
  };

in cgisysinfo
