{
  description = "lortane's wraps: my customized programs with configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      wrappers,
      ...
    }:
    let
      # Discover all programs
      programsDir = ./programs;
      programNames = builtins.attrNames (builtins.readDir programsDir);

      validPrograms = builtins.filter (
        name:
        let
          path = programsDir + "/${name}";
        in
        builtins.pathExists (path + "/default.nix")
      ) programNames;

      # Create overlay that works for any system
      makeOverlay =
        pkgs: final: prev:
        builtins.listToAttrs (
          builtins.map (name: {
            name = "lortane-${name}";
            value = import (programsDir + "/${name}") {
              inherit wrappers;
              pkgs = final;
            };
          }) validPrograms
        );

      # Create NixOS module
      makeNixOSModule =
        pkgs:
        { config, lib, ... }:
        {
          options.lortane-wraps = {
            enable = lib.mkEnableOption "lortane's custom programs";

            # Auto-generate options for each program
            programs = builtins.listToAttrs (
              builtins.map (name: {
                name = name;
                value = lib.mkOption {
                  type = lib.types.bool;
                  default = false;
                  description = "Enable lortane's ${name}";
                };
              }) validPrograms
            );
          };

          config = lib.mkIf config.lortane-wraps.enable {
            environment.systemPackages = builtins.concatLists (
              builtins.map (
                name: lib.optional config.lortane-wraps.programs.${name} pkgs."lortane-${name}"
              ) validPrograms
            );
          };
        };

    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Create packages for this system
        packages = builtins.listToAttrs (
          builtins.map (name: {
            inherit name;
            value = import (programsDir + "/${name}") { inherit pkgs wrappers; };
          }) validPrograms
        );

      in
      {
        inherit packages;

        apps = builtins.mapAttrs (name: pkg: {
          type = "app";
          program = "${pkg}/bin/${name}";
        }) packages;

        # System-specific overlay
        overlays.default = makeOverlay pkgs;
      }
    )
    // {
      # Global overlay (works across all systems)
      overlays.default = final: prev: makeOverlay final final prev;

      # NixOS module
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        makeNixOSModule pkgs { inherit config lib; };
    };
}
