{ config, lib, pkgs, inputs, ... }:

{
  imports = [
      ./hardware-configuration.nix
    ];

  # Bootloader
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

  # Graphics
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
        intel-media-driver
        intel-ocl
        intel-vaapi-driver
        nvidia-vaapi-driver
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      dynamicBoost.enable = true;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
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

  # Network
  networking = {
    hostName = "NixOS";
    networkmanager.enable = true;
  };

  # Time zone.
  time.timeZone = "Europe/Moscow";

  # Locales and Fonts
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "all" ];
  };
    
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
    # useXkbConfig = true;
  };

  fonts.packages = with pkgs; [
    noto-fonts
    font-awesome
    liberation_ttf
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    inter
  ];

  # GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer', 'variable-refresh-rate', 'xwayland-native-scaling']
      '';
    };
  };
  
  nixpkgs.overlays = [
    (final: prev: {
      mutter = prev.mutter.overrideAttrs (oldAttrs: {
        # GNOME dynamic triple buffering (huge performance improvement)
        # See https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1441
        src = final.fetchFromGitLab {
          domain = "gitlab.gnome.org";
          owner = "vanvugt";
          repo = "mutter";
          rev = "triple-buffering-v4-47";
          hash = "sha256-6n5HSbocU8QDwuhBvhRuvkUE4NflUiUKE0QQ5DJEzwI=";
        };

        preConfigure =
          let
            gvdb = final.fetchFromGitLab {
              domain = "gitlab.gnome.org";
              owner = "GNOME";
              repo = "gvdb";
              rev = "2b42fc75f09dbe1cd1057580b5782b08f2dcb400";
              hash = "sha256-CIdEwRbtxWCwgTb5HYHrixXi+G+qeE1APRaUeka3NWk=";
            };
          in
          ''
            cp -a "${gvdb}" ./subprojects/gvdb
          '';
       });
    })
  ];
  
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

  # Security
  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
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

