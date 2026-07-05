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
    id: root

    property var gameData
    property var themeColors: ({})
    property bool isDarkTheme: true
    property var soundManager: null

    signal closeRequested()

    anchors.fill: parent
    focus: true
    opacity: 0

    Component.onCompleted: {
        forceActiveFocus()
            fadeIn.start()
    }

    NumberAnimation { id: fadeIn; target: root; property: "opacity"; from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }

    function dismiss() { fadeOut.start() }

    SequentialAnimation {
        id: fadeOut
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 160; easing.type: Easing.InCubic }
        ScriptAction { script: root.closeRequested() }
    }

    Keys.onPressed: function(event) {
        if (api.keys.isCancel(event) || api.keys.isDetails(event)) {
            if (soundManager) soundManager.playBack();
            root.dismiss()
            event.accepted = true
        } else if (event.key === Qt.Key_Up) {
            if (soundManager) soundManager.playNav();
            flick.contentY = Math.max(0, flick.contentY - vpx(100))
            event.accepted = true
        } else if (event.key === Qt.Key_Down) {
            if (soundManager) soundManager.playNav();
            flick.contentY = Math.min(Math.max(0, flick.contentHeight - flick.height), flick.contentY + vpx(100))
            event.accepted = true
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#80000000"
    }

    Rectangle {
        id: closeBtn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: vpx(16)
        anchors.rightMargin: vpx(16)
        width: vpx(42)
        height: vpx(42)
        radius: vpx(8)
        color: closeBtnMouse.containsMouse ? "#33ffffff" : "#22000000"
        border.color: "#55ffffff"
        border.width: vpx(1)
        z: 10
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "\xd7"
            color: "#ffffff"
            font.pixelSize: vpx(24)
            font.bold: true
        }

        MouseArea {
            id: closeBtnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (soundManager) soundManager.playBack();
                root.dismiss()
            }
        }
    }

    Flickable {
        id: flick
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            topMargin: parent.height * 0.05
            bottomMargin: parent.height * 0.05
            leftMargin: parent.width * 0.05
            rightMargin: parent.width * 0.05
        }
        contentWidth: width
        contentHeight: col.height
        clip: true
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        Rectangle {
            anchors.right: parent.right
            y: flick.visibleArea.yPosition * flick.height
            width: vpx(3)
            height: flick.visibleArea.heightRatio * flick.height
            radius: vpx(2)
            color: "#44ffffff"
            visible: flick.visibleArea.heightRatio < 1.0
        }

        Column {
            id: col
            width: parent.width
            spacing: 0

            Item {
                width: parent.width
                height: titleBlock.height + vpx(48)

                Column {
                    id: titleBlock
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    spacing: vpx(16)

                    Text {
                        width: parent.width
                        text: root.gameData ? root.gameData.title : ""
                        color: "#ffffff"
                        font.pixelSize: vpx(54)
                        font.bold: true
                        wrapMode: Text.WordWrap
                        lineHeight: 1.05
                    }

                    Row {
                        spacing: vpx(20)
                        visible: (root.gameData && root.gameData.genre !== "") ||
                        (root.gameData && root.gameData.releaseYear > 0)

                        Text {
                            visible: root.gameData && root.gameData.genre !== ""
                            text: root.gameData ? root.gameData.genre : ""
                            color: root.themeColors.primary || "#3a6ea5"
                            font.pixelSize: vpx(22)
                            font.bold: true
                        }

                        Text {
                            visible: root.gameData && root.gameData.genre !== "" && root.gameData.releaseYear > 0
                            text: "·"
                            color: "#444444"
                            font.pixelSize: vpx(22)
                        }

                        Text {
                            visible: root.gameData && root.gameData.releaseYear > 0
                            text: root.gameData ? root.gameData.releaseYear.toString() : ""
                            color: "#666666"
                            font.pixelSize: vpx(22)
                        }
                    }
                }
            }

            Rectangle { width: parent.width; height: vpx(1); color: "#1effffff" }

            Item { width: 1; height: vpx(48) }

            Row {
                width: parent.width
                spacing: vpx(48)

                Column {
                    width: (parent.width - vpx(48)) / 2
                    spacing: 0

                    SectionLabel { text: "DETAILS" }
                    Item { width: 1; height: vpx(20) }

                    BigRow { label: "Developer";   value: root.gameData && root.gameData.developer  ? root.gameData.developer  : "—" }
                    BigRow { label: "Publisher";   value: root.gameData && root.gameData.publisher  ? root.gameData.publisher  : "—" }
                    BigRow {
                        label: "Release"
                        value: {
                            if (!root.gameData) return "—"
                                var y = root.gameData.releaseYear
                                var m = root.gameData.releaseMonth
                                var d = root.gameData.releaseDay
                                if (y > 0 && m > 0 && d > 0) return d + "/" + m + "/" + y
                                    if (y > 0 && m > 0)           return m + "/" + y
                                        if (y > 0)                     return y.toString()
                                            return "—"
                        }
                    }
                    BigRow { label: "Players";     value: root.gameData && root.gameData.players > 0 ? root.gameData.players.toString() : "1" }
                    BigRow {
                        label: "Rating"
                        value: root.gameData && root.gameData.rating > 0 ? Math.round(root.gameData.rating * 100) + "%" : "—"
                    }
                    BigRow {
                        label: "Collection(s)"
                        value: {
                            if (!root.gameData || !root.gameData.collections) return "—"
                                var names = []
                                for (var i = 0; i < root.gameData.collections.count; i++)
                                    names.push(root.gameData.collections.get(i).name)
                                    return names.length > 0 ? names.join(", ") : "—"
                        }
                    }
                    BigRow {
                        label: "Tags"
                        value: root.gameData && root.gameData.tagList && root.gameData.tagList.length > 0
                        ? root.gameData.tagList.join(", ") : "—"
                    }
                }

                Rectangle {
                    width: vpx(1)
                    height: parent.height
                    color: "#1effffff"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    width: (parent.width - vpx(48)) / 2 - vpx(1)
                    spacing: 0

                    SectionLabel { text: "PLAY STATS" }
                    Item { width: 1; height: vpx(20) }

                    BigRow {
                        label: "Play Count"
                        value: root.gameData
                        ? root.gameData.playCount + (root.gameData.playCount === 1 ? " time" : " times")
                        : "—"
                    }
                    BigRow {
                        label: "Last Played"
                        value: root.gameData && root.gameData.lastPlayed && !isNaN(root.gameData.lastPlayed.getTime())
                        ? root.gameData.lastPlayed.toLocaleDateString() : "Never"
                    }
                    BigRow {
                        label: "Play Time"
                        value: {
                            if (!root.gameData || root.gameData.playTime <= 0) return "—"
                                var s = root.gameData.playTime
                                var h = Math.floor(s / 3600)
                                var m = Math.floor((s % 3600) / 60)
                                var sec = s % 60
                                if (h > 0) return h + "h " + m + "m"
                                    if (m > 0) return m + "m " + sec + "s"
                                        return sec + "s"
                        }
                    }
                    BigRow {
                        label: "Favorite"
                        value: root.gameData && root.gameData.favorite ? "Yes  ♥" : "No"
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 0
                visible: root.gameData && root.gameData.summary && root.gameData.summary !== ""

                Item { width: 1; height: vpx(52) }
                Rectangle { width: parent.width; height: vpx(1); color: "#1effffff" }
                Item { width: 1; height: vpx(40) }

                SectionLabel { text: "SUMMARY" }
                Item { width: 1; height: vpx(16) }

                Text {
                    width: parent.width
                    text: root.gameData ? root.gameData.summary : ""
                    color: "#bbbbbb"
                    font.pixelSize: vpx(16)
                    wrapMode: Text.WordWrap
                    lineHeight: 1.7
                }
            }

            Column {
                width: parent.width
                spacing: 0
                visible: root.gameData && root.gameData.description && root.gameData.description !== ""

                Item { width: 1; height: vpx(52) }
                Rectangle { width: parent.width; height: vpx(1); color: "#1effffff" }
                Item { width: 1; height: vpx(40) }

                SectionLabel { text: "DESCRIPTION" }
                Item { width: 1; height: vpx(16) }

                Text {
                    width: parent.width
                    text: root.gameData ? root.gameData.description : ""
                    color: "#bbbbbb"
                    font.pixelSize: vpx(24)
                    wrapMode: Text.WordWrap
                    lineHeight: 1.7
                }
            }

            Item { width: 1; height: vpx(52) }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: vpx(8)

                Rectangle {
                    width: vpx(24); height: vpx(24)
                    radius: vpx(6)
                    color: "#1affffff"
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        anchors.centerIn: parent
                        text: "B"
                        color: "#666666"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }
                }
                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Back"
                    color: "#444444"
                    font.pixelSize: vpx(13)
                }
            }

            Item { width: 1; height: vpx(32) }
        }
    }

    component SectionLabel: Text {
        width: parent ? parent.width : 0
        color: "#444444"
        font.pixelSize: vpx(16)
        font.bold: true
        font.letterSpacing: 2.0
    }

    component BigRow: Item {
        property string label: ""
        property string value: ""
        width: parent ? parent.width : 0
        height: Math.max(vpx(52), valueT.implicitHeight + vpx(20))

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: vpx(1)
            color: "#0fffffff"
        }

        Text {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: label
            color: "#555555"
            font.pixelSize: vpx(18)
            width: vpx(130)
        }

        Text {
            id: valueT
            anchors.left: parent.left
            anchors.leftMargin: vpx(130)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: value
            color: "#eeeeee"
            font.pixelSize: vpx(22)
            font.bold: true
            wrapMode: Text.WordWrap
        }
    }
}
