{
  description = "polywrap wrapper test";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable"; };

  outputs = inputs@{ self, nixpkgs }:
    let
      eachSystem = systems: f:
        let
          op = attrs: system:
            let
              ret = f system;
              op = attrs: key:
                let
                  appendSystem = key: system: ret: { ${system} = ret.${key}; };
                in attrs // {
                  ${key} = (attrs.${key} or { })
                    // (appendSystem key system ret);
                };
            in builtins.foldl' op attrs (builtins.attrNames ret);
        in builtins.foldl' op { } systems;
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "i686-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in eachSystem defaultSystems (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages = { };
        defaultPackage = { };
        defaultApp = { };
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ nodejs yarn docker docker-compose ];
        };
      });
}
