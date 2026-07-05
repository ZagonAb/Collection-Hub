// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtGraphicalEffects 1.15

Item {
    id: volumeControl

    property var mediaPlayer: null
    property real screenWidth: 1280
    property bool lightTheme: false

    readonly property color _btnBg: lightTheme ? Qt.rgba(0,0,0,0.13) : "#22000000"
    readonly property color _btnBorder: lightTheme ? "#0d1117" : "#55ffffff"
    readonly property color _btnHoverBg: lightTheme ? Qt.rgba(0,0,0,0.22) : "#33ffffff"
    readonly property color _iconColor: lightTheme ? "#0d1117" : "#ffffff"
    readonly property color _barBg: lightTheme ? Qt.rgba(0,0,0,0.20) : "#44ffffff"
    readonly property color _barFill: lightTheme ? "#0d1117" : "#ffffff"
    readonly property color _knobColor: lightTheme ? "#0d1117" : "#ffffff"
    readonly property color _shadowColor: lightTheme ? "#40000000" : "#80000000"

    function px(v) { return v * (screenWidth / 1280) }

    width:  px(52)
    height: px(52 + 12 + 200)

    property real _volume: 1.0
    property bool _muted:  false

    Component.onCompleted: {
        var savedVol = api.memory.get("videoVolume")
        var savedMute = api.memory.get("videoMuted")
        if (savedVol !== undefined && savedVol !== null) {
            var v = parseFloat(savedVol)
            if (!isNaN(v)) _volume = Math.max(0.0, Math.min(1.0, v))
        }
        if (savedMute !== undefined && savedMute !== null) {
            _muted = (savedMute === true || savedMute === "true" || savedMute === 1)
        }
        _applyVolume()
    }

    function _applyVolume() {
        if (!mediaPlayer) return
        mediaPlayer.volume = _muted ? 0.0 : _volume
    }

    function _saveState() {
        api.memory.set("videoVolume", _volume)
        api.memory.set("videoMuted", _muted)
    }

    function volumeUp() {
        if (_muted) _muted = false
        _volume = Math.min(1.0, _volume + 0.05)
        _applyVolume(); _saveState()
    }

    function volumeDown() {
        _volume = Math.max(0.0, _volume - 0.05)
        if (_volume <= 0.001) { _volume = 0.0; _muted = true }
        _applyVolume(); _saveState()
    }

    function toggleMute() {
        _muted = !_muted
        if (!_muted && _volume <= 0.001) _volume = 0.5
        _applyVolume(); _saveState()
    }

    Rectangle {
        id: _btn
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        width: px(52)
        height: px(52)
        radius: px(10)
        color: _btnMA.containsMouse ? _btnHoverBg : _btnBg
        border.color: "white"
        border.width: px(1)
        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Item {
            anchors.centerIn: parent
            width: px(32); height: px(32)

            Image {
                id: _iconSrc
                anchors.fill: parent
                source: (_muted || _volume <= 0.001)
                        ? "assets/icons/mute.png"
                        : "assets/icons/unmute.png"
                fillMode: Image.PreserveAspectFit
                mipmap: true
                visible: false
            }

            ColorOverlay {
                id: _iconOverlay
                anchors.fill: parent
                source: _iconSrc
                color: "white"
                Behavior on color { ColorAnimation { duration: 300 } }
            }

            SequentialAnimation {
                running: _muted; loops: Animation.Infinite
                NumberAnimation { target: _iconOverlay; property: "opacity"; to: 0.35; duration: 650; easing.type: Easing.InOutSine }
                NumberAnimation { target: _iconOverlay; property: "opacity"; to: 1.0;  duration: 650; easing.type: Easing.InOutSine }
                onStopped: _iconOverlay.opacity = 1.0
            }
        }

        MouseArea {
            id: _btnMA
            anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: {
                volumeControl.toggleMute()
                volumeControl.parent.forceActiveFocus()
            }
        }
    }

    Item {
        id: _bar
        anchors {
            top: _btn.bottom
            topMargin: px(12)
            horizontalCenter: parent.horizontalCenter
        }
        width: px(52); height: px(200)

        readonly property real _effVol: (_muted || _volume <= 0.001) ? 0.0 : _volume

        Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: px(8); radius: px(4)
            color: "#615e5b"
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        Rectangle {
            id: _fill
            anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            width: px(8); radius: px(4)
            height: _bar.height * _bar._effVol
            Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
            color: "white"
            Behavior on color { ColorAnimation { duration: 200 } }
        }

        Rectangle {
            id: _knob
            anchors.horizontalCenter: parent.horizontalCenter
            y: _bar.height * (1.0 - _bar._effVol) - px(10)
            width: px(20); height: px(20); radius: px(10)
            color: "white"
            Behavior on y { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 200 } }
            layer.enabled: true
            layer.effect: DropShadow {
                radius: 6; samples: 13; color: _shadowColor; verticalOffset: 1
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        MouseArea {
            anchors.fill: parent
            preventStealing: true
            cursorShape: Qt.SizeVerCursor

            function applyMouse(my) {
                var ratio = 1.0 - Math.max(0.0, Math.min(1.0, my / _bar.height))
                _volume = (ratio <= 0.02) ? 0.0 : ratio
                _muted = (_volume === 0.0)
                _applyVolume()
                _saveState()
            }

            onPressed: applyMouse(mouseY)
            onPositionChanged: { if (pressed) applyMouse(mouseY) }
        }
    }
}
