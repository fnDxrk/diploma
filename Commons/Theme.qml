pragma Singleton

import QtQuick
import qs.Themes

// Singleton proxy. Active theme is set in shell.qml via `Theme.current = Dark { }`.
// All consumers read `Theme.foo` and stay agnostic of which theme is loaded.
QtObject {
    id: root

    // Active theme object. Defaults to Dark — falls back here if shell.qml forgets.
    property var current: defaultTheme

    readonly property Dark defaultTheme: Dark {}

    // Colors
    readonly property color background: current.background
    readonly property color backgroundTranslucent: current.backgroundTranslucent
    readonly property color foreground: current.foreground
    readonly property color foregroundDim: current.foregroundDim
    readonly property color foregroundDisabled: current.foregroundDisabled
    readonly property color border: current.border
    readonly property color separator: current.separator
    readonly property color hover: current.hover
    readonly property color trackInactive: current.trackInactive
    readonly property color trackMuted: current.trackMuted
    readonly property real trayIconColorization: current.trayIconColorization
    readonly property color trayIconColor: current.trayIconColor

    // Fonts
    readonly property string fontFamily: current.fontFamily
    readonly property string fontFamilyIcons: current.fontFamilyIcons
    readonly property int fontSizeBar: current.fontSizeBar
    readonly property int fontSizeAudio: current.fontSizeAudio
    readonly property int fontSizeMenu: current.fontSizeMenu
    readonly property int fontSizeOsdIcon: current.fontSizeOsdIcon
    readonly property int fontSizeOsdIconLarge: current.fontSizeOsdIconLarge
    readonly property int fontSizeArrow: current.fontSizeArrow

    // Sizes
    readonly property int barHeight: current.barHeight
    readonly property int popupRadius: current.popupRadius
    readonly property int menuRadius: current.menuRadius
    readonly property int popupPadding: current.popupPadding
    readonly property int popupBorderWidth: current.popupBorderWidth
    readonly property int trayIconSize: current.trayIconSize
    readonly property int trayIconImageSize: current.trayIconImageSize
    readonly property int trayIconSpacing: current.trayIconSpacing
    readonly property int menuItemHeight: current.menuItemHeight
    readonly property int separatorHeight: current.separatorHeight
    readonly property int menuItemHorizontalPadding: current.menuItemHorizontalPadding
    readonly property int menuPadding: current.menuPadding
}
