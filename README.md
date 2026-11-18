# Advanced Radio Player (TW)

<p>
  <img alt="Status: beta" src="https://img.shields.io/badge/status-beta-yellow">
  <a href="https://github.com/TechnikWeber/advanced-radio-player/releases/latest"><img alt="Download" src="https://img.shields.io/github/v/release/TechnikWeber/advanced-radio-player?include_prereleases&label=download&color=2ea44f"></a>
  <a href="https://github.com/TechnikWeber/advanced-radio-player/releases"><img alt="Downloads" src="https://img.shields.io/github/downloads/TechnikWeber/advanced-radio-player/total?color=blue"></a>
  <img alt="Platform: KDE Plasma 6" src="https://img.shields.io/badge/platform-KDE%20Plasma%206-blue">
  <a href="LICENSE"><img alt="License: GPL-2.0-or-later" src="https://img.shields.io/badge/license-GPL--2.0--or--later-green"></a>
</p>

<p>
  <a href="https://github.com/TechnikWeber/advanced-radio-player/releases/latest"><b>Download</b></a> &nbsp;·&nbsp;
  <a href="#install"><b>Install</b></a> &nbsp;·&nbsp;
  <a href="#moving-over-from-the-original-widget"><b>Moving over</b></a> &nbsp;·&nbsp;
  <a href="https://github.com/TechnikWeber/advanced-radio-player/releases"><b>Releases</b></a>
</p>

A fork of **Advanced Radio Player** by **Yuri Saurov**, an internet radio
plasmoid for KDE Plasma 6 with an editable station list and a station search
([KDE Store #2136933](https://store.kde.org/p/2136933)).

All the work in this widget is Yuri's. This fork only fixes one bug: the
widget **ignores the audio output you choose**.

## The bug

Connect Bluetooth headphones while the radio is playing, or pick another
output as the default, and the music keeps coming out of the laptop speakers.
In the volume applet the stream's output can't even be changed, because the
headphones don't show up as an option for it.

The cause: the widget creates its `AudioOutput` without a device. Qt
Multimedia then uses the device that was the default when `plasmashell`
started. It hands that device to PipeWire as a fixed target with
`node.dont-reconnect = true`, so neither WirePlumber nor the user can move the
stream, and every new station is sent to the same device again.

## The fix

Both players (the main player and the preview player in the station search)
now bind their output to the current system default:

```qml
MediaDevices { id: mediaDevices }

MediaPlayer {
    audioOutput: AudioOutput {
        device: mediaDevices.defaultAudioOutput
    }
}
```

When the default output changes, the stream follows it. The changes are in
commit `Follow the default audio output…`. The first commit is the original
3.1 package, unchanged, so `git diff` against it shows exactly what this fork
changes.

Other changes:

- Plugin ID `com.technikweber.advancedradio` and name *Advanced Radio Player (TW)*,
  so a KDE Store update of the original can't overwrite the fix, and both
  widgets can be installed side by side.
- Removed a leftover `configSearch.qml.bak` file.

## Install

Download `com.technikweber.advancedradio.plasmoid` from the
[latest release](https://github.com/TechnikWeber/advanced-radio-player/releases/latest),
then right-click the desktop → *Enter Edit Mode* → *Add or Manage Widgets…* →
*Get New Widgets…* → *Install Widget From Local File…* and pick it. Add
*Advanced Radio Player (TW)* to your desktop or panel.

From a clone:

```sh
make install     # installs or updates the widget for the current user
make uninstall
make dist        # builds dist/com.technikweber.advancedradio.plasmoid
```

## Moving over from the original widget

The fork has its own plugin ID, so your station list isn't copied over
automatically. Export the stations in the original widget's settings, import
them in the new one, then remove the original widget. (The list is the
`servers=` entry of the widget's `[Configuration][General]` group in
`~/.config/plasma-org.kde.plasma.desktop-appletsrc`.)

## Upstream

The fix has been suggested to the original author. If it lands there, use the
original widget again. This fork exists only until then.

## License

GPL-2.0-or-later, like the original. See [LICENSE](LICENSE).
Original work © Yuri Saurov.
