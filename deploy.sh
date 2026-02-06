#!/bin/bash

cnctsuns () {

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

mkdir -p temp AppDir/winedata AppDir/usr/share ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons ; cp wine-ts.sh ts-mp/winedata

TS_VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q $(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/downloads/"$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip

wget -q "https://github.com/mmtrt/dotnet-runtime_AppImage/releases/download/continuous/dotnet-runtime-$(wget -qO- https://github.com/mmtrt/dotnet-runtime_AppImage/releases/expanded_assets/continuous | grep -Eo me-.* | tail -1 | sed 's|-| |g' | awk '{print $2}')-x86_64.AppImage" -O temp/dotnet ; chmod +x temp/dotnet

( cd temp ; ./dotnet --appimage-extract &>/dev/null ; cp -R AppDir/usr/share/dotnet ../AppDir/usr/share/ ) || true

sed -i -e 's|progVer=|progVer='"$TS_VERSION"'|g' ts-mp/wrapper

mkdir -p AppDir/usr/share/tsclient ; cp -r "ts-mp/"* AppDir
unzip tsclient.zip -d AppDir/usr/share/tsclient
( cd AppDir/usr/share/tsclient ; mv "Tiberian Sun Client"/* . ; rmdir "Tiberian Sun Client" ; rm wine-ts.sh )

# NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

# sed -i "s|520|$NVDV|" cnctsun.yml

chmod +x AppDir/winedata/wine-ts.sh

./squashfs-root/AppRun --skip-appimage --recipe cnctsun.yml

rm *.AppImage

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export URUNTIME_PRELOAD=0
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable|*$ARCH.AppImage.zsync"
VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

echo "Generating AppImage..."
appimagetool --no-appstream -u "$UPINFO" AppDir cnctsun-"$VERSION"-"$ARCH".AppImage

ls -al
}

cnctsunswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX="/home/runner/work/cnctsun_AppImage/cnctsun_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|;s|AppImageKit|type2-runtime|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

mkdir -p temp AppDir/winedata AppDir/usr/share/tsclient

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons ; cp wine-ts.sh ts-mp/winedata

wget -q "https://github.com/mmtrt/dotnet-runtime_AppImage/releases/download/continuous/dotnet-runtime-$(wget -qO- https://github.com/mmtrt/dotnet-runtime_AppImage/releases/expanded_assets/continuous | grep -Eo me-.* | tail -1 | sed 's|-| |g' | awk '{print $2}')-x86_64.AppImage" -O temp/dotnet ; chmod +x temp/dotnet

( cd temp ; ./dotnet --appimage-extract &>/dev/null ; cp -R AppDir/usr/share/dotnet ../AppDir/usr/share/ ) || true

TS_VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q $(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/downloads/"$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip

if [ $(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | head -1 | grep -c rc) -gt 0 ]; then
 WINE_VERSION="$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1,2 | head -1)"
else
 WINE_VERSION="$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1 | head -1)"
fi

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-devel/wine-devel_${WINE_VERSION}-x86_64.AppImage -O wine-devel.AppImage
chmod +x *.AppImage

# Remove wrapper
rm wrapper

# Create WINEPREFIX
./wine-devel.AppImage wineboot -i ; sleep 5

unzip tsclient.zip -d AppDir/usr/share/tsclient
( cd AppDir/usr/share/tsclient ; mv "Tiberian Sun Client"/* . ; rmdir "Tiberian Sun Client" ; rm wine-ts.sh )

# Add dlloverrides for Game.exe TiberianSun.exe
./wine-devel.AppImage REG ADD HKCU\\Software\\Wine\\AppDefaults\\game.exe\\DllOverrides /v *ddraw /t REG_SZ /d native,builtin
./wine-devel.AppImage REG ADD HKCU\\Software\\Wine\\AppDefaults\\TiberianSun.exe\\DllOverrides /v *ddraw /t REG_SZ /d native,builtin

# Removing any existing user data
( cd "$WINEPREFIX/drive_c/" ; rm -rf users ) || true

rm ./*.AppImage ; echo "disabled" > $WINEPREFIX/.update-timestamp ; cp -r "ts-mp/"* AppDir

chmod +x AppDir/winedata/wine-ts.sh

sed -i -e 's|progVer=|progVer='"${TS_VERSION}_WP"'|g' AppDir/wrapper

sed -i 's/stable|/stable-wp|/' cnctsun.yml

./squashfs-root/AppRun --skip-appimage --recipe cnctsun.yml

rm *.AppImage

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
export URUNTIME_PRELOAD=0
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable-wp|*$ARCH.AppImage.zsync"
VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

echo "Generating AppImage..."
appimagetool --no-appstream -u "$UPINFO" AppDir  cnctsun-"$VERSION"_WP-"$ARCH".AppImage

ls -al

}

if [ "$1" == "stable" ]; then
    cnctsuns
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    cnctsunswp
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
