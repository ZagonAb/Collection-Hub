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
    id: root

    property var gameData
    property var detailColors: ({})
    property bool isDarkTheme: true

    signal close()
    signal launchRequested()
    signal favoriteToggled()

    property int currentButton: 0

    readonly property bool galleryAvailable: {
        if (!root.gameData || !root.gameData.assets) return false
        var list = root.buildMediaList()
        if (list.length === 0) return false
        if (list.length === 1 && list[0].label === "Box Front") return false
        return true
    }

    readonly property bool infoAvailable: {
        if (!root.gameData) return false
        var g = root.gameData
        var hasMetadata = !!(
            (g.developer && g.developer !== "") ||
            (g.publisher && g.publisher !== "") ||
            (g.genre && g.genre !== "") ||
            (g.description && g.description !== "") ||
            (g.rating && g.rating > 0) ||
            (g.releaseYear && g.releaseYear > 0) ||
            (g.players && g.players > 1)
        )
        var hasStats = !!(
            (g.playCount  && g.playCount > 0) ||
            (g.playTime   && g.playTime > 0) ||
            (g.lastPlayed && !isNaN(g.lastPlayed.getTime()))
        )
        return hasMetadata || hasStats
    }

    anchors.fill: parent
    focus: true

    Component.onCompleted: {
        currentButton = 0
        forceActiveFocus()
    }

    function buildMediaList() {
        if (!root.gameData || !root.gameData.assets) return []
            var assets = root.gameData.assets
            var all = []

            if (assets.screenshotList && assets.screenshotList.length > 0) {
                for (var i = 0; i < assets.screenshotList.length; i++) {
                    var ss = assets.screenshotList[i]
                    if (ss && ss.toString() !== "")
                        all.push({ source: ss,
                            label: "Screenshot" + (assets.screenshotList.length > 1 ? " "+(i+1) : ""),
                                 isVideo: false, orderPriority: 1 })
                }
            } else if (assets.screenshot && assets.screenshot.toString() !== "") {
                all.push({ source: assets.screenshot, label: "Screenshot",
                    isVideo: false, orderPriority: 1 })
            }

            if (assets.titlescreenList && assets.titlescreenList.length > 0) {
                for (var j = 0; j < assets.titlescreenList.length; j++) {
                    var ts = assets.titlescreenList[j]
                    if (ts && ts.toString() !== "")
                        all.push({ source: ts,
                            label: "Title Screen" + (assets.titlescreenList.length > 1 ? " "+(j+1) : ""),
                                 isVideo: false, orderPriority: 2 })
                }
            } else if (assets.titlescreen && assets.titlescreen.toString() !== "") {
                all.push({ source: assets.titlescreen, label: "Title Screen",
                    isVideo: false, orderPriority: 2 })
            }

            var others = [
                { prop: "logo", label: "Logo", p: 3 },
                { prop: "boxFront", label: "Box Front", p: 4 },
                { prop: "boxFull", label: "Box Full", p: 5 },
                { prop: "boxBack", label: "Box Back", p: 6 },
                { prop: "boxSpine", label: "Box Spine", p: 7 },
                { prop: "background", label: "Background", p: 8 },
                { prop: "banner", label: "Banner", p: 9 },
                { prop: "poster", label: "Poster", p: 10 },
                { prop: "tile", label: "Tile", p: 11 },
                { prop: "steam", label: "Steam Grid", p: 12 },
                { prop: "marquee", label: "Marquee", p: 13 },
                { prop: "bezel", label: "Bezel", p: 14 },
                { prop: "panel", label: "Panel", p: 15 },
                { prop: "cabinetLeft", label: "Cabinet L", p: 16 },
                { prop: "cabinetRight", label: "Cabinet R", p: 17 },
                { prop: "cartridge", label: "Cartridge", p: 18 }
            ]
            for (var k = 0; k < others.length; k++) {
                var a = others[k]
                var ln = a.prop + "List"
                if (assets[ln] && assets[ln].length > 0) {
                    for (var l = 0; l < assets[ln].length; l++) {
                        var ls = assets[ln][l]
                        if (ls && ls.toString() !== "")
                            all.push({ source: ls,
                                label: a.label + (assets[ln].length > 1 ? " "+(l+1) : ""),
                                     isVideo: false, orderPriority: a.p })
                    }
                } else if (assets[a.prop] && assets[a.prop].toString() !== "") {
                    all.push({ source: assets[a.prop], label: a.label,
                        isVideo: false, orderPriority: a.p })
                }
            }

            if (assets.videoList && assets.videoList.length > 0) {
                for (var m = 0; m < assets.videoList.length; m++) {
                    var vs = assets.videoList[m]
                    if (vs && vs.toString() !== "")
                        all.push({ source: vs,
                            label: "Video" + (assets.videoList.length > 1 ? " "+(m+1) : ""),
                                 isVideo: true, orderPriority: 99 })
                }
            } else if (assets.video && assets.video.toString() !== "") {
                all.push({ source: assets.video, label: "Video",
                    isVideo: true, orderPriority: 99 })
            }

            all.sort(function(a, b) { return a.orderPriority - b.orderPriority })
            return all
    }

    function isButtonDisabled(index) {
        if (index === 2 && !root.galleryAvailable) return true
        if (index === 3 && !root.infoAvailable)    return true
        return false
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Left) {
            var prev = currentButton - 1
            while (prev > 0 && root.isButtonDisabled(prev)) prev--
            currentButton = Math.max(0, prev)
            event.accepted = true

        } else if (event.key === Qt.Key_Right) {
            var next = currentButton + 1
            while (next < 5 && root.isButtonDisabled(next)) next++
            currentButton = Math.min(5, next)
            event.accepted = true

        } else if (!event.isAutoRepeat && api.keys.isAccept(event)) {
            if      (currentButton === 0) { root.launchRequested() }
            else if (currentButton === 1) { root.favoriteToggled() }
            else if (currentButton === 2 && root.galleryAvailable) { openGallery() }
            else if (currentButton === 3 && root.infoAvailable)    { openInfo() }
            else if (currentButton === 4) { openRaInfo() }
            else if (currentButton === 5) { root.close() }
            event.accepted = true

        } else if (api.keys.isCancel(event)) {
            root.close()
            event.accepted = true
        }
    }

    function openGallery() {
        galleryLoader.active = true
    }

    function closeGallery() {
        galleryLoader.active = false
        root.forceActiveFocus()
    }

    function openInfo() {
        infoLoader.active = true
    }

    function closeInfo() {
        infoLoader.active = false
        root.forceActiveFocus()
    }

    function openRaInfo() {
        raInfoLoader.active = true
    }

    function closeRaInfo() {
        raInfoLoader.active = false
        root.forceActiveFocus()
    }

    Item {
        id: blurredBackground
        anchors.fill: parent
        z: 0
        clip: true

        Image {
            id: bgImage
            anchors.fill: parent
            source: root.gameData && root.gameData.assets
            ? (root.gameData.assets.boxFront || "")
            : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: source !== "" && status === Image.Ready

            layer.enabled: true
            layer.effect: FastBlur {
                radius: 80
            }
            scale: 7.5
        }

        Rectangle {
            anchors.fill: parent
            color: root.detailColors.background || "#151519"
            visible: bgImage.source === "" || bgImage.status !== Image.Ready
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#AA000000"
        z: 1
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: vpx(52)
        z: 2
        visible: !infoLoader.active && !raInfoLoader.active
        opacity: (infoLoader.active || raInfoLoader.active) ? 0 : 1
        Behavior on opacity { NumberAnimation { duration: 180 } }

        Item {
            id: boxArtContainer
            width: vpx(405)
            height: vpx(505)
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: boxArt
                anchors.fill: parent
                source: root.gameData && root.gameData.assets
                ? (root.gameData.assets.boxFront || "")
                : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: source !== "" && status === Image.Ready

                layer.enabled: visible
                layer.effect: DropShadow {
                    horizontalOffset: vpx(0)
                    verticalOffset: vpx(8)
                    radius: vpx(24)
                    samples: 32
                    color: "#CC000000"
                    spread: 0.0
                    transparentBorder: true
                }
            }

            Rectangle {
                id: fallbackContainer
                anchors.fill: parent
                color: root.detailColors.tileImageBg || "#0f0f0f"
                radius: vpx(14)
                visible: boxArt.source === "" || boxArt.status !== Image.Ready

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: vpx(0)
                    verticalOffset: vpx(8)
                    radius: vpx(24)
                    samples: 32
                    color: "#CC000000"
                    spread: 0.0
                    transparentBorder: true
                }

                Item {
                    id: fallbackIconContainer
                    anchors.centerIn: parent
                    width: vpx(100)
                    height: vpx(100)
                    visible: fallbackImage.source !== ""

                    Image {
                        id: fallbackImage
                        anchors.fill: parent
                        source: {
                            if (root.gameData && root.gameData.collections && root.gameData.collections.count > 0) {
                                var firstColl = root.gameData.collections.get(0)
                                var shortName = firstColl.shortName || firstColl.name
                                if (shortName) {
                                    return "assets/systems/" + shortName.toLowerCase() + ".png"
                                }
                            }
                            return ""
                        }
                        fillMode: Image.PreserveAspectFit
                        visible: source !== "" && status === Image.Ready
                        mipmap: true
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "?"
                    font.pixelSize: vpx(72)
                    color: "#ffffff"
                    visible: !fallbackIconContainer.visible
                }
            }
        }

        Column {
            width: vpx(460)
            anchors.verticalCenter: parent.verticalCenter
            spacing: vpx(12)

            Text {
                width: parent.width
                text: root.gameData ? root.gameData.title : ""
                color: "#ffffff"
                font.pixelSize: vpx(42)
                font.bold: true
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.gameData && root.gameData.developer
                ? root.gameData.developer
                : "Unknown"
                color: "#ffffff"
                font.pixelSize: vpx(16)
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                text: "Last played: " + (root.gameData && root.gameData.lastPlayed &&
                !isNaN(root.gameData.lastPlayed.getTime())
                ? root.gameData.lastPlayed.toLocaleDateString()
                : "Never")
                color: "#cccccc"
                font.pixelSize: vpx(14)
            }

            Text {
                visible: root.gameData && root.gameData.playTime > 0
                text: "Play time: " + Utils.formatPlayTime(root.gameData ? root.gameData.playTime : 0)
                color: "#cccccc"
                font.pixelSize: vpx(14)
            }

            Row {
                spacing: vpx(10)
                topPadding: vpx(8)

                Item {
                    width: vpx(136)
                    height: vpx(46)

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width + vpx(6)
                        height: parent.height + vpx(6)
                        radius: vpx(26)
                        color: "transparent"
                        border.color: "#ffffff"
                        border.width: vpx(2)
                        opacity: root.currentButton === 0 ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: launchMouse.containsMouse ? "#e8e8e8" : "#ffffff"
                        radius: vpx(23)

                        scale: root.currentButton === 0 ? 1.05 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors.centerIn: parent
                            text: "Play"
                            color: "#111111"
                            font.pixelSize: vpx(22)
                            font.bold: true
                        }

                        MouseArea {
                            id: launchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: root.currentButton = 0
                            onClicked: root.launchRequested()
                        }
                    }
                }

                Rectangle {
                    width: vpx(46)
                    height: vpx(46)
                    color: favMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: root.currentButton === 1 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 1 ? vpx(2) : vpx(1)

                    scale: root.currentButton === 1 ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(32)
                        height: vpx(32)

                        Image {
                            id: favIcon
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectFit
                            source: root.gameData && root.gameData.favorite
                            ? "assets/icons/favorite-on.svg"
                            : "assets/icons/favorite-off.svg"
                            mipmap: true
                        }
                    }

                    MouseArea {
                        id: favMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentButton = 1
                        onClicked: root.favoriteToggled()
                    }
                }

                Rectangle {
                    id: galleryBtn
                    width: vpx(46)
                    height: vpx(46)
                    color: (!root.galleryAvailable) ? "#11000000"
                           : galleryMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: (!root.galleryAvailable) ? "#22ffffff"
                                  : root.currentButton === 2 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 2 ? vpx(2) : vpx(1)
                    opacity: root.galleryAvailable ? 1.0 : 0.35

                    scale: root.currentButton === 2 ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(32)
                        height: vpx(32)

                        Image {
                            id: galleryIcon
                            anchors.fill: parent
                            source: "assets/icons/gallery.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: galleryIcon
                            source: galleryIcon
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: galleryMouse
                        anchors.fill: parent
                        hoverEnabled: root.galleryAvailable
                        cursorShape: root.galleryAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: if (root.galleryAvailable) root.currentButton = 2
                        onClicked: if (root.galleryAvailable) root.openGallery()
                    }
                }

                Rectangle {
                    id: infoBtn
                    width: vpx(46)
                    height: vpx(46)
                    color: (!root.infoAvailable) ? "#11000000"
                           : infoMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: (!root.infoAvailable) ? "#22ffffff"
                                  : root.currentButton === 3 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 3 ? vpx(2) : vpx(1)
                    opacity: root.infoAvailable ? 1.0 : 0.35

                    scale: root.currentButton === 3 ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(32)
                        height: vpx(32)

                        Image {
                            id: infoIcon
                            anchors.fill: parent
                            source: "assets/icons/info.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: infoIcon
                            source: infoIcon
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: infoMouse
                        anchors.fill: parent
                        hoverEnabled: root.infoAvailable
                        cursorShape: root.infoAvailable ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: if (root.infoAvailable) root.currentButton = 3
                        onClicked: if (root.infoAvailable) root.openInfo()
                    }
                }

                Rectangle {
                    id: raBtn
                    width: vpx(46)
                    height: vpx(46)
                    color: raMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: root.currentButton === 4 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 4 ? vpx(2) : vpx(1)

                    scale: root.currentButton === 4 ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(32)
                        height: vpx(32)

                        Image {
                            id: raIcon
                            anchors.fill: parent
                            source: "assets/icons/ra.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: raIcon
                            source: raIcon
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: raMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentButton = 4
                        onClicked: root.openRaInfo()
                    }
                }

                Rectangle {
                    width: vpx(46)
                    height: vpx(46)
                    color: backMouse.containsMouse ? "#33ffffff" : "#22000000"
                    radius: vpx(10)
                    border.color: root.currentButton === 5 ? "#ffffff" : "#55ffffff"
                    border.width: root.currentButton === 5 ? vpx(2) : vpx(1)

                    scale: root.currentButton === 5 ? 1.08 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    Item {
                        anchors.centerIn: parent
                        width: vpx(32)
                        height: vpx(32)

                        Image {
                            id: backIcon
                            anchors.fill: parent
                            source: "assets/icons/back.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }

                        ColorOverlay {
                            anchors.fill: backIcon
                            source: backIcon
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: backMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: root.currentButton = 5
                        onClicked: root.close()
                    }
                }
            }
        }
    }

    Loader {
        id: galleryLoader
        anchors.fill: parent
        active: false
        z: 10

        sourceComponent: Component {
            GameMediaView {
                anchors.fill: parent
                mediaList: root.buildMediaList()
                startIndex: 0
                lightTheme: !root.isDarkTheme
                themeColors: root.detailColors
                onCloseRequested: root.closeGallery()
            }
        }

        onActiveChanged: {
            if (active) {
                Qt.callLater(function() {
                    if (galleryLoader.item)
                        galleryLoader.item.forceActiveFocus()
                })
            }
        }
    }

    Loader {
        id: infoLoader
        anchors.fill: parent
        active: false
        z: 11

        sourceComponent: Component {
            GameInfoView {
                anchors.fill: parent
                gameData: root.gameData
                themeColors: root.detailColors
                isDarkTheme: root.isDarkTheme
                onCloseRequested: root.closeInfo()
            }
        }

        onActiveChanged: {
            if (active) {
                Qt.callLater(function() {
                    if (infoLoader.item)
                        infoLoader.item.forceActiveFocus()
                })
            }
        }
    }

    Loader {
        id: raInfoLoader
        anchors.fill: parent
        active: false
        z: 12

        sourceComponent: Component {
            RAGameInfoSection {
                anchors.fill: parent
                gameData: root.gameData
                themeColors: root.detailColors
                isDarkTheme: root.isDarkTheme
                onCloseRequested: root.closeRaInfo()
            }
        }

        onActiveChanged: {
            if (active) {
                Qt.callLater(function() {
                    if (raInfoLoader.item)
                        raInfoLoader.item.forceActiveFocus()
                })
            }
        }
    }
}
