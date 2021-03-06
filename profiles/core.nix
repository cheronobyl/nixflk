{ config, lib, pkgs, ... }:
let inherit (lib) fileContents;

in {
  nix.package = pkgs.nixFlakes;

  nix.systemFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];

  imports = [ ../local/locale.nix ];

  boot = {

    kernelPackages = pkgs.linuxPackages_latest;

    tmpOnTmpfs = true;

    kernel.sysctl."kernel.sysrq" = 1;

  };

  environment = {

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      direnv
      dosfstools
      dnsutils
      fd
      git
      gotop
      gptfdisk
      gzip
      iputils
      manpages
      moreutils
      ripgrep
      stdmanpages
      utillinux
      vim
      wget
    ];

    shellAliases =
      let ifSudo = string: lib.mkIf config.security.sudo.enable string;
      in {
        # quick cd
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";

        # git
        g = "git";
	gad = "git add";
	gada = "git add -A";
	gus = "git status";
	geck = "git checkout";
	geckn = "git checkout -b";
	gush = "git push";
	gim = "git commit -m";
	
        # grep
        grep = "rg";
        gi = "grep -i";

        # nix
        n = "nix";
        np = "n profile";
        ni = "np install";
        nr = "np remove";
        ns = "n search";
        nrb = ifSudo "sudo nixos-rebuild";

        # sudo
        s = ifSudo "sudo -E ";
        si = ifSudo "sudo -i";
        se = ifSudo "sudoedit";

        # top
        top = "gotop";

        # systemd
        ctl = "systemctl";
        stl = ifSudo "s systemctl";
        utl = "systemctl --user";
        ut = "systemctl --user start";
        un = "systemctl --user stop";
        up = ifSudo "s systemctl start";
        dn = ifSudo "s systemctl stop";
        jtl = "journalctl";

	# misc
	
      };

  };

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

  fonts = {
    fonts = with pkgs; [ powerline-fonts dejavu_fonts ];

    fontconfig.defaultFonts = {

      monospace = [ "DejaVu Sans Mono for Powerline" ];

      sansSerif = [ "DejaVu Sans" ];

    };
  };

  nix = {

    autoOptimiseStore = true;

    gc.automatic = true;

    optimise.automatic = true;

    useSandbox = true;

    allowedUsers = [ "@wheel" ];

    trustedUsers = [ "root" "@wheel" ];

    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';

  };

  security = {

    hideProcessInformation = true;

    protectKernelImage = true;

  };

  services.earlyoom.enable = true;

}
