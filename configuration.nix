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




  #########
  # GNOME #
  #########
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




  ###########
  # Locales #
  ###########
  i18n = {
    defaultLocale = "ru_RU.UTF-8";
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
    adwaita-fonts
  ];




  ########
  # Time #
  ########
  time.timeZone = "Europe/Moscow";
 



  ##############
  # Networking #
  ##############
  networking = {
    hostName = "NixOS";
    networkmanager.enable = true;
    useDHCP = lib.mkForce true;
    firewall.checkReversePath = false;
    hosts = {
      "127.0.0.1" = [ "localhost" ];
      "::1" = [ "localhost" ];
      "127.0.02" = [ "ms7996" ];
      "50.7.85.219" = [ "inference.codeium.com" ];
      "50.7.87.83" = [ "proxy.individual.githubcopilot.com" ];
      "142.54.189.106" = [ "web.archive.org" ];
      "204.12.192.220" = [ "developer.nvidia.com" ];
      "50.7.85.222" = [ "www.canva.com" ];
      "204.12.192.222" = [
        "chatgpt.com"
        "ab.chatgpt.com"
        "auth.openai.com"
        "auth0.openai.com"
        "platform.openai.com"
        "cdn.oaistatic.com"
        "files.oaiusercontent.com"
        "cdn.auth0.com"
        "tcr9i.chat.openai.com"
        "webrtc.chatgpt.com"
        "api.openai.com"
        "sora.com"
        "gemini.google.com"
        "aistudio.google.com"
        "generativelanguage.googleapis.com"
        "alkalimakersuite-pa.clients6.google.com"
        "aitestkitchen.withgoogle.com"
        "webchannel-alkalimakersuite-pa.clients6.google.com"
        "o.pki.goog"
        "labs.google"
        "notebooklm.google"
        "notebooklm.google.com"
        "copilot.microsoft.com"
        "sydney.bing.com"
        "edgeservices.bing.com"
        "api.spotify.com"
        "xpui.app.spotify.com"
        "appresolve.spotify.com"
        "login5.spotify.com"
        "gew1-spclient.spotify.com"
        "spclient.wg.spotify.com"
        "api-partner.spotify.com"
        "aet.spotify.com"
        "www.spotify.com"
        "accounts.spotify.com"
        "claude.ai"
        "www.notion.so"
        "www.intel.com"
      ];
      "204.12.192.219" = [
        "android.chat.openai.com"
        "aisandbox-pa.googleapis.com"
      ];
      "204.12.192.221" = [
        "operator.chatgpt.com"
        "alkalimakersuite-pa.clients6.google.com"
        "assistant-s3-pa.googleapis.com"
        "rewards.bing.com"
      ];
      "50.7.87.85" = [
        "proactivebackend-pa.googleapis.com"
        "codeium.com"
      ];
      "50.7.85.221" = [
        "xsts.auth.xboxlive.com"
        "api.individual.githubcopilot.com"
      ];
      "138.201.204.218" = [
        "encore.scdn.co"
        "ap-gew1.spotify.com"
      ];
      "50.7.87.84" = [
        "login.app.spotify.com"
        "api.github.com"
      ];
    };
  };



  ##################
  # Virtualisation #
  ##################
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




  #########
  # Sound #
  #########
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




 ############
 # Security #
 ############
 security = {
    polkit.enable = true;
    sudo = {
      enable = true;
      execWheelOnly = true; 
      wheelNeedsPassword = false;
    };
  };
 
 programs = {
    mtr.enable = true;
    gnupg.agent.enable = true;
    seahorse.enable = true;
  };



  
  ############
  # Services #
  ############
  services = {
    flatpak.enable = true;
    printing.enable = true;
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




  ########
  # User #
  ########
  users.users.wenemous = {
    isNormalUser = true;
    description = "Wenemous Turnip";
    uid = 1000;
    extraGroups = [ "wheel" "docker" "input" "kvm" "libvirt" "storage" "video" "audio"  "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };




  #################
  # Nixos-related #
  #################
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];




  ############
  # Packages #
  ############
  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      (google-chrome.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ignore-gpu-blocklist"
          "--enable-zero-copy"
        ];
      })


    # # # # # #
    # Non-gui #
    # # # # # #
    vim
    sbctl
    adw-gtk3
    morewaita-icon-theme
    libsecret
    wget
    git


    # # # #
    # Gui #
    # # # #
    telegram-desktop
    clapper
    github-desktop
    nix-software-center
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




  ##################
  # Do not touch!! #
  ##################
  system.stateVersion = "24.11"; # Do not touch!!

}

