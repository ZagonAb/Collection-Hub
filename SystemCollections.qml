import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

Rectangle {
    id: systemCollectionsContainer

    signal collectionSelected(var collection)
    property int selectedCollectionIndex: -1
    property var themeColors: ({})
    property bool isDarkTheme: true
    property var focusManager: null
    property alias systemCollectionsList: systemCollectionsList

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: systemCollectionsList
                anchors.fill: parent
                model: api.collections
                spacing: vpx(5)
                clip: true
                leftMargin: vpx(4)
                rightMargin: vpx(10)
                topMargin: vpx(1)
                bottomMargin: vpx(1)
                focus: true
                keyNavigationWraps: false
                highlightFollowsCurrentItem: true

                delegate: Rectangle {
                    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                    height: vpx(43)
                    color: systemCollectionsContainer.selectedCollectionIndex === index ?
                    themeColors.primary || "#3a6ea5" :
                    "transparent"
                    radius: vpx(5)

                    property bool isCurrent: ListView.isCurrentItem

                    border.color: (isCurrent && systemCollectionsList.activeFocus) ? themeColors.primary :
                    (systemCollectionsContainer.selectedCollectionIndex === index ?
                    themeColors.primaryHover : themeColors.panelBorder)
                    border.width: vpx(2)

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(10)
                        anchors.right: parent.right
                        anchors.rightMargin: vpx(10)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(8)

                        Item {
                            width: vpx(32)
                            height: vpx(32)
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: systemCollectionIcon
                                anchors.fill: parent
                                source: "assets/systems/" + (modelData.shortName || modelData.name).toLowerCase() + ".png"
                                fillMode: Image.PreserveAspectFit
                                mipmap: true

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    visible: parent.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: "🎮"
                                        font.pixelSize: vpx(16)
                                        color: systemCollectionsContainer.selectedCollectionIndex === index ?
                                        (isDarkTheme ? "white" : "#f5f5f5") : themeColors.text || "white"
                                    }
                                }
                            }

                            ColorOverlay {
                                anchors.fill: systemCollectionIcon
                                source: systemCollectionIcon
                                color: systemCollectionsContainer.selectedCollectionIndex === index ?
                                (isDarkTheme ? "white" : "#f5f5f5") : themeColors.text || "white"
                            }
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

                Keys.onPressed: function(event) {
                    if (api.keys.isAccept(event)) {
                        if (currentItem) {
                            var modelData = model.get(currentIndex);
                            systemCollectionsContainer.selectedCollectionIndex = currentIndex;
                            systemCollectionsContainer.collectionSelected(modelData);
                            if (focusManager) {
                                focusManager.lastSystemIndex = currentIndex;
                                focusManager.moveFocusRight();
                            }
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (focusManager) focusManager.moveFocusRight();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Down && currentIndex === count - 1) {
                        if (focusManager) focusManager.moveFocusDown();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up && currentIndex === 0) {
                        if (focusManager) focusManager.selectAllGames();
                        event.accepted = true;
                    }
                }
            }

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: vpx(1)
                anchors.top: systemCollectionsList.top
                anchors.bottom: systemCollectionsList.bottom
                width: vpx(2)
                color: "transparent"
                visible: systemCollectionsList.contentHeight > systemCollectionsList.height

                Rectangle {
                    width: parent.width
                    height: Math.max(vpx(20), (systemCollectionsList.height / systemCollectionsList.contentHeight) * parent.height)
                    y: (systemCollectionsList.contentY / systemCollectionsList.contentHeight) * parent.height
                    color: themeColors.primaryHover || "#5a8ec5"
                    radius: vpx(1.5)
                    opacity: 0.6
                }
            }
        }
    }
}
