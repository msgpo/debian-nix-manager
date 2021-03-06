{ config, lib, pkgs, ... }:


let
  updatefont = ''fc-cache -f -v'';
  updateDoom = ".emacs.d/bin/doom sync";
  updateInit = "bash .doom.d/bin/emacs.sh";
in
{
  #fonts
    home.file.".local/share/fonts/my-font" = {
    source = ../dotfiles/my-font;
    onChange = updatefont;
  };


    home.activation.linkEmacsPrivate = config.lib.dag.entryAfter [ "writeBoundary" ] ''
     if [ ! -d "$HOME/.emacs.d" ];then
         ${pkgs.git}/bin/git clone https://github.com/GTrunSec/doom-emacs.git -b my-doom --depth=1 ~/.emacs.d
      if [ ! -d "$HOME/.emacs.d/bin/doom" ];then
       mv $HOME/.emacs.d $HOME/.emacs.d-backup
       ${pkgs.git}/bin/git clone https://github.com/GTrunSec/doom-emacs.git -b my-doom --depth=1 ~/.emacs.d
       fi
     fi
     if [ ! -d "$HOME/.doom.d" ];then
     mkdir -p $HOME/.doom.d/
     mkdir -p $HOME/.doom.d/etc
     fi
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/lisp" $HOME/.doom.d/lisp
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/bin" $HOME/.doom.d/bin
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/snippets" $HOME/.doom.d/snippets
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/modules" $HOME/.doom.d/modules
     ln -sfT "${config.home.homeDirectory}/.config/nixpkgs/dotfiles/doom/Makefile" $HOME/.doom.d/Makefile
     if [ ! -d "$HOME/.doom.d/modules/my-code" ];then
          mkdir -p $HOME/.doom.d/modules/private/my-org
          mkdir -p $HOME/.doom.d/modules/private/my-code
          mkdir -p $HOME/.doom.d/autoload
     fi
   '';

    # editors
    home.file.".doom.d/init.org" = {
      source = ../dotfiles/doom/init.org;
      onChange = updateInit;
    };
      home.file.".doom.d/xah-fly.org" = {
        source = ../dotfiles/doom/xah-fly.org;
      onChange = updateInit;
      };

   programs.emacs = {
     enable = true;
     extraPackages = epkgs: with epkgs;[
           #editon
          scrollkeeper
          #org
          lsp-haskell
          #python
          graphql-mode
          json-mode
          jsonnet-mode
          yaml-mode
          csv-mode
          dhall-mode
          protobuf-mode

          ivy-bibtex
          company-auctex
          company-reftex
          company-math
          auctex
          adaptive-wrap
          latex-preview-pane
          #markdown
          markdown-mode
          markdown-toc
          edit-indirect
          grip-mode
          #nix
          nix-mode
          nix-update
          company-nixos-options
          #helm-nixos-options
          ##vterm
          vterm
          ##magit
          magit-todos
          github-review
          magit-gitflow
          ##
          helm-tramp
          visual-fill-column
          vlf
          wakatime-mode
          imenu-list
          eyebrowse
          cnfonts
          dimmer
          beacon
          golden-ratio
          writegood-mode
          yatemplate
          pinyin-search
          grab-x-link
          hungry-delete
          flymake-json
          bm
          w3m
          org-super-agenda
          ob-mermaid
          org-starter
          helm-org-rifle
          org-wild-notifier
          plantuml-mode
          ccls
          company-tabnine
          polymode
          poly-markdown
          bicycle
          jsonrpc
        ];
     #  package = pkgs.emacs.overrideAttrs (old: rec {
     #    wrapperPath = with pkgs; stdenv.lib.makeBinPath ([
     #      gcc        # to compile emacsql
     #      aspell
     #      aspellDicts.en
     #      plantuml
     #      jre        # for plantuml
     #      wordnet
     #      languagetool
     #      pandoc     # markdown preview
     #    ]);
     #    postFixup = ''
     #      wrapProgram $out/bin/emacs --prefix PATH : ${wrapperPath} --set SHELL ${pkgs.bash}/bin/bash
     #    '';
     #  };
   };
   services.emacs.enable = true;
}
