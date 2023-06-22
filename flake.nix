{
  description = "xgen-cloud/crosstool-ng";
  nixConfig.bash-prompt-prefix = "(crosstool-ng) ";

  inputs = {
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };


  outputs = { self, nixpkgs, flake-compat, flake-utils, flake-parts }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = { };
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        apps.bootstrap = {
          type = "app";
          program = toString (pkgs.writers.writeBash "ct-bootstrap" ''
            	  	./bootstrap
            		CC=clang CXX=clang PATCH=/usr/bin/patch ./configure --enable-local
            		make
            		./ct-ng list-steps
            	  '');
        };
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
          shellHook = ''
            	    ulimit -n unlimited
            	    unset CC CXX
            	  '' + pkgs.lib.optionals pkgs.stdenv.isDarwin ''
            	    export CT_PREFIX=/Volumes/Casey/crosstool
            	  '';
          buildInputs = with pkgs; [
            bashInteractive
            gitFull
            jq
            wget
            binutils
            help2man
            libtool
            gnumake
            ncurses.dev
            autoconf
            automake
            zstd
            patch
          ];
        };
      };
    };
}

