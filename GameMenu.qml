import QtQuick 2.0
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: gameMenu
    width: parent.width * 0.25
    height: menuColumn.height + vpx(20)
    color: "#2c2c2c"
    border.color: "#3a6ea5"
    border.width: vpx(3)
    radius: vpx(12)
    z: 10

    // Propiedades públicas
    property var currentGame: null
    property string gameTitle: currentGame ? currentGame.title : ""
    property int selectedCollectionId: -1
    property string selectedCollectionName: ""
    property var selectedSystemCollection: null
    property var customCollections: []
    property int menuX: 0
    property int menuY: 0

    // Señales
    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection()
    signal launchGame()
    signal closeMenu()

    // Propiedad calculada
    property bool isInCurrentCollection: {
        if (selectedCollectionId === -1) return false;
        return Utils.isGameInCollection(selectedCollectionId, gameTitle);
    }

    // Actualizar posición cuando cambian las coordenadas
    onMenuXChanged: updatePosition()
    onMenuYChanged: updatePosition()

    function updatePosition() {
        // Asegurar que el menú no se salga de la pantalla
        if (parent) {
            x = Math.min(menuX, parent.width - width - vpx(10));
            y = Math.min(menuY, parent.height - height - vpx(10));
        }
    }

    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: vpx(12)
        spacing: vpx(6)

        // Título del juego
        Rectangle {
            width: parent.width
            height: vpx(50)
            color: "transparent"

            Text {
                anchors.fill: parent
                text: gameMenu.gameTitle
                color: "white"
                font.bold: true
                font.pixelSize: vpx(15)
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            height: vpx(2)
            width: parent.width
            color: "#555"
            radius: vpx(1)
        }

        // Sección: Añadir a colección (para All Games o colecciones del sistema)
        Column {
            width: parent.width
            spacing: vpx(6)
            visible: (selectedCollectionId === -1 || selectedSystemCollection !== null) && customCollections.length > 0

            Text {
                text: "Añadir a colección:"
                color: "#AAA"
                font.pixelSize: vpx(12)
                font.italic: true
            }

            Repeater {
                model: customCollections

                Rectangle {
                    width: parent.width
                    height: vpx(40)
                    color: mouseAddTo.containsMouse ? "#3a6ea5" : "transparent"
                    radius: vpx(6)

                    property bool alreadyInCollection: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(10)
                        spacing: vpx(10)

                        Text {
                            text: parent.parent.alreadyInCollection ? "✓" : "+"
                            color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                            font.pixelSize: vpx(16)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.name
                            color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                            font.pixelSize: vpx(13)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseAddTo
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: parent.alreadyInCollection ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                        enabled: !parent.alreadyInCollection
                        onClicked: {
                            if (currentGame) {
                                var success = Utils.addGameToCollection(
                                    modelData.id,
                                    currentGame
                                );

                                if (success) {
                                    gameMenu.gameAddedToCollection(modelData.id);
                                }
                            }
                        }
                        onEntered: if (enabled) parent.scale = 1.03
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }

        // Mensaje cuando no hay colecciones creadas
        Text {
            width: parent.width
            height: vpx(40)
            text: "Crea una colección primero"
            color: "#888"
            font.pixelSize: vpx(13)
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            visible: (selectedCollectionId === -1 || selectedSystemCollection !== null) && customCollections.length === 0
        }

        // Sección: Para colecciones personalizadas
        Column {
            width: parent.width
            spacing: vpx(6)
            visible: selectedCollectionId !== -1 && selectedSystemCollection === null

            // Quitar de colección actual
            Rectangle {
                width: parent.width
                height: vpx(45)
                color: mouseRemove.containsMouse ? "#f44336" : "transparent"
                radius: vpx(6)
                visible: isInCurrentCollection
                border.color: mouseRemove.containsMouse ? "#ef5350" : "transparent"
                border.width: vpx(2)

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(10)
                    spacing: vpx(10)

                    Text {
                        text: "✕"
                        color: "white"
                        font.pixelSize: vpx(16)
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Quitar de: " + selectedCollectionName
                        color: "white"
                        font.pixelSize: vpx(13)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: mouseRemove
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (currentGame && selectedCollectionId !== -1) {
                            var success = Utils.removeGameFromCollection(
                                selectedCollectionId,
                                currentGame.title
                            );

                            if (success) {
                                gameMenu.gameRemovedFromCollection();
                            }
                        }
                    }
                    onEntered: parent.scale = 1.03
                    onExited: parent.scale = 1.0
                }

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
            }

            // Añadir a otras colecciones
            Text {
                text: "Añadir a otra colección:"
                color: "#AAA"
                font.pixelSize: vpx(12)
                font.italic: true
                visible: customCollections.length > 1
            }

            Repeater {
                model: customCollections

                Rectangle {
                    width: parent.width
                    height: vpx(40)
                    color: mouseAddOther.containsMouse ? "#3a6ea5" : "transparent"
                    radius: vpx(6)
                    visible: modelData.id !== selectedCollectionId

                    property bool alreadyInCollection: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(10)
                        spacing: vpx(10)

                        Text {
                            text: parent.parent.alreadyInCollection ? "✓" : "+"
                            color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                            font.pixelSize: vpx(16)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.name
                            color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                            font.pixelSize: vpx(13)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseAddOther
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: parent.alreadyInCollection ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                        enabled: !parent.alreadyInCollection
                        onClicked: {
                            if (currentGame) {
                                var success = Utils.addGameToCollection(
                                    modelData.id,
                                    currentGame
                                );

                                if (success) {
                                    gameMenu.gameAddedToCollection(modelData.id);
                                }
                            }
                        }
                        onEntered: if (enabled) parent.scale = 1.03
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }

        Rectangle {
            height: vpx(2)
            width: parent.width
            color: "#555"
            radius: vpx(1)
        }

        // Lanzar juego
        Rectangle {
            width: parent.width
            height: vpx(45)
            color: mouseLaunch.containsMouse ? "#4CAF50" : "transparent"
            radius: vpx(6)
            border.color: mouseLaunch.containsMouse ? "#66BB6A" : "transparent"
            border.width: vpx(2)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(10)
                spacing: vpx(10)

                Text {
                    text: "▶"
                    color: "white"
                    font.pixelSize: vpx(16)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Lanzar juego"
                    color: "white"
                    font.pixelSize: vpx(13)
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
                onEntered: parent.scale = 1.03
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        // Cerrar menú
        Rectangle {
            width: parent.width
            height: vpx(45)
            color: mouseClose.containsMouse ? "#666" : "transparent"
            radius: vpx(6)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(10)
                spacing: vpx(10)

                Text {
                    text: "✕"
                    color: "white"
                    font.pixelSize: vpx(16)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Cerrar"
                    color: "white"
                    font.pixelSize: vpx(13)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseClose
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: gameMenu.closeMenu()
                onEntered: parent.scale = 1.03
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
