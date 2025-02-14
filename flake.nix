{
  description = "My Nixos Configuration";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation = {
      url = "github:nix-community/preservation/main";
    };
  };

  outputs =
    inputs:
    let
      lib = inputs.nixpkgs.lib.fold (overlay: lib: lib.extend (import overlay)) inputs.nixpkgs.lib (
        inputs.nixpkgs.lib.filesystem.listFilesRecursive ./lib
      );
      nixosModules = lib.scanPath ./modules;
      mapNixos = lib.mapAttrs (
        name: value:
        lib.nixosSystem {
          system = value;
          specialArgs = {
            inherit inputs;
          };
          modules = [ (lib.getHost name) ] ++ nixosModules;
        }
      );
    in
    {
      nixosConfigurations = mapNixos {
        cl-server = "x86_64-linux";
        cl-laptop = "x86_64-linux";
      };
    };
}
