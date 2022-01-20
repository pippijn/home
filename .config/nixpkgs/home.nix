{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "pippijn";
  home.homeDirectory = "/home/pippijn";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    git
    gnupg
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
  };
  
  programs.zsh = {
    enable = true;
    autocd = true;
    enableSyntaxHighlighting = true;

    initExtra = ''
      unsetopt beep                   # don't beep, ever
      setopt hist_reduce_blanks       # remove superfluous blanks
    '';

    shellAliases = {
      ll = "ls -l";
      reb = "sudo nixos-rebuild switch";
      hreb = "home-manager switch";
      k = "sudo kubectl";
    };

    history = {
      size = 1000000;
      save = 1000000;
      ignoreDups = true;
      extended = true;
      share = true;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "cypher";
    };
  };
}
