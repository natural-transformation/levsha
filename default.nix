{ pkgs ? import <nixpkgs> {} }:

let
  sbtix = pkgs.callPackage ./sbtix.nix { };

  inherit (pkgs.lib) optional;

  manualRepo = import ./manual-repo.nix;
  repoLock = import ./repo.nix;
  projectRepo = import ./project/repo.nix;

  # If present, include the meta-build (plugins-of-plugins) repo lock too.
  projectMetaRepoPath = ./project/project/repo.nix;
  projectMetaRepo =
    if builtins.pathExists projectMetaRepoPath then import projectMetaRepoPath else { };

  # Optional extra repo lock used by sbtix for some plugin dependencies.
  pluginRepoPath = ./sbtix-plugin-repo.nix;
  pluginRepo =
    if builtins.pathExists pluginRepoPath then import pluginRepoPath else null;

  repositories =
    [ repoLock projectRepo projectMetaRepo ]
    ++ optional (builtins.length (builtins.attrNames manualRepo.artifacts) > 0) manualRepo
    ++ optional (pluginRepo != null) pluginRepo;

  buildInputsPath = ./sbtix-build-inputs.nix;
  sbtixInputs =
    if builtins.pathExists buildInputsPath then pkgs.callPackage buildInputsPath { } else "";
in
  # Levsha is a library (not a packaged application), so we must not use
  # `buildSbtProgram` (which runs `sbt stage` and requires sbt-native-packager).
  sbtix.buildSbtLibrary {
    name = "levsha";
    src = pkgs.lib.cleanSource ./.;
    repo = repositories;
    sbtixBuildInputs = sbtixInputs;
  }
