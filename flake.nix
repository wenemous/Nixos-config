{
  description = "My nixos conf";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nix-software-center = {
      url = "github:ljubitje/nix-software-center";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, lanzaboote, ... }: rec {
    nixosConfigurations = {
      NixOS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          lanzaboote.nixosModules.lanzaboote

          ({ pkgs, lib, ... }: {
            
            environment.systemPackages = [
              pkgs.sbctl
            ];
            boot.loader.systemd-boot.enable = lib.mkForce false;
            boot.lanzaboote = {
              enable = true;
              pkiBundle = "/var/lib/sbctl";
            };
          })
        ];
      };
    };
  };
}
