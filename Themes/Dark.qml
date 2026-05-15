import QtQuick

QtObject {
    // Colors
    readonly property color background: "#000000"
    readonly property color backgroundTranslucent: "#80000000"
    readonly property color foreground: "#ffffff"
    readonly property color foregroundDim: "#808080"
    readonly property color foregroundDisabled: "#666666"
    readonly property color border: "#ffffff"
    readonly property color separator: "#444444"
    readonly property color hover: "#333333"
    readonly property color trackInactive: "#50ffffff"
    readonly property color trackMuted: "#686868"

    // Recolor SNI tray icons via MultiEffect so they always match the theme.
    // 0 = no colorization (icons rendered as-is).
    readonly property real trayIconColorization: 0
    readonly property color trayIconColor: foreground

    // Fonts
    readonly property string fontFamily: "JetBrains Mono"
    readonly property string fontFamilyIcons: "JetBrains Mono Nerd Font"
    readonly property int fontSizeBar: 18
    readonly property int fontSizeAudio: 20
    readonly property int fontSizeMenu: 14
    readonly property int fontSizeOsdIcon: 32
    readonly property int fontSizeOsdIconLarge: 48
    readonly property int fontSizeArrow: 24

    // Sizes
    readonly property int barHeight: 44
    readonly property int popupRadius: 12
    readonly property int menuRadius: 8
    readonly property int popupPadding: 16
    readonly property int popupBorderWidth: 1
    readonly property int trayIconSize: 32
    readonly property int trayIconImageSize: 16
    readonly property int trayIconSpacing: 10
    readonly property int menuItemHeight: 28
    readonly property int separatorHeight: 9
    readonly property int menuItemHorizontalPadding: 12
    readonly property int menuPadding: 8
}
