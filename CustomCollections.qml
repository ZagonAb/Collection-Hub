// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
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
    property var focusManager: null
    property var soundManager: null
    property alias customCollectionsList: customCollectionsList

    signal createNewCollection()
    signal deleteCollection(int collectionId, string collectionName)
    signal collectionRightClicked(int collectionId, string collectionName, int x, int y)
    signal collectionSelected(int collectionId, string collectionName, var gameFilePaths)

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
            font.pixelSize: vpx(20)
            color: themeColors.text || "white"
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: customCollectionsList
                anchors.fill: parent
                leftMargin: vpx(4)
                rightMargin: vpx(15)
                topMargin: vpx(1)
                bottomMargin: vpx(1)
                model: customCollectionsContainer.customCollections
                spacing: vpx(5)
                clip: true
                focus: true
                keyNavigationWraps: false
                highlightFollowsCurrentItem: true
                highlightMoveVelocity: -1

                Keys.onPressed: function(event) {
                    if (!activeFocus) return;

                    if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
                        if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playNav();
                    }

                    if (api.keys.isAccept(event)) {
                        if (currentItem) {
                            var modelData = customCollectionsContainer.customCollections[currentIndex];
                            customCollectionsContainer.selectedCollectionId = modelData.id;
                            positionViewAtIndex(currentIndex, ListView.Contain);

                            var filePaths = [];
                            for (var i = 0; i < modelData.games.length; i++) {
                                var fp = modelData.games[i].filePath || modelData.games[i].title;
                                filePaths.push(fp);
                            }

                            customCollectionsContainer.collectionSelected(
                                modelData.id,
                                modelData.name,
                                filePaths
                            );

                            if (focusManager) {
                                focusManager.lastCustomIndex = currentIndex;
                                focusManager.moveFocusRight();
                            }
                            if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playOk();
                        }
                        event.accepted = true;
                    } else if (api.keys.isDetails(event)) {
                        if (currentItem) {
                            var modelData = customCollectionsContainer.customCollections[currentIndex];
                            var globalPos = currentItem.mapToItem(null, currentItem.width / 2, currentItem.height / 2);
                            customCollectionsContainer.collectionRightClicked(
                                modelData.id,
                                modelData.name,
                                globalPos.x,
                                globalPos.y
                            );
                            if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playOk();
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (focusManager) focusManager.moveFocusRight();
                        if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playOk();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Up && currentIndex === 0) {
                        if (focusManager) focusManager.moveFocusUp();
                        event.accepted = true;
                    } else if (api.keys.isCancel(event)) {
                        if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playBack();
                        event.accepted = false;
                    }
                }

                delegate: Rectangle {
                    width: ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin
                    height: vpx(43)

                    property bool isCurrent: ListView.isCurrentItem
                    property bool isSelected: customCollectionsContainer.selectedCollectionId === modelData.id
                    property color primaryColor: themeColors.primary || "#3a6ea5"

                    color: {
                        if (isSelected) {
                            return primaryColor;
                        }
                        if (isCurrent && customCollectionsList.activeFocus && !isSelected) {
                            return Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, 0.15);
                        }
                        return "transparent";
                    }
                    radius: vpx(10)

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(10)
                        anchors.right: parent.right
                        anchors.rightMargin: vpx(10)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: vpx(8)

                        Item {
                            width: vpx(20)
                            height: vpx(20)
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: customCollectionIcon
                                anchors.fill: parent
                                source: "assets/icons/collection.svg"
                                fillMode: Image.PreserveAspectFit

                                Rectangle {
                                    anchors.fill: parent
                                    color: "transparent"
                                    visible: parent.status !== Image.Ready

                                    Text {
                                        anchors.centerIn: parent
                                        text: "📁"
                                        font.pixelSize: vpx(16)
                                        color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                                        "white" : themeColors.text || "white"
                                    }
                                }
                            }

                            ColorOverlay {
                                anchors.fill: customCollectionIcon
                                source: customCollectionIcon
                                color: customCollectionsContainer.selectedCollectionId === modelData.id ?
                                "white" : themeColors.text || "white"
                            }
                        }

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: vpx(2)
                            width: parent.width - vpx(40)

                            Item {
                                id: marqueeContainer
                                width: parent.width
                                height: marqueeText1.height
                                clip: true

                                property bool isActive: isCurrent && customCollectionsList.activeFocus
                                property bool needsScroll: marqueeText1.implicitWidth > marqueeContainer.width
                                property real scrollOffset: 0
                                property real cycleWidth: marqueeText1.implicitWidth + marqueeSep.implicitWidth
                                property color textColor: customCollectionsContainer.selectedCollectionId === modelData.id ?
                                    "white" : themeColors.text || "white"

                                Text {
                                    id: marqueeText1
                                    text: modelData.name
                                    color: marqueeContainer.textColor
                                    font.pixelSize: vpx(13)
                                    font.bold: true
                                    elide: marqueeContainer.isActive ? Text.ElideNone : Text.ElideRight
                                    width: marqueeContainer.isActive ? implicitWidth : marqueeContainer.width
                                    x: -marqueeContainer.scrollOffset
                                    y: 0
                                }

                                Text {
                                    id: marqueeSep
                                    text: "  •  "
                                    color: marqueeContainer.textColor
                                    font.pixelSize: vpx(13)
                                    elide: Text.ElideNone
                                    x: marqueeText1.implicitWidth - marqueeContainer.scrollOffset
                                    y: 0
                                    visible: marqueeContainer.needsScroll && marqueeContainer.isActive
                                }

                                Text {
                                    id: marqueeText2
                                    text: modelData.name
                                    color: marqueeContainer.textColor
                                    font.pixelSize: vpx(13)
                                    font.bold: true
                                    elide: Text.ElideNone
                                    x: marqueeText1.implicitWidth + marqueeSep.implicitWidth - marqueeContainer.scrollOffset
                                    y: 0
                                    visible: marqueeContainer.needsScroll && marqueeContainer.isActive
                                }

                                NumberAnimation {
                                    id: marqueeAnim
                                    target: marqueeContainer
                                    property: "scrollOffset"
                                    from: 0
                                    to: marqueeContainer.cycleWidth
                                    duration: marqueeContainer.cycleWidth * 22
                                    easing.type: Easing.Linear
                                    loops: Animation.Infinite
                                    running: false
                                }

                                onIsActiveChanged: {
                                    scrollOffset = 0;
                                    marqueeAnim.stop();
                                    if (isActive && needsScroll) {
                                        marqueeAnim.start();
                                    }
                                }

                                onNeedsScrollChanged: {
                                    if (isActive && needsScroll) {
                                        scrollOffset = 0;
                                        marqueeAnim.start();
                                    } else {
                                        marqueeAnim.stop();
                                        scrollOffset = 0;
                                    }
                                }
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
                                customCollectionsList.positionViewAtIndex(index, ListView.Contain);

                                var filePaths = [];
                                for (var i = 0; i < modelData.games.length; i++) {
                                    var fp = modelData.games[i].filePath || modelData.games[i].title;
                                    filePaths.push(fp);
                                }

                                customCollectionsContainer.collectionSelected(
                                    modelData.id,
                                    modelData.name,
                                    filePaths
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

                            if (customCollectionsContainer.soundManager) customCollectionsContainer.soundManager.playOk();
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

                Text {
                    anchors.centerIn: parent
                    text: "No collections yet"
                    color: themeColors.textTertiary || "#707070"
                    font.pixelSize: vpx(14)
                    font.italic: true
                    visible: customCollectionsContainer.customCollections.length === 0
                }
            }

            CustomScrollBar {
                id: scrollBarCus
                listView: customCollectionsList
                thumbColor: themeColors.primaryHover || "#5a8ec5"
            }
        }
    }
}
