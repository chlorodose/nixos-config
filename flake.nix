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

    nixvim = {
      url = "github:nix-community/nixvim/main";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };
  outputs =
    { self, ... }:
    let
      inherit (self) inputs outputs;
      specialArgs = {
        inherit inputs outputs;
      };
      extraSpecialArgs = specialArgs;
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
        cl-server = inputs.nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ (import ./hosts/cl-server) ];
        };
      };
      homeConfigurations = {
        "chlorodose@cl-laptop" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = outputs.nixosConfigurations.cl-laptop.pkgs;
          modules = [ (import ./users/chlorodose/hosts/cl-laptop.nix) ];
          inherit extraSpecialArgs;
        };
        "chlorodose@cl-server" = inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = outputs.nixosConfigurations.cl-server.pkgs;
          modules = [ (import ./users/chlorodose/hosts/cl-server.nix) ];
          inherit extraSpecialArgs;
        };
      };
    };
}
