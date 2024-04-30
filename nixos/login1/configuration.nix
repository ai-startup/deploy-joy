{ self, pkgs, ... }: {
  imports = [
    "${self}/nixos/common/nix.nix"
    "${self}/nixos/common/ec2.nix"
    "${self}/nixos/common/users.nix"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";

  # install a base set of packages
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
  ];

  system.stateVersion = "23.11";
}
