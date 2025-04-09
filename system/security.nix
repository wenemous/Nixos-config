{ pkgs, lib, ... }: {

  security = {
    polkit.enable = true;
    sudo = {
      enable = true;
      execWheelOnly = true; 
      wheelNeedsPassword = false;
    };
  };
}
