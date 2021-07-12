#!/bin/bash

# Convert and copy icon which is needed for desktop integration into place:
wget https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png &>/dev/null
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert cnctsun.png -resize ${width}x${width} $dir/cnctsun.png
done

wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract

cnctsuns () {

mkdir -p ts-mp/usr ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp AppRun ts-mp ;
cp -r icons ts-mp/usr/share ; cp cnctsun.png ts-mp

wget "https://dl.winehq.org/wine/wine-mono/5.1.1/wine-mono-5.1.1-x86.msi"
wget "https://downloads.cncnet.org/TiberianSun_Online_Installer.exe"
wget "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/thinkvantage_en/dotnetfx.exe"
wget "https://github.com/AutoHotkey/AutoHotkey/releases/download/v1.0.48.05/AutoHotkey104805_Install.exe"

cp -Rvp ./*.exe ts-mp/winedata ; cp -Rvp ./*.msi ts-mp/winedata

export ARCH=x86_64; squashfs-root/AppRun -v ./ts-mp -u "gh-releases-zsync|mmtrt|cnctsun_AppImage|stable|cnctsun*.AppImage.zsync" cnctsun_${ARCH}.AppImage

}

cnctsunswp () {

export WINEDLLOVERRIDES="mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

cnctsuns ; rm ./*AppImage*

# Create winetricks & wine cache
mkdir -p /home/runner/.cache/{wine,winetricks}/{dotnet20,ahk} ; cp dotnetfx.exe /home/runner/.cache/winetricks/dotnet20
cp -Rvp *.msi /home/runner/.cache/wine/ ; cp -Rvp AutoHotkey104805_Install.exe /home/runner/.cache/winetricks/ahk

# Create WINEPREFIX
wineboot ; sleep 5
winetricks -q dotnet20 ; sleep 5

# Install game
(wine TiberianSun_Online_Installer.exe /silent ; sleep 20)
ls -al ./

# Launch game
wine ./TiberianSun_Online/TSMPLauncher.exe &
sleep 10
wineserver -k

cp -Rvp ./TiberianSun_Online "$WINEPREFIX"/drive_c/

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ; rm windows/temp/* ) || true

# Pre patching dpi setting in WINEPREFIX & Pre patching to disable winemenubuilder
# DPI dword value 240=f0 180=b4 120=78 110=6e 96=60
( cd "$WINEPREFIX"; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./user.reg ; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./system.reg ; sed -i 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./system.reg ) || true

cp -Rvp $WINEPREFIX ts-mp/ ; rm -rf $WINEPREFIX ; rm -rf ./ts-mp/winedata

# ( cd ts-mp ; wget -qO- 'https://gist.github.com/mmtrt/6d111388fadf6a08b7f4c41cdc250080/raw/2227d6053f83d4ea713ae63ae61973b535715c91/cnctsunswp.patch' | patch -p1 )

export ARCH=x86_64; squashfs-root/AppRun -v ./ts-mp -n -u "gh-releases-zsync|mmtrt|cnctsun_AppImage|stable-wp|cnctsun*.AppImage.zsync" cnctsun_WP-${ARCH}.AppImage

}

if [ "$1" == "stable" ]; then
    cnctsuns
elif [ "$1" == "stablewp" ]; then
    cnctsunswp
fi
