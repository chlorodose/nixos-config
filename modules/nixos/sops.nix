{
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    inputs.sops-nix.nixosModules.default
  ];
  environment.systemPackages = [ pkgs.sops ];
  sops = {
    defaultSopsFile = outputs.lib.getSecret "default.yaml";
    age = {
      generateKey = true;
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
    secrets."random-pass" = {
      mode = "444";
    };
  };
}
