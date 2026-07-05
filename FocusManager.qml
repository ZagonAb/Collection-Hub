import QtQuick 2.15

Item {
    id: focusManager

    property var gamesGrid: null
    property var systemCollections: null
    property var customCollections: null
    property var searchBar: null
    property var sortBtn: null
    property var themeBtn: null
    property var createBtn: null
    property var raBtn: null
    property var customJumpBtn: null

    property int currentFocusArea: 0
    property int lastSystemIndex: 0
    property int lastCustomIndex: 0
    property int lastCollectionArea: focusSystem

    readonly property int focusGrid: 0
    readonly property int focusSystem: 1
    readonly property int focusCustom: 2
    readonly property int focusSearch: 3
    readonly property int focusRaBtn: 4
    readonly property int focusSortBtn: 5
    readonly property int focusThemeBtn: 6
    readonly property int focusCreateBtn: 7
    readonly property int focusCustomJumpBtn: 8
    property int lastGridIndex: 0

    signal selectAllGamesTriggered()
    signal focusAreaReported(int area)

    onFocusAreaReported: function(area) {
        currentFocusArea = area;
    }

    property var _gamesGridWatcher: Connections {
        target: focusManager.gamesGrid
        enabled: focusManager.gamesGrid !== null
        function onActiveFocusChanged() {
            if (focusManager.gamesGrid && focusManager.gamesGrid.activeFocus) {
                focusManager.currentFocusArea = focusManager.focusGrid;
            }
        }
    }

    property var _systemWatcher: Connections {
        target: focusManager.systemCollections
        enabled: focusManager.systemCollections !== null
        function onActiveFocusChanged() {
            if (focusManager.systemCollections && focusManager.systemCollections.activeFocus) {
                focusManager.currentFocusArea = focusManager.focusSystem;
            }
        }
    }

    property var _customWatcher: Connections {
        target: focusManager.customCollections
        enabled: focusManager.customCollections !== null
        function onActiveFocusChanged() {
            if (focusManager.customCollections && focusManager.customCollections.activeFocus) {
                focusManager.currentFocusArea = focusManager.focusCustom;
            }
        }
    }

    function selectAllGames() {
        lastSystemIndex = 0;
        lastCollectionArea = focusSystem;
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
        if (currentFocusArea === focusCustomJumpBtn) {
            currentFocusArea = focusCreateBtn;
            if (createBtn) createBtn.forceActiveFocus();
        } else if (currentFocusArea === focusCreateBtn) {
            currentFocusArea = focusThemeBtn;
            if (themeBtn) themeBtn.forceActiveFocus();
        } else if (currentFocusArea === focusThemeBtn) {
            currentFocusArea = focusSortBtn;
            if (sortBtn) sortBtn.forceActiveFocus();
        } else if (currentFocusArea === focusSortBtn) {
            currentFocusArea = focusRaBtn;
            if (raBtn) raBtn.forceActiveFocus();
        } else if (currentFocusArea === focusRaBtn) {
            currentFocusArea = focusSearch;
            if (searchBar) searchBar.forceActiveFocus();
        } else if (currentFocusArea === focusSearch && searchBar && searchBar.searchText === "") {
            searchBar.collapse();
            currentFocusArea = focusGrid;
            if (gamesGrid) gamesGrid.forceActiveFocus();
        } else {
            if (lastCollectionArea === focusCustom) {
                currentFocusArea = focusCustom;
                if (customCollections) {
                    customCollections.currentIndex = lastCustomIndex;
                    customCollections.forceActiveFocus();
                }
            } else {
                currentFocusArea = focusSystem;
                if (systemCollections) {
                    systemCollections.currentIndex = lastSystemIndex;
                    systemCollections.forceActiveFocus();
                }
            }
        }
    }

    function moveFocusRight() {
        if (currentFocusArea === focusSystem) {
            lastSystemIndex = systemCollections ? systemCollections.currentIndex : 0;
        } else if (currentFocusArea === focusCustom) {
            lastCustomIndex = customCollections ? customCollections.currentIndex : 0;
        }

        if (currentFocusArea === focusSystem || currentFocusArea === focusCustom) {
            lastCollectionArea = currentFocusArea;
            currentFocusArea = focusGrid;
            if (gamesGrid) {
                gamesGrid.currentIndex = 0;
                gamesGrid.forceActiveFocus();
            }
        } else if (currentFocusArea === focusSearch) {
            if (searchBar && searchBar.searchText === "") {
                searchBar.collapse();
            }
            currentFocusArea = focusRaBtn;
            if (raBtn) raBtn.forceActiveFocus();
        } else if (currentFocusArea === focusRaBtn) {
            currentFocusArea = focusSortBtn;
            if (sortBtn) sortBtn.forceActiveFocus();
        } else if (currentFocusArea === focusSortBtn) {
            currentFocusArea = focusThemeBtn;
            if (themeBtn) themeBtn.forceActiveFocus();
        } else if (currentFocusArea === focusThemeBtn) {
            currentFocusArea = focusCreateBtn;
            if (createBtn) createBtn.forceActiveFocus();
        } else if (currentFocusArea === focusCreateBtn) {
            if (customCollections && customCollections.count > 0) {
                currentFocusArea = focusCustomJumpBtn;
                if (customJumpBtn) customJumpBtn.forceActiveFocus();
            }
        }
    }

    function moveFocusUp() {
        if (currentFocusArea === focusGrid) {
            currentFocusArea = focusSearch;
            if (searchBar) {
                searchBar.forceActiveFocus();
            }
        } else if (currentFocusArea === focusCustom) {
            lastCustomIndex = customCollections ? customCollections.currentIndex : 0;
            currentFocusArea = focusSystem;
            if (systemCollections) {
                systemCollections.currentIndex = systemCollections.count - 1;
                systemCollections.forceActiveFocus();
            }
        }
    }

    function moveFocusDown() {
        if (currentFocusArea === focusSearch ||
            currentFocusArea === focusRaBtn ||
            currentFocusArea === focusSortBtn ||
            currentFocusArea === focusThemeBtn ||
            currentFocusArea === focusCreateBtn ||
            currentFocusArea === focusCustomJumpBtn) {
            currentFocusArea = focusGrid;
            if (searchBar && searchBar.searchText === "") {
                searchBar.collapse();
            }
            if (gamesGrid) {
                gamesGrid.forceActiveFocus();
            }
        } else if (currentFocusArea === focusSystem) {
            lastSystemIndex = systemCollections ? systemCollections.currentIndex : 0;
            currentFocusArea = focusCustom;
            if (customCollections) {
                customCollections.currentIndex = lastCustomIndex;
                customCollections.forceActiveFocus();
            }
        }
    }

    function focusOnSortBtn() {
        currentFocusArea = focusSortBtn;
        if (sortBtn) sortBtn.forceActiveFocus();
    }

    function goToFirstCustomCollection() {
        if (!customCollections || customCollections.count === 0) return;
        lastCustomIndex = 0;
        lastCollectionArea = focusCustom;
        currentFocusArea = focusCustom;
        customCollections.currentIndex = 0;
        customCollections.forceActiveFocus();
    }
}
