{ pkgs, ... }:
{
  programs.starship = {
    enable = true;
    settings = {
      format = "$os$shell$all$line_break$character";
      add_newline = false;
      memory_usage = {
        disabled = false;
        threshold = 50;
        symbol = " ";
        style = "bold dimmed red";
      };
      shell = {
        bash_indicator = " ";
        fish_indicator = "󰈺 ";
        nu_indicator = "_";
        disabled = false;
      };
      os.disabled = false;
      status.disabled = false;
      time.disabled = false;
      username.show_always = true;
    };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -U fish_escape_delay_ms 500
    '';
    plugins = with pkgs.fishPlugins; [
      {

        name = "z";
        src = z.src;
      }
      {
        name = "sudope";
        src = plugin-sudope.src;
      }
      {
        name = "foreign-env";
        src = foreign-env.src;
      }
    ];
  };
  programs.nushell.enable = true;
  programs.bash.enable = true;
  home.packages = with pkgs; [
    z-lua
  ];
}
