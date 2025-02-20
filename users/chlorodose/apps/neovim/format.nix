{
  plugins.conform-nvim = {
    enable = true;
    settings.format_on_save = {
      timeout_ms = 1000;
      lsp_format = "prefer";
    };
  };
}
