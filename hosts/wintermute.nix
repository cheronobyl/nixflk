# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../local/hardware-configuration.nix
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

  # The following pins the Kernel version and applies a ACS override patch allowing IOMMU groups to be seperated far more granularly
  boot.kernelPackages = pkgs.linuxPackages_4_19;
  nixpkgs.config.packageOverrides = pkgs: {
      linux_4_17 = pkgs.linux_4_19.override {
        kernelPatches = pkgs.linux_4_19.kernelPatches ++ [
          { name = "acs";
            patch = pkgs.fetchurl {
              url = "https://aur.archlinux.org/cgit/aur.git/plain/add-acs-overrides.patch?h=linux-vfio";
              sha256 = "5517df72ddb44f873670c75d89544461473274b2636e2299de93eb829510ea50";
            };
          }
        ];
      };
    };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.  networking.useDHCP = false;
  networking.interfaces.enp42s0.useDHCP = false;
  networking.interfaces.wlp39s0.useDHCP = false;
  
  # Add netowrking configuration
  networking.hostName = "wintermute";
  networking.interfaces.enp42s0.ipv4.addresses = [ {
    address = "192.168.1.50";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.1" "1.1.1.1" "1.1.1.0" "8.8.8.8" ];
  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim gzip unzip pciutils firefox cura git virt-manager 
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    
    
    # Enable i3 as the window manager
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu #application launcher most people use
        i3status # gives you the default i3 status bar
        i3lock #default i3 screen locker
     ];
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.caleb = {
    isNormalUser = true;
    home = "/home/caleb";
    description = "Caleb Schmucker";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };
  
  # Virtualization configuration.
  virtualisation = {
    libvirtd = {
      enable = true;
      qemuOvmf = true;
    };
  };

  # Enable/Configure Fish
  programs.fish.enable = true;
  
  # Enable/Configure EMACS
  services.emacs = {
    enable = true;
    defaultEditor = true;
  };

  # Enable/Configure TMUX
  programs.tmux.enable = true;
 
  # Enable/Configure urxvtd
  services.urxvtd.enable = true;

  # Enable GPG
  programs.gnupg.agent.enable = true;
  programs.gnupg.agent = {
    enableSSHSupport = true;
    pinentryFlavor = "qt";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?

}

