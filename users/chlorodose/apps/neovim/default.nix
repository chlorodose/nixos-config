{
  pkgs,
  lib,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs.nixvim = lib.mkMerge (
    # TODO: Add more plugin
    [
      {
        enable = true;
        defaultEditor = true;
        withNodeJs = true;
        withRuby = false;
        impureRtp = false;
        wrapRc = true;
        nixpkgs.useGlobalPackages = true;
        performance.byteCompileLua = {
          enable = false;
          configs = true;
          initLua = true;
          luaLib = true;
          nvimRuntime = true;
          plugins = true;
        };
      }
      # Pager
      {
        extraPlugins = [
          pkgs.vimPlugins.vim-plugin-AnsiEsc
        ];
        extraConfigLua = "
          if vim.g.is_pager then
            vim.api.nvim_create_autocmd('VimEnter', {
              pattern = '*',
              once = true,
              callback = function()
                vim.bo.buftype = 'nofile'
                vim.bo.bufhidden = 'wipe'

                vim.keymap.set('n', 'q', ':q<CR>', { silent = true, buffer = true })

                vim.cmd('AnsiEsc')
              end,
            })
          end
        ";
      }
    ]
    ++ (lib.map import (outputs.lib.scanPath ./.))
  );
  home.sessionVariables.PAGER = "${pkgs.writeScriptBin "nvim-pager" ''
    #!${pkgs.bashNonInteractive}/bin/sh
    exec nvim -R -n --cmd 'lua vim.g.is_pager=true'
  ''}/bin/nvim-pager";
}
