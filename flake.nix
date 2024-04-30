{
  description = "build aaai hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, deploy-rs, nixos-generators, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        packages = {
          nixos-ami = nixos-generators.nixosGenerate {
            inherit system;
            format = "amazon";
            specialArgs = {
              diskSize = 20 * 1024;
            };
            modules = [
              # this replaces nixos/common/ec2.nix
              # we can't import that directly due to "error: infinite recursion encountered".
              # probably due to its "amazon-image.nix" import
              ({ ... }: {
                ec2.hvm = true;
                systemd.services.amazon-init.enable = false;

                system.stateVersion = "23.11";
              })
              ./nixos/common/nix.nix
              ./nixos/common/users.nix
            ];
          };
        };
      };

      flake = {
        nixosConfigurations = {
          login1 = nixpkgs.lib.nixosSystem {
            specialArgs = { inherit self inputs; };
            modules = [ ./nixos/login1/configuration.nix ];
          };
        };

        deploy = {
          nodes = {
            login1 = let
              cfg = self.nixosConfigurations.login1;
            in {
              hostname = "login1.dev.artificial.agency";
              profiles.system.path = deploy-rs.lib.${cfg.pkgs.system}.activate.nixos cfg;
            };
          };
          user = "root";
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
    };
}
