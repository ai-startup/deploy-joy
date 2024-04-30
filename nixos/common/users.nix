{ ... }: {
  config = let
    users = [
      {
        username = "brendan";
        sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDH6vVNS0vZF/b3J/qSVB0Y/W/KZwPI+1fe18Gfdyd/SJ6qlD2nInJyzYajz1WYbGnXQ2Co1GM7bOmCjmkS9fizPfxFwd+AgEdtzz3+kZ4iTpB4oQMLt+8JRYZetZdTRHPks0Y9ML1FUIfuVnqb5FtlrMd9Bra8wObkQZAF9UdHcIXBIK+BHtK0uUEtL1KUgn4Dy7Z1DuH/rRSeMQM/v/sxUORMXnCPEhBQ7lYRvv39Pdygk9dHxFEZDXtHaP3cxPMESqeoo5njULgYwj6VikW3Fb7j07ImZQwHfTYJXBT5L7s28Hj2tuLDbzSc5NZOvpwNOawMUV/LwrDDseBDSZWLp/vtgUOJqWc+Igks4OuZIho4BCKXG0m89WDcUtZs/HnG8rhtoJchptBNlkV36zu1yr+0pmB7kg7YdGqqDv1n+VGterKjK8WTCtmTQvkzmszfRmjz1T9MaLz4/y8Ai5E1fHx3H0ReFR09eZYqjymazlmpbyzJAQES/DBFyvSRLsM= brendan@dunwich 2023-11-08";
        isDeployer = true;
      }
    ];
  in {
    users = {
      # do not allow /etc/passwd & /etc/group to be modified directly.
      mutableUsers = false;

      groups = {
        users = { };
      };

      users = let
        mkUser = user: {
          name = user.username;
          value = {
            isNormalUser = true;
            group = "users";
            extraGroups = if user.isDeployer then [ "wheel" ] else [];
            openssh.authorizedKeys.keys = [ user.sshKey ];
          };
        };
      in
        builtins.listToAttrs (map mkUser users);
    };

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "@wheel" ];
  };
}
