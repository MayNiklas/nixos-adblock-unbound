{
  description = "A very basic flake";

  inputs = {
    flake-utils = { url = "github:numtide/flake-utils"; };
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    with inputs;

    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        stdenv = pkgs.stdenv;
      in
      rec {
        formatter = pkgs.nixpkgs-fmt;
        defaultPackage = packages.generate-unbound-conf;

        packages = flake-utils.lib.flattenTree {

          nixos-adblock-unbound = pkgs.buildGoModule rec {
            pname = "nixos-adblock-unbound";
            version = "1.0.0";
            src = self;
            vendorSha256 = "sha256-pQpattmS9VmO3ZIQUFn66az8GSmB4IvYhTTCFn6SUmo=";
            installCheckPhase = ''
              runHook preCheck
              $out/bin/nixos-adblock-unbound -h
              runHook postCheck
            '';
            doCheck = true;
            meta = with pkgs.lib; {
              description = "converts pihole lists to unbound";
              homepage =
                "https://github.com/MayNiklas/nixos-adblock-unbound";
              platforms = platforms.unix;
              maintainers = with maintainers; [ MayNiklas ];
            };
          };

          unbound-adblockStevenBlack = stdenv.mkDerivation {
            name = "unbound-adblockStevenBlack";
            src = (adblockStevenBlack + "/hosts");
            phases = [ "installPhase" ];
            installPhase = ''
              ${self.packages.${system}.nixos-adblock-unbound}/bin/nixos-adblock-unbound -adlist ${adblockStevenBlack}/hosts | tr '[:upper:]' '[:lower:]' | sort -u >  $out
            '';
          };

        };

      }
    );

}
