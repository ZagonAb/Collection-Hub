// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: notification
    anchors.fill: parent
    z: 1100
    visible: false
    opacity: 0
    focus: visible

    property var themeColors: ({})
    property bool isDarkTheme: true
    property var soundManager: null

    property string latestVersion: ""
    property string releaseUrl: ""
    property string releaseNotes: ""
    property bool expanded: false
    property int currentButton: 0

    function show(version, url, notes) {
        latestVersion = version;
        releaseUrl = url || "";
        releaseNotes = notes || "";
        expanded = false;
        currentButton = 0;
        visible = true;
        opacity = 1;
        if (notification.soundManager) notification.soundManager.playOk();
        notification.forceActiveFocus();
    }

    function hide() {
        opacity = 0;
        visible = false;
        if (notification.soundManager) notification.soundManager.playBack();
    }

    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.65

        MouseArea {
            anchors.fill: parent
            onClicked: notification.hide()
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.85, vpx(480))
        height: column.height + vpx(36)
        radius: vpx(15)
        color: notification.themeColors.panel || "#111111"
        border.color: notification.themeColors.primary || "#2d5c8f"
        border.width: vpx(2)

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutQuad }
        }

        Column {
            id: column
            anchors.centerIn: parent
            width: parent.width - vpx(36)
            spacing: vpx(14)

            Text {
                width: parent.width
                text: "✨ New update available"
                color: notification.themeColors.primaryHover || "#4677ad"
                font.pixelSize: vpx(24)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                width: parent.width
                text: "Collection Hub " + notification.latestVersion + " is now available."
                color: notification.themeColors.text || "#ffffff"
                font.pixelSize: vpx(18)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: vpx(12)

                Rectangle {
                    id: viewButton
                    width: vpx(130)
                    height: vpx(42)
                    radius: vpx(10)
                    color: notification.themeColors.primary || "#2d5c8f"
                    border.color: notification.currentButton === 0 ? "#ffffff" : "transparent"
                    border.width: notification.currentButton === 0 ? vpx(2) : 0
                    scale: notification.currentButton === 0 ? 1.05 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: notification.expanded ? "Hide changes" : "View changes"
                        color: "#ffffff"
                        font.pixelSize: vpx(16)
                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: notification.currentButton = 0
                        onClicked: {
                            if (notification.soundManager) notification.soundManager.playNav();
                            notification.expanded = !notification.expanded;
                        }
                    }
                }

                Rectangle {
                    id: openButton
                    width: vpx(150)
                    height: vpx(42)
                    radius: vpx(10)
                    color: notification.isDarkTheme ? "#1c1c1c" : "#e0e0e0"
                    border.color: notification.currentButton === 1
                        ? (notification.themeColors.primaryHover || "#4677ad")
                        : "transparent"
                    border.width: notification.currentButton === 1 ? vpx(2) : 0
                    scale: notification.currentButton === 1 ? 1.05 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Open on GitHub"
                        color: notification.themeColors.text || "#ffffff"
                        font.pixelSize: vpx(16)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: notification.currentButton = 1
                        onClicked: {
                            if (notification.soundManager) notification.soundManager.playNav();
                            if (notification.releaseUrl) Qt.openUrlExternally(notification.releaseUrl);
                            notification.hide();
                        }
                    }
                }

                Rectangle {
                    id: closeButton
                    width: vpx(110)
                    height: vpx(42)
                    radius: vpx(10)
                    color: notification.isDarkTheme ? "#1c1c1c" : "#e0e0e0"
                    border.color: notification.currentButton === 2
                        ? (notification.themeColors.primaryHover || "#4677ad")
                        : "transparent"
                    border.width: notification.currentButton === 2 ? vpx(2) : 0
                    scale: notification.currentButton === 2 ? 1.05 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on border.color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Close"
                        color: notification.themeColors.text || "#ffffff"
                        font.pixelSize: vpx(16)
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: notification.currentButton = 2
                        onClicked: notification.hide()
                    }
                }
            }

            Text {
                width: parent.width
                visible: notification.expanded && notification.releaseNotes.length > 0
                text: notification.releaseNotes
                color: notification.themeColors.textSecondary || "#b0b0b0"
                font.pixelSize: vpx(15)
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Keys.onPressed: function(event) {
        if (api.keys.isCancel(event)) {
            event.accepted = true;
            notification.hide();
        } else if (api.keys.isAccept(event)) {
            event.accepted = true;
            if (notification.currentButton === 0) {
                if (notification.soundManager) notification.soundManager.playNav();
                notification.expanded = !notification.expanded;
            } else if (notification.currentButton === 1) {
                if (notification.releaseUrl) Qt.openUrlExternally(notification.releaseUrl);
                notification.hide();
            } else {
                notification.hide();
            }
        } else if (event.key === Qt.Key_Left) {
            event.accepted = true;
            if (notification.currentButton > 0) {
                if (notification.soundManager) notification.soundManager.playNav();
                notification.currentButton -= 1;
            }
        } else if (event.key === Qt.Key_Right) {
            event.accepted = true;
            if (notification.currentButton < 2) {
                if (notification.soundManager) notification.soundManager.playNav();
                notification.currentButton += 1;
            }
        }
    }
}
