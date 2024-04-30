{ inputs, ... }: {
  # http://jackkelly.name/blog/archives/2020/08/30/building_and_importing_nixos_amis_on_ec2/
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/amazon-image.nix"
  ];

  config = {
    ec2.hvm = true;

    # turn off refresh from user configuration, because we're setting it up manually with deploy-rs.
    systemd.services.amazon-init.enable = false;
  };
}
