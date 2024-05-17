{
  description = "A flake for aider";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aider = {
      url = "github:paul-gauthier/aider";
      flake = false;
    };
    grep-ast = {
      url = "github:paul-gauthier/grep-ast";
      flake = false;
    };
  };

  outputs = { nixpkgs, flake-parts, aider, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems =
        [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }:
        let
          # py = pkgs.python312;
          pyPkgs = pkgs.python312Packages;
          aider = pyPkgs.buildPythonPackage {
            pname = "aider";
            version = "0.30.0";
            src = fetchGit {
              url = "https://github.com/paul-gauthier/aider";
              rev = "b14ca861c1709cc3e53160560f09f6ebf16f2d66";
            };
            doCheck = false;
            propagatedBuildInputs = with pyPkgs; [
              configargparse
              gitpython
              openai
              tiktoken
              jsonschema
              rich
              prompt-toolkit
              numpy
              scipy
              backoff
              pathspec
              networkx
              diskcache
              packaging
              sounddevice
              soundfile
              beautifulsoup4
              pyyaml
              pillow
              diff-match-patch
              playwright
              pypandoc
              litellm
              google-generativeai
              # not defined in nixpkgs
              grep-ast
            ];
          };
          grep-ast = pyPkgs.buildPythonPackage {
            pname = "grep-ast";
            version = "0.2.4";
            src = fetchGit {
              url = "https://github.com/paul-gauthier/grep-ast";
              rev = "4adb83e164f31c3a9ae364de8a7b14b9481aca60";
            };
            doCheck = false;
            propagatedBuildInputs = with pyPkgs; [
              pathspec
              # not defined in nixpkgs
              tree-sitter-languages
            ];
          };
          tree-sitter-languages = pyPkgs.buildPythonPackage {
            pname = "tree_sitter_languages";
            version = "1.10.2";
            format = "wheel";
            src =
              ./tree_sitter_languages-1.10.2-cp312-cp312-manylinux_2_17_x86_64.manylinux2014_x86_64.whl;
            # src = pyPkgs.fetchPypi {
            #   inherit pname version format;
            #   sha256 = "bS8c0dG91lMy+cK2fUnc8UjPHe11KFHRWaw+XuT00mA=";
            #   python = "cp312";
            #   abi = "cp312";
            #   platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
            # };
            propagatedBuildInputs = with pyPkgs; [ tree-sitter ];
          };
        in { packages = { default = aider; }; };
    };
}
