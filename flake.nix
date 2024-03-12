{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.devenv.url = "github:cachix/devenv";

  outputs = inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
    {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "x86_64-linux" "x86_64-darwin" ];
      perSystem = { pkgs, ... }:{
        devenv.shells.default = {
          packages = with pkgs; [ zlib haskellPackages.hoogle haskell-language-server ];
          scripts.site = {
            exec = "stack exec blog -- $@";
          };
          scripts.deploy = {
            exec = ''
              git stash
              stack exec site rebuild
              git switch gh-pages
              rm -rf docs
              cp -r _site docs
              git add docs
              git commit -m "$(date)"
              git push --force origin gh-pages
              git switch master
              git stash pop
            '';
          };
        };
      };
    };
}
