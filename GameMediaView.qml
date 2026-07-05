// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtGraphicalEffects 1.15
import QtMultimedia 5.15

FocusScope {
    id: root

    property var mediaList: []
    property int startIndex: 0
    property bool lightTheme: false
    property var themeColors: null
    property var soundManager: null

    signal closeRequested()

    readonly property color _bgPrimary: themeColors ? themeColors.background : (lightTheme ? "#dfe3e8" : "#1c222b")
    readonly property color _topBarBg: themeColors ? themeColors.panel : (lightTheme ? "#dfe3e8" : "#1c222b")
    readonly property color _panelBorder: themeColors ? themeColors.panelBorder : (lightTheme ? "#e0e0e0" : "#28282c")
    readonly property color _textPrimary: themeColors ? themeColors.text : (lightTheme ? "#0d1117" : "#ffffff")
    readonly property color _textSecondary: themeColors ? themeColors.textSecondary : (lightTheme ? "#5a6472" : "#607d8b")
    readonly property color _accentColor: themeColors ? themeColors.primary : (lightTheme ? "#2196F3" : "#3a6ea5")
    readonly property color _videoBadgeBg: themeColors ? Qt.rgba(
        parseInt(themeColors.primary.toString().slice(1,3),16)/255,
                                                                 parseInt(themeColors.primary.toString().slice(3,5),16)/255,
                                                                 parseInt(themeColors.primary.toString().slice(5,7),16)/255,
                                                                 0.80)
    : (lightTheme ? "#1a6b7a" : "#cc3db54a")
    readonly property color _videoBadgeText: "#ffffff"
    readonly property color _loadingSpinner: lightTheme ? "#cc0d1117" : "#22ffffff"
    readonly property color _loadingTick: lightTheme ? "#aa0d1117" : "#aaffffff"
    readonly property color _progressBarBg: lightTheme ? "#22000000" : "#40ffffff"
    readonly property color _progressFill: themeColors ? themeColors.text : (lightTheme ? "#0d1117" : "#ffffff")
    readonly property color _thumbBg: themeColors ? themeColors.tileImageBg : (lightTheme ? "#e2e8f0" : "#0d1921")
    readonly property color _thumbBorder: themeColors ? themeColors.text : (lightTheme ? "#0d1117" : "#ffffff")
    readonly property color _thumbOverlay: themeColors ? Qt.rgba(
        parseInt(themeColors.background.toString().slice(1,3),16)/255,
                                                                 parseInt(themeColors.background.toString().slice(3,5),16)/255,
                                                                 parseInt(themeColors.background.toString().slice(5,7),16)/255,
                                                                 0.80)
    : (lightTheme ? "#ccdfe3e8" : "#99000000")
    readonly property color _navBtnBg: lightTheme ? "#22000000" : "#22000000"
    readonly property color _navBtnBorder: themeColors ? themeColors.panelBorder : "#55ffffff"
    readonly property color _navBtnHover: themeColors ? themeColors.primary : "#33ffffff"
    property int _currentIndex: startIndex
    readonly property var _current: mediaList.length > 0 ? mediaList[_currentIndex] : null
    readonly property int _total: mediaList.length

    readonly property string _firstImageSource: {
        for (var i = 0; i < mediaList.length; i++) {
            if (mediaList[i] && !mediaList[i].isVideo)
                return mediaList[i].source
        }
        return ""
    }

    function _prev() {
        if (_currentIndex > 0) {
            if (soundManager) soundManager.playNav();
            _currentIndex--
        }
    }

    function _next() {
        if (_currentIndex < _total - 1) {
            if (soundManager) soundManager.playNav();
            _currentIndex++
        }
    }

    readonly property string _bgImageSource: {
        if (root._current && !root._current.isVideo) return root._current.source
            return root._firstImageSource
    }

    Item {
        id: blurredBackground
        anchors.fill: parent
        z: 0
        clip: true

        Rectangle {
            anchors.fill: parent
            color: _bgPrimary
            Behavior on color { ColorAnimation { duration: 400; easing.type: Easing.InOutQuad } }
        }

        Image {
            id: bgImage
            anchors.fill: parent
            source: root._bgImageSource
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            visible: source !== "" && status === Image.Ready

            layer.enabled: true
            layer.effect: FastBlur {
                radius: 80
            }
            scale: 7.5

            Behavior on source { PropertyAnimation { duration: 0 } }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#AA000000"
    }

    Item {
        id: _topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: vpx(46)

        Rectangle {
            anchors.fill: parent
            color: _topBarBg
            border.color: _panelBorder
            border.width: vpx(1)
            Behavior on color { ColorAnimation { duration: 400 } }
        }

        Text {
            anchors { left: parent.left; leftMargin: vpx(20); verticalCenter: parent.verticalCenter }
            text: root._current ? root._current.label : ""
            color: _textPrimary
            font.pixelSize: vpx(14)
            font.bold: true
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Rectangle {
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            anchors.leftMargin: vpx(20) + (root._current ? Math.min(root._current.label.length * vpx(8.5), vpx(200)) : 0) + vpx(10)
            width: vpx(44); height: vpx(18)
            radius: vpx(3)
            color: _videoBadgeBg
            visible: root._current && root._current.isVideo
            Behavior on color { ColorAnimation { duration: 300 } }

            Text {
                anchors.centerIn: parent
                text: "VIDEO"
                color: _videoBadgeText
                font.pixelSize: vpx(9)
                font.bold: true
                font.letterSpacing: vpx(0.8)
            }
        }

        Text {
            anchors { right: closeBtn.left; rightMargin: vpx(14); verticalCenter: parent.verticalCenter }
            text: root._total > 0 ? (root._currentIndex + 1) + " / " + root._total : ""
            color: _textSecondary
            font.pixelSize: vpx(13)
            font.bold: true
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Rectangle {
            id: closeBtn
            anchors { right: parent.right; rightMargin: vpx(10); verticalCenter: parent.verticalCenter }
            width: vpx(42); height: vpx(42)
            radius: vpx(8)
            color: closeBtnMouse.containsMouse ? _navBtnHover : _navBtnBg
            border.color: _navBtnBorder
            border.width: vpx(1)
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                anchors.centerIn: parent
                text: "×"
                color: _textPrimary
                font.pixelSize: vpx(24)
                font.bold: true
            }

            MouseArea {
                id: closeBtnMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (soundManager) soundManager.playBack();
                    root.closeRequested()
                }
            }
        }
    }

    Item {
        id: _mediaArea
        anchors {
            top: _topBar.bottom; topMargin: vpx(6)
            bottom: _filmStrip.top; bottomMargin: vpx(6)
            left: parent.left;  leftMargin: vpx(76)
            right: parent.right; rightMargin: vpx(76)
        }

        readonly property real _glowPad: vpx(22)

        readonly property rect _imgFitRect: {
            var sw = _img.sourceSize.width
            var sh = _img.sourceSize.height
            if (sw <= 0 || sh <= 0) return Qt.rect(0, 0, width, height)
                var imgAR = sw / sh
                var areaAR = width / height
                var w, h
                if (imgAR > areaAR) { w = width; h = w / imgAR }
                else { h = height; w = h * imgAR }
                return Qt.rect((width - w) / 2, (height - h) / 2, w, h)
        }

        Image {
            id: _img
            anchors.fill: parent
            source: root._current && !root._current.isVideo ? root._current.source : ""
            fillMode: Image.PreserveAspectFit
            asynchronous: true; smooth: true; mipmap: true
            visible: !(root._current && root._current.isVideo)
            opacity: status === Image.Ready ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }

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
            anchors.centerIn: parent
            width: vpx(36); height: vpx(36); radius: vpx(18)
            color: _loadingSpinner
            visible: _img.visible && _img.status === Image.Loading
            Behavior on color { ColorAnimation { duration: 200 } }

            RotationAnimation on rotation {
                from: 0; to: 360
                duration: 900; loops: Animation.Infinite
                running: parent.visible
            }
            Rectangle {
                anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
                width: vpx(3); height: vpx(10); radius: vpx(2)
                color: _loadingTick
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        MediaPlayer {
            id: _mediaPlayer
            autoPlay: false
            source: root._current && root._current.isVideo ? root._current.source : ""

            onSourceChanged: {
                if (source !== "") { seek(0); play() }
                else { stop() }
            }
            onStatusChanged: {
                if (status === MediaPlayer.Loaded || status === MediaPlayer.Buffered) play()
            }
            onStopped: {
                if (source !== "") { seek(0); play() }
            }
        }

        VideoOutput {
            id: _videoOutput
            anchors.fill: parent
            source: _mediaPlayer
            fillMode: VideoOutput.PreserveAspectFit
            visible: root._current !== null && root._current.isVideo

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
            id: _progressBar
            x: _videoOutput.contentRect.x
            y: _videoOutput.contentRect.y + _videoOutput.contentRect.height - height
            width: _videoOutput.contentRect.width
            height: vpx(3)
            color: _progressBarBg
            z: 10
            visible: _videoOutput.visible && _mediaPlayer.duration > 0
            Behavior on color { ColorAnimation { duration: 200 } }

            Rectangle {
                id: _progressFillRect
                anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
                width: _mediaPlayer.duration > 0
                ? parent.width * (_mediaPlayer.position / _mediaPlayer.duration)
                : 0
                color: _progressFill
                Behavior on color { ColorAnimation { duration: 200 } }
            }

            Timer {
                interval: 32
                running: _mediaPlayer.playbackState === MediaPlayer.PlayingState
                repeat: true
                property real _lastTimestamp: 0
                onTriggered: {
                    var now = Date.now()
                    var elapsed = now - _lastTimestamp
                    if (_mediaPlayer.playbackState === MediaPlayer.PlayingState && _mediaPlayer.duration > 0) {
                        var interp = Math.min(_mediaPlayer.position + elapsed, _mediaPlayer.duration)
                        _progressFillRect.width = _progressBar.width * (interp / _mediaPlayer.duration)
                    }
                    _lastTimestamp = now
                }
                onRunningChanged: { if (running) _lastTimestamp = Date.now() }
            }
        }
    }

    Rectangle {
        anchors { left: parent.left; leftMargin: vpx(8); verticalCenter: _mediaArea.verticalCenter }
        width: vpx(56); height: vpx(100)
        radius: vpx(10)
        color: navLeftMouse.containsMouse ? _navBtnHover : _navBtnBg
        border.color: "white"; border.width: vpx(2)
        visible: root._currentIndex > 0
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "‹"
            color: "white"
            font.pixelSize: vpx(38)
            font.bold: true
        }
        MouseArea {
            id: navLeftMouse
            anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: root._prev()
        }
    }

    Rectangle {
        anchors { right: parent.right; rightMargin: vpx(8); verticalCenter: _mediaArea.verticalCenter }
        width: vpx(56); height: vpx(100)
        radius: vpx(10)
        color: navRightMouse.containsMouse ? _navBtnHover : _navBtnBg
        border.color: "white"; border.width: vpx(2)
        visible: root._currentIndex < root._total - 1
        Behavior on color { ColorAnimation { duration: 120 } }

        Text {
            anchors.centerIn: parent
            text: "›"
            color: "white"
            font.pixelSize: vpx(38)
            font.bold: true
        }
        MouseArea {
            id: navRightMouse
            anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: root._next()
        }
    }

    VideoVolumeControl {
        id: _volumeControl
        mediaPlayer: _mediaPlayer
        screenWidth: root.width
        lightTheme: root.lightTheme

        anchors {
            right: _mediaArea.right; rightMargin: vpx(14)
            top: _mediaArea.verticalCenter; topMargin: vpx(-15)
        }

        visible: root._current !== null && root._current.isVideo
        opacity: visible ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 180 } }
    }

    Item {
        id: _filmStrip
        anchors {
            bottom: parent.bottom; bottomMargin: vpx(14)
            left: parent.left; right: parent.right
        }
        height: vpx(96)

        ListView {
            id: _strip
            anchors.centerIn: parent
            width: Math.min(parent.width - vpx(40), contentWidth)
            height: parent.height
            orientation: ListView.Horizontal
            spacing: vpx(8)
            interactive: false
            clip: true
            model: root.mediaList
            currentIndex: root._currentIndex
            preferredHighlightBegin: width / 2 - vpx(64)
            preferredHighlightEnd:   width / 2 + vpx(64)
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 220

            delegate: Item {
                width: vpx(128); height: vpx(96)

                Rectangle {
                    id: _sThumb
                    anchors.fill: parent
                    radius: vpx(5)
                    color: "transparent"
                    Behavior on color { ColorAnimation { duration: 300 } }
                    layer.enabled: true

                    Image {
                        anchors.fill: parent
                        source: modelData.isVideo ? "" : modelData.source
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true; mipmap: true
                        visible: !modelData.isVideo
                    }

                    Item {
                        anchors.fill: parent
                        visible: modelData.isVideo
                        Image {
                            anchors.fill: parent
                            source: root.mediaList.length > 0 && root.mediaList[0] && !root.mediaList[0].isVideo
                            ? root.mediaList[0].source : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true; mipmap: true
                            opacity: 0.3
                        }
                        Image {
                            id: _playIcon
                            anchors.centerIn: parent
                            width: vpx(32); height: vpx(32)
                            source: "assets/icons/video.svg"
                            sourceSize.width: vpx(32)
                            sourceSize.height: vpx(32)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "▶"
                            color: "white"
                            font.pixelSize: vpx(32)
                            visible: _playIcon.status !== Image.Ready
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: vpx(2)
                        color: "transparent"
                        border.width: index === root._currentIndex ? vpx(5) : 0
                        border.color: index === root._currentIndex ? _accentColor : "transparent"
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }

                Rectangle {
                    anchors.fill: _sThumb
                    radius: vpx(3)
                    color: "transparent"
                    opacity: index === root._currentIndex ? 0.0 : 0.45
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                    Behavior on color { ColorAnimation { duration: 300 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (soundManager) soundManager.playNav();
                        root._currentIndex = index
                    }
                }
            }
        }
    }

    Keys.onPressed: {
        if (!event.isAutoRepeat && api.keys.isCancel(event)) {
            event.accepted = true
            if (soundManager) soundManager.playBack();
            root.closeRequested()
            return
        }
        if (event.key === Qt.Key_Left || (!event.isAutoRepeat && api.keys.isPrevPage(event))) {
            event.accepted = true; root._prev(); return
        }
        if (event.key === Qt.Key_Right || (!event.isAutoRepeat && api.keys.isNextPage(event))) {
            event.accepted = true; root._next(); return
        }
        if (root._current && root._current.isVideo) {
            if (event.key === Qt.Key_Up) {
                event.accepted = true; _volumeControl.volumeUp(); return
            }
            if (event.key === Qt.Key_Down) {
                event.accepted = true; _volumeControl.volumeDown(); return
            }
        }
    }
}
