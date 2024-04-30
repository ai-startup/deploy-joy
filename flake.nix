{
  description = "build aaai hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, deploy-rs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }: {
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
              hostname = "35.88.116.119";
              profiles.system.path = deploy-rs.lib.${cfg.pkgs.system}.activate.nixos cfg;
            };
          };
          user = "root";
        };

        checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
      };
    };
}
