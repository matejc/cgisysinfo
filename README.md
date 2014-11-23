cgisysinfo
==========


Description
-----------

Get system info of remote computer through ssl and basic auth.
Uses nginx and fcgiwrap.

This is one day long proof of concept relaxing project. :)


Requirements
------------

- Nix


Usage
-----

```bash
git clone git://github.com/matejc/cgisysinfo.git

cd cgisysinfo

nix-shell --argstr prefix `pwd`
```

Open `https://localhost:9999/` in browser
or use `curl`: `curl --user user:password -k https://localhost:9999/`


Example output:

```

RAM: 2.6G/7.8G
Swap: 38M/9G
firefox: cpu:9.2%, mem:3.6%, u:matej
chromium: cpu:1.9%, mem:1.5%, u:matej
chromium: cpu:1.6%, mem:1.2%, u:matej

```


Options
-------

`prefix`

    Default: "/var/lib/cgisysinfo"


`listenAddress`

    Default: "localhost:9999"


`user`

    Default: "user"


`password`
    
    Default: "passord"


Example:
```bash
nix-shell --argstr prefix `pwd` --argstr listenAddress "0.0.0.0:8080" --argstr user "matejc" --argstr password "mypassword"
```
