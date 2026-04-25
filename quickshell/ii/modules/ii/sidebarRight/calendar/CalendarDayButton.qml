import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic

RippleButton {
    id: button
    property string day
    property int isToday
    property bool bold
    property string holidayName: ""

    Layout.fillWidth: false
    Layout.fillHeight: false
    implicitWidth: 38;
    implicitHeight: 38;

    toggled: (isToday == 1)
    buttonRadius: Appearance.rounding.small

    contentItem: Item {
        anchors.fill: parent

        StyledText {
            anchors.centerIn: parent
            text: day
            horizontalAlignment: Text.AlignHCenter
            font.weight: bold ? Font.DemiBold : Font.Normal
            color: (isToday == 1) ? Appearance.m3colors.m3onPrimary :
                (isToday == -1) ? Appearance.colors.colOutlineVariant :
                holidayName.length > 0 ? Appearance.colors.colPrimary :
                Appearance.colors.colOnLayer1

            Behavior on color {
                animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
            }
        }

        // Holiday dot
        Rectangle {
            visible: holidayName.length > 0 && isToday !== 1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            width: 4; height: 4; radius: 2
            color: Appearance.colors.colPrimary
        }
    }

    HoverHandler { id: hoverHandler }

    ToolTip {
        visible: hoverHandler.hovered && holidayName.length > 0
        text: holidayName
        delay: 400
    }
}
