import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: customCollectionsContainer

    property var customCollections: []
    property int selectedCollectionId: -1
    property var themeColors: ({})
    property bool isDarkTheme: true

    signal collectionSelected(int collectionId, string collectionName, var gameTitles)
    signal createNewCollection()
    signal deleteCollection(int collectionId, string collectionName)
    signal collectionRightClicked(int collectionId, string collectionName, int x, int y)

    radius: 10
    color: themeColors.panel || "#2c2c2c"
    border.color: themeColors.panelBorder || "#444"
    border.width: vpx(1)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: vpx(10)
        spacing: vpx(10)

        Text {
            text: "My Collections"
            font.bold: true
            font.pixelSize: vpx(18)
            color: themeColors.text || "white"
        }

        Rectangle {
            Layout.fillWidth: true
            height: vpx(2)
            color: themeColors.separator || "#444"
            radius: vpx(1)
        }

        ListView {
            id: customCollectionsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: customCollectionsContainer.customCollections
            spacing: vpx(5)
            clip: true
            leftMargin: vpx(4)
            rightMargin: vpx(4)
            topMargin: vpx(1)
            bottomMargin: vpx(1)

            delegate: Rectangle {
                width: parent.width
                height: vpx(43)
                color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                themeColors.primary || "#3a6ea5" :
                "transparent"
                radius: vpx(5)
                border.color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                themeColors.primaryHover || "#5a8ec5" :
                themeColors.panelBorder || "#555"
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
                            color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                            "white" : themeColors.text || "white"
                            font.pixelSize: vpx(13)
                            font.bold: customCollectionsContainer.selectedCollectionId === modelData.id
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "(" + modelData.games.length + " games)"
                            color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                            (isDarkTheme ? "white" : "#f5f5f5") : themeColors.textSecondary || "#AAA"
                            font.pixelSize: vpx(10)
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
                        } else if (mouse.button === Qt.RightButton) {
                            var globalPos = mapToItem(customCollectionsContainer.parent.parent, mouse.x, mouse.y);
                            customCollectionsContainer.collectionRightClicked(
                                modelData.id,
                                modelData.name,
                                globalPos.x,
                                globalPos.y
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

            // Mensaje cuando no hay colecciones
            Text {
                anchors.centerIn: parent
                text: "No collections yet"
                color: themeColors.textTertiary || "#707070"
                font.pixelSize: vpx(14)
                font.italic: true
                visible: customCollectionsContainer.customCollections.length === 0
            }
        }

        Rectangle {
            id: createCollectionBtn
            Layout.fillWidth: true
            height: vpx(30)
            color: mouseCreate.containsMouse ?
            themeColors.successLight || "#4CAF50" :
            themeColors.successDark || "#2E7D32"
            radius: vpx(5)
            border.color: themeColors.successLight || "#66BB6A"
            border.width: vpx(2)

            Text {
                anchors.centerIn: parent
                text: "+ New Collection"
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
                onEntered: parent.scale = 1.01
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }
}
