{
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    glamour.enable = false;
    nvim.enable = false;
    mako.enable = false;
    vscode.enable = false;
  };
}
