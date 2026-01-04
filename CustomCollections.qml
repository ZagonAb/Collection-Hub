import QtQuick 2.0
import "utils.js" as Utils

Rectangle {
    id: customCollectionsContainer
    color: "#2c2c2c"

    property var customCollections: []
    property int selectedCollectionId: -1

    signal collectionSelected(int collectionId, string collectionName, var gameTitles)
    signal createNewCollection()
    signal deleteCollection(int collectionId, string collectionName)

    Column {
        anchors.fill: parent
        anchors.margins: vpx(15)
        spacing: vpx(10)

        Text {
            text: "Mis Colecciones"
            font.bold: true
            font.pixelSize: vpx(18)
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: vpx(2)
            color: "#555"
            radius: vpx(1)
        }

        ListView {
            id: customCollectionsList
            width: parent.width
            height: parent.height - vpx(150)
            model: customCollectionsContainer.customCollections
            spacing: vpx(8)
            clip: true

            delegate: Rectangle {
                width: parent.width
                height: vpx(50)
                color: customCollectionsContainer.selectedCollectionId === modelData.id ? "#3a6ea5" : "#444"
                radius: vpx(8)
                border.color: customCollectionsContainer.selectedCollectionId === modelData.id ? "#5a8ec5" : "#555"
                border.width: vpx(2)

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(10)
                    anchors.right: parent.right
                    anchors.rightMargin: vpx(10)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: vpx(8)

                    Text {
                        text: "📁"
                        font.pixelSize: vpx(20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(2)
                        width: parent.width - vpx(40)

                        Text {
                            text: modelData.name
                            color: "white"
                            font.pixelSize: vpx(13)
                            font.bold: customCollectionsContainer.selectedCollectionId === modelData.id
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "(" + modelData.games.length + " juegos)"
                            color: "#AAA"
                            font.pixelSize: vpx(11)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function(mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            customCollectionsContainer.selectedCollectionId = modelData.id;

                            var titles = [];
                            for (var i = 0; i < modelData.games.length; i++) {
                                titles.push(modelData.games[i].title);
                            }

                            customCollectionsContainer.collectionSelected(
                                modelData.id,
                                modelData.name,
                                titles
                            );
                        }
                    }

                    onPressAndHold: {
                        customCollectionsContainer.deleteCollection(
                            modelData.id,
                            modelData.name
                        );
                    }

                    onEntered: parent.scale = 1.02
                    onExited: parent.scale = 1.0
                }

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
            }
        }

        Rectangle {
            id: createCollectionBtn
            width: parent.width
            height: vpx(50)
            color: mouseCreate.containsMouse ? "#4CAF50" : "#2E7D32"
            radius: vpx(8)
            border.color: "#66BB6A"
            border.width: vpx(2)

            Text {
                anchors.centerIn: parent
                text: "+ Nueva Colección"
                color: "white"
                font.pixelSize: vpx(15)
                font.bold: true
            }

            MouseArea {
                id: mouseCreate
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: customCollectionsContainer.createNewCollection()
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
