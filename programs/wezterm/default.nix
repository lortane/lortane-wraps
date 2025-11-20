{
  pkgs,
  wrappers,
  ...
}:
wrappers.wrapperModules.wezterm.wrap {
  inherit pkgs;

  "wezterm.lua".path = ./config.lua;
}
