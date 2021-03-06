{ config, pkgs, lib, ... }:
let
 ownpkgs_git = builtins.fetchTarball {
    url    = "https://github.com/GTrunSec/nixpkgs/tarball/806fac5d109cdc6653c33a18924dac31ac477a2b";
    sha256 = "0b1aksy1070xh9wn7mwdgyz2hpfljr4jxs6qj90x7pnxj3m3p7a4";
  };

  ownpkgs = (import ownpkgs_git) { };
  USER = builtins.getEnv "USER";
in
with lib;
{

  #fish
  #      "oh-my-fish/theme-bobthefish"
  programs.direnv.enable = true;
  programs.fish = let
    plugins = [
      "edc/bass"
      "tuvistavie/fish-fastdir"
      "danhper/fish-theme-afowler"
      "oh-my-fish/plugin-bang-bang"
      "oh-my-fish/plugin-direnv"
      "jethrokuan/fzf"
      "rominf/omf-plugin-fzf-autojump"
      "rominf/omf-plugin-autojump"
      "otms61/fish-pet"
    ];
    in {
    enable = true;
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
    };
    
     interactiveShellInit = ''
    if not functions -q fundle; eval (curl -sfL https://git.io/fundle-install); end
        ${concatMapStringsSep "\n" (p: "fundle plugin '${p}'") plugins}
    fundle init
    #infocmp | ssh $remote "cat > $TERM.ti ; tic -o ~/.terminfo $TERM.ti"
    source ${pkgs.autojump}/share/autojump/autojump.fish
    set -x -U GOPATH $HOME/go 
    set -x -U GOBIN $GOPATH/bin
    set -x -U OSQUERY /var/empty/local/bin
    set -x -U NIXBIN $HOME/.nix-profile/bin
    set -g -x PATH $PATH $GOBIN $NIXBIN /usr/sbin $OSQUERY
    set -g -x NIX_PATH $HOME/.nix-defexpr/channels
    set -g -x TERM screen-256color-bce;
    set -g theme_color_scheme gruvbox
    kitty + complete setup fish | source
    direnv hook fish | source
    alias ...='cd ../..'
    alias ....='cd ../../..'
    alias .....='cd ../../../..'
    abbr -a g git
    abbr -a gr "git reset --hard"
    abbr -a gl "git pull --rebase"

    set -l project
    if echo (pwd) | grep -qEi "^/Users/$USER/Sites/"
        set  project (echo (pwd) | sed "s#^/Users/$USER/Sites/\\([^/]*\\).*#\\1#")
    else
        set  project "Terminal"
    end
    wakatime --write --plugin "fish-wakatime/0.0.1" --entity-type app --project "$project" --entity (echo $history[1] | cut -d ' ' -f1) 2>&1 > /dev/null&

    if status is-interactive
    and not set -q TMUX
    exec tmux
    end
    switch (whoami)
    case nsm
        set -x -U http_proxy http://127.0.0.1:8123
        set -x -U https_proxy http://127.0.0.1:8123
   end
    '';
    };
home.activation.linkFuncations = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/fish/functions" ~/.config/fish/functions
    '';
 home.activation.linkCompletions = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/fish/completions" ~/.config/fish/completions
'';
}
