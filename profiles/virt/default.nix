{ pkgs, ... }: {
  virtualisation.libvirtd = {
    enable = true;
    qemuOvmf = true;
    qemuRunAsRoot = false;
  };

  # you'll need to add your user to 'libvirtd' group to use virt-manager
  environment.systemPackages = with pkgs; [ virt-manager pciutils ];
}

