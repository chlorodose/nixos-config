{
  plugins.neo-tree.enable = true;
  keymaps = [
    {
      action = "<cmd>Neotree toggle<CR>";
      key = "\\";
      mode = "n";
      options = {
        desc = "Troggle neotree";
      };
    }
  ];
}
