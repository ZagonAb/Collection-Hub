import QtQuick 2.0
import QtGraphicalEffects 1.12

Rectangle {
    id: systemCollectionsContainer
    color: "#2c2c2c"

    signal collectionSelected(var collection)

    property int selectedCollectionIndex: -1



    Column {
        anchors.fill: parent
        anchors.margins: vpx(10)
        spacing: vpx(10)

        Text {
            text: "System Collections"
            font.bold: true
            font.pixelSize: vpx(18)
            color: "white"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: parent.width
            height: vpx(2)
            color: "#444"
            radius: vpx(1)
            clip: true
        }

        ListView {
            id: systemCollectionsList
            width: parent.width
            height: parent.height - vpx(10)
            model: api.collections
            spacing: vpx(5)
            clip: true

            delegate: Rectangle {
                width: parent.width
                height: vpx(43)
                color: systemCollectionsContainer.selectedCollectionIndex === index ? "#3a6ea5" : "#444"
                radius: vpx(5)
                border.color: systemCollectionsContainer.selectedCollectionIndex === index ? "#5a8ec5" : "#555"
                border.width: vpx(2)

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(10)
                    anchors.right: parent.right
                    anchors.rightMargin: vpx(10)
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: vpx(8)

                    Text {
                        text: "🎮" //cambiar a icono de la coleccion o un solo icono para todos como ahora.! pero imagen.
                        font.pixelSize: vpx(20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(2)
                        width: parent.width - vpx(40)

                        Text {
                            text: modelData.name || modelData.shortName
                            color: "white"
                            font.pixelSize: vpx(13)
                            font.bold: systemCollectionsContainer.selectedCollectionIndex === index
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "(" + modelData.games.count + " games)"
                            color: "#AAA"
                            font.pixelSize: vpx(10)
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        systemCollectionsContainer.selectedCollectionIndex = index;
                        systemCollectionsContainer.collectionSelected(modelData);
                    }
                    onEntered: parent.scale = 1.02
                    onExited: parent.scale = 1.0
                }

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
            }
        }
    }
}
