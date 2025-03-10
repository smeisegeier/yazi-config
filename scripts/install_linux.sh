# Use this mode (single user) in case SELinux is present (e.g., Fedora)
sh <(curl -L https://nixos.org/nix/install) --no-daemon

# Run to activate nix
. /home/parallels/.nix-profile/etc/profile.d/nix.sh

# Install yazi and all dependencies
export NIXPKGS_ALLOW_UNFREE=1

nix-env -iA nixpkgs.yazi nixpkgs.ffmpeg nixpkgs.p7zip nixpkgs.jq nixpkgs.poppler nixpkgs.fd nixpkgs.ripgrep nixpkgs.fzf nixpkgs.zoxide nixpkgs.imagemagick nixpkgs.vscode nixpkgs.nushell nixpkgs.wezterm nixpkgs.broot nixpkgs.ncdu

# Update packs
ya pack -i

# Add alias to config.nu
echo -e "\nalias q = exit" >> ~/.config/nushell/config.nu

# Define a custom function 'y' in Nushell config
y='def --env y [] {
    let tempfile = $"/($env.HOME)/.config/yazi/tempfile"
    yazi --cwd-file=($tempfile)
    let new_dir = (open $tempfile | str trim | default "")
    cd $new_dir
}'

touch ~/.config/yazi/tempfile

echo "$y" >> ~/.config/nushell/config.nu
