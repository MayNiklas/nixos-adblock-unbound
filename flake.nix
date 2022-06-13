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

          unbound-adblockStevenBlack = stdenv.mkDerivation {
            name = "unbound-adblockStevenBlack";
            src = (adblockStevenBlack + "/hosts");
            phases = [ "installPhase" ];
            installPhase = ''
              ${pkgs.gawk}/bin/awk '{sub(/\r$/,"")} {sub(/^127\.0\.0\.1/,"0.0.0.0")} BEGIN { OFS = "" } NF == 2 && $1 == "0.0.0.0" { print "local-zone: \"", $2, "\" static"}' $src | tr '[:upper:]' '[:lower:]' | sort -u >  $out
            '';
          };

          generate-unbound-conf = with pkgs.python3Packages;
            pkgs.python3Packages.buildPythonPackage rec {
              pname = "generate-unbound-conf";
              version = "1.0.0";
              propagatedBuildInputs = [ setuptools ];
              doCheck = false;
              src = self;
              meta = with pkgs.lib; {
                description = "generate unbound conf from adlist";
                homepage = "https://github.com/MayNiklas/nixos-adblock-unbound/";
                platforms = platforms.unix;
                maintainers = with maintainers; [ mayniklas ];
              };
            };

        };

      }
    );

}
