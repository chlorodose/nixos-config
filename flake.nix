{
  description = "My Nix* Configuration";
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils = {
      url = "github:numtide/flake-utils/main";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    preservation = {
      url = "github:nix-community/preservation/main";
    };

    catppuccin = {
      url = "github:catppuccin/nix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/main";
      inputs.nixpkgs.follows = "nixpkgs";
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
      packages = inputs.nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (
        system:
        let
          lib = inputs.nixpkgs.lib;
          pkgs = inputs.nixpkgs.legacyPackages.${system};
        in
        (lib.listToAttrs (
          lib.map (sub: rec {
            value = pkgs.callPackage sub { };
            name = value.pname;
          }) (outputs.lib.scanPath ./pkgs)
        ))
      );
      defaultPackage = inputs.nixpkgs.lib.genAttrs inputs.flake-utils.lib.defaultSystems (
        system:
        inputs.nixpkgs.legacyPackages.${system}.writeText "root-gc-anchor" (
          builtins.concatStringsSep "\n" (self.lib.listRoots outputs)
        )
      );
      nixosModules.default = import ./modules/nixos;
      homeModules.default = import ./modules/home;
      templates = {
        rust = {
          path = templates/rust;
          description = ''
            Rust project template.
          '';
        };
        typescript = {
          path = templates/typescript;
          description = ''
            Typescript project template.
          '';
        };
      };
      nixosConfigurations = {
        cl-laptop = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit specialArgs;
          modules = [ (import ./hosts/cl-laptop) ];
        };
        cl-server = inputs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
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
