# NixOS Unbound Configs

Used to generate unbound configs via Nix functions.

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
  inputs = {
    # Adblocking lists for Unbound DNS servers running on NixOS
    # https://github.com/MayNiklas/nixos-adblock-unbound
    adblock-unbound = {
      url = "github:MayNiklas/nixos-adblock-unbound";
      inputs = {
        adblockStevenBlack.follows = "adblockStevenBlack";
      };
    };
    # Adblocking lists for DNS servers
    # input here, so it will get updated by nix flake update
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
  };
}
```

2. Use the config file with your unbound server:

```nix
{ config, lib, pkgs, adblock-unbound, ... }:
with lib;
let adlist = adblock-unbound.packages.${pkgs.system}; in
{
  config = {
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
