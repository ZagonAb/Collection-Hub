import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

FocusScope {
    id: root

    property var gameData
    property var detailColors: ({})
    property bool isDarkTheme: true

    signal close()
    signal launchRequested()
    signal favoriteToggled()

    property int currentButton: 0

    anchors.fill: parent
    focus: true

    Component.onCompleted: {
        currentButton = 0
        forceActiveFocus()
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Left) {
            currentButton = Math.max(0, currentButton - 1)
            event.accepted = true

        } else if (event.key === Qt.Key_Right) {
            currentButton = Math.min(2, currentButton + 1)
            event.accepted = true

        } else if (!event.isAutoRepeat && api.keys.isAccept(event)) {
            if (currentButton === 0) {
                root.launchRequested()
            } else if (currentButton === 1) {
                root.favoriteToggled()
            } else if (currentButton === 2) {
                root.close()
            }
            event.accepted = true

        } else if (api.keys.isCancel(event)) {
            root.close()
            event.accepted = true
        }
    }

    Item {
        id: blurredBackground
        anchors.fill: parent
        z: 0
        clip: true

        Image {
            id: bgImage
            anchors.fill: parent
            source: root.gameData && root.gameData.assets
                    ? (root.gameData.assets.boxFront || "")
                    : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: source !== "" && status === Image.Ready

            layer.enabled: true
            layer.effect: FastBlur {
                radius: 80
            }
            scale: 7.5
        }

        Rectangle {
            anchors.fill: parent
            color: root.detailColors.background || "#151519"
            visible: bgImage.source === "" || bgImage.status !== Image.Ready
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#AA000000"
        z: 1
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: vpx(52)
        z: 2

        Item {
            id: boxArtContainer
            width: vpx(405)
            height: vpx(505)
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: boxArt
                anchors.fill: parent
                source: root.gameData && root.gameData.assets
                        ? (root.gameData.assets.boxFront || "")
                        : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: source !== "" && status === Image.Ready
            }

            Rectangle {
                id: fallbackContainer
                anchors.fill: parent
                color: root.detailColors.tileImageBg || "#0f0f0f"
                radius: vpx(14)
                visible: boxArt.source === "" || boxArt.status !== Image.Ready

                Item {
                    id: fallbackIconContainer
                    anchors.centerIn: parent
                    width: vpx(100)
                    height: vpx(100)
                    visible: fallbackImage.source !== ""

                    Image {
                        id: fallbackImage
                        anchors.fill: parent
                        source: {
                            if (root.gameData && root.gameData.collections && root.gameData.collections.count > 0) {
                                var firstColl = root.gameData.collections.get(0);
                                var shortName = firstColl.shortName || firstColl.name;
                                if (shortName) {
                                    return "assets/systems/" + shortName.toLowerCase() + ".png";
                                }
                            }
                            return "";
                        }
                        fillMode: Image.PreserveAspectFit
                        visible: source !== "" && status === Image.Ready
                        mipmap: true
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "?"
                    font.pixelSize: vpx(72)
                    color: "#ffffff"
                    visible: !fallbackIconContainer.visible
                }
            }
        }

        Column {
            width: vpx(360)
            anchors.verticalCenter: parent.verticalCenter
            spacing: vpx(12)

            Text {
                width: parent.width
                text: root.gameData ? root.gameData.title : ""
                color: "#ffffff"
                font.pixelSize: vpx(32)
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.gameData && root.gameData.developer
                      ? root.gameData.developer
                      : "Unknown"
                color: "#ffffff"
                font.pixelSize: vpx(16)
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                text: "Last played: " + (root.gameData && root.gameData.lastPlayed &&
                                         !isNaN(root.gameData.lastPlayed.getTime())
                                         ? root.gameData.lastPlayed.toLocaleDateString()
                                         : "Never")
                color: "#cccccc"
                font.pixelSize: vpx(14)
            }

            Text {
                visible: root.gameData && root.gameData.playTime > 0
                text: "Play time: " + Utils.formatPlayTime(root.gameData ? root.gameData.playTime : 0)
                color: "#cccccc"
                font.pixelSize: vpx(14)
            }

            Row {
                spacing: vpx(10)
                topPadding: vpx(8)

                Item {
                    width: vpx(136)
                    height: vpx(46)

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + vpx(6)
                        height: parent.height + vpx(6)
                        radius: vpx(26)
                        color: "transparent"
                        border.color: "#ffffff"
                        border.width: vpx(2)
                        opacity: root.currentButton === 0 ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: launchMouse.containsMouse ? "#e8e8e8" : "#ffffff"
                        radius: vpx(23)

                        scale: root.currentButton === 0 ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation  { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Play"
                            color: "#111111"
                            font.pixelSize: vpx(16)
                            font.bold: true
                        }

                        MouseArea {
                            id: launchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.currentButton = 0
                            onClicked: root.launchRequested()
                        }
                    }
                }

                Rectangle {
                    width: vpx(46)
                    height: vpx(46)
                    color: favMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: root.currentButton === 1 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 1 ? vpx(2) : vpx(1)

                    scale: root.currentButton === 1 ? 1.08 : 1.0
                    Behavior on scale        { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color        { ColorAnimation  { duration: 120 } }
                    Behavior on border.color { ColorAnimation  { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(22)
                        height: vpx(22)

                        Image {
                            id: favIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: root.gameData && root.gameData.favorite
                                    ? "assets/icons/favorite-on.svg"
                                    : "assets/icons/favorite-off.svg"
                            mipmap: true
                        }
                    }

                    MouseArea {
                        id: favMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentButton = 1
                        onClicked: root.favoriteToggled()
                    }
                }

                Rectangle {
                    width: vpx(46)
                    height: vpx(46)
                    color: backMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: root.currentButton === 2 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 2 ? vpx(2) : vpx(1)

                    scale: root.currentButton === 2 ? 1.08 : 1.0
                    Behavior on scale        { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color        { ColorAnimation  { duration: 120 } }
                    Behavior on border.color { ColorAnimation  { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(22)
                        height: vpx(22)

                        Image {
                            id: backIcon
                            anchors.fill: parent
                            source: "assets/icons/back.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: backIcon
                            source: backIcon
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentButton = 2
                        onClicked: root.close()
                    }
                }
            }
        }
    }
}
