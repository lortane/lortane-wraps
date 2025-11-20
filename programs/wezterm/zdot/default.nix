{
  pkgs,
  runCommand,
  writeText,
  ...
}:
let
  starshipConfig = writeText "starship.toml" (builtins.readFile ./starship.toml);

  zshrc = writeText "zshrc" ''
    # Use starship prompt
    export STARSHIP_CONFIG="${starshipConfig}"
    eval "$(${pkgs.starship}/bin/starship init zsh)"
  '';
in
runCommand "wezterm-zdotdir" { } ''
  mkdir -p $out
  cp ${zshrc} $out/.zshrc
  cp ${starshipConfig} $out/starship.toml
''
