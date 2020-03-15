{ config, pkgs, lib, ... }:
let
  home_directory = builtins.getEnv "HOME";
  log_directory = "${home_directory}/logs";
  #sysconfig = (import <nixpkgs/nixos> {}).config;

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
  imports = [
    ./home-packages.nix
    ./ownpkgs.nix
    ./home-file.nix
    ./home-manager/fish.nix
    ./home-manager/emacs.nix
    ./home-manager/tmux.nix
    ./home-manager/git.nix
    ./home-manager/ssh.nix
    ./pkgs/network
  ]; #++ lib.optionals sysconfig.services.xserver.enable [
    #./home-manager/desktop.nix ];
  
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "19.09";
}
