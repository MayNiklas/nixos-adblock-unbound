{
  description = "A very basic flake";

  inputs = {
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, adblockStevenBlack, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; overlays = [ ]; });
    in
    {
      packages = forAllSystems
        (system:
          let pkgs = nixpkgsFor.${system}; in
          {
            nixos-adblock-unbound = pkgs.callPackage
              ({ lib
               , stdenv
               , adlist ? (adblockStevenBlack + "/hosts")
               , ...
               }:
                let
                  lines = lib.splitString "\n" (lib.readFile adlist);
                  domains = lib.filter (line: lib.hasPrefix "0.0.0.0" line) lines;
                  config-file = builtins.toFile "config" (lib.concatStringsSep "\n" (map (domain: "local-zone: \"${(lib.strings.removePrefix "0.0.0.0 " domain)}\" static") domains));
                in
                stdenv.mkDerivation {
                  pname = "nixos-adblock-unbound";
                  version = "1.0.0";
                  phases = [ "installPhase" ];
                  installPhase = ''
                    cp ${config-file} $out
                  '';
                  meta = with pkgs.lib; {
                    description = "converts pihole lists to unbound";
                    homepage =
                      "https://github.com/MayNiklas/nixos-adblock-unbound";
                    platforms = platforms.unix;
                    maintainers = with maintainers; [ MayNiklas ];
                  };
                })
              { };
            unbound-adblockStevenBlack = self.packages.${system}.nixos-adblock-unbound.override { adlist = (adblockStevenBlack + "/hosts"); };
          });
    };
}

