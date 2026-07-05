// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils

FocusScope {
    id: addGameRoot
    anchors.fill: parent
    focus: true

    property var currentGame: null
    property var themeColors: ({})
    property bool isDarkTheme: true
    property var customCollections: []
    property var soundManager: null
    property bool isCollectionContext: false

    readonly property color currentItemBorderColor: {
        if (customCollections.length > 0 && listNavIndex >= 0 && listNavIndex < customCollections.length) {
            var col = customCollections[listNavIndex];
            if (currentGame && Utils.isGameInCollection(col.id, currentGame)) {
                return addedBorder;
            }
        }
        return accentColor;
    }

    property int selectedCollectionId: -1
    property var selectedSystemCollection: null
    property bool isInCurrentCollection: selectedCollectionId !== -1 && currentGame
    && Utils.isGameInCollection(selectedCollectionId, currentGame)

    signal closed()
    signal launchGame()
    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection(int collectionId)

    readonly property color panelBg: isDarkTheme ? "#1c1c20" : "#f2f2f4"
    readonly property color panelBorder: themeColors.primary || (isDarkTheme ? "#3a6ea5" : "#2196F3")
    readonly property color titleColor: isDarkTheme ? "#ffffff" : "#212121"
    readonly property color subtitleColor: isDarkTheme ? "#a0a0a0" : "#616161"
    readonly property color separatorColor: isDarkTheme ? "#2a2a2e" : "#e0e0e0"
    readonly property color itemBg: isDarkTheme ? "#111114" : "#ffffff"
    readonly property color itemBorder: isDarkTheme ? "#303036" : "#e0e0e0"
    readonly property color addedBg: isDarkTheme ? "#1a3a22" : "#e8f5e9"
    readonly property color addedBorder: "#4CAF50"
    readonly property color accentColor: themeColors.primary || "#3a6ea5"

    property int navSection: 0
    property int listNavIndex: 0

    function activateCurrent() {
        if (navSection === 0 && customCollections.length > 0) {
            var col = customCollections[listNavIndex];
            if (col && !Utils.isGameInCollection(col.id, currentGame)) {
                if (Utils.addGameToCollection(col.id, currentGame)) {
                    addGameRoot.gameAddedToCollection(col.id);
                    addGameRoot.customCollections = Utils.loadCustomCollections();
                }
            }
        } else if (navSection === 1) {
            if (soundManager) soundManager.playOk();
            addGameRoot.launchGame();
        } else if (navSection === 2 && removeBtn.visible) {
            var gamePath = Utils.getGamePath(currentGame);
            var success = Utils.removeGameFromCollection(selectedCollectionId, currentGame.title, gamePath);
            if (success) {
                addGameRoot.gameRemovedFromCollection(selectedCollectionId);
                addGameRoot.closed();
            }
        } else if (navSection === 3 || (!removeBtn.visible && navSection === 2)) {
            if (soundManager) soundManager.playBack();
            addGameRoot.closed();
        }
    }

    Component.onCompleted: {
        forceActiveFocus();
        navSection = 0;
        listNavIndex = 0;
    }

    Keys.onPressed: function(event) {
        if (api.keys.isDetails(event) || api.keys.isCancel(event)) {
            if (soundManager) soundManager.playBack();
            addGameRoot.closed();
            event.accepted = true;
            return;
        }
        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
            if (soundManager) soundManager.playNav();
            activateCurrent();
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Up) {
            if (soundManager) soundManager.playNav();
            if (navSection === 0) {
                if (listNavIndex > 0) {
                    listNavIndex--;
                    collectionsView.currentIndex = listNavIndex;
                }
            } else if (navSection === 1) {
                navSection = 0;
                listNavIndex = Math.max(0, customCollections.length - 1);
                collectionsView.currentIndex = listNavIndex;
            } else if (navSection === 2) {
                navSection = 1;
            } else if (navSection === 3) {
                navSection = removeBtn.visible ? 2 : 1;
            }
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Down) {
            if (soundManager) soundManager.playNav();
            if (navSection === 0) {
                if (listNavIndex < customCollections.length - 1) {
                    listNavIndex++;
                    collectionsView.currentIndex = listNavIndex;
                } else {
                    navSection = 1;
                }
            } else if (navSection === 1) {
                navSection = removeBtn.visible ? 2 : 3;
            } else if (navSection === 2) {
                navSection = 3;
            }
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Left) {
            if (soundManager) soundManager.playNav();
            if (navSection === 2) {
                navSection = 1;
            } else if (navSection === 3) {
                navSection = removeBtn.visible ? 2 : 1;
            }
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Right) {
            if (soundManager) soundManager.playNav();
            if (navSection === 1) {
                navSection = removeBtn.visible ? 2 : 3;
            } else if (navSection === 2) {
                navSection = 3;
            }
            event.accepted = true;
            return;
        }
    }

    Rectangle {
        id: panel
        z: 1
        anchors.centerIn: parent
        width: Math.min(vpx(520), parent.width * 0.75)
        height: Math.min(vpx(440), parent.height * 0.82)
        color: panelBg
        radius: vpx(20)

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: vpx(10)
            radius: vpx(18)
            samples: 35
            color: "black"
        }

        scale: 0.88
        opacity: 0
        Component.onCompleted: entryAnim.start()

        ParallelAnimation {
            id: entryAnim
            NumberAnimation { target: panel; property: "scale"; from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: panel; property: "opacity"; from: 0.0; to: 1.0; duration: 200; easing.type: Easing.OutQuad }
        }

        Item {
            id: headerArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(22)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(68)

            Text {
                id: titleTxt
                width: parent.width
                text: addGameRoot.currentGame ? addGameRoot.currentGame.title : ""
                color: titleColor
                font.pixelSize: vpx(22)
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
        }

        Rectangle {
            id: sep1
            anchors.top: headerArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(4)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: separatorColor
        }

        Item {
            id: sectionLabel
            anchors.top: sep1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(36)

            Text {
                text: "Add to collection"
                color: subtitleColor
                font.pixelSize: vpx(12)
                font.bold: true
                font.capitalization: Font.AllUppercase
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            id: listArea
            anchors.top: sectionLabel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: sep2.top
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            anchors.bottomMargin: vpx(8)
            clip: true

            Text {
                anchors.centerIn: parent
                text: "No custom collections yet.\nCreate one from the left panel."
                color: subtitleColor
                font.pixelSize: vpx(14)
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                visible: addGameRoot.customCollections.length === 0
            }

            ListView {
                id: collectionsView
                anchors.fill: parent
                anchors.rightMargin: vpx(10)
                model: addGameRoot.customCollections
                clip: true
                spacing: vpx(7)
                currentIndex: addGameRoot.listNavIndex
                interactive: true
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: colDelegate
                    width: collectionsView.width - vpx(24)
                    height: vpx(50)
                    anchors.horizontalCenter: parent.horizontalCenter

                    readonly property bool alreadyAdded: {
                        var _ = addGameRoot.customCollections.length;
                        return addGameRoot.currentGame
                        ? Utils.isGameInCollection(modelData.id, addGameRoot.currentGame)
                        : false;
                    }
                    readonly property bool padHighlight:
                    addGameRoot.navSection === 0 && addGameRoot.listNavIndex === index

                    Rectangle {
                        anchors.fill: parent
                        radius: vpx(8)
                        color: {
                            if (colDelegate.alreadyAdded) return addedBg;
                            if (colDelegate.padHighlight || colMouse.containsMouse)
                                return isDarkTheme ? "#22334455" : "#eaf2fb";
                            return itemBg;
                        }
                        border.color: {
                            if (colDelegate.alreadyAdded) return addedBorder;
                            if (colDelegate.padHighlight) return accentColor;
                            return itemBorder;
                        }
                        border.width: (colDelegate.padHighlight || colDelegate.alreadyAdded) ? vpx(2) : vpx(1)

                        Behavior on color { ColorAnimation { duration: 100 } }
                        Behavior on border.color { ColorAnimation { duration: 100 } }

                        Text {
                            id: stateIcon
                            anchors.left: parent.left
                            anchors.leftMargin: vpx(14)
                            anchors.verticalCenter: parent.verticalCenter
                            text: colDelegate.alreadyAdded ? "✓"
                            : (colDelegate.padHighlight || colMouse.containsMouse) ? "+" : "○"
                            color: colDelegate.alreadyAdded ? addedBorder
                            : (colDelegate.padHighlight || colMouse.containsMouse) ? accentColor
                            : subtitleColor
                            font.pixelSize: vpx(18)
                            font.bold: true
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        Text {
                            anchors.left: stateIcon.right
                            anchors.leftMargin: vpx(10)
                            anchors.right: parent.right
                            anchors.rightMargin: vpx(12)
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name || ""
                            color: colDelegate.alreadyAdded ? addedBorder : titleColor
                            font.pixelSize: vpx(18)
                            font.bold: colDelegate.alreadyAdded || colDelegate.padHighlight
                            elide: Text.ElideRight
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                    }

                    scale: colDelegate.padHighlight ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }

                    MouseArea {
                        id: colMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            if (soundManager) soundManager.playNav();
                            addGameRoot.navSection = 0;
                            addGameRoot.listNavIndex = index;
                        }
                        onClicked: {
                            if (!colDelegate.alreadyAdded && addGameRoot.currentGame) {
                                if (Utils.addGameToCollection(modelData.id, addGameRoot.currentGame)) {
                                    addGameRoot.gameAddedToCollection(modelData.id);
                                    addGameRoot.customCollections = Utils.loadCustomCollections();
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            id: sep2
            anchors.bottom: btnArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: separatorColor
        }

        Item {
            id: btnArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: vpx(20)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(50)

            Item {
                id: launchBtn
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width - closeBtn.width
                - (removeBtn.visible ? removeBtn.width + vpx(10) : 0)
                - vpx(10)

                readonly property bool padFocus: addGameRoot.navSection === 1

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + vpx(6)
                    height: parent.height + vpx(6)
                    radius: vpx(30)
                    color: "transparent"
                    border.color: addGameRoot.currentItemBorderColor
                    border.width: vpx(2)
                    opacity: launchBtn.padFocus ? 1.0 : 0.0
                    scale: launchBtn.padFocus ? 1.02 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }

                Rectangle {
                    anchors.fill: parent
                    color: launchMouse.containsMouse ? "#e0e0e0" : "#ffffff"
                    radius: vpx(25)
                    scale: launchBtn.padFocus ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: " Play"
                        color: "#111111"
                        font.pixelSize: vpx(16)
                        font.bold: true
                    }

                    MouseArea {
                        id: launchMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            if (soundManager) soundManager.playNav();
                            addGameRoot.navSection = 1;
                        }
                        onClicked: {
                            if (soundManager) soundManager.playOk();
                            addGameRoot.launchGame();
                        }
                    }
                }
            }

            Item {
                id: removeBtn
                anchors.left: launchBtn.right
                anchors.leftMargin: vpx(10)
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: vpx(160)
                visible: !addGameRoot.isCollectionContext
                && selectedCollectionId !== -1
                && selectedSystemCollection === null
                && isInCurrentCollection

                readonly property bool padFocus: addGameRoot.navSection === 2

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width + vpx(6)
                    height: parent.height + vpx(6)
                    radius: vpx(30)
                    color: "transparent"
                    border.color: addGameRoot.currentItemBorderColor
                    border.width: vpx(2)
                    opacity: removeBtn.padFocus ? 1.0 : 0.0
                    scale: removeBtn.padFocus ? 1.02 : 1.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: vpx(25)
                    color: mouseRemove.containsMouse ? "#e0e0e0" : "#ffffff"
                    scale: removeBtn.padFocus ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Remove game"
                        color: "#111111"
                        font.pixelSize: vpx(16)
                        font.bold: true
                    }
                }

                MouseArea {
                    id: mouseRemove
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        if (soundManager) soundManager.playNav();
                        addGameRoot.navSection = 2;
                    }
                    onClicked: {
                        var gamePath = Utils.getGamePath(currentGame);
                        var success = Utils.removeGameFromCollection(
                            selectedCollectionId,
                            currentGame.title,
                            gamePath
                        );
                        if (success) {
                            addGameRoot.gameRemovedFromCollection(selectedCollectionId);
                            addGameRoot.closed();
                        }
                    }
                }
            }

            Item {
                id: closeBtn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: vpx(50)

                readonly property bool padFocus: addGameRoot.navSection === 3

                Rectangle {
                    anchors.fill: parent
                    color: closeMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: closeBtn.padFocus ? addGameRoot.currentItemBorderColor : "#55ffffff"
                    border.width: closeBtn.padFocus ? vpx(2) : vpx(1)
                    scale: closeBtn.padFocus ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(20)
                        height: vpx(20)

                        Image {
                            id: closeIcon
                            anchors.fill: parent
                            source: "assets/icons/back.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            visible: status === Image.Ready
                        }

                        ColorOverlay {
                            anchors.fill: closeIcon
                            source: closeIcon
                            color: isDarkTheme ? "#ffffff" : "#212121"
                            visible: closeIcon.visible
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: isDarkTheme ? "#ffffff" : "#212121"
                            font.pixelSize: vpx(16)
                            visible: closeIcon.status !== Image.Ready
                        }
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            if (soundManager) soundManager.playNav();
                            addGameRoot.navSection = 3;
                        }
                        onClicked: {
                            if (soundManager) soundManager.playBack();
                            addGameRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
