{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    acl
    attr
    curl
    fd
    git
    htop
    iftop
    jq
    libcap_ng
    lsof
    mosh
    mtr
    neovim
    netcat-openbsd
    openssh
    openssl
    psmisc
    python3
    ripgrep
    rsync
    rxvt-unicode # just trying to install rxvt-unicode.terminfo did not work
    strace
    sysstat
    tcpdump
    tmux
    tree
  ];
}
