{ config, pkgs, ... }:
let inherit (builtins) readFile;
in {
  imports = [  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  hardware.pulseaudio.enable = true;
  services.openssh = {
     forwardX11 = true;
  };
  services.xserver = { # Setup x11
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
}
