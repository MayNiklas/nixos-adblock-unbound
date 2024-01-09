{
  description = "A very basic flake";

  inputs = {
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };
    lancache-domains = {
      url = "github:uklans/cache-domains";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, adblockStevenBlack, lancache-domains, ... }@inputs:
    let
      # System types to support.
      supportedSystems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
    in
    {

      overlays.default = final: prev: {
        adblock = {

          # converts a pihole list to a unbound config
          nixos-adblock-unbound = final.callPackage
            ({ lib
             , stdenv
             , adlist ? (adblockStevenBlack + "/hosts")
             , ...
             }:
              let
                lines = lib.splitString "\n" (lib.readFile adlist);
                domains = map (line: (lib.strings.removePrefix "0.0.0.0 " line)) (lib.filter (line: lib.hasPrefix "0.0.0.0" line) lines);
                cleaned-domains = map (domain: (builtins.elemAt (lib.strings.splitString " " domain) 0)) domains;
                config-file = builtins.toFile "config" (lib.concatStringsSep "\n" (map (domain: "local-zone: \"${domain}\" static") cleaned-domains));
              in
              stdenv.mkDerivation {
                pname = "nixos-adblock-unbound";
                version = "1.0.0";
                phases = [ "installPhase" ];
                installPhase = ''
                  cp ${config-file} $out
                '';
                meta = with lib; {
                  description = "converts pihole lists to unbound";
                  homepage =
                    "https://github.com/MayNiklas/nixos-adblock-unbound";
                  platforms = platforms.unix;
                  maintainers = with maintainers; [ MayNiklas ];
                };
              })
            { };

          # StevenBlack adblock list as unbound config
          unbound-adblockStevenBlack = final.adblock.nixos-adblock-unbound.override { adlist = (adblockStevenBlack + "/hosts"); };

          # Unbound config forwarding requests to the lancache server
          lancache-unbound-config = final.callPackage
            ({ lib
             , stdenv
             , LANCACHE_IP ? "192.168.0.2"
             , services ? [ "blizzard" "epicgames" "nintendo" "origin" "riot" "sony" "steam" "windowsupdates" ]
             , ...
             }:
              stdenv.mkDerivation {
                name = "lancache-unbound-config";
                phases = [ "installPhase" ];
                installPhase = toString ([
                  ''
                    CONFIG_FILE=$out
                    touch $CONFIG_FILE
                    echo "server:" > "$CONFIG_FILE"
                  ''
                  (lib.strings.concatMapStrings
                    (service:
                      ''
                        echo >> $CONFIG_FILE
                        echo "# Configuration for ${service}" >> $CONFIG_FILE
                        FILE=${lancache-domains}/${service}.txt

                        # Read the upstream file line by line
                        while read -r LINE || [ -n "$LINE" ];
                        do
                          # Skip line if it is a comment
                          if [[ ''${LINE:0:1} == '#' ]]; then
                            continue
                          fi
                         
                          # Check if hostname is a wildcard
                          if [[ $LINE == *"*"* ]]; then

                            # Remove the asterix and the dot from the start of the hostname
                            LINE=''${LINE/#\*./}
                              
                            # Add a wildcard config line
                            echo "local-zone: \"''${LINE}.\" redirect" >> $CONFIG_FILE
                          fi

                          # Add a standard A record config line
                          echo "local-data: \"''${LINE}. A ${LANCACHE_IP}\"" >> $CONFIG_FILE
                        done < $FILE
                      ''
                    )
                    services)
                ]);
              })
            { };
        };
      };

      packages = forAllSystems
        (system:
          let pkgs = nixpkgsFor.${system}; in
          {

            inherit (pkgs.adblock)
              nixos-adblock-unbound
              unbound-adblockStevenBlack
              lancache-unbound-config
              ;

          });
    };
}

