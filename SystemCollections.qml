import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

Rectangle {
    id: systemCollectionsContainer

    signal collectionSelected(var collection)

    ColorMapping {
        id: colorMapper
    }

    property int selectedCollectionIndex: -1
    property var themeColors: ({})
    property bool isDarkTheme: true
    property var focusManager: null
    property alias systemCollectionsList: systemCollectionsList

    property color scrollbarColor: {
        if (selectedCollectionIndex >= 0 && selectedCollectionIndex < systemCollectionsList.count) {
            var data = systemCollectionsList.model.get(selectedCollectionIndex);
            var shortName = data.shortName || data.name || "";
            var mapped = colorMapper.getColor(shortName);
            if (mapped !== "#000000" && mapped !== "") {
                return mapped;
            }
        }
        return themeColors.primaryHover || "#5a8ec5";
    }

    radius: 10
    color: themeColors.panel || "#2c2c2c"
    border.color: themeColors.panelBorder || "#444"
    border.width: vpx(1)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: vpx(10)
        spacing: vpx(10)

        Text {
            text: "Platforms"
            font.bold: true
            font.pixelSize: vpx(20)
            color: themeColors.text || "white"
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

                    property bool isHovered: false
                    property bool isSelected: systemCollectionsContainer.selectedCollectionIndex === index

                    property color systemColor: {
                        var shortName = modelData.shortName || modelData.name || "";
                        var mapped = colorMapper.getColor(shortName);
                        return mapped === "#000000" || !mapped
                        ? themeColors.primary || "#3a6ea5"
                        : mapped;
                    }

                    color: {
                        if (isSelected) {
                            return Qt.rgba(systemColor.r, systemColor.g, systemColor.b, 0.55);
                        }
                        if ((isHovered || (isCurrent && systemCollectionsList.activeFocus)) && !isSelected) {
                            return Qt.rgba(systemColor.r, systemColor.g, systemColor.b, 0.30);
                        }
                        return "transparent";
                    }
                    radius: vpx(10)
                    property bool isCurrent: ListView.isCurrentItem

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
                                        (isDarkTheme ? "white" : themeColors.text) : themeColors.text || "white"
                                    }
                                }
                            }

                            ColorOverlay {
                                anchors.fill: systemCollectionIcon
                                source: systemCollectionIcon
                                color: systemCollectionsContainer.selectedCollectionIndex === index ?
                                (isDarkTheme ? "white" : themeColors.text) : themeColors.text || "white"
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

                                property bool isActive: isCurrent && systemCollectionsList.activeFocus
                                property bool needsScroll: marqueeText1.implicitWidth > marqueeContainer.width
                                property real scrollOffset: 0
                                property real cycleWidth: marqueeText1.implicitWidth + marqueeSep.implicitWidth
                                property color textColor: systemCollectionsContainer.selectedCollectionIndex === index ?
                                    (isDarkTheme ? "white" : themeColors.text) : themeColors.text || "white"

                                Text {
                                    id: marqueeText1
                                    text: modelData.name || modelData.shortName
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
                                    text: modelData.name || modelData.shortName
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
                                text: "(" + modelData.games.count + " games)"
                                color: systemCollectionsContainer.selectedCollectionIndex === index ?
                                (isDarkTheme ? "white" : themeColors.text) : themeColors.textSecondary || "#AAA"
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
                            systemCollectionsList.positionViewAtIndex(index, ListView.Contain);

                            if (systemCollectionsContainer.focusManager) {
                                systemCollectionsContainer.focusManager.lastSystemIndex = index;
                                systemCollectionsContainer.focusManager.moveFocusRight();
                            }
                        }
                        onEntered: {
                            parent.isHovered = true;
                            parent.scale = 1.02;
                        }
                        onExited: {
                            parent.isHovered = false;
                            parent.scale = 1.0;
                        }
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
                            positionViewAtIndex(currentIndex, ListView.Contain);
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
                width: vpx(3)
                color: "transparent"
                visible: systemCollectionsList.contentHeight > systemCollectionsList.height

                Rectangle {
                    width: parent.width
                    height: Math.max(vpx(20), (systemCollectionsList.height / systemCollectionsList.contentHeight) * parent.height)
                    y: (systemCollectionsList.contentY / systemCollectionsList.contentHeight) * parent.height
                    color: systemCollectionsContainer.scrollbarColor
                    radius: vpx(1.5)
                    opacity: 1.0
                }
            }
        }
    }
}


