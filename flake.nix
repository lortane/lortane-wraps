{
  description = "lortane's wraps: my customized programs with configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    wrappers.url = "github:BirdeeHub/nix-wrapper-modules";
  };

  outputs =
    {
      self,
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

      # Function to create package - handles both module and direct wrap
      makePackage =
        pkgs: name:
        let
          programImport = import (programsDir + "/${name}");
        in
        if builtins.isFunction programImport then
          # It's a module - evaluate it with pkgs
          (wrappers.lib.evalModule (
            { config, ... }:
            {
              imports = [ programImport ];
              config.pkgs = pkgs;
            }
          )).config.wrapper.wrap
            { inherit pkgs; }
        else
          # It's already a package (direct wrap call)
          programImport { inherit pkgs wrappers; };

      # Create overlay
      makeOverlay =
        pkgs: final: prev:
        builtins.listToAttrs (
          builtins.map (name: {
            name = "lortane-${name}";
            value = makePackage final name;
          }) validPrograms
        );

    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Create packages for this system
        packages = builtins.listToAttrs (
          builtins.map (name: {
            inherit name;
            value = makePackage pkgs name;
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
      # Global overlay
      overlays.default = final: prev: makeOverlay final final prev;

      # NixOS module
      nixosModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          customPkgs = pkgs.extend self.overlays.default;
        in
        {
          options.lortane-wraps = {
            enable = lib.mkEnableOption "lortane's custom programs";
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
                name: lib.optional config.lortane-wraps.programs.${name} customPkgs."lortane-${name}"
              ) validPrograms
            );
          };
        };
    };
}
