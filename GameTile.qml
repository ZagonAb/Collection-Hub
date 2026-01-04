import QtQuick 2.0

Rectangle {
    id: tile
    color: "#2c2c2c"
    radius: vpx(10)
    border.color: inCollection ? "#4CAF50" : "#444"
    border.width: vpx(2)

    property var gameData
    property bool showCollectionsInfo: false
    property bool isGameInUserCollection: false

    signal rightClicked(var gameData, real x, real y)

    property bool isHovered: false

    Column {
        anchors.fill: parent
        anchors.margins: vpx(12)
        spacing: vpx(8)

        Rectangle {
            width: parent.width
            height: parent.height * 0.65
            color: "#1a1a1a"
            radius: vpx(8)
            clip: true
            border.color: "#555"
            border.width: vpx(1)

            Image {
                anchors.fill: parent
                anchors.margins: vpx(3)
                source: gameData.assets.boxFront || ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true

                Rectangle {
                    anchors.fill: parent
                    color: "#333"
                    visible: parent.status !== Image.Ready
                    radius: vpx(5)

                    Text {
                        anchors.centerIn: parent
                        text: "🎮"
                        font.pixelSize: vpx(50)
                        color: "#555"
                    }
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: vpx(8)
                width: vpx(35)
                height: vpx(35)
                radius: vpx(18)
                color: gameData.favorite ? "#FFD700" : "transparent"
                border.color: "#FFD700"
                border.width: vpx(2)
                visible: gameData.favorite

                Text {
                    anchors.centerIn: parent
                    text: "★"
                    color: "#000"
                    font.bold: true
                    font.pixelSize: vpx(18)
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "#40FFFFFF"
                radius: vpx(8)
                visible: tile.isHovered

                Text {
                    anchors.centerIn: parent
                    text: "▶"
                    font.pixelSize: vpx(50)
                    color: "white"
                    font.bold: true
                }
            }
        }

        Text {
            width: parent.width
            text: gameData.title
            color: "white"
            font.pixelSize: vpx(13)
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            id: textGameInfo
            width: parent.width
            height: showCollectionsInfo && collectionsText.text !== "" ? vpx(20) : 0
            color: "transparent"
            visible: showCollectionsInfo && collectionsText.text !== ""

            Text {
                id: collectionsText
                anchors.centerIn: parent
                width: parent.width
                text: {
                    if (!gameData.collections || gameData.collections.count === 0) {
                        return "";
                    }

                    var collectionNames = [];
                    var maxCollections = 2;

                    for (var i = 0; i < Math.min(gameData.collections.count, maxCollections); i++) {
                        var collection = gameData.collections.get(i);
                        if (collection && collection.shortName) {
                            collectionNames.push(collection.shortName);
                        } else if (collection && collection.name) {
                            var name = collection.name;
                            var words = name.split(' ');
                            if (words.length > 2) {
                                name = words.slice(0, 2).join(' ');
                            }
                            collectionNames.push(name);
                        }
                    }

                    if (gameData.collections.count > maxCollections) {
                        return collectionNames.join(", ") + " (+" + (gameData.collections.count - maxCollections) + ")";
                    } else {
                        return collectionNames.join(", ");
                    }
                }
                color: "#AAA"
                font.pixelSize: vpx(11)
                wrapMode: Text.Wrap
                maximumLineCount: 1
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    MouseArea {
        id: tileMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            tile.isHovered = true;
            tile.scale = 1.05;
        }

        onExited: {
            tile.isHovered = false;
            tile.scale = 1.0;
        }

        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                tile.rightClicked(gameData, mouse.x, mouse.y);
            } else if (mouse.button === Qt.LeftButton) {
                Utils.launchGameFromCollection(gameData.title);
            }
        }

        onPressAndHold: {
            tile.rightClicked(gameData, width/2, height/2);
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }
    }
}
