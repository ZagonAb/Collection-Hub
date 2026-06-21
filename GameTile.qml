import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: tile
    color: "transparent"
    radius: vpx(15)

    property bool isCurrent: GridView.isCurrentItem
    property bool gridHasFocus: GridView.view ? GridView.view.activeFocus : false
    property bool isSelected: false
    property color selectedBorderColor: tileColors.primary

    onIsCurrentChanged: {
        if (isCurrent) {
            tile.scale = 1.02;
        } else {
            tile.scale = 1.0;
            tile.isSelected = false;
        }
    }

    border.width: vpx(5)
    border.color: (isCurrent && (gridHasFocus || isSelected)) ? selectedBorderColor :
    (isDarkMode ? "transparent" : tileColors.tileBorder || "#e0e0e0")

    property var gameData
    property bool showCollectionsInfo: false
    property bool isGameInUserCollection: false
    property var tileColors: ({})
    property bool isDarkMode: true
    property bool isHovered: tileMouseArea.containsMouse || isCurrent

    signal rightClicked(var gameData, real x, real y)
    signal showDetailRequested(var gameData)

    Column {
        anchors.fill: parent
        anchors.margins: vpx(5)
        spacing: vpx(0)
        z: 2

        Rectangle {
            id: imageContainer
            width: parent.width
            height: parent.height
            color: tileColors.tileImageBg
            radius: vpx(10)
            clip: true

            Rectangle {
                id: bgBlurMask
                anchors.fill: parent
                radius: vpx(10)
                visible: false
            }

            Item {
                id: bgBlurContainer
                anchors.fill: parent
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: bgBlurMask
                }

                Image {
                    id: bgBlurImage
                    anchors.fill: parent
                    source: gameData.assets.boxFront || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    visible: source !== "" && status === Image.Ready
                    scale: 7.5

                    layer.enabled: true
                    layer.effect: FastBlur {
                        radius: 48
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#55000000"
                    visible: bgBlurImage.visible
                }
            }

            Rectangle {
                id: playTimeBadge
                anchors.bottom: parent.bottom
                anchors.right: fvImage.visible ? fvImage.left : (textGameInfo.visible ? textGameInfo.left : parent.right)
                anchors.rightMargin: fvImage.visible ? vpx(4) : (textGameInfo.visible ? vpx(4) : vpx(6))
                anchors.bottomMargin: vpx(6)
                width: playTimeText.contentWidth + vpx(10)
                height: vpx(20)
                color: "#AA000000"
                radius: vpx(4)
                visible: gameData.playTime > 0
                z: 3

                Behavior on anchors.rightMargin { NumberAnimation { duration: 150 } }

                Text {
                    id: playTimeText
                    anchors.centerIn: parent
                    text: Utils.formatPlayTime(gameData.playTime)
                    color: "white"
                    font.pixelSize: vpx(11)
                }
            }

            Rectangle {
                id: playCountBadge
                anchors.bottom: parent.bottom
                anchors.right: playTimeBadge.visible ? playTimeBadge.left : (fvImage.visible ? fvImage.left : (textGameInfo.visible ? textGameInfo.left : parent.right))
                anchors.rightMargin: playTimeBadge.visible ? vpx(4) : (fvImage.visible ? vpx(4) : (textGameInfo.visible ? vpx(4) : vpx(6)))
                anchors.bottomMargin: vpx(6)
                width: playCountText.contentWidth + vpx(10)
                height: vpx(20)
                color: "#AA000000"
                radius: vpx(4)
                visible: gameData.playCount > 0
                z: 3

                Behavior on anchors.rightMargin { NumberAnimation { duration: 150 } }

                Text {
                    id: playCountText
                    anchors.centerIn: parent
                    text: "\u25b6 " + gameData.playCount
                    color: "white"
                    font.pixelSize: vpx(11)
                }
            }

            Rectangle {
                id: fvImage
                anchors.bottom: parent.bottom
                anchors.right:  textGameInfo.visible ? textGameInfo.left : parent.right
                anchors.rightMargin: textGameInfo.visible ? vpx(4) : vpx(6)
                anchors.bottomMargin: vpx(6)
                width: vpx(20)
                height: vpx(20)
                color: "#AA000000"
                radius: vpx(4)
                visible: gameData.favorite
                z: 3

                Behavior on anchors.rightMargin { NumberAnimation { duration: 150 } }

                Item {
                    anchors.centerIn: parent
                    width: vpx(12)
                    height: vpx(12)

                    Image {
                        id: favIndicatorIcon
                        anchors.fill: parent
                        source: "assets/icons/favorite-on.svg"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }

                    ColorOverlay {
                        anchors.fill: favIndicatorIcon
                        source: favIndicatorIcon
                        color: "#ffffff"
                    }
                }
            }

            Rectangle {
                id: textGameInfo
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.margins: vpx(6)
                width: collectionsText.contentWidth + vpx(16)
                height: vpx(20)
                color: "#AA000000"
                radius: vpx(4)
                visible: showCollectionsInfo && collectionsText.text !== ""
                z: 3

                Text {
                    id: collectionsText
                    anchors.centerIn: parent
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
                    color: "white"
                    font.pixelSize: vpx(11)
                }
            }

            Item {
                anchors.fill: parent
                anchors.margins: vpx(3)

                Image {
                    id: gameImage
                    anchors.fill: parent
                    source: gameData.assets.boxFront || ""
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    smooth: true
                    visible: source !== "" && status === Image.Ready
                }

                Column {
                    anchors.centerIn: parent
                    spacing: vpx(8)
                    width: parent.width - vpx(10)
                    visible: gameImage.source === "" || gameImage.status !== Image.Ready

                    Item {
                        id: defaultIconContainer
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: vpx(86)
                        height: vpx(86)

                        Image {
                            id: systemFallbackIcon
                            anchors.fill: parent

                            source: {
                                if (gameData.collections && gameData.collections.count > 0) {
                                    var firstColl = gameData.collections.get(0);
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

                        ColorOverlay {
                            anchors.fill: systemFallbackIcon
                            source: systemFallbackIcon
                            visible: systemFallbackIcon.visible
                            color: tile.isDarkMode ? "white" : (tileColors.text || "#212121")
                        }
                    }

                    Text {
                        id: gameTitleText
                        width: parent.width
                        text: gameData.title
                        color: tileColors.text
                        font.pixelSize: vpx(13)
                        font.bold: true
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

    }


    MouseArea {
        id: tileMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 3

        onEntered: {
            if (!tile.isCurrent) {
                tile.scale = 1.01;
            }
        }

        onExited: {
            if (!tile.isCurrent) {
                tile.scale = 1.0;
            }
        }

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tile.isSelected = true;
                if (GridView.view) {
                    GridView.view.currentIndex = index;
                    GridView.view.forceActiveFocus();
                }
            } else if (mouse.button === Qt.RightButton) {
                tile.rightClicked(gameData, mouse.x, mouse.y);
            }
        }

        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                tile.showDetailRequested(gameData);
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
