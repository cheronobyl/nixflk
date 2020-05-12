{ config, pkgs, ... }:
let inherit (builtins) readFile;
in {
  imports = [  ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport = true;
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  services.openssh = {
     forwardX11 = true;
  };

  environment.systemPackages = with pkgs; [
    cursor
    firefox
    ffmpeg-full
    imagemagick
    imlib2
  ];
  services = {
    xserver = { # Setup x11
      enable = true;
      layout = "us";	
      windowManager.i3 = {  # Enable i3 as the window manager
        enable = true;
	extraPackages = with pkgs; [
	  dmenu #application launcher most people use
	  i3status # gives you the default i3 status bar
	  i3lock #default i3 screen locker
	  ];
	};
    };
    emacs = {
      enable = true;
      defaultEditor = true;
    };
    urxvtd.enable = true;
  };
}
