## Add repos
```
wget -q -O - https://build.opensuse.org/projects/home:manuelschneid3r/public_key | sudo apt-key add -  
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -  
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -  
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu zesty stable"  
sudo add-apt-repository "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"  
sudo add-apt-repository -y ppa:x4121/ripgrep  
sudo add-apt-repository -y ppa:linrunner/tlp
```

## Update sources and update system
```
sudo apt-get update  
sudo apt-get upgrade
```

## Install packages
```
apt install -y  
  albert \  
  apt-transport-https \  
  autoconf \  
  bison \  
  build-essential \  
  cmake \  
  cryptsetup \
  ctags \  
  curl \  
  diskie \  
  docker-ce \  
  ecryptfs-utils \
  exfat-fuse exfat-utils \  
  gcc-6 \  
  git \  
  google-chrome-stable \  
  libffi-dev \  
  libfontconfig1-dev \  
  libfreetype6-dev \  
  libgdbm-dev \  
  libgdbm3 \  
  libncurses5-dev \  
  libreadline6-dev \  
  libssl-dev \  
  libyaml-dev \  
  openconnect \  
  parcellite \  
  pasystray \  
  ripgrep \  
  tig \  
  tlp \  
  vim \  
  xautolock \  
  xclip \  
  xdotool \  
  zlib1g-dev \  
  zsh
```

## Use zsh as default shell
```
chsh -s $(which zsh)
```

## Make fzf available (config is done elsewhere)
```
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
```

## Changes needed in GRUB (/etc/default/grub) to boot faster and more verbose
GRUB_HIDDEN_TIMEOUT=2  
GRUB_TIMEOUT=0  
GRUB_CMDLINE_LINUX_DEFAULT="acpi_osi=Linux"  
sudo update-grub  

## SSH keys (if present)
```
copy .ssh from elsewhere
chmod 600 .ssh/id_rsa 
```

## Fetch configs
```
mkdir -p ~/dev/config  
cd dev/config && git clone git@github.com:thenoseman/vim_config.git && cd vim_config && relink  
cd dev/config && git clone git@github.com:thenoseman/zsh_config.git && cd zsh_config && relink 
```

## Install NVM
```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | zsh
```

## Install rbenv
```
git clone https://github.com/rbenv/rbenv.git ~/.rbenv  
cd ~/.rbenv && src/configure && make -C src  
mkdir -p "$(rbenv root)"/plugins  
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build  
rbenv install 2.4.2
```

## Install i3-wm
```
/usr/lib/apt/apt-helper download-file http://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2017.01.02_all.deb keyring.deb SHA256:4c3c6685b1181d83efe3a479c5ae38a2a44e23add55e16a328b8c8560bf05e5f  
sudo su -  
dpkg -i ./keyring.deb  
echo "deb http://debian.sur5r.net/i3/ $(grep '^DISTRIB_CODENAME=' /etc/lsb-release | cut -f2 -d=) universe" >> /etc/apt/sources.list.d/sur5r-i3.list  
apt update  
apt install i3  
```

## Install font
```
mkdir ~/.local/share/fonts  
curl -LO http://www.fantascienza.net/leonardo/ar/inconsolatag/inconsolata-g_font.zip  
unzip and put in "fonts"  
```

