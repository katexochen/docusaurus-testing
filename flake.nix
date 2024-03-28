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
      packages.${system}.default = (pkgs.callPackage
        ({ baseUrl ? ""
         , mkYarnPackage
         , fetchYarnDeps
         }: mkYarnPackage rec {
          pname = "my-website";
          version = "0.1.0";
          src = ./my-website;
          packageJSON = "${src}/package.json";
          offlineCache = fetchYarnDeps {
            yarnLock = "${src}/yarn.lock ";
            hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
          configurePhase = ''
            cp -r $node_modules node_modules
            chmod +w node_modules
          '' + lib.optionalString (baseUrl != "") ''
            sed -i "s|baseUrl: '/docusaurus-testing/',|baseUrl: '${baseUrl}',|" docusaurus.config.js
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
        })
        { });
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          yarn
          nodejs_20
        ];
      };
    };
}
