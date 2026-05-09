import QtQuick 2.15
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
    property alias gridView: gamesGrid
    property bool scrollbarReady: false
    property var  customCollections: []
    property var  addGameLoaderRef:  null

    signal gameRightClicked(var game, int x, int y)
    signal showGameDetail(var game)
    signal requestAddGame(var game)
    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection(int collectionId)

    onRequestAddGame: function(game) {
        addGameLoader.openForGame(game);
    }

    ListModel {
        id: filteredModel
    }

    ColorMapping {
        id: colorMapper
    }

    Component.onCompleted: {
        Qt.callLater(updateFilteredModel);
    }

    function updateFilteredModel() {
        filteredModel.clear();

        var sourceGames = [];
        var seenTitles = {};

        if (searchFilter.trim() !== "") {
            for (var i = 0; i < api.allGames.count; i++) {
                var g = api.allGames.get(i);
                if (g && g.title && !seenTitles[g.title]) {
                    var filterLower = searchFilter.toLowerCase();
                    if (g.title.toLowerCase().indexOf(filterLower) !== -1 ||
                        (g.developer && g.developer.toLowerCase().indexOf(filterLower) !== -1) ||
                        (g.publisher && g.publisher.toLowerCase().indexOf(filterLower) !== -1) ||
                        (g.genre && g.genre.toLowerCase().indexOf(filterLower) !== -1)) {
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
                        var gamePath = Utils.getGamePath(game);
                        var matchByPath = gamePath && foundPaths[gamePath];
                        var matchByTitle = foundTitles[game.title];
                        if (matchByPath || matchByTitle) {
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
                if (timeB !== timeA) {
                    return timeB - timeA;
                }
                var countA = a.playCount || 0;
                var countB = b.playCount || 0;
                return countB - countA;
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
                    var countA = a.playCount || 0;
                    var countB = b.playCount || 0;
                    return countB - countA;
                }

                var ta = (a.sortBy || a.title || "").toLowerCase();
                var tb = (b.sortBy || b.title || "").toLowerCase();
                return ta < tb ? -1 : ta > tb ? 1 : 0;
            });
        }

        for (var i = 0; i < sourceGames.length; i++) {
            filteredModel.append(sourceGames[i]);
        }
    }

    onSystemCollectionChanged: {
        updateFilteredModel();
    }

    onSelectedCollectionIdChanged: {
        updateFilteredModel();
    }

    onCollectionGameTitlesChanged: {
        if (selectedCollectionId !== -1) {
            updateFilteredModel();
        }
    }

    onSearchFilterChanged: {
        updateFilteredModel();
    }

    onSortOrderChanged: {
        updateFilteredModel();
    }

    Connections {
        target: api.allGames
        function onModelReset() {
            updateFilteredModel();
        }
    }

    Item {
        anchors.fill: parent

        GridView {
            id: gamesGrid
            focus: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            property int desiredColumns: 3
            property int spacing: vpx(10)
            property int calculatedCellWidth: Math.floor((parent.width - vpx(20) - (desiredColumns + 1) * spacing) / desiredColumns)
            property int calculatedCellHeight: Math.floor(calculatedCellWidth * 1.0)

            width: desiredColumns * calculatedCellWidth + (desiredColumns + 1) * spacing

            cellWidth: calculatedCellWidth + spacing
            cellHeight: calculatedCellHeight + spacing
            model: filteredModel
            clip: true
            keyNavigationWraps: false
            highlightFollowsCurrentItem: true
            leftMargin: spacing
            topMargin: spacing

            highlightRangeMode: GridView.StrictlyEnforceRange
            preferredHighlightBegin: topMargin
            preferredHighlightEnd: height - topMargin - cellHeight

            Component.onCompleted: {
                currentIndex = 0;
                forceActiveFocus();
                Qt.callLater(function() {
                    gridContainer.scrollbarReady = true;
                });
            }

            delegate: GameTile {
                gameData: model
                width: gamesGrid.calculatedCellWidth
                height: gamesGrid.calculatedCellHeight
                showCollectionsInfo: gridContainer.isAllGamesSelected ||
                gridContainer.searchFilter !== "" ||
                (gridContainer.selectedCollectionId !== -1 &&
                gridContainer.systemCollection === null)

                onShowDetailRequested: function(game) {
                    gridContainer.showGameDetail(game);
                }

                isGameInUserCollection: {
                    if (gridContainer.selectedCollectionId === -1) return false;
                    return Utils.isGameInCollection(gridContainer.selectedCollectionId, model);
                }

                tileColors: gridContainer.themeColors
                isDarkMode: gridContainer.isDarkTheme

                onIsSelectedChanged: {
                    if (isSelected) {
                        gamesGrid.currentIndex = index;
                    }
                }

                onRightClicked: function(game, x, y) {
                    gridContainer.requestAddGame(game);
                }

                selectedBorderColor: {
                    if (gridContainer.systemCollection && gridContainer.systemCollection.shortName) {
                        var mappedColor = colorMapper.getColor(gridContainer.systemCollection.shortName);
                        if (mappedColor !== "#000000") {
                            return mappedColor;
                        }
                    }
                    return gridContainer.themeColors.primary;
                }
            }

            Keys.onPressed: function(event) {
                if (api.keys.isDetails(event)) {
                    if (currentItem && currentItem.gameData) {
                        gridContainer.requestAddGame(currentItem.gameData);
                        event.accepted = true;
                    }
                    return;
                }

                if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                    if (currentItem && currentItem.gameData) {
                        gridContainer.showGameDetail(currentItem.gameData);
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
                visible: gamesGrid.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: vpx(10)

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "🔭"
                        font.pixelSize: vpx(40)
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            if (gridContainer.searchFilter !== "") {
                                return "No games were found";
                            } else if (gridContainer.systemCollection !== null) {
                                return "There are no games in this collection.";
                            } else if (gridContainer.selectedCollectionId === -1) {
                                return "Loading games...";
                            } else {
                                return "There are no games in this collection.";
                            }
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
            anchors.rightMargin: vpx(10)
            anchors.top: parent.top
            anchors.topMargin: gamesGrid.topMargin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: vpx(25)
            width: vpx(3)
            color: "transparent"
            visible: gridContainer.scrollbarReady && gamesGrid.contentHeight > gamesGrid.height

            Rectangle {
                width: parent.width
                height: Math.max(vpx(30), (gamesGrid.height / gamesGrid.contentHeight) * parent.height)
                y: (gamesGrid.contentY / gamesGrid.contentHeight) * parent.height
                color: gridContainer.themeColors.primaryHover || "#5a8ec5"
                radius: vpx(1.5)
                opacity: 0.6
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
                    addGameLoader.item.currentGame          = addGameLoader._pendingGame;
                    addGameLoader.item.themeColors          = gridContainer.themeColors;
                    addGameLoader.item.isDarkTheme          = gridContainer.isDarkTheme;
                    addGameLoader.item.customCollections    = gridContainer.customCollections;
                    addGameLoader.item.selectedCollectionId = gridContainer.selectedCollectionId;
                    addGameLoader.item.selectedSystemCollection = gridContainer.systemCollection;

                    addGameLoader.item.closed.connect(function() {
                        addGameLoader.active = false;
                        gamesGrid.forceActiveFocus();
                    });
                    addGameLoader.item.launchGame.connect(function() {
                        if (addGameLoader._pendingGame) {
                            Utils.launchGameFromCollection(addGameLoader._pendingGame.title);
                        }
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
