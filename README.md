![CI](https://github.com/avojak/replay/workflows/CI/badge.svg)
![Lint](https://github.com/avojak/replay/workflows/Lint/badge.svg)
![GitHub](https://img.shields.io/github/license/avojak/replay.svg?color=blue)
![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/avojak/replay?sort=semver)

<p align="center">
  <img src="data/assets/replay.svg" alt="Icon" />
</p>
<h1 align="center">Replay</h1>
<!-- <p align="center">
  <a href="https://appcenter.elementary.io/com.github.avojak.replay"><img src="https://appcenter.elementary.io/badge.svg" alt="Get it on AppCenter" /></a>
</p> -->

## Replay the Classics!

Replay is a native Linux multi-system emulator built in Vala and GTK for [elementary OS](https://elementary.io).

| ![Screenshot](data/assets/screenshots/replay-screenshot-01.png) | ![Screenshot](data/assets/screenshots/replay-screenshot-02.png) |
|------------------------------------------------------------------|------------------------------------------------------------------|
| ![Screenshot](data/assets/screenshots/replay-screenshot-03.png) | ![Screenshot](data/assets/screenshots/replay-screenshot-04.png) |

### Included Cores

Replay ships with several [libretro](https://www.libretro.com) cores:

| Name | System(s) | License |
| ---- | ------------------ | ------- |
| mGBA | Game Boy<br>Game Boy Color<br>Game Boy Advance | MPLv2.0 |

Additional cores can be easily imported (See: <a href="#installing-additional-cores">Installing Additional Cores</a>).

### Included Games

Replay also ships with several games:

| Name | System | License |
| ---- | ------ | ------- |
| [Game Boy Wordyl](https://github.com/bbbbbr/gb-wordle) | Game Boy | GPLv3 | 
| [Flooder](https://github.com/Obalfour/Flooder) | Game Boy | MIT |

<!-- | Varooom 3D | Game Boy Advance | ZLib | [Source](https://github.com/GValiente/butano) | -->


Additional games can be easily added to the library (See: <a href="#installing-additional-games">Installing Additional Games</a>).

## Install from Source

You can install Replay by compiling from source. Here's the list of
dependencies required:

- `libgranite (>= 6.2.0)`
- `libgtk-3-dev (>= 3.24.20)`
- `libgee-0.8-dev (>= 3.24.20)`
- `libhandy-1-dev (>= 1.2.0)`
- `retro-gtk-1 (>= 1.0.2)`
- `meson`
- `valac (>= 0.28.0)`

## Building and Running

### Flatpak

Flatpak is the preferred method of building Replay to ensure that built-in cores and core info are included:

```bash
$ flatpak-builder build com.github.avojak.replay.yml --user --install --force-clean
$ flatpak run --env=G_MESSAGES_DEBUG=all com.github.avojak.replay
```

### Updating Translations

When new translatable strings are added, ensure that `po/POTFILES` contains a
reference to the file with the translatable string.

Update the `.pot` file which contains the translatable strings:

```
$ ninja -C build com.github.avojak.replay-pot
```

Generate translations for the languages listed in the `po/LINGUAS` files:

```
$ ninja -C build com.github.avojak.replay-update-po
```

## Installing Additional Cores

TODO

## Installing Additional Games

TODO

## Related Projects

For my work on developing a Game Boy emulator written in Vala, check out [Vee](https://github.com/avojak/vee)!

---

## Copyright Notice

Replay is not affiliated, associated, authorized, endorsed by, or in any way officially connected with Nintendo&reg;, or any of its subsidiaries or its affiliates. Game Boy&trade; is a registered trademark of Nintendo Corporation.

All other product names mentioned herein, with or without the registered trademark symbol &reg; or trademark symbol &trade; are generally trademarks and/or registered trademarks of their respective owners.

## Disclaimer

Replay is not designed to enable illegal activity. We do not promote piracy, and Replay users are expected to follow all applicable local laws.