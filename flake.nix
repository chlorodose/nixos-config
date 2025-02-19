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
    { self, ... }:
    let
      inherit (self) inputs outputs;
      specialArgs = {
        inherit inputs outputs;
      };
    in
    {
      lib = (import ./lib) inputs.nixpkgs.lib;
      nixosModule = import ./modules/nixos;
      homeModule = import ./modules/home;
      nixosConfigurations = {
        cl-laptop = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ (import ./hosts/cl-laptop) ];
        };
      };
      homeConfigurations = { };
    };
}
