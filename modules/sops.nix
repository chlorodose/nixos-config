{ inputs, lib, ... }:
{
  imports = [
    inputs.sops-nix.nixosModules.default
  ];
  sops.defaultSopsFile = lib.getSecret "default.yaml";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.age.generateKey = true;
}
