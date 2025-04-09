{ pkgs, ... }: {
  environment.sessionVariables = {
    EDITOR = "nano";
    QT_WAYLAND_DECORATION = "adwaita";
    QT_QPA_PLATFORMTHEME = "gtk3";
    NIXOS_OZONE_WL = 1;
    QT_QPA_PLATFORM = "wayland";
    GDK_BACKEND = "wayland";
    XDG_SESSION_TYPE = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
  };
  environment.systemPackages = with pkgs; [
    ffmpeg_7
    libpng12
    gcc
    clang
    gnumake
    cargo
    yarn
    dhcpcd
    bluez
    bluez-tools
    bluez-alsa
    usbutils
    gvfs
    unzip
    unrar
    linux-firmware
    gnupg
    lshw
    python313
    adwaita-qt
    adwaita-qt6
    qadwaitadecorations
    qadwaitadecorations-qt6
  ];
}
