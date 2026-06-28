import QtQuick 2.15
// Collection Hub Theme
// Copyright (C) 2026 Gonzalo
//
// Licensed under Creative Commons
// Attribution-NonCommercial-ShareAlike 4.0 International.
//
// https://creativecommons.org/licenses/by-nc-sa/4.0/
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.12
import "utils.js" as Utils

Rectangle {
    id: gridContainer
    color: "transparent"

    property int selectedCollectionId: -1
    property string selectedCollectionName: ""
    property var collectionGameTitles: []
    property var systemCollection: null
    property string searchFilter: ""
    property int sortOrder: 0
    property bool isAllGamesSelected: false
    property var themeColors: ({})
    property bool isDarkTheme: true
    property var focusManager: null
    property alias gridView: gamesGridView
    property bool scrollbarReady: false
    property var customCollections: []
    property var addGameLoaderRef: null
    property int activeLetterIdx: -1
    property bool letterFilterActive: false
    property string activeLetter: ""
    property var letterIndex: []
    property var filteredRealRefs: []
    property var displayRealRefs: []

    property color scrollbarColor: {
        if (systemCollection && systemCollection.shortName) {
            var mapped = colorMapper.getColor(systemCollection.shortName);
            if (mapped !== "#000000" && mapped !== "")
                return mapped;
        }
        return themeColors.primaryHover || "#5a8ec5";
    }

    signal gameRightClicked(var game, int x, int y)
    signal showGameDetail(var game)
    signal requestAddGame(var game)
    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection(int collectionId)

    onRequestAddGame: function(game) {
        addGameLoader.openForGame(game);
    }

    ListModel { id: filteredModel }

    ListModel { id: displayModel }

    ColorMapping { id: colorMapper }

    Component.onCompleted: {
        Qt.callLater(updateFilteredModel);
    }

    function buildLetterIndex() {
        var seen = {};
        var letters = [];
        for (var i = 0; i < filteredModel.count; i++) {
            var title = filteredModel.get(i).title || "";
            var ch = title.charAt(0).toUpperCase();
            ch = ch.replace(/[AÁÀÄÂ]/g, "A")
            .replace(/[EÉÈËÊ]/g, "E")
            .replace(/[IÍÌÏÎ]/g, "I")
            .replace(/[OÓÒÖÔ]/g, "O")
            .replace(/[UÚÙÜÛ]/g, "U");
            if (!seen[ch]) {
                seen[ch] = true;
                letters.push(ch);
            }
        }
        letters.sort(function(a, b) {
            var aNum = (a >= "0" && a <= "9");
            var bNum = (b >= "0" && b <= "9");
            if (aNum && !bNum) return -1;
            if (!aNum && bNum) return 1;
            return a < b ? -1 : a > b ? 1 : 0;
        });
        letterIndex = letters;
    }

    function applyLetterFilter() {
        displayModel.clear();
        var newDisplayRefs = [];

        if (!letterFilterActive || activeLetterIdx < 0 || activeLetterIdx >= letterIndex.length) {
            for (var i = 0; i < filteredModel.count; i++) {
                displayModel.append(filteredModel.get(i));
                newDisplayRefs.push(filteredRealRefs[i]);
            }
            activeLetter = "";
            displayRealRefs = newDisplayRefs;
            return;
        }

        var target = letterIndex[activeLetterIdx];
        activeLetter = target;

        for (var i = 0; i < filteredModel.count; i++) {
            var item = filteredModel.get(i);
            var ch = (item.title || "").charAt(0).toUpperCase()
            .replace(/[AÁÀÄÂ]/g, "A")
            .replace(/[EÉÈËÊ]/g, "E")
            .replace(/[IÍÌÏÎ]/g, "I")
            .replace(/[OÓÒÖÔ]/g, "O")
            .replace(/[UÚÙÜÛ]/g, "U");
            if (ch === target) {
                displayModel.append(item);
                newDisplayRefs.push(filteredRealRefs[i]);
            }
        }
        displayRealRefs = newDisplayRefs;
    }

    function goNextLetter() {
        if (letterIndex.length === 0) return;
        if (!letterFilterActive) {
            activeLetterIdx = 0;
            letterFilterActive = true;
        } else if (activeLetterIdx >= letterIndex.length - 1) {
            activeLetterIdx = -1;
            letterFilterActive = false;
        } else {
            activeLetterIdx = activeLetterIdx + 1;
        }
        applyLetterFilter();
        gamesGridView.currentIndex = 0;
        letterHud.triggerShow();
    }

    function goPrevLetter() {
        if (letterIndex.length === 0) return;
        if (!letterFilterActive) {
            activeLetterIdx = letterIndex.length - 1;
            letterFilterActive = true;
        } else if (activeLetterIdx <= 0) {
            activeLetterIdx = -1;
            letterFilterActive = false;
        } else {
            activeLetterIdx = activeLetterIdx - 1;
        }
        applyLetterFilter();
        gamesGridView.currentIndex = 0;
        letterHud.triggerShow();
    }

    function updateFilteredModel() {
        filteredModel.clear();
        var newFilteredRefs = [];

        var sourceGames = [];
        var seenTitles = {};

        if (searchFilter.trim() !== "") {
            for (var i = 0; i < api.allGames.count; i++) {
                var g = api.allGames.get(i);
                if (g && g.title && !seenTitles[g.title]) {
                    var fl = searchFilter.toLowerCase();
                    if (g.title.toLowerCase().indexOf(fl) !== -1 ||
                        (g.developer && g.developer.toLowerCase().indexOf(fl) !== -1) ||
                        (g.publisher && g.publisher.toLowerCase().indexOf(fl) !== -1) ||
                        (g.genre && g.genre.toLowerCase().indexOf(fl) !== -1)) {
                        sourceGames.push(g);
                    seenTitles[g.title] = true;
                        }
                }
            }
        } else {
            if (systemCollection !== null) {
                for (var i = 0; i < systemCollection.games.count; i++) {
                    var game = systemCollection.games.get(i);
                    if (game && game.title && !seenTitles[game.title]) {
                        sourceGames.push(game);
                        seenTitles[game.title] = true;
                    }
                }
            } else if (selectedCollectionId === -1) {
                for (var i = 0; i < api.allGames.count; i++) {
                    var game = api.allGames.get(i);
                    if (game && game.title && !seenTitles[game.title]) {
                        sourceGames.push(game);
                        seenTitles[game.title] = true;
                    }
                }
            } else {
                var foundPaths = {};
                var foundTitles = {};
                for (var i = 0; i < collectionGameTitles.length; i++) {
                    var entry = collectionGameTitles[i];
                    if (entry && entry.indexOf("/") !== -1) {
                        foundPaths[entry] = true;
                    } else {
                        foundTitles[entry] = true;
                    }
                }
                for (var i = 0; i < api.allGames.count; i++) {
                    var game = api.allGames.get(i);
                    if (game && game.title && !seenTitles[game.title]) {
                        var gp = Utils.getGamePath(game);
                        if ((gp && foundPaths[gp]) || foundTitles[game.title]) {
                            sourceGames.push(game);
                            seenTitles[game.title] = true;
                        }
                    }
                }
            }
        }

        if (sortOrder === 0) {
            sourceGames.sort(function(a, b) {
                var ta = (a.sortBy || a.title || "").toLowerCase();
                var tb = (b.sortBy || b.title || "").toLowerCase();
                return ta < tb ? -1 : ta > tb ? 1 : 0;
            });
        } else if (sortOrder === 1) {
            sourceGames.sort(function(a, b) {
                var ta = (a.sortBy || a.title || "").toLowerCase();
                var tb = (b.sortBy || b.title || "").toLowerCase();
                return ta > tb ? -1 : ta < tb ? 1 : 0;
            });
        } else if (sortOrder === 2) {
            sourceGames.sort(function(a, b) {
                var da = (a.lastPlayed && !isNaN(a.lastPlayed.getTime())) ? a.lastPlayed.getTime() : 0;
                var db = (b.lastPlayed && !isNaN(b.lastPlayed.getTime())) ? b.lastPlayed.getTime() : 0;
                return db - da;
            });
        } else if (sortOrder === 3) {
            sourceGames.sort(function(a, b) {
                var timeA = a.playTime || 0;
                var timeB = b.playTime || 0;
                if (timeB !== timeA) return timeB - timeA;
                return (b.playCount || 0) - (a.playCount || 0);
            });
        } else if (sortOrder === 4) {
            sourceGames.sort(function(a, b) {
                var fa = a.favorite ? 1 : 0;
                var fb = b.favorite ? 1 : 0;
                if (fa !== fb) return fb - fa;
                if (fa === 1) {
                    var timeA = a.playTime || 0;
                    var timeB = b.playTime || 0;
                    if (timeB !== timeA) return timeB - timeA;
                    return (b.playCount || 0) - (a.playCount || 0);
                }
                var ta = (a.sortBy || a.title || "").toLowerCase();
                var tb = (b.sortBy || b.title || "").toLowerCase();
                return ta < tb ? -1 : ta > tb ? 1 : 0;
            });
        }

        for (var i = 0; i < sourceGames.length; i++) {
            filteredModel.append(sourceGames[i]);
            newFilteredRefs.push(sourceGames[i]);
        }
        filteredRealRefs = newFilteredRefs;

        activeLetterIdx = -1;
        letterFilterActive = false;
        buildLetterIndex();
        applyLetterFilter();
    }

    onSystemCollectionChanged: { updateFilteredModel(); }
    onSelectedCollectionIdChanged: { updateFilteredModel(); }
    onCollectionGameTitlesChanged: { if (selectedCollectionId !== -1) updateFilteredModel(); }
    onSearchFilterChanged: { updateFilteredModel(); }
    onSortOrderChanged: { updateFilteredModel(); }

    Connections {
        target: api.allGames
        function onModelReset() { updateFilteredModel(); }
    }

    Item {
        id: mainArea
        anchors.fill: parent

        GridView {
            id: gamesGridView
            focus: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            property int desiredColumns: 3
            property int spacing: vpx(10)
            property int calculatedCellWidth: Math.floor((parent.width - vpx(20) - (desiredColumns + 1) * spacing) / desiredColumns)
            property int calculatedCellHeight: Math.floor(calculatedCellWidth * 0.85)

            width: desiredColumns * calculatedCellWidth + (desiredColumns + 1) * spacing

            cellWidth: calculatedCellWidth + spacing
            cellHeight: calculatedCellHeight + spacing
            model: displayModel
            clip: true
            keyNavigationWraps: false
            highlightFollowsCurrentItem: true
            leftMargin: spacing
            topMargin: spacing

            highlightRangeMode: GridView.StrictlyEnforceRange
            preferredHighlightBegin: topMargin
            preferredHighlightEnd: height - topMargin - cellHeight

            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onWheel: {
                    var delta = wheel.angleDelta.y;
                    var step = gamesGridView.cellHeight;
                    if (delta > 0 && gamesGridView.currentIndex > 0) {
                        gamesGridView.currentIndex = Math.max(0, gamesGridView.currentIndex - gamesGridView.desiredColumns);
                    } else if (delta < 0) {
                        gamesGridView.currentIndex = Math.min(gamesGridView.count - 1, gamesGridView.currentIndex + gamesGridView.desiredColumns);
                    }
                    wheel.accepted = true;
                }
                onClicked: mouse.accepted = false
                onPressed: mouse.accepted = false
                onReleased: mouse.accepted = false
            }

            onActiveFocusChanged: {
                if (activeFocus && gridContainer.focusManager) {
                    gridContainer.focusManager.currentFocusArea = gridContainer.focusManager.focusGrid;
                }
            }

            Component.onCompleted: {
                currentIndex = 0;
                forceActiveFocus();
                Qt.callLater(function() { gridContainer.scrollbarReady = true; });
            }

            delegate: GameTile {
                gameData: model
                width: gamesGridView.calculatedCellWidth
                height: gamesGridView.calculatedCellHeight
                showCollectionsInfo: gridContainer.isAllGamesSelected ||
                gridContainer.searchFilter !== "" ||
                (gridContainer.selectedCollectionId !== -1 && gridContainer.systemCollection === null)

                onShowDetailRequested: function(game) {
                    var realGame = gridContainer.displayRealRefs[index];
                    gridContainer.showGameDetail(realGame || game);
                }

                isGameInUserCollection: {
                    if (gridContainer.selectedCollectionId === -1) return false;
                    return Utils.isGameInCollection(gridContainer.selectedCollectionId, model);
                }

                tileColors: gridContainer.themeColors
                isDarkMode: gridContainer.isDarkTheme

                onIsSelectedChanged: { if (isSelected) gamesGridView.currentIndex = index; }

                onRightClicked: function(game, x, y) {
                    var realGame = gridContainer.displayRealRefs[index];
                    gridContainer.requestAddGame(realGame || game);
                }
                selectedBorderColor: {
                    if (gridContainer.systemCollection && gridContainer.systemCollection.shortName) {
                        var mc = colorMapper.getColor(gridContainer.systemCollection.shortName);
                        if (mc !== "#000000") return mc;
                    }
                    return gridContainer.themeColors.primary;
                }
            }

            Keys.onPressed: function(event) {
                if (api.keys.isNextPage(event)) {
                    gridContainer.goNextLetter();
                    event.accepted = true;
                    return;
                }
                if (api.keys.isPrevPage(event)) {
                    gridContainer.goPrevLetter();
                    event.accepted = true;
                    return;
                }
                if (api.keys.isDetails(event)) {
                    if (currentItem && currentItem.gameData) {
                        var realGame = gridContainer.displayRealRefs[currentIndex];
                        gridContainer.requestAddGame(realGame || currentItem.gameData);
                        event.accepted = true;
                    }
                    return;
                }
                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    if (currentItem && currentItem.gameData) {
                        var realGame = gridContainer.displayRealRefs[currentIndex];
                        gridContainer.showGameDetail(realGame || currentItem.gameData);
                        event.accepted = true;
                    }
                } else if (api.keys.isCancel(event)) {
                    if (focusManager) focusManager.moveFocusLeft();
                    event.accepted = true;
                } else if (event.key === Qt.Key_Left && currentIndex === 0) {
                    if (focusManager) focusManager.moveFocusLeft();
                    event.accepted = true;
                }
            }

            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.4
                height: vpx(100)
                color: gridContainer.themeColors.panel
                radius: vpx(10)
                visible: gamesGridView.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: vpx(10)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridContainer.letterFilterActive ? "\uD83D\uDD24" : "\uD83D\uDD2D"
                        font.pixelSize: vpx(40)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (gridContainer.letterFilterActive)
                                return "No games starting with \"" + gridContainer.activeLetter + "\"";
                            if (gridContainer.searchFilter !== "")
                                return "No games were found";
                            if (gridContainer.systemCollection !== null)
                                return "There are no games in this collection.";
                            if (gridContainer.selectedCollectionId === -1)
                                return "Loading games...";
                            return "There are no games in this collection.";
                        }
                        color: gridContainer.themeColors.textSecondary
                        font.pixelSize: vpx(16)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }

        Rectangle {
            anchors.right: parent.right
            anchors.rightMargin: vpx(5)
            anchors.top: parent.top
            anchors.topMargin: gamesGridView.topMargin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: vpx(25)
            width: vpx(8)
            color: "transparent"
            visible: gridContainer.scrollbarReady && gamesGridView.contentHeight > gamesGridView.height

            Rectangle {
                width: parent.width
                height: Math.max(vpx(30), (gamesGridView.height / gamesGridView.contentHeight) * parent.height)
                y: (gamesGridView.contentY / gamesGridView.contentHeight) * parent.height
                color: gridContainer.scrollbarColor
                radius: vpx(4)
                opacity: 0.5
            }
        }

        FastBlur {
            id: gridBlur
            anchors.fill: gamesGridView
            source: gamesGridView
            radius: 0
            visible: radius > 0
            z: 9

            Behavior on radius {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }

        Rectangle {
            anchors.fill: gamesGridView
            color: gridContainer.isDarkTheme ? "#B3000000" : "#B3F2F2F4"
            opacity: gridBlur.radius > 0 ? 1.0 : 0.0
            visible: opacity > 0
            z: 10
            radius: vpx(10)

            Behavior on opacity {
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
        }

        Item {
            id: letterHud
            anchors.centerIn: gamesGridView
            width: hudCard.width
            height: hudCard.height
            z: 11
            opacity: 0
            visible: opacity > 0

            Timer {
                id: hudTimer
                interval: 1600
                repeat: false
                onTriggered: {
                    letterHud.opacity = 0;
                    gridBlur.radius = 0;
                }
            }

            function triggerShow() {
                opacity = 1;
                gridBlur.radius = 40;
                hudTimer.restart();
            }

            Behavior on opacity {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Rectangle {
                id: hudCard
                width: hudInner.implicitWidth + vpx(64)
                height: vpx(140)
                radius: vpx(22)
                color: gridContainer.isDarkTheme
                ? Qt.rgba(0.07, 0.07, 0.10, 0.95)
                : Qt.rgba(0.97, 0.97, 0.99, 0.95)
                border.color: gridContainer.themeColors.primary
                border.width: vpx(1)

                layer.enabled: true
                layer.effect: DropShadow {
                    color: gridContainer.themeColors.primary
                    radius: vpx(28)
                    samples: 50
                    spread: 0.04
                    transparentBorder: true
                }

                Column {
                    id: hudInner
                    anchors.centerIn: parent
                    spacing: vpx(6)

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: vpx(22)

                        Text {
                            text: "\u2039"
                            color: gridContainer.themeColors.primaryHover
                            font.pixelSize: vpx(48)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: (!gridContainer.letterFilterActive || gridContainer.activeLetterIdx > 0) ? 1.0 : 0.18
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        Text {
                            id: hudLetterText
                            text: gridContainer.letterFilterActive ? gridContainer.activeLetter : "ALL"
                            color: gridContainer.themeColors.primary
                            font.pixelSize: vpx(72)
                            font.bold: true
                            font.letterSpacing: vpx(3)
                            anchors.verticalCenter: parent.verticalCenter

                            Behavior on text {
                                SequentialAnimation {
                                    NumberAnimation {
                                        target: hudLetterText; property: "scale"
                                        to: 0.72; duration: 70; easing.type: Easing.InCubic
                                    }
                                    PropertyAction { target: hudLetterText; property: "text" }
                                    NumberAnimation {
                                        target: hudLetterText; property: "scale"
                                        to: 1.0; duration: 130; easing.type: Easing.OutBack
                                    }
                                }
                            }
                        }

                        Text {
                            text: "\u203a"
                            color: gridContainer.themeColors.primaryHover
                            font.pixelSize: vpx(48)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                            opacity: (!gridContainer.letterFilterActive || gridContainer.activeLetterIdx < gridContainer.letterIndex.length - 1) ? 1.0 : 0.18
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: gridContainer.letterFilterActive
                        ? (displayModel.count + (displayModel.count === 1 ? " game" : " games"))
                        : "Showing all games"
                        color: gridContainer.themeColors.textSecondary
                        font.pixelSize: vpx(15)
                        font.letterSpacing: vpx(1)
                    }
                }
            }
        }

        Loader {
            id: addGameLoader
            anchors.fill: parent
            active: false
            z: 50
            source: active ? "AddGame.qml" : ""

            Component.onCompleted: {
                gridContainer.addGameLoaderRef = addGameLoader;
            }

            property var _pendingGame: null

            function openForGame(game) {
                _pendingGame = game;
                active = true;
            }

            onLoaded: {
                if (addGameLoader.item) {
                    addGameLoader.item.currentGame = addGameLoader._pendingGame;
                    addGameLoader.item.themeColors = gridContainer.themeColors;
                    addGameLoader.item.isDarkTheme = gridContainer.isDarkTheme;
                    addGameLoader.item.customCollections = gridContainer.customCollections;
                    addGameLoader.item.selectedCollectionId = gridContainer.selectedCollectionId;
                    addGameLoader.item.selectedSystemCollection = gridContainer.systemCollection;

                    addGameLoader.item.closed.connect(function() {
                        addGameLoader.active = false;
                        gamesGridView.forceActiveFocus();
                    });
                    addGameLoader.item.launchGame.connect(function() {
                        if (addGameLoader._pendingGame)
                            Utils.launchGameFromCollection(addGameLoader._pendingGame.title);
                        addGameLoader.active = false;
                    });
                    addGameLoader.item.gameAddedToCollection.connect(function(collectionId) {
                        gridContainer.gameAddedToCollection(collectionId);
                    });
                    addGameLoader.item.gameRemovedFromCollection.connect(function(collectionId) {
                        gridContainer.gameRemovedFromCollection(collectionId);
                    });

                    addGameLoader.item.forceActiveFocus();
                }
            }
        }
    }
}
