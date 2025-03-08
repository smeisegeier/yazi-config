# file-manager-config

🚧 work in progress 🚧

## pre-install

- have nerdfonts installed

## install

![macos](https://img.shields.io/badge/macOS-blue?logo=apple&logoColor=white&labelColor=grey)

```bash
brew install yazi

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# update packs
ya pack -i

```
<!-- install yazi packages from toml -->

[![windows](https://badgen.net/badge/icon/windows?icon=windows&label)](https://microsoft.com/windows/)

```bash
winget install yazi

# -> config dir
cd ${env:APPDATA}/yazi 2>nul || cd "%APPDATA%"/yazi

# clone into %APPDATA%/yazi/config
git clone https://github.com/smeisegeier/yazi-config ./config

# go there
cd config

# update packs
ya pack -i
```

![linux](https://img.shields.io/badge/Linux-blue?logo=linux&labelColor=grey)

```bash
# nixos is also an option, but homebrew had latest version
brew install yazi

git clone https://github.com/smeisegeier/yazi-config ~/.config/yazi

# update packs
ya pack -i
```