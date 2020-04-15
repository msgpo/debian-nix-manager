{ config, lib, pkgs, ... }:
let
    home_directory = builtins.getEnv "HOME";
in
{
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    autocd = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" "z" "history-substring-search"];
      theme = "robbyrussell";
    };
    history = {
      share = true;
      path = config.programs.zsh.dotDir + "/.zsh_history";
      save = 10000000;
      ignoreDups = true;
      extended = true;
      size = 10000000;
    };
    shellAliases = with pkgs; {
      l     = "exa -lah";
      f     = "rg --files";
      E     = "env SUDO_EDITOR=\"emacsclient\" sudo -e";
      em    = "emacs";
      cp    = "cp -i";
      mv    = "mv -i";
      overlay-go   = "cd ~/.config/nixpkgs/nixos/overlays/go";
      overlay-python   = "cd ~/.config/nixpkgs/nixos/overlays/python";
      overlay-custom   = "cd ~/.config/nixpkgs/nixos/overlays/custom";
      ag0   = "rg --max-depth=1";
      pcat  = "${python3Packages.pygments}/bin/pygmentize";
      so    = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*usb/{if (a != \"\") print a;} {a=$NF}\\\')";
      si    = "pactl set-default-sink (pacmd list-sinks | awk \\\'/name:.*pci/{if (a != \"\") print a;} {a=$NF}\\\')";
    };

    initExtra = builtins.readFile "${home_directory}/.config/nixpkgs/dotfiles/keys.sh" + builtins.readFile "${home_directory}/.config/nixpkgs/dotfiles/zshrc" + ''
        SPACESHIP_TIME_SHOW=true
        SPACESHIP_EXIT_CODE_SHOW=true
        SPACESHIP_VI_MODE_SHOW=false
        SPACESHIP_BATTERY_THRESHOLD=30
        setopt HIST_IGNORE_ALL_DUPS
        ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#fdf6e3,bg=#586e75,bold,underline"
'';
    
    plugins =
      [
        {
          name = "bd";
          src = pkgs.fetchFromGitHub {
            owner = "Tarrasch";
            repo = "zsh-bd";
            rev = "d4a55e661b4c9ef6ae4568c6abeff48bdf1b1af7";
            sha256 = "020f8nq86g96cps64hwrskppbh2dapfw2m9np1qbs5pgh16z4fcb";
          };
        }

        {
          name = "zsh-256color";
          src = pkgs.fetchFromGitHub {
            owner = "chrissicool";
            repo = "zsh-256color";
            rev = "9d8fa1015dfa895f2258c2efc668bc7012f06da6";
            sha256 = "14pfg49mzl32ia9i9msw9412301kbdjqrm7gzcryk4wh6j66kps1";
          };
        }
        {
          name = "spaceship";
          file = "spaceship.zsh";
          src = pkgs.fetchgit {
            url = "https://github.com/denysdovhan/spaceship-prompt";
            rev = "v3.11.1";
            sha256 = "0habry3r6wfbd9xbhw10qfdar3h5chjffr5pib4bx7j4iqcl8lw8";
          };
        }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma";
            repo = "fast-syntax-highlighting";
            rev = "a3242a93399535faccda4896ab5c61a7a6dca1fe";
            sha256 = "17f8ysyvp0bpr6hbcg32mqpy91da6m9xgd3b5kdyk4mp8scwfbn1";
          };
        }
        {
          name = "fzf-z";
          src = pkgs.fetchFromGitHub {
            owner = "andrewferrier";
            repo = "fzf-z";
            rev = "2db04c704360b5b303fb5708686cbfd198c6bf4f";
            sha256 = "1ib98j7v6hy3x43dcli59q5rpg9bamrg335zc4fw91hk6jcxvy45";
          };
        }
      ];
  };
}
