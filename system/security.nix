{ pkgs, lib, ... }: {
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = false;
  };

  security.polkit = {
    enable = true;
  };
}
