import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

Rectangle {
    id: systemCollectionsContainer

    signal collectionSelected(var collection)
    property int selectedCollectionIndex: -1
    property var themeColors: ({})
    property bool isDarkTheme: true

    radius: 10
    color: themeColors.panel || "#2c2c2c"
    border.color: themeColors.panelBorder || "#444"
    border.width: vpx(1)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: vpx(10)
        spacing: vpx(10)

        Text {
            text: "System Collections"
            font.bold: true
            font.pixelSize: vpx(18)
            color: themeColors.text || "white"
        }

        Rectangle {
            Layout.fillWidth: true
            height: vpx(2)
            color: themeColors.separator || "#444"
            radius: vpx(1)
            clip: true
        }

        ListView {
            id: systemCollectionsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: api.collections
            spacing: vpx(5)
            clip: true
            leftMargin: vpx(4)
            rightMargin: vpx(4)
            topMargin: vpx(1)
            bottomMargin: vpx(1)

            delegate: Rectangle {
                width: parent.width
                height: vpx(43)
                color: systemCollectionsContainer.selectedCollectionIndex === index ?
                themeColors.primary || "#3a6ea5" :
                "transparent"
                radius: vpx(5)
                border.color: systemCollectionsContainer.selectedCollectionIndex === index ?
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
                        text: "🎮"
                        font.pixelSize: vpx(20)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(2)
                        width: parent.width - vpx(40)

                        Text {
                            text: modelData.name || modelData.shortName
                            color: systemCollectionsContainer.selectedCollectionIndex === index ?
                            (isDarkTheme ? "white" : "#f5f5f5") : themeColors.text || "white"
                            font.pixelSize: vpx(13)
                            font.bold: systemCollectionsContainer.selectedCollectionIndex === index
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: "(" + modelData.games.count + " games)"
                            color: systemCollectionsContainer.selectedCollectionIndex === index ?
                            (isDarkTheme ? "white" : "#f5f5f5") : themeColors.textSecondary || "#AAA"
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
