import QtQuick 2.0

Rectangle {
    id: systemCollectionsContainer
    color: "#2c2c2c"

    signal collectionSelected(var collection)

    property int selectedCollectionIndex: -1

    Column {
        anchors.fill: parent
        anchors.margins: vpx(15)
        spacing: vpx(10)

        Text {
            text: "Colecciones del Sistema"
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
            id: systemCollectionsList
            width: parent.width
            height: parent.height - vpx(80)
            model: api.collections
            spacing: vpx(8)
            clip: true

            delegate: Rectangle {
                width: parent.width
                height: vpx(50)
                color: systemCollectionsContainer.selectedCollectionIndex === index ? "#3a6ea5" : "#444"
                radius: vpx(8)
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
                        text: "🎮"
                        font.pixelSize: vpx(20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(2)
                        width: parent.width - vpx(40)

                        Text {
                            text: modelData.shortName || modelData.name
                            color: "white"
                            font.pixelSize: vpx(13)
                            font.bold: systemCollectionsContainer.selectedCollectionIndex === index
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "(" + modelData.games.count + " juegos)"
                            color: "#AAA"
                            font.pixelSize: vpx(11)
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
