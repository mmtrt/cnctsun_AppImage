#!/bin/bash

cnctsuns () {

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons

TS_VERSION=6.$(wget -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tiberian-sun-client-600 | grep TS_Client | cut -d'.' -f2)

wget -q "https://dl.winehq.org/wine/wine-mono/4.7.5/wine-mono-4.7.5.msi"
wget -q $(wget -q -O- https://www.moddb.com/downloads/"$(wget -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tiberian-sun-client-600" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip
wget -q "https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe"
wget -q "https://web.archive.org/web/20120325002813/https://download.microsoft.com/download/A/C/2/AC2C903B-E6E8-42C2-9FD7-BEBAC362A930/xnafx40_redist.msi"

cp -Rp ./*.exe ts-mp/winedata ; cp -Rp ./*.msi ts-mp/winedata
sed -i -e 's|progVer=|progVer='"$TS_VERSION"'|g' ts-mp/wrapper

mkdir -p AppDir/winedata ; cp -r "ts-mp/"* AppDir
unzip tsclient.zip -d AppDir/usr/share/tsclient

NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

sed -i "s|520|$NVDV|" cnctsun.yml

./builder --recipe cnctsun.yml

}

cnctsunswp () {

export WINEDLLOVERRIDES="mshtml="
export WINEARCH="win32"
export WINEPREFIX="/home/runner/work/cnctsun_AppImage/cnctsun_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons

TS_VERSION=6.$(wget -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tiberian-sun-client-600 | grep TS_Client | cut -d'.' -f2)

wget -q "https://dl.winehq.org/wine/wine-mono/4.7.5/wine-mono-4.7.5.msi"
wget -q $(wget -q -O- https://www.moddb.com/downloads/"$(wget -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tiberian-sun-client-600" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip
wget -q "https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe"
wget -q "https://web.archive.org/web/20120325002813/https://download.microsoft.com/download/A/C/2/AC2C903B-E6E8-42C2-9FD7-BEBAC362A930/xnafx40_redist.msi"

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-stable-4-i386/wine-stable-i386_4.0.4-x86_64.AppImage
chmod +x *.AppImage ; mv wine-stable-i386_4.0.4-x86_64.AppImage wine-stable.AppImage

# Create winetricks & wine cache
mkdir -p /home/runner/.cache/{wine,winetricks}/{dotnet40,ahk,xna40} ; cp dotNetFx40_Full_x86_x64.exe /home/runner/.cache/winetricks/dotnet40 ; cp xnafx40_redist.msi /home/runner/.cache/winetricks/xna40
cp -Rp ./wine*.msi /home/runner/.cache/wine/ ; rm wrapper

# Create WINEPREFIX
./wine-stable.AppImage winetricks -q xna40 ; sleep 5

unzip tsclient.zip -d AppDir/usr/share/tsclient

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

echo "disabled" > $WINEPREFIX/.update-timestamp ; cp -r "ts-mp/"* AppDir

NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

sed -i "s|520|$NVDV|" cnctsun.yml

sed -i -e 's|progVer=|progVer='"${TS_VERSION}_WP"'|g' AppDir/wrapper

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
