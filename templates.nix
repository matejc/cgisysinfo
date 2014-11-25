{ pkgs, prefix }:
[

  {
    name = "index.sh";
    text = ''
      #!${pkgs.bash}/bin/bash

      export PATH="$PATH:${pkgs.procps}/bin:${pkgs.sysstat}${pkgs.sysstat}/bin"
      echo -e "Content-type: text/plain\n\n"

      echo RAM: `free -mh | awk 'NR==2{ print $3"/"$2 }'`
      echo Swap: `free -mh | awk 'NR==3{ print $3"/"$2 }'`
      ps -eo pcpu,pmem,user,args | sort -k 1 -r | awk 'NR>1 && NR<5{n=split($4,a,"/"); print a[n]": cpu:"$1"%, mem:"$2"%, u:"$3}'
      echo
    '';
  }

  {
    name = "hello.pl";
    text = ''
      #!${pkgs.perl}/bin/perl

      print "Content-type: text/html\n\n";
      print "<html><body>Hello, Perl world.</body></html>";
    '';
  }

  {
    name = "hello.py";
    text = ''
      #!${pkgs.python27}/bin/python

      print "Content-type: text/html\n\n";
      print "<html><body>Hello, Python world.</body></html>";
    '';
  }

]
