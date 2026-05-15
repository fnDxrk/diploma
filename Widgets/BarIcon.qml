import QtQuick
import qs.Commons

// Bar icon with stable width regardless of which glyph is shown.
//
// Sizes itself to the widest glyph among `glyphs` and centers the current
// `icon` glyph inside that fixed box. Without this, swapping Nerd Font
// glyphs of different widths (e.g. volume mute vs high) jiggles the bar.
//
// Usage:
//   BarIcon {
//       glyphs: ["󰕾", "󰖀", "󰕿", "󰝟"]
//       icon: Audio.icon
//       fontSize: Theme.fontSizeAudio
//   }
Item {
    id: root

    property string icon: ""
    property var glyphs: []
    property int fontSize: Theme.fontSizeBar
    property color iconColor: Theme.foreground
    property int weight: Font.Normal

    // Width of the widest glyph from `glyphs`. Falls back to current `icon`
    // width before the loop runs, so the layout is sane during construction.
    property real maxGlyphWidth: measurer.implicitWidth

    implicitWidth: maxGlyphWidth
    implicitHeight: fontSize

    function recomputeWidth() {
        let m = 0;
        for (let i = 0; i < glyphs.length; i++) {
            measurer.text = glyphs[i];
            if (measurer.implicitWidth > m) m = measurer.implicitWidth;
        }
        measurer.text = root.icon;   // restore so binding stays sensible
        maxGlyphWidth = m;
    }

    Component.onCompleted: recomputeWidth()
    onGlyphsChanged: recomputeWidth()
    onFontSizeChanged: recomputeWidth()

    Text {
        id: measurer
        visible: false
        font.pixelSize: root.fontSize
        font.family: Theme.fontFamilyIcons
        font.weight: root.weight
        text: root.icon   // initial value before recomputeWidth runs
    }

    Text {
        anchors.centerIn: parent
        font.pixelSize: root.fontSize
        font.family: Theme.fontFamilyIcons
        font.weight: root.weight
        color: root.iconColor
        text: root.icon
    }
}
