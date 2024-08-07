{
  description = "A flake for aider";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    aider-input = {
      # v0.47.0 is commit 5ae96231
      url = "github:paul-gauthier/aider/5ae96231ad5be9158e35bb916b3d276f3139d18a";
      flake = false;
    };
    grep-ast = {
      url = "github:paul-gauthier/grep-ast";
      flake = false;
    };
  };

  outputs = {
    flake-parts,
    aider-input,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {pkgs, ...}: let
        pyPkgs = pkgs.python312Packages;
        aider = pyPkgs.buildPythonPackage {
          pname = "aider";
          version = "0.47.0";
          src = aider-input;
          doCheck = false;
          propagatedBuildInputs = with pyPkgs; [
            backoff
            beautifulsoup4
            configargparse
            diff-match-patch
            diskcache
            gitpython
            google-generativeai
            importlib-resources
            jsonschema
            litellm
            networkx
            numpy
            openai
            packaging
            pathspec
            pillow
            playwright
            prompt-toolkit
            pypandoc
            pyyaml
            rich
            scipy
            sounddevice
            soundfile
            tiktoken
            # not defined in nixpkgs
            streamlit
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
        streamlit = pyPkgs.buildPythonPackage rec {
          pname = "streamlit";
          version = "1.2.0";
          format = "wheel";
          src = pyPkgs.fetchPypi {
            inherit pname version format;
            sha256 = "sha256-NoRvVpc/AZyYCmVzn81rYhWRoMWq4crulZsjixQy67c=";
          };
          propagatedBuildInputs = with pyPkgs; [blinker tornado];
          doCheck = false;
        };
        tree-sitter-languages = pyPkgs.buildPythonPackage rec {
          pname = "tree_sitter_languages";
          version = "1.10.2";
          format = "wheel";
          src = pkgs.fetchPypi {
            inherit pname version format;
            python = "cp312";
            abi = "cp312";
            platform = "manylinux_2_17_x86_64.manylinux2014_x86_64";
            sha256 = "sha256-bS8c0dG91lMy+cK2fUnc8UjPHe11KFHRWaw+XuT00mA=";
          };
          propagatedBuildInputs = with pyPkgs; [tree-sitter];
          doCheck = false;
        };
      in {packages = {default = aider;};};
    };
}
