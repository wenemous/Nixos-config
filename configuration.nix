{ config, lib, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
    ];

  ##############
  # Bootloader #
  ##############
  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "i915.force_probe=!46a3"
      "xe.force_probe=46a3"
    ];
    loader = {
      timeout = 0; 
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };

  ############
  # Graphics #
  ############
  services = {
    xserver.videoDrivers = [ "nvidia" ];
    switcherooControl.enable = true;
  };
         
  hardware = {
    cpu.intel.updateMicrocode = true;
    nvidia-container-toolkit.enable = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
      ];
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




  # Time zone.
  time.timeZone = "Europe/Moscow";
 
  # Flatpak
  services.flatpak.enable = true;

  # Virtualisation
  programs.virt-manager.enable = true;
  virtualisation = {
    spiceUSBRedirection.enable = true;
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
    libvirtd = {
      enable = true;
    };
  };  

  # Printing (CUPS)
  services.printing.enable = true;

  # Sound.
  services = {
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      audio.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
  };


  
  programs = {
    mtr.enable = true;
    gnupg.agent.enable = true;
    seahorse.enable = true;
  };

  # Other stuff
  services = {
    irqbalance.enable = true;
    fwupd.enable = true; 
    dbus.implementation = "broker";   
    ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # User
  users.users.wenemous = {
    isNormalUser = true;
    description = "Wenemous Turnip";
    uid = 1000;
    extraGroups = [ "wheel" "docker" "input" "kvm" "libvirt" "storage" "video" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Nixos-related
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System packages
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
     # (google-chrome.override {
     #   commandLineArgs = [
          #"--enable-features=TouchpadOverscrollHistoryNavigation"
          #"--enable-features=AcceleratedVideoEncoder,VaapiOnNvidiaGPUs,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"
          #"--enable-features=VaapiIgnoreDriverChecks,VaapiVideoDecoder,PlatformHEVCDecoderSupport"
          #"--enable-features=UseMultiPlaneFormatForHardwareVideo"
          #"--ignore-gpu-blocklist"
          #"--enable-zero-copy"
     #   ];
     # })
    vim
    nix-software-center
    sbctl
    github-desktop
    libsecret
    wget
    git
    telegram-desktop
    clapper
    morewaita-icon-theme
    adw-gtk3
    gnome-tweaks
    hiddify-app
    bottles
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nix-software-center = pkgs.callPackage (pkgs.fetchFromGitHub {
      owner = "ljubitje";
      repo = "nix-software-center";
      rev = "0.1.3"; # on update, change this value manually!
      sha256 = "HVnDccOT6pNOXjtNMvT9T3Op4JbJm2yMBNWMUajn3vk="; # on update, change this value manually!
    }) {};
  };

  # Do not touch!!
  system.stateVersion = "24.11"; # Do not touch!!

}

