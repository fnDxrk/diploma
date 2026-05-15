pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// Microphone (Pipewire default source) + list of available input devices.
Singleton {
    id: root

    readonly property real maxVolume: 1.5

    readonly property var source: Pipewire.defaultAudioSource
    readonly property real volume: source?.audio?.volume ?? 0
    readonly property bool muted: source?.audio?.muted ?? false
    readonly property real ratio: maxVolume > 0 ? volume / maxVolume : 0

    readonly property string icon: muted ? "󰍭" : "󰍬"

    // All audio input nodes (sources)
    readonly property var sources: {
        const all = Pipewire.nodes?.values ?? [];
        return all.filter(n => !n.isSink && n.audio);
    }

    function toggleMute() {
        if (source?.audio)
            source.audio.muted = !source.audio.muted;
    }

    function setRatio(value) {
        if (!source?.audio) return;
        source.audio.volume = Math.max(0, Math.min(1, value)) * maxVolume;
    }

    function setDefaultSource(node) {
        Pipewire.preferredDefaultAudioSource = node;
    }

    function labelFor(node) {
        if (!node) return "";
        return node.description || node.nickname || node.name || "Unknown";
    }

    PwObjectTracker {
        objects: {
            const list = [];
            if (root.source) list.push(root.source);
            for (const s of root.sources) if (s !== root.source) list.push(s);
            return list;
        }
    }
}
