pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Audio data source. Wraps Pipewire's default sink + exposes the list of all
// audio output devices for the popup picker.
Singleton {
    id: root

    readonly property real maxVolume: 1.5

    // ----- Default sink (current output) -----

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false
    readonly property real ratio: maxVolume > 0 ? volume / maxVolume : 0

    readonly property string icon: {
        if (muted) return "󰝟";
        if (ratio <= 0.33) return "󰕿";
        if (ratio <= 0.66) return "󰖀";
        return "󰕾";
    }

    // ----- All audio sinks (output devices) -----
    //
    // Pipewire.nodes is an ObjectModel of every node — filter to audio sinks.
    // Recomputed reactively when the model changes.
    readonly property var sinks: {
        const all = Pipewire.nodes?.values ?? [];
        return all.filter(n => n.isSink && n.audio);
    }

    // ----- Actions -----

    function toggleMute() {
        if (sink?.audio)
            sink.audio.muted = !sink.audio.muted;
    }

    function setRatio(value) {
        if (!sink?.audio) return;
        sink.audio.volume = Math.max(0, Math.min(1, value)) * maxVolume;
    }

    function bump(step) {
        setRatio(ratio + step);
    }

    function setDefaultSink(node) {
        Pipewire.preferredDefaultAudioSink = node;
    }

    // Suggest a user-friendly label for a sink node.
    // description (e.g. "Ryzen HD Audio Controller Analog Stereo") is usually
    // the most informative; nickname is sometimes terser ("ALC257 Analog");
    // name is the raw alsa identifier ("alsa_output.pci-...").
    function labelFor(node) {
        if (!node) return "";
        return node.description || node.nickname || node.name || "Unknown";
    }

    // Track the default sink + every other sink we want to read volume of.
    // For the popup we only really need the default's audio object alive,
    // but PwObjectTracker is cheap.
    PwObjectTracker {
        objects: {
            const list = [];
            if (root.sink) list.push(root.sink);
            for (const s of root.sinks) if (s !== root.sink) list.push(s);
            return list;
        }
    }
}
