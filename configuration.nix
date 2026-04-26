{ config, pkgs, ... }:

let
  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };

  androidComposition = androidEnv.composeAndroidPackages {
    cmdLineToolsVersion = "latest";
    platformVersions = [ "36" ];
    buildToolsVersions = [ "28.0.3" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
    includeNDK = false;
    extraLicenses = [
      "android-sdk-license"
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "android-googlexr-license"
      "mips-android-sysimage-license"
    ];
  };
in
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.auto-optimise-store = true;
  # nix.gc.automatic = true;
  # nix.gc.dates = "daily";
  # nix.gc.options = "--delete-older-than 20d";

  networking.hostName = "gruvw";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
  };

  # ESP-32 USB
  services.udev.extraRules = ''ATTRS{idVendor}=="303a", ATTRS{idProduct}=="1001", MODE="0666", GROUP="dialout"'';
  # arduino
  services.udev.packages = [ pkgs.arduino-ide ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim
    git
    delta
    gh
    wget
    xwayland-satellite
    kitty
    alacritty
    brave
    orca-slicer
    albert
    vifm
    stow
    fish
    starship
    waybar
    bat
    gnupg
    pinentry-qt
    pavucontrol
    copyq
    wl-clipboard
    bottom
    vlc
    gtklock
    killall
    gcc
    clang
    gnumake
    sqlite
    tree-sitter
    brightnessctl
    wev
    (pkgs.networkmanagerapplet.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        rm -f $out/etc/xdg/autostart/nm-applet.desktop
      '';
    }))
    simp1e-cursors
    dragon-drop
    hollywood
    go
    gopls
    arduino-ide
    arduino-cli
    obs-studio
    aseprite
    zola
    gimp
    nomacs
    vlc
    sqlitebrowser
    qbittorrent
    typst
    tinymist
    ccrypt
    cloc
    ripgrep
    blender
    libreoffice-still
    thunderbird
    androidComposition.androidsdk
    flutter
    jdk17
    cmake
    ninja
    (python3.withPackages (ps: with ps; [
      pandas
      numpy
      matplotlib
      ipykernel
      notebook
      jupyterlab
    ]))
    signal-desktop
    kooha
    mesa-demos
    file-roller
    show-midi
    jq
    dig
    wpaperd
    typescript-language-server
    evince
    fritzing
  ];

  virtualisation.libvirtd.enable = true;

  # Enable the GNOME Keyring + unlock automatically on login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # programs.nix-ld.libraries = with pkgs; [
  #   stdenv.cc.cc
  #   zlib
  #   fuse3
  #   icu
  #   nss
  #   openssl
  #   curl
  #   expat
  #   # Add any other libraries the ESP tools complain about
  # ];

  security.pam.services.gtklock = {};

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      noto-fonts
      inter
    ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gruvw = {
    isNormalUser = true;
    description = "gruvw";
    extraGroups = [ "dialout" "plugdev" "networkmanager" "wheel" "adbusers" "kvm" ];
    packages = with pkgs; [
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  programs.niri.enable = true;

  # printing
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enables resolution for IPv4 .local domains
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };

  environment.sessionVariables = {
    DEFAULT_BROWSER = "${pkgs.brave}/bin/brave";
    CHROME_EXECUTABLE = "${pkgs.brave}/bin/brave";
    NIXOS_OZONE_WL = "1";
    ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
    JAVA_HOME = "${pkgs.jdk17.home}";
    FLUTTER_SDK_ROOT = "${pkgs.flutter}";
  };

  xdg.mime.defaultApplications = {
    "text/html" = "brave-browser.desktop";
    "x-scheme-handler/http" = "brave-browser.desktop";
    "x-scheme-handler/https" = "brave-browser.desktop";
    "x-scheme-handler/about" = "brave-browser.desktop";
  };

  # dark mode
  # dconf.settings = {
  #   "org/gnome/desktop/interface" = {
  #     color-scheme = "prefer-dark";
  #   };
  # };
}
