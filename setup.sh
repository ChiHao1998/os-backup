#!/usr/bin/env bash

# Preparation #######################################
sudo pacman -Syu
sudo pacman -S --noconfirm --needed pacman-contrib

rsync etc/ /etc/
rsync usr/ /usr/
rsync .config/ ~/.config/
rankmirrors -n 10 /etc/pacman.d/mirrorlist.backup >/etc/pacman.d/mirrorlist

pacman -Syu

sed -i 's/NAME=.*/NAME=LainOS/' /etc/os-release
sed -i 's/PRETTY_NAME=.*/PRETTY_NAME=LainOS/' /etc/os-release
sed -i 's/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"LainOS\"/' /etc/lsb-release

# Install official repository packages ##############

if [[ -f pkglist.txt ]]; then
    pacman -S --needed --noconfirm $(grep -vE '^\s*#|^\s*$' pkglist.txt)
fi

# Setup GRUB theme ###############
if grep -q '^GRUB_THEME="/boot/grub/themes/LainOS/theme.txt"$' /etc/default/grub; then
    echo "LainOS GRUB theme already configured, skipping."
else
    cp -an /etc/default/grub /etc/default/grub.bak
    mkdir -pv /boot/grub/themes/LainOS
    cp -r ../assets/grub/themes/LainOS/* /boot/grub/themes/LainOS

    sed -i '/GRUB_CMDLINE_LINUX_DEFAULT=/d' /etc/default/grub
    sed -i '4a\GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet splash"' /etc/default/grub

    sed -i '/GRUB_TIMEOUT_STYLE=/d' /etc/default/grub
    echo 'GRUB_TIMEOUT_STYLE="menu"' >> /etc/default/grub

    sed -i '/GRUB_TIMEOUT=/d' /etc/default/grub
    echo 'GRUB_TIMEOUT="13"' >> /etc/default/grub

    sed -i '/GRUB_THEME=/d' /etc/default/grub
    echo 'GRUB_THEME="/boot/grub/themes/LainOS/theme.txt"' >> /etc/default/grub

    sed -i '/GRUB_GFXMODE=/d' /etc/default/grub
    echo 'GRUB_GFXMODE="auto"' >> /etc/default/grub

    grub-mkconfig -o /boot/grub/grub.cfg
fi

# Setup Plymouth theme
if plymouth-set-default-theme -l | grep -qx 'lainos'; then
    if [[ "$(plymouth-set-default-theme)" != "lainos" ]]; then
        plymouth-set-default-theme -R lainos
    fi
else
    echo "Plymouth theme 'lainos' is not installed."
fi

# Setup default user
existing_user=$(
    awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }' /etc/passwd
)

if [[ -n "$existing_user" ]]; then
    echo "User '$existing_user' already exists, skipping user creation."
else
    read -rp "Enter the name of the new user: " user

    useradd --create-home \
        --groups sddm,video,wheel \
        --shell /bin/zsh \
        "$user"

    echo "Now type your new password"
    passwd "$user"

    echo "Uncomment the line: %wheel ALL=(ALL) ALL"
    read -r
    EDITOR=nano visudo
fi

existing_user=$(
    awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }' /etc/passwd
)

existing_user=$(
    awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }' /etc/passwd
)

existing_user=$(
    awk -F: '$3 >= 1000 && $1 != "nobody" { print $1; exit }' /etc/passwd
)

# Install paru
if command -v paru >/dev/null 2>&1; then
    echo "paru is already installed, skipping."
else
    git clone https://aur.archlinux.org/paru.git "$HOME/paru"
    cd "$HOME/paru" || exit 1
    makepkg -si
fi

if [[ -f aurlist.txt ]]; then
    paru -S --needed --noconfirm $(grep -vE '^\s*#|^\s*$' aurlist.txt)
fi

# Block add domains
hblock

# Enable services
if [[ -s enabled-services.txt ]]; then
    echo "Enabling services..."
    xargs -a enabled-services.txt systemctl enable
else
    echo "enabled-services.txt missing or empty, skipping."
fi
