import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: gameMenu

    width: parent.width * 0.15
    height: Math.min(menuColumn.height + vpx(25), parent.height * 0.8)

    property var themeColors: ({})
    property bool isDarkTheme: true
    property var currentGame: null
    property string gameTitle: currentGame ? currentGame.title : ""
    property int selectedCollectionId: -1
    property string selectedCollectionName: ""
    property var selectedSystemCollection: null
    property var customCollections: []
    property int menuX: 0
    property int menuY: 0

    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection()
    signal launchGame()
    signal closeMenu()

    property bool isInCurrentCollection: {
        if (selectedCollectionId === -1) return false;
        return Utils.isGameInCollection(selectedCollectionId, gameTitle);
    }

    color: root ? root.colors.menucolor || root.colors.panel || "#2c2c2c" : "#2c2c2c"
    border.color: themeColors.primary || "#3a6ea5"
    border.width: vpx(3)
    radius: vpx(12)
    z: 10

    onMenuXChanged: updatePosition()
    onMenuYChanged: updatePosition()

    function updatePosition() {
        if (parent) {
            x = Math.min(menuX, parent.width - width - vpx(10));
            y = Math.min(menuY, parent.height - height - vpx(10));
        }
    }

    RadialGradientOverlay {
        anchors.fill: parent
        isDarkTheme: gameMenu.isDarkTheme
        opacityMultiplier: 0.5
        radius: gameMenu.radius
        visible: gameMenu.isDarkTheme
    }

    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: vpx(10)
        spacing: vpx(6)

        Rectangle {
            width: parent.width
            height: vpx(35)
            color: "transparent"

            Text {
                anchors.fill: parent
                anchors.leftMargin: vpx(5)
                text: gameMenu.gameTitle
                color: themeColors.text || "white"
                font.bold: true
                font.pixelSize: vpx(13)
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
        }

        Rectangle {
            width: parent.width
            height: vpx(35)
            color: mouseLaunch.containsMouse ?
            themeColors.success || "#4CAF50" :
            "transparent"
            radius: vpx(5)
            border.color: mouseLaunch.containsMouse ?
            themeColors.successLight || "#66BB6A" :
            "transparent"
            border.width: vpx(1)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Text {
                    text: "▶"
                    color: mouseLaunch.containsMouse ? "white" : themeColors.text || "white"
                    font.pixelSize: vpx(14)
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Launch Game"
                    color: mouseLaunch.containsMouse ? "white" : themeColors.text || "white"
                    font.pixelSize: vpx(12)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseLaunch
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    gameMenu.launchGame();
                }
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        Column {
            width: parent.width
            spacing: vpx(4)
            visible: customCollections.length > 0

            Text {
                text: {
                    if (selectedCollectionId !== -1 && selectedSystemCollection === null) {
                        return "Collections:";
                    } else {
                        return "Add to Collection:";
                    }
                }
                color: themeColors.textSecondary || "#AAA"
                font.pixelSize: vpx(10)
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: vpx(5)
            }

            Rectangle {
                width: parent.width
                height: Math.min(customCollections.length * vpx(30), vpx(150))
                color: "transparent"

                ListView {
                    id: collectionsListView
                    anchors.fill: parent
                    model: customCollections
                    clip: true
                    spacing: vpx(3)
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: parent.width
                        height: vpx(28)
                        color: collectionMouse.containsMouse ?
                        themeColors.primary || "#3a6ea5" :
                        "transparent"
                        radius: vpx(4)

                        property bool isCurrentCollection: selectedCollectionId === modelData.id
                        property bool hasGame: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: vpx(8)
                            spacing: vpx(6)
                            width: parent.width - vpx(16)

                            Rectangle {
                                width: vpx(16)
                                height: vpx(16)
                                radius: vpx(8)
                                color: {
                                    if (hasGame) return themeColors.success || "#4CAF50";
                                    if (isCurrentCollection) return themeColors.primary || "#3a6ea5";
                                    return "transparent";
                                }
                                border.color: themeColors.inputBorder || "#555"
                                border.width: vpx(1)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (hasGame) return "✓";
                                        if (isCurrentCollection) return "−";
                                        return "+";
                                    }
                                    color: {
                                        if (hasGame) return "white";
                                        if (isCurrentCollection) return themeColors.primary || "#3a6ea5";
                                        return themeColors.text || "white";
                                    }
                                    font.pixelSize: vpx(10)
                                    font.bold: true
                                }
                            }

                            Column {
                                width: parent.width - vpx(22)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: vpx(0)

                                Text {
                                    width: parent.width
                                    text: modelData.name
                                    color: {
                                        if (hasGame) return themeColors.success || "#4CAF50";
                                        if (isCurrentCollection) return themeColors.primary || "#3a6ea5";
                                        return themeColors.text || "white";
                                    }
                                    font.pixelSize: vpx(11)
                                    font.bold: hasGame || isCurrentCollection
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.games.length + " games"
                                    color: themeColors.text || "#888"
                                    font.pixelSize: vpx(8)
                                }
                            }
                        }

                        MouseArea {
                            id: collectionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: {
                                if (isCurrentCollection && hasGame) return Qt.PointingHandCursor;
                                if (hasGame) return Qt.ForbiddenCursor;
                                return Qt.PointingHandCursor;
                            }

                            enabled: {
                                if (hasGame) {
                                    return isCurrentCollection;
                                }
                                return true;
                            }

                            onClicked: {
                                if (hasGame && isCurrentCollection) {
                                    var success = Utils.removeGameFromCollection(
                                        selectedCollectionId,
                                        currentGame.title
                                    );
                                    if (success) {
                                        gameMenu.gameRemovedFromCollection();
                                    }
                                } else if (!hasGame) {
                                    var success = Utils.addGameToCollection(
                                        modelData.id,
                                        currentGame
                                    );
                                    if (success) {
                                        gameMenu.gameAddedToCollection(modelData.id);
                                    }
                                }
                            }
                            onEntered: if (enabled) parent.scale = 1.02
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: vpx(3)
                    color: themeColors.inputBorder || "#555"
                    radius: vpx(1)
                    visible: collectionsListView.contentHeight > collectionsListView.height
                    opacity: 0.5
                }
            }

            Text {
                width: parent.width
                height: vpx(30)
                text: "Create a collection first"
                color: themeColors.textTertiary || "#888"
                font.pixelSize: vpx(11)
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: customCollections.length === 0
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
            visible: customCollections.length > 0
        }

        Rectangle {
            width: parent.width
            height: vpx(35)
            color: mouseClose.containsMouse ?
            themeColors.error || "#f44336" :
            "transparent"
            radius: vpx(5)
            border.color: mouseClose.containsMouse ?
            themeColors.errorLight || "#ef5350" :
            themeColors.error || "#f44336"
            border.width: vpx(1)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Text {
                    text: "✕"
                    color: themeColors.error || "#f44336"
                    font.pixelSize: vpx(14)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Close"
                    color: themeColors.error || "#f44336"
                    font.pixelSize: vpx(12)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseClose
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: gameMenu.closeMenu()
                onEntered: {
                    parent.scale = 1.02;
                    for (var i = 0; i < parent.children.length; i++) {
                        var row = parent.children[i];
                        if (row.objectName === "row" || row instanceof Row) {
                            for (var j = 0; j < row.children.length; j++) {
                                var textItem = row.children[j];
                                if (textItem instanceof Text) {
                                    textItem.color = "white";
                                }
                            }
                        }
                    }
                }
                onExited: {
                    parent.scale = 1.0;
                    for (var i = 0; i < parent.children.length; i++) {
                        var row = parent.children[i];
                        if (row.objectName === "row" || row instanceof Row) {
                            for (var j = 0; j < row.children.length; j++) {
                                var textItem = row.children[j];
                                if (textItem instanceof Text) {
                                    textItem.color = themeColors.error || "#f44336";
                                }
                            }
                        }
                    }
                }
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
