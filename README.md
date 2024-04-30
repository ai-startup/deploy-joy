# deploy-joy

## Create an AMI

To build an EC2 image and send it to Amazon as an AMI:

    nix build .#nixos-ami
    AWS_PROFILE=dev-application ./upload-amazon-image.sh result

## Deploy a host

To deploy a defined host:

    nix run github:serokell/deploy-rs -- -k .#login1
