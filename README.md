# file-manager-config

## install

install yazi packages from toml

```bash
# windows 
winget install yazi

# -> config dir
cd ${env:APPDATA}/yazi 2>nul || cd "%APPDATA%"/yazi

# clone
git clone https://github.com/smeisegeier/yazi-config ./config

# go there
cd config

# update packs
ya pack -i
```
