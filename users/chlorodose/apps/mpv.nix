{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.mpv = {
      enable = true;
      config = {
        vo = "gpu";
        ao = "pipewire";
        hwdec = "auto";
        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        dscale = "ewa_lanczossharp";
        interpolation = true;
        tscale = "oversample";
        video-sync = "display-resample";
        sub-auto = "fuzzy";
        volume-max = 150;
        af = "loudnorm";
        osc = false;
        screenshot-directory = "~/Pictures/screenshots";
        screenshot-format = "png";
        screenshot-template = "mpv-%f-%wH.%wM.%wS.%wT-#%#00n";
        loop-playlist = true;
        watch-later-dir = "~/.local/share/mpv/watch-later";
        save-position-on-quit = true;
        ytdl-raw-options = "cookies-from-browser=chromium";
        cache-on-disk = true;
        cache-pause-initial = true;
        demuxer-max-bytes = "512Mib";
        demuxer-max-back-bytes = "64Mib";
        force-seekable = true;
        ytdl-format = "best";
      };
      scriptOpts.ytdl_hook = {
        all_formats = true;
        use_manifests = true;
      };
      scriptOpts.modernz = {
        icon_theme = "material";
        timems = true;
        unicodeminus = true;
        cache_info = true;
        cache_info_speed = true;
        speed_button = true;
        download_button = true;
        screenshot_button = true;
        download_path = "~/Downloads";
        loop_button = true;
        playlist_button = true;
      };
      scripts = with pkgs.mpvScripts; [
        modernz
        pkgs.mpvScripts."builtins".autoload
      ];
    };
  };
}
