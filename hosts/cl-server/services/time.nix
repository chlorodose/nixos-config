{
  lib,
  config,
  outputs,
  ...
}:
{
  services.ntpd-rs = {
    enable = true;
    settings.server = [
      {
        listen = "0.0.0.0:123";
      }
    ];
  };
  systemd.services.ntpd-rs.serviceConfig = {
    User = lib.mkForce "root";
    Group = lib.mkForce "root";
    DynamicUser = lib.mkForce false;
  };
}
