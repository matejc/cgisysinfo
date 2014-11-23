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
