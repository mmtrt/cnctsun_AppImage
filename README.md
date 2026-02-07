<p align="center">
    <img src="https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png" alt="cnctsun logo" width=128 height=128>

<h2 align="center">cnctsun AppImage</h2>

  <p align="center">cnctsun Stable (unofficial) AppImages by GitHub Actions Continuous Integration
    <br>
    <a href="https://github.com/mmtrt/cnctsun_AppImage/issues/new">Report bug</a>
    ·
    <a href="https://github.com/mmtrt/cnctsun_AppImage/issues/new">Request feature</a>
    ·
    <a href="https://github.com/mmtrt/cnctsun_AppImage/releases">Download AppImage</a>
  </p>
</p>

## Info
 * This AppImage has two versions one stable only contains required files to install game with all redistributable which takes quite time to first boot as it installs all theses requirements and other one have all these preinstalled inside wineprefix which boots instant.

## Get Started

Download the latest release from

| Stable | Stable-WP |
| ------- | --------- |
| <img src="https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png" height=100> | <img src="https://github.com/mmtrt/cnctsun/raw/master/snap/gui/cnctsun.png" height=100> |
| [Download](https://github.com/mmtrt/cnctsun_AppImage/releases/tag/stable) | [Download](https://github.com/mmtrt/cnctsun_AppImage/releases/tag/stable-wp) |


### Executing
#### File Manager
Just double click the `*.AppImage` file and you are done!

> In normal cases, the above method should work, but in some rare cases
the `+x` permissisions. So, right click > Properties > Allow Execution

#### Terminal
```bash
./cnctsun-*.AppImage
```
```bash
chmod +x cnctsun-*.AppImage
./cnctsun-*.AppImage
```

In case, if FUSE support libraries are not installed on the host system, it is
still possible to run the AppImage

```bash
./cnctsun-*.AppImage --appimage-extract
cd squashfs-root
./AppRun
```
