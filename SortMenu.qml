import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: sortMenu

    property var themeColors: ({})
    property bool isDarkTheme: true
    property int currentSort: 0
    property int highlightIndex: 0

    signal sortSelected(int sortIndex)
    signal closeMenu()
    signal sortOrderChangedOnly(int sortIndex)

    width: vpx(200)
    height: bubble.height + tail.height
    visible: false

    onVisibleChanged: {
        if (visible) {
            highlightIndex = currentSort;
            forceActiveFocus();
        }
    }

    focus: true

    Keys.onPressed: function(event) {
        if (api.keys.isCancel(event)) {
            sortMenu.closeMenu();
            event.accepted = true;
        } else if (api.keys.isAccept(event)) {
            sortMenu.sortOrderChangedOnly(highlightIndex);
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            highlightIndex = Math.max(0, highlightIndex - 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            highlightIndex = Math.min(4, highlightIndex + 1);
            event.accepted = true;
        }
    }

    Canvas {
        id: tail
        width: vpx(16)
        height: vpx(10)
        anchors.right: parent.right
        anchors.rightMargin: vpx(12)
        anchors.top: parent.top
        z: 2

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var bg = sortMenu.isDarkTheme ? "#28282c" : "#f2f2f4";
            ctx.fillStyle = bg;
            ctx.beginPath();
            ctx.moveTo(width, height);
            ctx.lineTo(width / 2, 0);
            ctx.lineTo(0, height);
            ctx.closePath();
            ctx.fill();
        }

        Connections {
            target: sortMenu
            function onIsDarkThemeChanged() { tail.requestPaint(); }
        }
    }

    Rectangle {
        id: bubble
        anchors.top: tail.bottom
        anchors.topMargin: vpx(-1)
        width: parent.width
        height: titleRow.height + optionsList.height + vpx(24)
        color: isDarkTheme ? "#28282c" : "#f2f2f4"
        radius: vpx(10)

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: vpx(4)
            radius: vpx(12)
            samples: 17
            color: "#88000000"
        }

        Row {
            id: titleRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: vpx(12)
            height: vpx(36)
            spacing: vpx(6)

            Text {
                text: "Sort by"
                color: isDarkTheme ? "#ffffff" : "#212121"
                font.pixelSize: vpx(13)
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            anchors.top: titleRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: vpx(12)
            anchors.rightMargin: vpx(12)
            height: vpx(1)
            color: isDarkTheme ? "#3a3a3e" : "#e0e0e0"
        }

        Column {
            id: optionsList
            anchors.top: titleRow.bottom
            anchors.topMargin: vpx(4)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: vpx(8)
            anchors.rightMargin: vpx(8)

            Repeater {
                model: [
                    { label: "A-Z",          icon: "↑" },
                    { label: "Z-A",          icon: "↓" },
                    { label: "Last played",  icon: "🕐" },
                    { label: "Most played",  icon: "🏆" },
                    { label: "Favorites",    icon: "★" }
                ]

                delegate: Rectangle {
                    width: parent.width
                    height: vpx(34)
                    color: {
                        if (sortMenu.activeFocus && sortMenu.highlightIndex === index)
                            return (isDarkTheme ? "#4a4a5e" : "#c0c8ff");
                            if (optionMouse.containsMouse)
                                return (isDarkTheme ? "#3a3a3e" : "#e8e8f0");
                                if (sortMenu.currentSort === index)
                                    return (isDarkTheme ? "#333366" : "#d0d8ff");
                                    return "transparent";
                    }
                    radius: vpx(6)

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(8)
                        spacing: vpx(10)

                        Rectangle {
                            width: vpx(14)
                            height: vpx(14)
                            radius: vpx(7)
                            anchors.verticalCenter: parent.verticalCenter
                            color: "transparent"
                            border.color: sortMenu.currentSort === index
                                ? (isDarkTheme ? "#5a8ec5" : "#2196F3")
                                : (isDarkTheme ? "#606060" : "#aaaaaa")
                            border.width: vpx(2)

                            Rectangle {
                                anchors.centerIn: parent
                                width: vpx(6)
                                height: vpx(6)
                                radius: vpx(3)
                                color: isDarkTheme ? "#5a8ec5" : "#2196F3"
                                visible: sortMenu.currentSort === index
                            }
                        }

                        Text {
                            text: modelData.label
                            color: sortMenu.currentSort === index
                                ? (isDarkTheme ? "#ffffff" : "#212121")
                                : (isDarkTheme ? "#c0c0c0" : "#616161")
                            font.pixelSize: vpx(12)
                            font.bold: sortMenu.currentSort === index
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: optionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            sortMenu.highlightIndex = index;
                            sortMenu.sortSelected(index);
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: sortMenu.parent
        function onWidthChanged() {}
    }
}
