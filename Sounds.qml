// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import QtQuick 2.15
import QtMultimedia 5.15

Item {
    id: soundManager

    property bool enabled: true
    property real masterVolume: 0.8

    SoundEffect {
        id: navSound
        source: "assets/sounds/nav.wav"
        volume: soundManager.masterVolume
    }

    function playNav() {
        if (!enabled) return;
        navSound.play();
    }

    SoundEffect {
        id: okSound
        source: "assets/sounds/ok.wav"
        volume: soundManager.masterVolume
    }

    function playOk() {
        if (!enabled) return;
        okSound.play();
    }

    SoundEffect {
        id: backSound
        source: "assets/sounds/back.wav"
        volume: soundManager.masterVolume
    }

    function playBack() {
        if (!enabled) return;
        backSound.play();
    }

    SoundEffect {
        id: noticeSound
        source: "assets/sounds/notice.wav"
        volume: soundManager.masterVolume
    }

    function playNotice() {
        if (!enabled) return;
        noticeSound.play();
    }
}
