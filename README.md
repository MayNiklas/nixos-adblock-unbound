# Adblocking with NixOS & Unbound

*Work in progess!*
*Needs to be public so I can play arround with Flakes!*

### Nix / NixOS

This repository contains a `flake.nix` file.

```sh
# build the package
nix build .#
```

## How to use

### NixOS

1. Add this repository to your `flake.nix`:

```nix
{
  inputs.adblock-unbound = {
    url = "github:MayNiklas/nixos-adblock-unbound";
    inputs = { nixpkgs.follows = "nixpkgs"; };
  };
}
```

2. Use the config file with your unbound server:

```nix
{ config, lib, pkgs, adblock-unbound, ... }:
with lib;
{
  config =
    let
      adlist = adblock-unbound.packages.${pkgs.system};
    in
    {
      services.unbound = {
        enable = true;
        settings = {
          server = {
            include = [
              "\"${adlist.unbound-adblockStevenBlack}\""
            ];
            interface = [ "127.0.0.1" ];
            access-control = [ "127.0.0.0/8 allow" ];
          };
          forward-zone = [
            {
              name = ".";
              forward-addr = [
                "1.1.1.1@853#cloudflare-dns.com"
                "1.0.0.1@853#cloudflare-dns.com"
              ];
              forward-tls-upstream = "yes";
            }
          ];
        };
      };
    };
}
```
