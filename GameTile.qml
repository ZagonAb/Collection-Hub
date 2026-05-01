import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: tile
    color: tileColors.tileBg
    radius: vpx(10)

    property bool isCurrent: GridView.isCurrentItem
    property bool gridHasFocus: GridView.view ? GridView.view.activeFocus : false
    property bool isSelected: false

    onIsCurrentChanged: {
        if (isCurrent) {
            tile.scale = 1.05;
        } else {
            tile.scale = 1.0;
            tile.isSelected = false;
        }
    }

    border.width: vpx(2)
    border.color: (isCurrent && (gridHasFocus || isSelected)) ? tileColors.primary :
    (isDarkMode ? "transparent" : tileColors.tileBorder || "#e0e0e0")

    property var gameData
    property bool showCollectionsInfo: false
    property bool isGameInUserCollection: false
    property var tileColors: ({})
    property bool isDarkMode: true
    property bool isHovered: tileMouseArea.containsMouse || isCurrent

    signal rightClicked(var gameData, real x, real y)

    RadialGradient {
        anchors.fill: parent
        horizontalOffset: parent.width * 0.5
        verticalOffset: parent.height * 0.5
        visible: isDarkMode
        gradient: Gradient {
            GradientStop { position: 0.0; color: isDarkMode ? "#20ffffff" : "#15ffffff" }
            GradientStop { position: 0.5; color: isDarkMode ? "#08ffffff" : "#05ffffff" }
            GradientStop { position: 1.0; color: "transparent" }
        }
        z: 0

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: tile.width
                height: tile.height
                radius: vpx(10)
            }
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: vpx(12)
        spacing: vpx(8)
        z: 2

        Rectangle {
            id: imageContainer
            width: parent.width
            height: parent.height * 0.80
            color: tileColors.tileImageBg
            radius: vpx(8)
            clip: true

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

                Item {
                    id: defaultIconContainer
                    anchors.centerIn: parent
                    width: vpx(86)
                    height: vpx(86)
                    visible: gameImage.source === "" || gameImage.status !== Image.Ready

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

                    Item {
                        anchors.fill: parent
                        visible: !systemFallbackIcon.visible

                        Image {
                            id: defaultGameIcon
                            anchors.fill: parent
                            source: "assets/icons/allgames.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true

                            Rectangle {
                                anchors.fill: parent
                                color: "transparent"
                                visible: parent.status !== Image.Ready

                                Text {
                                    anchors.centerIn: parent
                                    text: "🎮"
                                    font.pixelSize: vpx(30)
                                    color: tileColors.inputBorder
                                }
                            }
                        }

                        ColorOverlay {
                            anchors.fill: defaultGameIcon
                            source: defaultGameIcon
                            color: tile.isDarkMode ? "white" : "#212121"
                        }
                    }
                }
            }

            Rectangle {
                id: glassMask
                anchors.fill: parent
                radius: vpx(8)
                visible: false
            }

            Item {
                id: glassEffect
                anchors.fill: parent
                visible: tile.isHovered

                LinearGradient {
                    id: diagonalReflection
                    anchors.fill: parent
                    start: Qt.point(0, 0)
                    end: Qt.point(parent.width, parent.height)
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#60ffffff" }
                        GradientStop { position: 0.4; color: "#25ffffff" }
                        GradientStop { position: 0.7; color: "#08ffffff" }
                        GradientStop { position: 1.0; color: "transparent" }
                    }

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: glassMask
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(8)
                    color: "transparent"
                    border.color: "#40ffffff"
                    border.width: vpx(1.5)
                    opacity: 0.6
                }
            }

            Item {
                anchors.fill: parent
                visible: tile.isHovered

                Rectangle {
                    anchors.fill: parent
                    color: "#50000000"

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: glassMask
                    }
                }
            }
        }

        Text {
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
                color: tileColors.textSecondary
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
        z: 3

        onEntered: {
            if (!tile.isCurrent) {
                tile.scale = 1.02;
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
