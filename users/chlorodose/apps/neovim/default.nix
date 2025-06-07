{
  pkgs,
  lib,
  inputs,
  outputs,
  config,
  ...
}:
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];
  programs.nixvim = lib.mkMerge (
    [
      {
        enable = true;
        defaultEditor = true;
        withNodeJs = true;
        withRuby = false;
        impureRtp = false;
        wrapRc = true;
        nixpkgs.useGlobalPackages = true;
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
  home.sessionVariables.PAGER = "nvim -R -n --cmd 'lua vim.g.is_pager=true'";
}
