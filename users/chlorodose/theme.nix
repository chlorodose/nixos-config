{
  inputs,
  ...
}:
{
  imports = [ inputs.catppuccin.homeManagerModules.catppuccin ];
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";

    glamour.enable = false;
    nvim.enable = false;
  };
}
