import QtQuick 2.15

Item {
    id: focusManager

    property var gamesGrid: null
    property var systemCollections: null
    property var customCollections: null
    property var searchBar: null

    property int currentFocusArea: 0
    property int lastSystemIndex: 0
    property int lastCustomIndex: 0

    readonly property int focusGrid: 0
    readonly property int focusSystem: 1
    readonly property int focusCustom: 2
    readonly property int focusSearch: 3

    signal selectAllGamesTriggered()

    function selectAllGames() {
        console.log("selectAllGames llamado");
        lastSystemIndex = 0;
        currentFocusArea = focusGrid;
        selectAllGamesTriggered();
        if (gamesGrid) {
            gamesGrid.currentIndex = 0;
            gamesGrid.forceActiveFocus();
        }
    }

    function setInitialFocus() {
        currentFocusArea = focusGrid;
        if (gamesGrid) {
            gamesGrid.currentIndex = 0;
            gamesGrid.forceActiveFocus();
        }
    }

    function moveFocusLeft() {
        console.log("moveFocusLeft llamado, systemCollections:", systemCollections);
        currentFocusArea = focusSystem;
        if (systemCollections) {
            console.log("Intentando enfocar systemCollections");
            systemCollections.currentIndex = lastSystemIndex;
            systemCollections.forceActiveFocus();
        }
    }

    function moveFocusRight() {
        console.log("moveFocusRight llamado, currentFocusArea:", currentFocusArea, "gamesGrid:", gamesGrid);
        if (currentFocusArea === focusSystem) {
            lastSystemIndex = systemCollections ? systemCollections.currentIndex : 0;
        } else if (currentFocusArea === focusCustom) {
            lastCustomIndex = customCollections ? customCollections.currentIndex : 0;
        }

        if (currentFocusArea === focusSystem || currentFocusArea === focusCustom) {
            currentFocusArea = focusGrid;
            if (gamesGrid) {
                console.log("Enfocando gamesGrid");
                gamesGrid.currentIndex = 0;
                gamesGrid.forceActiveFocus();
            }
        }
    }

    function moveFocusUp() {
        console.log("moveFocusUp llamado, currentFocusArea:", currentFocusArea);
        if (currentFocusArea === focusGrid) {
            currentFocusArea = focusSearch;
            if (searchBar) {
                searchBar.forceActiveFocus();
            }
        } else if (currentFocusArea === focusCustom) {
            lastCustomIndex = customCollections ? customCollections.currentIndex : 0;
            currentFocusArea = focusSystem;
            if (systemCollections) {
                console.log("Regresando a systemCollections");
                systemCollections.currentIndex = systemCollections.count - 1;
                systemCollections.forceActiveFocus();
            }
        }
    }

    function moveFocusDown() {
        console.log("moveFocusDown llamado, currentFocusArea:", currentFocusArea);
        if (currentFocusArea === focusSearch) {
            currentFocusArea = focusGrid;
            if (gamesGrid) {
                gamesGrid.forceActiveFocus();
            }
        } else if (currentFocusArea === focusSystem) {
            lastSystemIndex = systemCollections ? systemCollections.currentIndex : 0;
            currentFocusArea = focusCustom;
            if (customCollections) {
                console.log("Enfocando customCollections");
                customCollections.currentIndex = lastCustomIndex;
                customCollections.forceActiveFocus();
            }
        }
    }
}
