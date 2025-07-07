{
  lib,
  config,
  pkgs,
  ...
}:
{
  config = lib.mkIf config.modules.desktop.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.chromium;
      extensions = [
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin Lite
        { id = "bpoadfkcbjbfhfodiogcnhhhpibjhbnh"; } # 沉浸式翻译
        { id = "doojmbjmlfjjnbmnoijecmcbfeoakpjm"; } # No Script
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "jfedfbgedapdagkghmgibemcoggfppbb"; } # 猫抓
        { id = "jpbjcnkcffbooppibceonlgknpkniiff"; } # Global Speed
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      ];
    };
  };
}
