{ pkgs, ... }: {
  imports = [ ../graphical ];
  environment.systemPackages = with pkgs; [ cura inkscape krita unzip ];
}
