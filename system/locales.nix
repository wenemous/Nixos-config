{ pkgs, ... }: {

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
  ];
}
