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
          pyPkgs = pkgs.python312Packages;
          aider = pyPkgs.buildPythonPackage {
            pname = "aider";
            version = "0.35.0";
            src = fetchGit {
              url = "https://github.com/paul-gauthier/aider";
              rev = "aaaef12ccec391006637957d506c532435184d32";
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
              streamlit
              # not defined in nixpkgs
              grep-ast
            ];
          };
          streamlit = pyPkgs.buildPythonPackage {
            pname = "streamlit";
            version = "1.2.0";
            format = "wheel";
            src = ./streamlit-1.34.0-py2.py3-none-any.whl;
            propagatedBuildInputs = with pyPkgs; [ blinker tornado ];
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
            propagatedBuildInputs = with pyPkgs; [ tree-sitter ];
          };
        in { packages = { default = aider; }; };
    };
}
