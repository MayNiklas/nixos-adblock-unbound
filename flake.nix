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
               , src ? (adblockStevenBlack + "/hosts")
               , ...
               }:
                stdenv.mkDerivation {
                  pname = "nixos-adblock-unbound";
                  version = "1.0.0";
                  phases = [ "installPhase" ];
                  installPhase =
                    ''
                      CONFIG_FILE=./tmp.conf
                      # Read the upstream file line by line
                      while read -r LINE || [ -n "$LINE" ];
                      do
                        # If line begins with "0.0.0.0" it is a valid line
                        if [[ ''${LINE:0:7} == "0.0.0.0" ]]; then
                          domain=$(echo $LINE | awk '{print $2}')
                          echo "local-zone: \""$domain"\" static" >> $CONFIG_FILE
                        fi
                      done < ${adblockStevenBlack}/hosts
                      cat $CONFIG_FILE | tr '[:upper:]' '[:lower:]' | sort -u >  $out
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
            unbound-adblockStevenBlack = self.packages.${system}.nixos-adblock-unbound.override { src = (adblockStevenBlack + "/hosts"); };
          });
    };
}
