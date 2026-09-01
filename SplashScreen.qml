// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: splash
    anchors.fill: parent
    z: 1000

    property var themeColors: ({})
    property string titleText: "COLLECTION HUB"
    property string subtitleText: "Loading your library..."
    property int minSplashDuration: 1500

    // Set this from the outside (e.g. root.interfaceReady) once the app
    // actually finished loading. The splash stays up until BOTH this is
    // true AND the minimum duration timer below has elapsed.
    property bool interfaceReady: false

    property bool _minTimeElapsed: false
    readonly property bool hidden: interfaceReady && _minTimeElapsed

    signal splashFinished()

    color: themeColors.background || "#000000"
    opacity: hidden ? 0 : 1
    visible: opacity > 0

    onHiddenChanged: {
        if (hidden) splash.splashFinished();
    }

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    Timer {
        interval: splash.minSplashDuration
        running: true
        repeat: false
        onTriggered: splash._minTimeElapsed = true
    }

    MouseArea {
        anchors.fill: parent
        enabled: splash.visible
    }

    Column {
        anchors.centerIn: parent
        spacing: vpx(18)

        Text {
            id: hubTitleText
            anchors.horizontalCenter: parent.horizontalCenter
            text: splash.titleText
            color: splash.themeColors.text || "#ffffff"
            font.pixelSize: vpx(45)
            font.bold: true
            font.letterSpacing: vpx(1)

            opacity: 0
            scale: 0.8

            transform: Translate {
                id: titleTranslate
                y: -vpx(14)
                Behavior on y { NumberAnimation { duration: 550; easing.type: Easing.OutCubic } }
            }

            Behavior on opacity { NumberAnimation { duration: 550; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 550; easing.type: Easing.OutBack } }

            Component.onCompleted: {
                opacity = 1;
                scale = 1;
                titleTranslate.y = 0;
            }

            property real glowPulse: 0.7
            SequentialAnimation on glowPulse {
                loops: Animation.Infinite
                running: splash.visible
                NumberAnimation { from: 0.7; to: 1.3; duration: 1400; easing.type: Easing.InOutSine }
                NumberAnimation { from: 1.3; to: 0.7; duration: 1400; easing.type: Easing.InOutSine }
            }

            layer.enabled: true
            layer.effect: Glow {
                radius: vpx(20) * hubTitleText.glowPulse
                samples: 32
                spread: 0.35
                color: "#80FFFFFF"
                transparentBorder: true
            }
        }

        Row {
            id: dotsRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: vpx(10)

            opacity: 0
            scale: 0.6

            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 400; easing.type: Easing.OutBack } }

            SequentialAnimation {
                running: true
                PauseAnimation { duration: 280 }
                ScriptAction {
                    script: {
                        dotsRow.opacity = 1;
                        dotsRow.scale = 1;
                    }
                }
            }

            Repeater {
                model: 3
                Rectangle {
                    width: vpx(15)
                    height: vpx(15)
                    radius: width / 2
                    color: splash.themeColors.primary || "#2d5c8f"

                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: splash.visible
                        PauseAnimation { duration: index * 140 }
                        NumberAnimation { from: 0.25; to: 1.0; duration: 320; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.0; to: 0.25; duration: 320; easing.type: Easing.InOutQuad }
                    }

                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        running: splash.visible
                        PauseAnimation { duration: index * 140 }
                        NumberAnimation { from: 0.85; to: 1.15; duration: 320; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 1.15; to: 0.85; duration: 320; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        Text {
            id: loadingText
            anchors.horizontalCenter: parent.horizontalCenter
            text: splash.subtitleText
            color: splash.themeColors.textSecondary || "#b0b0b0"
            font.pixelSize: vpx(24)

            opacity: 0

            transform: Translate {
                id: loadingTranslate
                y: vpx(10)
                Behavior on y { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }
            }

            Behavior on opacity { NumberAnimation { duration: 450; easing.type: Easing.OutCubic } }

            SequentialAnimation {
                running: true
                PauseAnimation { duration: 480 }
                ScriptAction {
                    script: {
                        loadingText.opacity = 1;
                        loadingTranslate.y = 0;
                    }
                }
            }
        }
    }
}
