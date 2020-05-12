{ config, pkgs, ... }:

{
# Grab the hardware conf. Change this to hostname specific later.
  imports =
    [ # Include the results of the hardware scan.
      ../local/hardware-configuration.nix
      ../users/caleb
      ../users/root
      ../profiles/graphical
      ../profiles/virt
    ];
  
  # Configure boot options
  boot = {
    loader = {
      # EFI conf, sourced from initial setup
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.useOSProber = true;
    };
    kernelParams = [ "amd_iommu=on" "pcie_acs_override=downstream,multifunction" ]; # Set kernel paramters for VFIO passthrough
    blacklistedKernelModules = [ "amdgpu" "radeon" "amdgpu-pro" ]; # Blacklist all AMD GPU drivers so head doesnt use them
    kernelModules = [ "kvm-amd" "vfio_virqfd" "vfio_pci" "vfio_iommu_type1" "vfio" "amdgpu" "amdgpu-pro"]; # Load kernel modules necessary for VFIO passthrough of GFX cards
    extraModprobeConfig = "options vfio-pci ids=1002:687f,1002:aaf8";
  };


# Disabled temporarily to clear conflict. Also, probably outdated.
  # The following pins the Kernel version and applies a ACS override patch allowing IOMMU groups to be seperated far more granularly
#  boot.kernelPackages = pkgs.linuxPackages_4_19;
#  nixpkgs.config.packageOverrides = pkgs: {
#      linux_4_17 = pkgs.linux_4_19.override {
#        kernelPatches = pkgs.linux_4_19.kernelPatches ++ [
#          { name = "acs";
#            patch = pkgs.fetchurl {
#              url = "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio";
#              sha256 = "5517df72ddb44f873670c75d89544461473274b2636e2299de93eb829510ea50";
#            };
#          }
#        ];
#      };
#    };
  
  # Networking configuration.
  networking = {
    hostName = "wintermute"; # Lame but il think of something better later
    interfaces.enp42s0.ipv4.addresses = [ {
      address = "192.168.1.50";
      prefixLength = 24;
    } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" "1.1.1.1" "1.1.1.0" "8.8.8.8" ]; # Use PFSense as initial DNS resolution, then use CF and Google last
  };
  
  # Packages to install, should trim later
  environment.systemPackages = with pkgs; [
    unzip pciutils cura 
  ];


  # Enable/Configure basic utilities
  programs = {
    fish.enable = true;
    tmux.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "qt"; # Change to emacs later to test
    };
  };
 # Enable Services
  services = {
    openssh = {
      enable = true;
    };
  };
  
  # You should change this only after NixOS release notes say you should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

