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

Use `unbound-adblockStevenBlack` as a config file in unbound.
