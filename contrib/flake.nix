{
  description = "Neovim development shell with Zig";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable?shallow=1";
    flake-utils.url = "github:numtide/flake-utils?shallow=1";
    # BUG: neovim-developer compilation fails due to memory leaks, see https://github.com/neovim/neovim/issues/26952
    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay?shallow=1";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # overlays = [ neovim-nightly-overlay.overlays.default ];
        pkgs = import nixpkgs {
          inherit system;
          # overlays = overlays;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.zig
            # pkgs.neovim-developer # See the BUG comment above
            # Shell script to open Neovim built using Zig with the proper runtime PATH
            (pkgs.writeShellScriptBin "nvim-dev" "VIMRUNTIME=$PWD/runtime $PWD/zig-out/bin/nvim $@")
          ];

          shellHook = ''
            echo "Entered Neovim developer shell (system: ${system})"
            # echo "Zig: $(which zig || echo 'zig not in PATH')"
            echo "Note: Use nvim-dev command to run the produced nvim binary using Zig once you compile Neovim"
          '';
        };
      });
}
