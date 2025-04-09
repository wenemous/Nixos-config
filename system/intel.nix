{ pkgs, config, ... }: {

  hardware = {
    cpu.intel.updateMicrocode = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
      ];
    };
  };
}
