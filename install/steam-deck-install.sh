#! /usr/bin/env bash

if [[ $1 == "remove" ]]; then
	sudo pacman -Rcns xone-dkms xone-dongle-firmware

	echo ""
	echo ""
	echo "Done!"
	echo "Just reboot your Deck :)"

	exit 0
fi

ro_status=$(steamos-readonly status)
if [[ $ro_status == "enabled" ]]; then
    echo "Disabling readonly"
    echo ""
    steamos-readonly disable
fi

pacman-key --init
pacman-key --populate archlinux
pacman-key --populate holo

mkdir xone-install
cd xone-install || exit 1


AUR_LINK="https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h="
curl "${AUR_LINK}xone-dkms" -o PKGBUILD_XONE
curl "${AUR_LINK}xone-dongle-firmware" -o PKGBUILD_FIRMWARE

# to ABSOLUTELY make sure we have acces when running sudo -u deck
chown -R deck:deck .
chmod 777 .

echo ""
echo "Don't worry about \"error: command failed to execute correctly\""
echo ""

linux=$(pacman -Qsq linux-neptune | grep -e "[0-9]$" | tail -n 1)
pacman -Syu --noconfirm base-devel fakeroot glibc git \
    "$linux" "$linux-headers" linux-api-headers

echo ""
echo "You'll be asked for password again :("
echo ""
sleep 2s

cat <<- EOF > build.sh
#! /usr/bin/sh
makepkg -scri --noconfirm -p PKGBUILD_XONE
makepkg -scri --noconfirm -p PKGBUILD_FIRMWARE
EOF

chmod 755 build.sh
sudo -u deck ./build.sh

echo ""
echo "Again, don't worry about this ^"

cd ..
rm -rf xone-install

echo ""
echo ""
echo "Done!"
echo "Just reboot your Deck :)"
