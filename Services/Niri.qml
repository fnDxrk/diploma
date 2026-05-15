pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Niri compositor integration via `niri msg event-stream`.
//
// One long-lived Process: niri pushes events as JSON lines, we parse them.
// Zero polling, zero CPU at idle — just a stdin-blocked client process.
Singleton {
    id: root

    // List of workspaces, sorted by idx. niri sends them in arbitrary order
    // (order in which they were created/destroyed), but visually we always
    // want them left-to-right by index.
    property var workspaces: []
    readonly property var sortedWorkspaces: {
        const arr = workspaces.slice();
        arr.sort(function(a, b) { return a.idx - b.idx; });
        return arr;
    }

    readonly property var focusedWorkspace: workspaces.find(w => w.is_focused) ?? null
    readonly property int focusedWorkspaceIdx: focusedWorkspace?.idx ?? 0

    // Output name of the currently focused workspace — used to pick the
    // right physical screen for OSDs / popups in multi-monitor setups.
    readonly property string focusedOutput: focusedWorkspace?.output ?? ""

    // Resolve focusedOutput to the matching Quickshell ShellScreen object.
    readonly property var focusedScreen: {
        const name = focusedOutput;
        if (!name) return null;
        const screens = Quickshell.screens ?? [];
        return screens.find(s => s.name === name) ?? null;
    }

    // ----- Actions -----

    // Switch to workspace by 1-based index (idx as niri reports it).
    function switchToWorkspace(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    // ----- Event stream -----

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                try {
                    const obj = JSON.parse(line);
                    if (obj.WorkspacesChanged) {
                        root.workspaces = obj.WorkspacesChanged.workspaces;
                    } else if (obj.WorkspaceActivated) {
                        // Single-workspace activation. The event only carries
                        // {id, focused}, no output — look up the activated
                        // workspace's output ourselves so we can clear
                        // is_active on the previous one on that output.
                        const ev = obj.WorkspaceActivated;
                        const activated = root.workspaces.find(w => w.id === ev.id);
                        const activatedOutput = activated ? activated.output : null;
                        const next = root.workspaces.map(function(w) {
                            return {
                                id: w.id,
                                idx: w.idx,
                                name: w.name,
                                output: w.output,
                                is_urgent: w.is_urgent,
                                active_window_id: w.active_window_id,
                                is_active: w.id === ev.id
                                           ? true
                                           : (activatedOutput && w.output === activatedOutput ? false : w.is_active),
                                is_focused: ev.focused ? (w.id === ev.id) : w.is_focused
                            };
                        });
                        root.workspaces = next;
                    }
                } catch (e) {}
            }
        }
    }
}
