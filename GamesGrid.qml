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
    property bool isAllGamesSelected: false
    property var themeColors: ({})
    property bool isDarkTheme: true

    signal gameRightClicked(var game, int x, int y)

    ListModel {
        id: filteredModel
    }

    Component.onCompleted: {
        console.log("GamesGrid: Inicializando, total juegos:", api.allGames.count);
        updateFilteredModel();
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
                var foundTitles = {};
                for (var i = 0; i < collectionGameTitles.length; i++) {
                    foundTitles[collectionGameTitles[i]] = true;
                }

                for (var i = 0; i < api.allGames.count; i++) {
                    var game = api.allGames.get(i);
                    if (game && game.title && !seenTitles[game.title] && foundTitles[game.title]) {
                        sourceGames.push(game);
                        seenTitles[game.title] = true;
                    }
                }
            }
        }

        for (var i = 0; i < sourceGames.length; i++) {
            filteredModel.append(sourceGames[i]);
        }

        console.log("GamesGrid: Mostrando", filteredModel.count, "juegos filtrados (sin duplicados)");
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
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom

            property int desiredColumns: 5
            property int spacing: vpx(10)
            property int calculatedCellWidth: Math.floor((parent.width - vpx(20) - (desiredColumns + 1) * spacing) / desiredColumns)
            property int calculatedCellHeight: Math.floor(calculatedCellWidth * 1.3)

            width: desiredColumns * calculatedCellWidth + (desiredColumns + 1) * spacing

            cellWidth: calculatedCellWidth + spacing
            cellHeight: calculatedCellHeight + spacing
            model: filteredModel
            clip: true

            leftMargin: spacing
            topMargin: spacing

            delegate: GameTile {
                gameData: model
                width: gamesGrid.calculatedCellWidth
                height: gamesGrid.calculatedCellHeight
                showCollectionsInfo: gridContainer.isAllGamesSelected ||
                gridContainer.searchFilter !== "" ||
                (gridContainer.selectedCollectionId !== -1 &&
                gridContainer.systemCollection === null)

                isGameInUserCollection: {
                    if (gridContainer.selectedCollectionId === -1) return false;
                    return Utils.isGameInCollection(gridContainer.selectedCollectionId, model.title);
                }

                tileColors: gridContainer.themeColors
                isDarkMode: gridContainer.isDarkTheme

                onRightClicked: function(game, x, y) {
                    var globalPos = mapToItem(gridContainer, x, y);
                    gridContainer.gameRightClicked(game, globalPos.x, globalPos.y);
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
                                return "No se encontraron juegos";
                            } else if (gridContainer.systemCollection !== null) {
                                return "No hay juegos en esta colección";
                            } else if (gridContainer.selectedCollectionId === -1) {
                                return "Cargando juegos...";
                            } else {
                                return "No hay juegos en esta colección";
                            }
                        }
                        color: gridContainer.themeColors.textSecondary
                        font.pixelSize: vpx(16)
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
}
