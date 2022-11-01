#!/bin/bash

cnctsuns () {

# Download icon:
wget -q https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons

wget -q "https://dl.winehq.org/wine/wine-mono/4.7.5/wine-mono-4.7.5.msi"
wget -q "https://downloads.cncnet.org/TiberianSun_Online_Installer.exe"
wget -q "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/thinkvantage_en/dotnetfx.exe"
wget -q "https://github.com/AutoHotkey/AutoHotkey/releases/download/v1.0.48.05/AutoHotkey104805_Install.exe"

cp -Rp ./*.exe ts-mp/winedata ; cp -Rp ./*.msi ts-mp/winedata

mkdir -p AppDir/winedata ; cp -r "ts-mp/"* AppDir

NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

sed -i "s|520|$NVDV|" cnctsun.yml

./builder --recipe cnctsun.yml

}

cnctsunswp () {

export WINEDLLOVERRIDES="mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/work/cnctsun_AppImage/cnctsun_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

wget -q https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons

wget -q "https://dl.winehq.org/wine/wine-mono/4.7.5/wine-mono-4.7.5.msi"
wget -q "https://downloads.cncnet.org/TiberianSun_Online_Installer.exe"
wget -q "https://download.lenovo.com/ibmdl/pub/pc/pccbbs/thinkvantage_en/dotnetfx.exe"
wget -q "https://github.com/AutoHotkey/AutoHotkey/releases/download/v1.0.48.05/AutoHotkey104805_Install.exe"

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-i386/wine-stable-i386_4.0.4-x86_64.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-x86_64.AppImage wine-stable.AppImage

# Create winetricks & wine cache
mkdir -p /home/runner/.cache/{wine,winetricks}/{dotnet20,ahk} ; cp dotnetfx.exe /home/runner/.cache/winetricks/dotnet20
cp -Rp ./*.msi /home/runner/.cache/wine/ ; cp -Rp AutoHotkey104805_Install.exe /home/runner/.cache/winetricks/ahk ; rm wrapper

# Create WINEPREFIX
./wine-stable.AppImage winetricks -q dotnet20 ; sleep 5

# Install game
( ./wine-stable.AppImage TiberianSun_Online_Installer.exe /silent ; sleep 5 )

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

for pkgs in $(wget -qO- "https://files.cncnet.org/maps.php?game=ts" | awk '/Balance-Vet/,EOF' | sed -r '/Popular Mods/q;1d' | head -n -1 | cut -d'=' -f1); do
( cd "tmp/Maps/Balance-Vet Patch" || exit ; wget -q "https://mapdb.cncnet.org/ts/$pkgs.zip" ; 7z x "$pkgs".zip &>/dev/null ; rm "$pkgs".zip )
done

for pkgs in $(wget -qO- "https://files.cncnet.org/maps.php?game=ts" | awk '/Popular/,EOF' | sed -r '/Training/q;1d' | head -n -3 | cut -d'=' -f1); do
( cd "tmp/Maps/Popular Mods" || exit ; wget -q "https://mapdb.cncnet.org/ts/$pkgs.zip" ; 7z x "$pkgs".zip &>/dev/null ; rm "$pkgs".zip )
done

cp -Rp tmp/* TiberianSun_Online/ ; rm ./*.7z
cp -Rp ./TiberianSun_Online "$WINEPREFIX"/drive_c/

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

echo "disabled" > $WINEPREFIX/.update-timestamp

mkdir -p AppDir/winedata ; cp -r "ts-mp/"* AppDir

NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

sed -i "s|520|$NVDV|" cnctsun.yml

sed -i "23s/"1.0"/"1.0_WP"/" cnctsun.yml

sed -i 's/stable|/stable-wp|/' cnctsun.yml

./builder --recipe cnctsun.yml

}

if [ "$1" == "stable" ]; then
    cnctsuns
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    cnctsunswp
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
