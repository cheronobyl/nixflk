users.users.caleb = {
  isNormalUser = true;
  home = "/home/caleb";
  description = "Caleb Schmucker";
  shell = pkgs.fish;
  extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  initialPassword = ""; # Should be given a real password ASAP
};