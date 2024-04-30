{ inputs, pkgs, ... }: {
  # http://jackkelly.name/blog/archives/2020/08/30/building_and_importing_nixos_amis_on_ec2/
  imports = [ "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix" ];
  ec2.hvm = true;

  nixpkgs.hostPlatform = "x86_64-linux";

  # turn off refresh from user configuration, because we're setting it up manually with deploy-rs.
  systemd.services.amazon-init.enable = false;

  users = {
    # do not allow /etc/passwd & /etc/group to be modified directly.
    mutableUsers = false;

    groups = {
      users = { };
    };

    users = {
      brendan = {
        isNormalUser = true;
        group = "users";
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH6vVNS0vZF/b3J/qSVB0Y/W/KZwPI+1fe18Gfdyd/SJ6qlD2nInJyzYajz1WYbGnXQ2Co1GM7bOmCjmkS9fizPfxFwd+AgEdtzz3+kZ4iTpB4oQMLt+8JRYZetZdTRHPks0Y9ML1FUIfuVnqb5FtlrMd9Bra8wObkQZAF9UdHcIXBIK+BHtK0uUEtL1KUgn4Dy7Z1DuH/rRSeMQM/v/sxUORMXnCPEhBQ7lYRvv39Pdygk9dHxFEZDXtHaP3cxPMESqeoo5njULgYwj6VikW3Fb7j07ImZQwHfTYJXBT5L7s28Hj2tuLDbzSc5NZOvpwNOawMUV/LwrDDseBDSZWLp/vtgUOJqWc+Igks4OuZIho4BCKXG0m89WDcUtZs/HnG8rhtoJchptBNlkV36zu1yr+0pmB7kg7YdGqqDv1n+VGterKjK8WTCtmTQvkzmszfRmjz1T9MaLz4/y8Ai5E1fHx3H0ReFR09eZYqjymazlmpbyzJAQES/DBFyvSRLsM= brendan@dunwich 2023-11-08"
        ];
      };
    };
  };

  security.sudo.wheelNeedsPassword = false;

  # install a base set of packages
  environment.systemPackages = with pkgs; [
    vim
    git
    tmux
  ];

  nix = {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
    };
  };

  system.stateVersion = "23.11";
}
