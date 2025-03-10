# Use this mode (single user) in case SELinux is present (e.g., Fedora)
echo "Running Nix installation script..."
sh <(curl -L https://nixos.org/nix/install) --no-daemon
echo "Nix installation complete."

# Run to activate nix
echo "Activating Nix..."
. /home/parallels/.nix-profile/etc/profile.d/nix.sh
echo "Nix activated."

# Install yazi and all dependencies
echo "Setting environment variable NIXPKGS_ALLOW_UNFREE=1"
export NIXPKGS_ALLOW_UNFREE=1

echo "Installing packages: yazi, ffmpeg, p7zip, jq, poppler, fd, ripgrep, fzf, zoxide, imagemagick, vscode, nushell, wezterm, broot, ncdu..."
nix-env -iA nixpkgs.yazi nixpkgs.ffmpeg nixpkgs.p7zip nixpkgs.jq nixpkgs.poppler nixpkgs.fd nixpkgs.ripgrep nixpkgs.fzf nixpkgs.zoxide nixpkgs.imagemagick nixpkgs.vscode nixpkgs.nushell nixpkgs.wezterm nixpkgs.broot nixpkgs.ncdu
echo "Packages installed."

# Clone into ~/.config
echo "Cloning yazi config repository into ~/.config/yazi..."
git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi
echo "Config cloned."

# Update packs
echo "Updating packs..."
ya pack -i
echo "Packs updated."

# Add alias to config.nu
echo "Adding alias q=exit to Nushell config..."
echo -e "\nalias q = exit" >> ~/.config/nushell/config.nu
echo "Alias added."

# Define a custom function 'y' in Nushell config
echo "Adding custom function 'y' to Nushell config..."
y='def --env y [] {
    let tempfile = $"/($env.HOME)/.config/yazi/tempfile"
    yazi --cwd-file=($tempfile)
    let new_dir = (open $tempfile | str trim | default "")
    cd $new_dir
}'

touch ~/.config/yazi/tempfile

echo "$y" >> ~/.config/nushell/config.nu
echo "Custom function 'y' added."
