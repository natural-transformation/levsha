{
  description = "Flake for dev shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    sbtix.url = "github:natural-transformation/sbtix";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      # Use the same nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, sbtix, gitignore, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: 
      let
        # Levsha currently cross-builds older Scala versions (2.12/2.13/3),
        # so we keep the devShell on JDK 17 for maximum compatibility.
        jdk17-overlay = self: super: {
          jdk = super.jdk17;
          jre = super.jdk17;
          sbt = super.sbt.override { jre = super.jdk17; };
        };
        newPkgs = import nixpkgs {
          inherit system;
          overlays = [ jdk17-overlay ];
        };
        # Get the sbtix CLI tool from the flake for devShell (handy for generating repo locks later).
        sbtixCli = inputs'.sbtix.packages.sbtix;
      in {
        devShells.default = newPkgs.mkShell {
          nativeBuildInputs = with newPkgs; [
            sbt
            sbtixCli
            jdk
            # Needed for Scala.js tests (sbt-scalajs uses Node.js as a JS runtime).
            nodejs
          ];
          # Set NIX_PATH so `nix-build --arg pkgs 'import <nixpkgs> {}'` stays consistent.
          NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
        };
      };
     
      flake = { };
    };
}


