{ pkgs, config, ... }: {
 
  services = {
    xserver.videoDrivers = [ "nvidia" ];
    switcherooControl.enable = true;
  };


  hardware = {
    nvidia-container-toolkit.enable = true;

    graphics = {
      enable = true;
      extraPackages = with pkgs; [ nvidia-vaapi-driver ];
    };

    nvidia = {
      modesetting.enable = true;
      dynamicBoost.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0"; 
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  }; 
}
