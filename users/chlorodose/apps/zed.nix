{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.zed-editor = {
      enable = true;
      extensions = [
        "catppuccin"
        "catppuccin-blur"
        "catppuccin-icons"
        "rust-snippets"
        "nix"
        "make"
        "basher"
      ];
      userSettings = {
        vim_mode = true;
        features = {
          copilot = true;
          edit_prediction_provider = "copilot";
        };
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];
          };
        };
        icon_theme = "Catppuccin Mocha";
        base_keymap = "VSCode";
        theme = "Catppuccin Mocha (Blur)";
        autosave = "on_focus_change";
        auto_update = false;
        buffer_font_family = "Maple Mono NF CN";
        minimap.show = "auto";
        tabs = {
          file_icons = true;
          git_status = true;
          show_diagnostics = "all";
        };
        toolbar.code_actions = true;
        diagnostics.inline.enabled = true;
      };
    };
  };
}
