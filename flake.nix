{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      inherit (pkgs) lib;
    in
    {
      packages.${system}.default = pkgs.mkYarnPackage
        rec {
          pname = "my-website";
          version = "0.1.0";
          src = ./my-website;
          packageJSON = "${src}/package.json";
          offlineCache = pkgs.fetchYarnDeps {
            yarnLock = "${src}/yarn.lock ";
            hash = "sha256-cdqM2AkGzgiuoHAyWmq/btbubJkYqBCSlPCAOgMSEZ0=";
          };
          configurePhase = ''
            cp -r $node_modules node_modules
            chmod +w node_modules
          '';
          buildPhase = ''
            export HOME=$(mktemp -d)
            yarn --offline build
          '';
          distPhase = "true";
          installPhase = ''
            mkdir -p $out
            cp -R build/* $out
          '';
        };

      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          yarn
          nodejs_20
        ];
      };
    };
}
