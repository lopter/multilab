# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    ../../modules/basepkgs.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "certbot-sfo-ashpool"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "UTC";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     thunderbird
  #   ];
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    permitRootLogin = "yes";
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHG0HKQxkku9UZCSbaWp+PZPuUKOieefPPo6beNPH0elFVJjrjuwNZ6MUYkbVyWwprwHL6oXklpV48GvM/l3vkD886Pc+VUfGSeDayiRIT1aKGqY0ELKvTr6uZVQDH1Kqa36YmHpaLUcpvs7Y9/XCyeOMX8EGfQvwbZ+DbFxn4oPHxsW7Lt2xR+8HgGFOUaxTK0obLxeOJvplPHFpQacoyNvFcXRVt31GspoSu+KcfYbfH888e+nh01URXU+8h5Jlim+WNjUNxbxzYSIr2zQhzRJxL4ZLH08er+v0p6BDCVxgFINwY6zVTLPmKFt0dd9G8kzSS+v/d3EIUIdfYouqH7uNPSFtJZsLcKHdI7VJQdcXRZGhVgbvUoxxqJKQR1MVvppxmed1z8mzsT7S5GvuweRxSKAgJZo920pWSe5v1D6lT0TifbG6rwFjwsgOGpL6OTvmRsgUZamRfwj4G1LU7F3oaJTsK7wggdiX1qC/oLyEXZaH0f0w3iQb6213RRn+Kp8+AmWnKZ6TwcjLZsMAZLVSkYHD39YmNyq4SFWjk+gk8wMqaLp4oVgDOTch9NeEqKN+k7XFi2JmOz4y+tC8cVOXuKbufYGq6y0H4mlrO7soT3nzAPotOEmJXo43x7g4nyWqZIQOEz5zotr+HdprOc8Ynls76XJ4Hv2Ek3HiiyQ== cardno:7059178"
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}

