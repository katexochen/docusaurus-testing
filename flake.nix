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
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          yarn
          nodejs_20
        ];
      };
    };
}
