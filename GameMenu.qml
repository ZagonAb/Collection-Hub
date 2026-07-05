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
    id: gameMenuRoot
    anchors.fill: parent
    focus: true

    property var themeColors: ({})
    property bool isDarkTheme: true
    property int contextCollectionId: -1
    property string contextCollectionName: ""
    property var focusManager: null
    property var soundManager: null

    readonly property color panelBg: isDarkTheme ? "#1c1c20" : "#f2f2f4"
    readonly property color titleColor: isDarkTheme ? "#ffffff" : "#212121"
    readonly property color subtitleColor: isDarkTheme ? "#a0a0a0" : "#616161"
    readonly property color separatorColor: isDarkTheme ? "#2a2a2e" : "#e0e0e0"
    readonly property color itemBg: isDarkTheme ? "#111114" : "#ffffff"
    readonly property color itemBorder: isDarkTheme ? "#303036" : "#e0e0e0"
    readonly property color accentColor: themeColors.primary || "#3a6ea5"

    property int navSection: 0
    property bool renameMode: false

    signal closeMenu()
    signal deleteCollection(int collectionId, string collectionName)
    signal renameCollection(int collectionId)

    function openMenu() {
        navSection = 0;
        renameMode = false;
        forceActiveFocus();
        entryAnim.restart();
    }

    function saveRename() {
        var newName = renameInput.text.trim();
        if (newName !== "" && newName !== contextCollectionName) {
            if (Utils.renameCollection(contextCollectionId, newName)) {
                gameMenuRoot.renameCollection(contextCollectionId);
            }
        }
        if (soundManager) soundManager.playNav();
        cancelRename();
        gameMenuRoot.closeMenu();
    }

    function cancelRename() {
        if (soundManager) soundManager.playBack();
        renameMode = false;
        navSection = 0;
        normalMenu.forceActiveFocus();
    }

    Component.onCompleted: {
        forceActiveFocus();
        navSection = 0;
    }

    Keys.onPressed: function(event) {
        if (renameMode) {
            if (event.key === Qt.Key_Escape || api.keys.isCancel(event)) {
                if (soundManager) soundManager.playBack();
                cancelRename();
                event.accepted = true;
            }
            return;
        }

        if (api.keys.isDetails(event) || api.keys.isCancel(event)) {
            if (soundManager) soundManager.playBack();
            gameMenuRoot.closeMenu();
            event.accepted = true;
            return;
        }

        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
            if (navSection === 0) {
                if (soundManager) soundManager.playNav();
                renameMode = true;
                renameInput.text = contextCollectionName;
                renameInput.selectAll();
                renameMenuArea.forceActiveFocus();
            } else if (navSection === 1) {
                if (soundManager) soundManager.playNav();
                gameMenuRoot.deleteCollection(contextCollectionId, contextCollectionName);
                gameMenuRoot.closeMenu();
            } else {
                if (soundManager) soundManager.playBack();
                gameMenuRoot.closeMenu();
            }
            event.accepted = true;
            return;
        }

        if (event.key === Qt.Key_Up) {
            if (soundManager) soundManager.playNav();
            if (navSection > 0) navSection--;
            event.accepted = true;
            return;
        }
        if (event.key === Qt.Key_Down) {
            if (soundManager) soundManager.playNav();
            if (navSection < 2) navSection++;
            event.accepted = true;
            return;
        }
    }

    Rectangle {
        id: panel
        z: 1
        anchors.centerIn: parent
        width: Math.min(vpx(380), parent.width * 0.6)
        height: renameMode ? Math.min(vpx(280), parent.height * 0.5)
        : Math.min(vpx(300), parent.height * 0.5)
        color: panelBg
        radius: vpx(20)

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

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
        opacity: 0.0

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
            height: vpx(58)

            Text {
                id: titleTxt
                width: parent.width
                text: contextCollectionName
                color: titleColor
                font.pixelSize: vpx(22)
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                anchors.bottom: parent.bottom
                text: "COLLECTION"
                color: subtitleColor
                font.pixelSize: vpx(10)
                font.bold: true
                font.capitalization: Font.AllUppercase
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
            id: normalMenu
            visible: !renameMode
            anchors.top: sep1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            anchors.bottomMargin: vpx(20)
            focus: !renameMode

            Rectangle {
                id: renameBtn
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(44)
                radius: vpx(8)

                readonly property bool padFocus: gameMenuRoot.navSection === 0

                color: renameMouse.containsMouse || padFocus
                ? (isDarkTheme ? "#22334455" : "#eaf2fb")
                : (isDarkTheme ? "#111114" : "#ffffff")
                border.color: renameMouse.containsMouse || padFocus
                ? accentColor
                : itemBorder
                border.width: (renameMouse.containsMouse || padFocus) ? vpx(2) : vpx(1)

                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.color { ColorAnimation { duration: 100 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(12)
                    spacing: vpx(10)

                    Item {
                        width: vpx(22)
                        height: vpx(22)
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: renameIcon
                            anchors.fill: parent
                            source: "assets/icons/rename.svg"
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            mipmap: true
                        }
                        ColorOverlay {
                            anchors.fill: renameIcon
                            source: renameIcon
                            color: renameMouse.containsMouse || renameBtn.padFocus
                            ? accentColor
                            : (isDarkTheme ? "#a0a0a0" : "#616161")
                            visible: renameIcon.visible
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "✏"
                            font.pixelSize: vpx(14)
                            color: renameMouse.containsMouse || renameBtn.padFocus
                            ? accentColor
                            : (isDarkTheme ? "#a0a0a0" : "#616161")
                            visible: renameIcon.status !== Image.Ready
                        }
                    }

                    Text {
                        text: "Rename"
                        color: renameMouse.containsMouse || renameBtn.padFocus
                        ? (isDarkTheme ? "#ffffff" : "#212121")
                        : (isDarkTheme ? "#a0a0a0" : "#616161")
                        font.pixelSize: vpx(16)
                        font.bold: renameMouse.containsMouse || renameBtn.padFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: renameMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: gameMenuRoot.navSection = 0
                    onClicked: {
                        if (soundManager) soundManager.playNav();
                        renameMode = true;
                        renameInput.text = contextCollectionName;
                        renameInput.selectAll();
                        renameMenuArea.forceActiveFocus();
                    }
                }
            }

            Rectangle {
                id: deleteBtn
                anchors.top: renameBtn.bottom
                anchors.topMargin: vpx(8)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(44)
                radius: vpx(8)

                readonly property bool padFocus: gameMenuRoot.navSection === 1

                color: deleteMouse.containsMouse || padFocus
                ? (isDarkTheme ? "#2a1010" : "#fdecea")
                : (isDarkTheme ? "#111114" : "#ffffff")
                border.color: deleteMouse.containsMouse || padFocus
                ? (themeColors.error || "#f44336")
                : itemBorder
                border.width: (deleteMouse.containsMouse || padFocus) ? vpx(2) : vpx(1)

                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on border.color { ColorAnimation { duration: 100 } }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(12)
                    spacing: vpx(10)

                    Item {
                        width: vpx(22)
                        height: vpx(22)
                        anchors.verticalCenter: parent.verticalCenter

                        Image {
                            id: deleteIcon
                            anchors.fill: parent
                            source: "assets/icons/trash.svg"
                            fillMode: Image.PreserveAspectFit
                            visible: status === Image.Ready
                            mipmap: true
                        }
                        ColorOverlay {
                            anchors.fill: deleteIcon
                            source: deleteIcon
                            color: deleteMouse.containsMouse || deleteBtn.padFocus
                            ? (themeColors.error || "#f44336")
                            : (isDarkTheme ? "#a0a0a0" : "#616161")
                            visible: deleteIcon.visible
                        }
                        Text {
                            anchors.centerIn: parent
                            text: "🗑"
                            font.pixelSize: vpx(12)
                            color: deleteMouse.containsMouse || deleteBtn.padFocus
                            ? (themeColors.error || "#f44336")
                            : (isDarkTheme ? "#a0a0a0" : "#616161")
                            visible: deleteIcon.status !== Image.Ready
                        }
                    }

                    Text {
                        text: "Delete Collection"
                        color: deleteMouse.containsMouse || deleteBtn.padFocus
                        ? (themeColors.error || "#f44336")
                        : (isDarkTheme ? "#a0a0a0" : "#616161")
                        font.pixelSize: vpx(16)
                        font.bold: deleteMouse.containsMouse || deleteBtn.padFocus
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: deleteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: gameMenuRoot.navSection = 1
                    onClicked: {
                        if (soundManager) soundManager.playNav();
                        gameMenuRoot.deleteCollection(contextCollectionId, contextCollectionName);
                        gameMenuRoot.closeMenu();
                    }
                }
            }

            Rectangle {
                id: sep2
                anchors.top: deleteBtn.bottom
                anchors.topMargin: vpx(12)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(1)
                color: separatorColor
            }

            Item {
                id: closeBtn
                anchors.top: sep2.bottom
                anchors.topMargin: vpx(12)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(44)

                readonly property bool padFocus: gameMenuRoot.navSection === 2

                Rectangle {
                    anchors.fill: parent
                    color: closeMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: closeBtn.padFocus ? accentColor : "#55ffffff"
                    border.width: closeBtn.padFocus ? vpx(2) : vpx(1)
                    scale: closeBtn.padFocus ? 1.03 : 1.0

                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: vpx(8)

                        Item {
                            width: vpx(22)
                            height: vpx(22)
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: closeIcon
                                anchors.fill: parent
                                source: "assets/icons/close.svg"
                                fillMode: Image.PreserveAspectFit
                                visible: status === Image.Ready
                                mipmap: true
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
                                font.pixelSize: vpx(14)
                                font.bold: true
                                visible: closeIcon.status !== Image.Ready
                            }
                        }

                        Text {
                            text: "Close"
                            color: isDarkTheme ? "#ffffff" : "#212121"
                            font.pixelSize: vpx(16)
                            font.bold: closeBtn.padFocus
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: gameMenuRoot.navSection = 2
                        onClicked: {
                            if (soundManager) soundManager.playBack();
                            gameMenuRoot.closeMenu();
                        }
                    }
                }
            }
        }

        Item {
            id: renameMenuArea
            visible: renameMode
            anchors.top: sep1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            anchors.bottomMargin: vpx(20)
            focus: renameMode

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape || api.keys.isCancel(event)) {
                    if (soundManager) soundManager.playBack();
                    cancelRename();
                    event.accepted = true;
                }
            }

            Text {
                id: renameSubTxt
                anchors.top: parent.top
                text: "ENTER A NEW NAME"
                color: subtitleColor
                font.pixelSize: vpx(9)
                font.bold: true
                font.capitalization: Font.AllUppercase
            }

            Rectangle {
                id: renameInputBox
                anchors.top: renameSubTxt.bottom
                anchors.topMargin: vpx(8)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(44)
                radius: vpx(8)
                color: itemBg
                border.width: renameInput.activeFocus ? vpx(2) : vpx(1)
                border.color: renameInput.activeFocus ? accentColor : itemBorder

                Behavior on border.color { ColorAnimation { duration: 100 } }

                TextInput {
                    id: renameInput
                    anchors.fill: parent
                    anchors.margins: vpx(12)
                    color: isDarkTheme ? "#ffffff" : "#212121"
                    font.pixelSize: vpx(15)
                    font.bold: true
                    selectByMouse: true
                    verticalAlignment: TextInput.AlignVCenter
                    focus: true
                    onAccepted: saveRename()
                }
            }

            Rectangle {
                id: renameSep
                anchors.top: renameInputBox.bottom
                anchors.topMargin: vpx(14)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(1)
                color: separatorColor
            }

            Row {
                anchors.top: renameSep.bottom
                anchors.topMargin: vpx(14)
                anchors.left: parent.left
                anchors.right: parent.right
                height: vpx(44)
                spacing: vpx(10)

                Rectangle {
                    width: parent.width - cancelRenameBtn.width - vpx(10)
                    height: parent.height
                    color: saveMouse.containsMouse ? "#e0e0e0" : "#ffffff"
                    radius: vpx(25)
                    scale: saveMouse.containsMouse ? 1.02 : 1.0

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    Text {
                        anchors.centerIn: parent
                        text: "Save"
                        color: "#111111"
                        font.pixelSize: vpx(15)
                        font.bold: true
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (soundManager) soundManager.playNav();
                            saveRename();
                        }
                    }
                }

                Rectangle {
                    id: cancelRenameBtn
                    width: vpx(90)
                    height: parent.height
                    color: cancelMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: isDarkTheme ? "#55ffffff" : "#aaaaaa"
                    border.width: vpx(1)

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: isDarkTheme ? "#ffffff" : "#212121"
                        font.pixelSize: vpx(13)
                        font.bold: true
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: cancelRename()
                    }
                }
            }
        }
    }
}
