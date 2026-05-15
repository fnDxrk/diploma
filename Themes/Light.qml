import QtQuick

QtObject {
    // Colors — inverted Dark for now, just to prove themes work
    readonly property color background: "#ffffff"
    readonly property color backgroundTranslucent: "#80ffffff"
    readonly property color foreground: "#1a1a1a"
    readonly property color foregroundDim: "#666666"
    readonly property color foregroundDisabled: "#aaaaaa"
    readonly property color border: "#1a1a1a"
    readonly property color separator: "#cccccc"
    readonly property color hover: "#e0e0e0"
    readonly property color trackInactive: "#50000000"
    readonly property color trackMuted: "#999999"

    // Recolor SNI icons to dark on Light theme so white-on-transparent ones are readable.
    readonly property real trayIconColorization: 1
    readonly property color trayIconColor: foreground

    // Fonts
    readonly property string fontFamily: "JetBrains Mono"
    readonly property string fontFamilyIcons: "JetBrains Mono Nerd Font"
    readonly property int fontSizeBar: 18
    readonly property int fontSizeAudio: 24
    readonly property int fontSizeMenu: 14
    readonly property int fontSizeOsdIcon: 32
    readonly property int fontSizeOsdIconLarge: 48
    readonly property int fontSizeArrow: 24

    // Sizes
    readonly property int barHeight: 36
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
