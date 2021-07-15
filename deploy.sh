#!/bin/bash

# Convert and copy icon which is needed for desktop integration into place:
wget -q https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png &>/dev/null
for width in 8 16 22 24 32 36 42 48 64 72 96 128 192 256; do
    dir=icons/hicolor/${width}x${width}/apps
    mkdir -p $dir
    convert cnctsun.png -resize ${width}x${width} $dir/cnctsun.png
done

wget -qc "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
chmod +x ./appimagetool-x86_64.AppImage
./appimagetool-x86_64.AppImage --appimage-extract &>/dev/null

cnctsuns () {

mkdir -p ts-mp/usr ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp AppRun ts-mp ;
cp -r icons ts-mp/usr/share ; cp cnctsun.png ts-mp

wget -q "https://dl.winehq.org/wine/wine-mono/5.1.1/wine-mono-5.1.1-x86.msi"
wget -q "https://downloads.cncnet.org/TiberianSun_Online_Installer.exe"
wget -q "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/thinkvantage_en/dotnetfx.exe"
wget -q "https://github.com/AutoHotkey/AutoHotkey/releases/download/v1.0.48.05/AutoHotkey104805_Install.exe"

cp -Rp ./*.exe ts-mp/winedata ; cp -Rp ./*.msi ts-mp/winedata

export ARCH=x86_64; squashfs-root/AppRun -v ./ts-mp -u "gh-releases-zsync|mmtrt|cnctsun_AppImage|stable|cnctsun*.AppImage.zsync" cnctsun_${ARCH}.AppImage &>/dev/null

}

cnctsunswp () {

sudo dpkg --add-architecture i386
wget -qnc https://dl.winehq.org/wine-builds/winehq.key
sudo apt-key add winehq.key &>/dev/null
sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main' &>/dev/null
sudo apt update &>/dev/null
sudo apt install --install-recommends winehq-stable -y &>/dev/null ; sudo apt install cabextract -y &>/dev/null
wget -qnc https://github.com/Winetricks/winetricks/raw/master/src/winetricks
chmod +x winetricks ; sudo mv winetricks /usr/bin

export WINEDLLOVERRIDES="mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/.wine"
export WINEDEBUG="-all"

cnctsuns ; rm ./*AppImage*

# Create winetricks & wine cache
mkdir -p /home/runner/.cache/{wine,winetricks}/{dotnet20,ahk} ; cp dotnetfx.exe /home/runner/.cache/winetricks/dotnet20
cp -Rp ./*.msi /home/runner/.cache/wine/ ; cp -Rp AutoHotkey104805_Install.exe /home/runner/.cache/winetricks/ahk

# Create WINEPREFIX
winetricks -q dotnet20 ; sleep 5

# Install game
(wine TiberianSun_Online_Installer.exe /silent ; sleep 10 ; wineserver -k)

# Download game updates manually
for pkgs in CnCNet5Version.txt cncnet5.7z Sounds.7z Language.7z Icons.7z GeoIP.7z ts-spawn.7z TS_Maps.7z TS_Rules.7z TS_CnCNet5ClientBackground.7z System.Data.SQLite.dll.7z hints.7z LAN.7z _Servers.7z ts-voxels.7z ts-config.7z ts-terrain.7z; do
wget -q "https://downloads.cncnet.org/updates/cncnet5/${pkgs}"
if [[ $pkgs = "CnCNet5Version.txt" ]]; then
mkdir -p tmp/CnCNet5/Others ; mv $pkgs tmp/CnCNet5/Others
elif [[ $pkgs = "_Servers.7z" || $pkgs = "GeoIP.7z" || $pkgs = "TS_CnCNet5ClientBackground.7z" || $pkgs = "hints.7z" ]]; then
7z x -aos "$pkgs" "-otmp/CnCNet5/Others" &>/dev/null
elif [[ $pkgs = "Icons.7z" || $pkgs = "LAN.7z" || $pkgs = "Language.7z" || $pkgs = "Sounds.7z" ]]; then
7z x -aos "$pkgs" "-otmp/CnCNet5" &>/dev/null
elif [[ $pkgs = "cncnet5.7z" ]]; then
7z x "$pkgs" -so > "tmp/cncnet5.exe"
else
7z x -aos "$pkgs" "-otmp" &>/dev/null
fi
done

# Download maps updates manually
mkdir -p "tmp/Maps/Balance-Vet Patch" "tmp/Maps/Popular Mods"
wget -qO- "https://files.cncnet.org/maps.php?game=ts" > "tmp/CnCNet5/Others/TiberianSunMaps.ini"

for pkgs in $(wget -qO- "https://gist.github.com/mmtrt/449d0f655b0673b55b7723826267e06e/raw/36d5e557cd24b0e750040df7235ce50172e717f1/mapbvt.txt"); do
(cd "tmp/Maps/Balance-Vet Patch" || exit ; wget -q "https://mapdb.cncnet.org/ts/$pkgs.zip" ; 7z x "$pkgs".zip ; rm "$pkgs".zip)
done

for pkgs in $(wget -qO- "https://files.cncnet.org/maps.php?game=ts" | awk '/Popular/,EOF' | sed -r '/Training/q;1d' | head -n -3 | cut -d'=' -f1); do
(cd "tmp/Maps/Popular Mods" || exit ; wget -q "https://mapdb.cncnet.org/ts/$pkgs.zip" ; 7z x "$pkgs".zip ; rm "$pkgs".zip)
done

cp -Rp tmp/* TiberianSun_Online/ ; rm ./*.7z
cp -Rp ./TiberianSun_Online "$WINEPREFIX"/drive_c/

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ; rm windows/temp/* ) || true

# Pre patching dpi setting in WINEPREFIX & Pre patching to disable winemenubuilder
# DPI dword value 240=f0 180=b4 120=78 110=6e 96=60
( cd "$WINEPREFIX"; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./user.reg ; sed -i 's|"LogPixels"=dword:00000060|"LogPixels"=dword:0000006e|' ./system.reg ; sed -i 's/winemenubuilder.exe -a -r/winemenubuilder.exe -r/g' ./system.reg ) || true

cp -Rp $WINEPREFIX ts-mp/ ; rm -rf $WINEPREFIX ; rm -rf ./ts-mp/winedata

( cd ts-mp || exit ; wget -qO- 'https://gist.github.com/mmtrt/49df9fc50ae567a3d5d89791bdb65d45/raw/19b5f3a08fa3ec1429e989adba1cfe9314cd6b52/cnctsunswp.patch' | patch -p1 )

export ARCH=x86_64; squashfs-root/AppRun -v ./ts-mp -n -u "gh-releases-zsync|mmtrt|cnctsun_AppImage|stable-wp|cnctsun*.AppImage.zsync" cnctsun_WP-${ARCH}.AppImage &>/dev/null

}

if [ "$1" == "stable" ]; then
    cnctsuns
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    cnctsunswp
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
