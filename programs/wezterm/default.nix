{
  config,
  wlib,
  lib,
  ...
}:
let
  # Create the zdot directory with our zsh config
  zdotdir = config.pkgs.callPackage ./zdot { };
in
{
  imports = [ wlib.wrapperModules.wezterm ];

  config = {
    "wezterm.lua".content = builtins.readFile ./config.lua;

    luaInfo = {
      # Wezterm config values
      font = lib.generators.mkLuaInline "wezterm.font('Terminess Nerd Font Mono')";
      font_size = 14.0;
      color_scheme = "kanagawabones";

      set_environment_variables = {
        ZDOTDIR = "${zdotdir}";
      };
    };
  };

  # Make starship available
  config.extraPackages = [ config.pkgs.starship ];
}
