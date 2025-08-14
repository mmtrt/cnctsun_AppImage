#!/bin/bash

cnctsuns () {

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# Add static appimage runtime
mkdir -p appimage-build/prime AppDir/winedata
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/runtime-x86_64" -O appimage-build/prime/runtime-x86_64
mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons ; cp wine-ts.sh ts-mp/winedata

wget -q "https://github.com/mmtrt/dotnet-runtime_AppImage/releases/download/ts-asset/dotnet-runtime-$(wget -qO- https://github.com/mmtrt/dotnet-runtime_AppImage/releases/expanded_assets/ts-asset | grep -Eo me-.* | tail -1 | sed 's|-| |g' | awk '{print $2}')-x86_64.AppImage" -O AppDir/winedata/dotnet ; chmod +x AppDir/winedata/dotnet

TS_VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q $(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/downloads/"$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-devel/wine-devel_$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1 | head -1)-x86_64.AppImage -O wine-devel.AppImage
chmod +x *.AppImage ; cp wine-devel.AppImage ts-mp/winedata/

sed -i -e 's|progVer=|progVer='"$TS_VERSION"'|g' ts-mp/wrapper

mkdir -p AppDir/winedata AppDir/usr/share/tsclient ; cp -r "ts-mp/"* AppDir
unzip tsclient.zip -d AppDir/usr/share/tsclient
( cd AppDir/usr/share/tsclient ; mv "Tiberian Sun Client"/* . ; rmdir "Tiberian Sun Client" ; rm wine-ts.sh )

# NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

# sed -i "s|520|$NVDV|" cnctsun.yml

chmod +x AppDir/winedata/wine-ts.sh

./squashfs-root/AppRun --skip-appimage --recipe cnctsun.yml

rm *.AppImage

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable|*$ARCH.AppImage.zsync"
VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Keep the mount point (speeds up launch time)
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime-lite

# Add udpate info to runtime
echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 --header uruntime-lite -i AppDir -o ./cnctsun-"$VERSION"-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

}

cnctsunswp () {

export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEPREFIX="/home/runner/work/cnctsun_AppImage/cnctsun_AppImage/AppDir/winedata/.wine"
export WINEDEBUG="-all"

wget -q "https://github.com/AppImageCrafters/appimage-builder/releases/download/v1.0.3/appimage-builder-1.0.3-x86_64.AppImage" -O builder ; chmod +x builder ; ./builder --appimage-extract &>/dev/null

# add custom mksquashfs
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/mksquashfs" -O squashfs-root/usr/bin/mksquashfs

# force zstd format in appimagebuilder for appimages
rm builder ; sed -i 's|xz|zstd|' squashfs-root/usr/lib/python3.8/site-packages/appimagebuilder/modules/prime/appimage_primer.py

# Add static appimage runtime
mkdir -p appimage-build/prime AppDir/winedata AppDir/usr/share/tsclient
wget -q "https://github.com/mmtrt/WINE_AppImage/raw/master/runtime/runtime-x86_64" -O appimage-build/prime/runtime-x86_64

mkdir -p ts-mp/usr/share/icons ts-mp/winedata ; cp cnctsun.desktop ts-mp ; cp wrapper ts-mp ; cp cnctsun.png ts-mp/usr/share/icons ; cp wine-ts.sh ts-mp/winedata

wget -q "https://github.com/mmtrt/dotnet-runtime_AppImage/releases/download/ts-asset/dotnet-runtime-$(wget -qO- https://github.com/mmtrt/dotnet-runtime_AppImage/releases/expanded_assets/ts-asset | grep -Eo me-.* | tail -1 | sed 's|-| |g' | awk '{print $2}')-x86_64.AppImage" -O AppDir/winedata/dotnet ; chmod +x AppDir/winedata/dotnet

TS_VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)

wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q $(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/downloads/"$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- "https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70" |grep -Eo "/start/.*" | cut -d'"' -f1)" | grep -Eo https.* | grep mirror | cut -d'"' -f1) -O tsclient.zip

wget -q https://github.com/mmtrt/WINE_AppImage/releases/download/continuous-devel/wine-devel_$(wget -qO- https://github.com/mmtrt/WINE_AppImage/releases/expanded_assets/continuous-devel | grep -Eo 'devel_[0-9].*' | cut -d'_' -f2 | cut -d'-' -f1 | head -1)-x86_64.AppImage -O wine-devel.AppImage
chmod +x *.AppImage ; cp wine-devel.AppImage ts-mp/winedata/

# Create winetricks & wine cache
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

echo "disabled" > $WINEPREFIX/.update-timestamp ; cp -r "ts-mp/"* AppDir

# NVDV=$(wget "https://launchpad.net/~graphics-drivers/+archive/ubuntu/ppa/+packages?field.name_filter=&field.status_filter=published&field.series_filter=kinetic" -qO- | grep -Eo drivers-.*changes | sed -r "s|_| |g;s|-| |g" | tail -n1 | awk '{print $9}')

# sed -i "s|520|$NVDV|" cnctsun.yml

chmod +x AppDir/winedata/wine-ts.sh

sed -i -e 's|progVer=|progVer='"${TS_VERSION}_WP"'|g' AppDir/wrapper

sed -i 's/stable|/stable-wp|/' cnctsun.yml

./squashfs-root/AppRun --skip-appimage --recipe cnctsun.yml

rm *.AppImage

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1
UPINFO="gh-releases-zsync|$(echo "$GITHUB_REPOSITORY" | tr '/' '|')|stable-wp|*$ARCH.AppImage.zsync"
VERSION=7.$(wget --user-agent='Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0' -q -O- https://www.moddb.com/mods/tiberian-sun-client/downloads/tsclient70 | grep TS_Client | cut -d'.' -f2)
URUNTIME="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-$ARCH"
URUNTIME_LITE="https://github.com/VHSgunzo/uruntime/releases/latest/download/uruntime-appimage-dwarfs-lite-$ARCH"
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime
wget --retry-connrefused --tries=30 "$URUNTIME_LITE" -O ./uruntime-lite
chmod +x ./uruntime*

# Keep the mount point (speeds up launch time)
sed -i 's|URUNTIME_MOUNT=[0-9]|URUNTIME_MOUNT=0|' ./uruntime-lite

echo "Adding update information \"$UPINFO\" to runtime..."
./uruntime-lite --appimage-addupdinfo "$UPINFO"

echo "Generating AppImage..."
./uruntime --appimage-mkdwarfs -f --set-owner 0 --set-group 0 --no-history --no-create-timestamp --compression zstd:level=22 -S26 -B8 --header uruntime-lite -i AppDir -o ./cnctsun-"$VERSION"_WP-"$ARCH".AppImage

echo "Generating zsync file..."
zsyncmake *.AppImage -u *.AppImage

}

if [ "$1" == "stable" ]; then
    cnctsuns
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
elif [ "$1" == "stablewp" ]; then
    cnctsunswp
    ( mkdir -p dist ; mv cnctsun*.AppImage* dist/. ; cd dist || exit ; chmod +x ./*.AppImage )
fi
