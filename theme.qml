import QtQuick 2.15
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.12
import QtQuick.Layouts 1.15
import "utils.js" as Utils

FocusScope {
    id: root

    property var customCollections: []
    property var currentCollectionGameTitles: []
    property int selectedCollectionId: -1
    property string selectedCollectionName: "All Games"
    property var selectedSystemCollection: null
    property bool showCollectionEditor: false
    property bool showGameMenu: false
    property int sortOrder: 0
    property bool showSortMenu: false
    property var currentDetailGame: null

    function openGameDetail(game) {
        currentDetailGame = game;
        gameDetailLoader.active = true;
    }

    function closeGameDetail() {
        gameDetailLoader.active = false;
        currentDetailGame = null;
        if (focusManager && focusManager.gamesGrid) {
            focusManager.gamesGrid.forceActiveFocus();
        }
    }

    onShowSortMenuChanged: {
        //console.log("[ROOT] showSortMenu cambio a:", showSortMenu);
    }
    property var currentGameForMenu: null
    property bool showDeleteConfirm: false
    property int collectionToDelete: -1
    property int deleteConfirmIndex: 0
    property string collectionToDeleteName: ""
    property bool isAllGamesSelected: selectedCollectionId === -1 && selectedSystemCollection === null
    property int menuX: 0
    property int menuY: 0
    property bool isDarkTheme: true
    property var colors: isDarkTheme ? darkColors : lightColors

    property var darkColors: ({
        "background": "#000000",
        "panel": "#111111",
        "rightpanel": "#0c0c0c",
        "menucolor": "#050505",
        "panelBorder": "#111111",
        "primary": "#2d5c8f",
        "primaryHover": "#4677ad",
        "text": "#ffffff",
        "textSecondary": "#b0b0b0",
        "textTertiary": "#7a7a7a",
        "success": "#43A047",
        "successDark": "#2E7D32",
        "successLight": "#66BB6A",
        "error": "#E53935",
        "errorDark": "#C62828",
        "errorLight": "#EF5350",
        "inputBg": "#050505",
        "inputBorder": "#1f1f1f",
        "separator": "#181818",
        "tileBg": "#101010",
        "tileBorder": "#1c1c1c",
        "tileImageBg": "#080808",
        "overlay": "#E0000000"
    })

    property var lightColors: ({
        "background": "#d7d7d8",
        "panel": "#f2f2f4",
        "rightpanel": "#fafafb",
        "menucolor": "#ebebeb",
        "panelBorder": "#f2f2f4",
        "primary": "#2196F3",
        "primaryHover": "#42A5F5",
        "text": "#212121",
        "textSecondary": "#616161",
        "textTertiary": "#9e9e9e",
        "success": "#4CAF50",
        "successDark": "#388E3C",
        "successLight": "#66BB6A",
        "error": "#f44336",
        "errorDark": "#D32F2F",
        "errorLight": "#ef5350",
        "inputBg": "#fafafa",
        "inputBorder": "#bdbdbd",
        "separator": "#e0e0e0",
        "tileBg": "#ffffff",
        "tileBorder": "#e0e0e0",
        "tileImageBg": "#d7d7d8",
        "overlay": "#CC000000"
    })

    FocusManager {
        id: focusManager

        onSelectAllGamesTriggered: {
            root.selectedCollectionId = -1;
            root.selectedCollectionName = "All Games";
            root.selectedSystemCollection = null;
            root.currentCollectionGameTitles = [];
            systemCollections.selectedCollectionIndex = -1;
            customCollectionsView.selectedCollectionId = -1;
        }
    }

    function createNewCollection() {
        if (collectionNameInput.text.trim() !== "") {
            var newId = Utils.createCollection(collectionNameInput.text.trim());
            customCollections = Utils.loadCustomCollections();
            showCollectionEditor = false;
        }
    }

    function toggleTheme() {
        isDarkTheme = !isDarkTheme;
        api.memory.set("theme", isDarkTheme ? "dark" : "light");
    }

    Component.onCompleted: {
        customCollections = Utils.loadCustomCollections();
        selectedCollectionId = -1;
        selectedCollectionName = "All Games";
        selectedSystemCollection = null;
        currentCollectionGameTitles = [];

        if (api.memory.has("theme")) {
            isDarkTheme = api.memory.get("theme") === "dark";
        }

        Qt.callLater(function() {
            focusManager.gamesGrid = gamesGrid.gridView;
            focusManager.systemCollections = systemCollections.systemCollectionsList;
            focusManager.customCollections = customCollectionsView.customCollectionsList;
            focusManager.searchBar = searchBar;
            focusManager.sortBtn = sortBtn;
            focusManager.themeBtn = themeBtnScope;
            focusManager.createBtn = createCollectionTopBtn;
            focusManager.setInitialFocus();
        });
    }

    Rectangle {
        anchors.fill: parent
        color: colors.background
    }

    RowLayout {
        anchors.fill: parent
        spacing: 1

        Rectangle {
            id: leftPanel
            Layout.preferredWidth: parent.width * 0.22
            Layout.preferredHeight: parent.height
            color: colors.panel
            radius: 0

            Column {
                anchors.fill: parent
                anchors.margins: vpx(10)
                spacing: vpx(10)
                z: 1

                Row {
                    width: parent.width
                    height: vpx(40)
                    spacing: vpx(8)

                    Rectangle {
                        id: allGames
                        width: parent.width
                        height: vpx(40)
                        color: root.selectedCollectionId === -1 && root.selectedSystemCollection === null ? colors.primary : "transparent"
                        border.color: colors.primary
                        border.width: vpx(1)
                        radius: vpx(10)

                        Row {
                            anchors.centerIn: parent
                            spacing: vpx(8)

                            Item {
                                width: vpx(28)
                                height: vpx(28)
                                anchors.verticalCenter: parent.verticalCenter

                                Image {
                                    id: allGamesIcon
                                    anchors.fill: parent
                                    source: "assets/icons/allgames.svg"
                                    fillMode: Image.PreserveAspectFit

                                    Rectangle {
                                        anchors.fill: parent
                                        color: colors.panel
                                        visible: parent.status !== Image.Ready

                                        Text {
                                            anchors.centerIn: parent
                                            text: "🎮"
                                            font.pixelSize: vpx(14)
                                            color: colors.text
                                        }
                                    }
                                }

                                ColorOverlay {
                                    anchors.fill: allGamesIcon
                                    source: allGamesIcon
                                    color: root.isDarkTheme ? "white" : "#212121"
                                }
                            }

                            Text {
                                text: "All Games (" + api.allGames.count + ")"
                                color: colors.text
                                font.pixelSize: vpx(13)
                                font.bold: root.selectedCollectionId === -1 && root.selectedSystemCollection === null
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.selectedCollectionId = -1;
                                root.selectedCollectionName = "All Games";
                                root.selectedSystemCollection = null;
                                root.currentCollectionGameTitles = [];
                                systemCollections.selectedCollectionIndex = -1;
                                customCollectionsView.selectedCollectionId = -1;
                                searchBar.clear();
                                gamesGrid.searchFilter = "";
                            }
                            onEntered: parent.opacity = 0.8
                            onExited: parent.opacity = 1.0
                        }

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }


                }

                SystemCollections {
                    id: systemCollections
                    width: parent.width
                    height: (parent.height - vpx(40)) * 0.5
                    color: "transparent"
                    themeColors: root.colors
                    isDarkTheme: root.isDarkTheme
                    focusManager: focusManager

                    onCollectionSelected: function(collection) {
                        root.selectedSystemCollection = collection;
                        root.selectedCollectionId = -1;
                        root.selectedCollectionName = collection.name;
                        root.currentCollectionGameTitles = [];
                        customCollectionsView.selectedCollectionId = -1;
                        searchBar.clear();
                        gamesGrid.searchFilter = "";
                    }
                }

                CustomCollections {
                    id: customCollectionsView
                    width: parent.width
                    height: (parent.height - vpx(90)) * 0.5
                    customCollections: root.customCollections
                    selectedCollectionId: root.selectedCollectionId
                    color: "transparent"
                    themeColors: root.colors
                    isDarkTheme: root.isDarkTheme
                    focusManager: focusManager

                    onCollectionSelected: function(collectionId, collectionName, gameFilePaths) {
                        root.selectedCollectionId = collectionId;
                        root.selectedCollectionName = collectionName;
                        root.selectedSystemCollection = null;
                        root.currentCollectionGameTitles = gameFilePaths;
                        systemCollections.selectedCollectionIndex = -1;
                        searchBar.clear();
                        gamesGrid.searchFilter = "";
                    }

                    onCreateNewCollection: {
                        root.showCollectionEditor = true;
                        collectionNameInput.text = "";
                    }

                    onDeleteCollection: function(collectionId, collectionName) {
                        root.collectionToDelete = collectionId;
                        root.collectionToDeleteName = collectionName;
                        root.showDeleteConfirm = true;
                    }

                    onCollectionRightClicked: function(collectionId, collectionName, x, y) {
                        if (root.showGameMenu) {
                            root.showGameMenu = false;
                        } else {
                            gameMenu.contextCollectionId   = collectionId;
                            gameMenu.contextCollectionName = collectionName;
                            root.showGameMenu = true;
                            gameMenu.openMenu();
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                id: topBarContainer
                Layout.fillWidth: true
                Layout.preferredHeight: vpx(60)
                color: colors.rightpanel

                Row {
                    id: leftIndicators
                    anchors {
                        left: parent.left
                        leftMargin: vpx(10)
                        verticalCenter: parent.verticalCenter
                    }
                    spacing: vpx(16)

                    Component {
                        id: iconOverlay
                        ColorOverlay {
                            color: root.isDarkTheme ? "#ffffff" : "#212121"
                        }
                    }

                    Row {
                        spacing: vpx(4)
                        Image {
                            width: vpx(22); height: vpx(22)
                            source: "assets/icons/x.svg"
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: iconOverlay
                            mipmap: true
                        }
                        Text {
                            text: "Menu"
                            color: colors.text
                            font.pixelSize: vpx(12)
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: vpx(4)
                        Image {
                            width: vpx(22); height: vpx(22)
                            source: "assets/icons/a.svg"
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: iconOverlay
                            mipmap: true
                        }
                        Text {
                            text: "Details"
                            color: colors.text
                            font.pixelSize: vpx(12)
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Row {
                        spacing: vpx(4)
                        Image {
                            width: vpx(24); height: vpx(24)
                            source: "assets/icons/lb.svg"
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: iconOverlay
                            mipmap: true
                        }
                        Text {
                            text: "Filter by letter"
                            color: colors.text
                            font.pixelSize: vpx(12)
                            font.bold: true
                            font.capitalization: Font.AllUppercase
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Image {
                            width: vpx(24); height: vpx(24)
                            source: "assets/icons/rb.svg"
                            fillMode: Image.PreserveAspectFit
                            layer.enabled: true
                            layer.effect: iconOverlay
                            mipmap: true
                        }
                    }
                }

                SearchBar {
                    id: searchBar
                    anchors {
                        right: sortBtn.left
                        rightMargin: vpx(8)
                        verticalCenter: parent.verticalCenter
                    }
                    searchColors: root.colors

                    onSearchChanged: function(text) {
                        gamesGrid.searchFilter = text;
                    }

                    onMoveToSortMenu: {
                        focusManager.focusOnSortBtn();
                    }
                }

                FocusScope {
                    id: sortBtn
                    anchors {
                        right: themeBtnScope.left
                        rightMargin: vpx(6)
                        verticalCenter: parent.verticalCenter
                    }
                    width: vpx(44)
                    height: vpx(44)

                    property bool keyboardFocused: activeFocus &&
                        focusManager.currentFocusArea === focusManager.focusSortBtn

                    Rectangle {
                        anchors.fill: parent
                        color: root.showSortMenu
                            ? colors.primary
                            : (sortBtnMouse.containsMouse || parent.keyboardFocused
                               ? colors.primary : "transparent")
                        /*border.color: root.showSortMenu || parent.keyboardFocused
                            ? colors.primary : colors.inputBorder
                        border.width: vpx(2)*/
                        radius: vpx(10)

                        Item {
                            width: vpx(22)
                            height: vpx(22)
                            anchors.centerIn: parent

                            Image {
                                id: sortIcon
                                anchors.fill: parent
                                source: "assets/icons/menu.svg"
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                anchors.fill: sortIcon
                                source: sortIcon
                                color: root.isDarkTheme ? "#ffffff" : "#212121"
                            }
                        }

                        MouseArea {
                            id: sortBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.showSortMenu = !root.showSortMenu;
                                if (root.showSortMenu) {
                                    root.showGameMenu = false;
                                    sortMenuPopup.highlightIndex = root.sortOrder;
                                    sortMenuPopup.forceActiveFocus();
                                }
                            }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (root.showSortMenu) { return; }
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            root.showSortMenu = true;
                            root.showGameMenu = false;
                            sortMenuPopup.highlightIndex = root.sortOrder;
                            sortMenuPopup.forceActiveFocus();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            focusManager.moveFocusRight();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            focusManager.moveFocusLeft();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            focusManager.moveFocusDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            focusManager.moveFocusUp();
                            event.accepted = true;
                        }
                    }
                }

                FocusScope {
                    id: themeBtnScope
                    anchors {
                        right: createCollectionTopBtn.left
                        rightMargin: vpx(6)
                        verticalCenter: parent.verticalCenter
                    }
                    width: vpx(44)
                    height: vpx(44)

                    property bool keyboardFocused: activeFocus &&
                        focusManager.currentFocusArea === focusManager.focusThemeBtn

                    Rectangle {
                        id: themeIconRect
                        anchors.fill: parent
                        color: themeToggleMouseArea.containsMouse || parent.keyboardFocused
                            ? colors.primary : "transparent"
                        /*border.color: parent.keyboardFocused ? colors.primary : colors.inputBorder
                        border.width: vpx(2)*/
                        radius: vpx(10)

                        Item {
                            id: iconContainer
                            width: vpx(24)
                            height: vpx(24)
                            anchors.centerIn: parent

                            Image {
                                id: lightIcon
                                anchors.fill: parent
                                mipmap: true
                                source: "assets/icons/light.svg"
                                visible: root.isDarkTheme
                            }

                            ColorOverlay {
                                anchors.fill: lightIcon
                                source: lightIcon
                                color: "#ffffff"
                                visible: lightIcon.visible
                            }

                            Image {
                                id: darkIcon
                                anchors.fill: parent
                                mipmap: true
                                source: "assets/icons/dark.svg"
                                visible: !root.isDarkTheme
                            }

                            ColorOverlay {
                                anchors.fill: darkIcon
                                source: darkIcon
                                color: "#212121"
                                visible: darkIcon.visible
                            }
                        }

                        MouseArea {
                            id: themeToggleMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.toggleTheme()
                            onEntered: themeIconRect.scale = 1.05
                            onExited: themeIconRect.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            root.toggleTheme();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            focusManager.moveFocusRight();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            focusManager.moveFocusLeft();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            focusManager.moveFocusDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            focusManager.moveFocusUp();
                            event.accepted = true;
                        }
                    }
                }

                FocusScope {
                    id: createCollectionTopBtn
                    anchors {
                        right: parent.right
                        rightMargin: vpx(10)
                        verticalCenter: parent.verticalCenter
                    }
                    width: vpx(44)
                    height: vpx(44)

                    property bool keyboardFocused: activeFocus &&
                        focusManager.currentFocusArea === focusManager.focusCreateBtn

                    Rectangle {
                        anchors.fill: parent
                        color: createBtnMouse.containsMouse || parent.keyboardFocused
                            ? colors.primary : "transparent"
                        /*border.color: parent.keyboardFocused ? colors.primary : colors.inputBorder
                        border.width: vpx(2)*/
                        radius: vpx(10)

                        Item {
                            width: vpx(22)
                            height: vpx(22)
                            anchors.centerIn: parent

                            Image {
                                id: plusIcon
                                anchors.fill: parent
                                source: "assets/icons/plus.svg"
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                            }

                            ColorOverlay {
                                anchors.fill: plusIcon
                                source: plusIcon
                                color: root.isDarkTheme ? "#ffffff" : "#212121"
                            }
                        }

                        MouseArea {
                            id: createBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.showCollectionEditor = true;
                                collectionNameInput.text = "";
                            }
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                        Behavior on color {
                            ColorAnimation { duration: 120 }
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (!event.isAutoRepeat && api.keys.isAccept(event)) {
                            root.showCollectionEditor = true;
                            collectionNameInput.text = "";
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            focusManager.moveFocusRight();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            focusManager.moveFocusLeft();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            focusManager.moveFocusDown();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            focusManager.moveFocusUp();
                            event.accepted = true;
                        }
                    }
                }
            }

            GamesGrid {
                id: gamesGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
                selectedCollectionId: root.selectedCollectionId
                selectedCollectionName: root.selectedCollectionName
                collectionGameTitles: root.currentCollectionGameTitles
                systemCollection: root.selectedSystemCollection
                isAllGamesSelected: root.isAllGamesSelected
                sortOrder: root.sortOrder
                color: colors.rightpanel
                themeColors: root.colors
                isDarkTheme: root.isDarkTheme
                focusManager: focusManager
                customCollections: root.customCollections

                onShowGameDetail: function(game) {
                    root.openGameDetail(game);
                }

                onGameAddedToCollection: function(collectionId) {
                    root.customCollections = Utils.loadCustomCollections();
                    if (root.selectedCollectionId === collectionId) {
                        for (var i = 0; i < root.customCollections.length; i++) {
                            if (root.customCollections[i].id === collectionId) {
                                var filePaths = [];
                                for (var j = 0; j < root.customCollections[i].games.length; j++) {
                                    var fp = root.customCollections[i].games[j].filePath
                                    || root.customCollections[i].games[j].title;
                                    filePaths.push(fp);
                                }
                                root.currentCollectionGameTitles = filePaths;
                                break;
                            }
                        }
                    }
                }

                onGameRemovedFromCollection: function(collectionId) {
                    root.customCollections = Utils.loadCustomCollections();
                    if (root.selectedCollectionId === collectionId) {
                        for (var i = 0; i < root.customCollections.length; i++) {
                            if (root.customCollections[i].id === collectionId) {
                                var filePaths = [];
                                for (var j = 0; j < root.customCollections[i].games.length; j++) {
                                    var fp = root.customCollections[i].games[j].filePath
                                    || root.customCollections[i].games[j].title;
                                    filePaths.push(fp);
                                }
                                root.currentCollectionGameTitles = filePaths;
                                break;
                            }
                        }
                    }
                    gamesGrid.updateFilteredModel();
                }

                onGameRightClicked: function(game, x, y) {
                    gamesGrid.requestAddGame(game);
                }
            }
        }
    }

    Rectangle {
        id: collectionEditor
        width: Math.min(vpx(440), parent.width * 0.55)
        height: Math.min(vpx(280), parent.height * 0.42)
        anchors.centerIn: parent
        color: root.isDarkTheme ? "#1c1c20" : "#f2f2f4"
        radius: vpx(20)
        visible: root.showCollectionEditor
        focus: true
        z: 10

        scale: 0.88
        opacity: 0.0

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: vpx(10)
            radius: vpx(18)
            samples: 35
            color: "black"
        }

        ParallelAnimation {
            id: editorEntryAnim
            NumberAnimation { target: collectionEditor; property: "scale";   from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: collectionEditor; property: "opacity"; from: 0.0;  to: 1.0; duration: 200; easing.type: Easing.OutQuad  }
        }

        onVisibleChanged: {
            if (visible) {
                editorEntryAnim.stop();
                collectionEditor.scale   = 0.88;
                collectionEditor.opacity = 0.0;
                editorEntryAnim.start();
                collectionNameInput.forceActiveFocus();
                collectionNameInput.selectAll();
            }
        }

        Item {
            id: editorHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(22)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(52)

            Text {
                id: editorTitle
                text: "New Collection"
                color: root.isDarkTheme ? "#ffffff" : "#212121"
                font.pixelSize: vpx(22)
                font.bold: true
                anchors.top: parent.top
            }

            Text {
                text: "Choose a name for your collection"
                color: root.isDarkTheme ? "#a0a0a0" : "#616161"
                font.pixelSize: vpx(12)
                font.bold: true
                font.capitalization: Font.AllUppercase
                anchors.bottom: parent.bottom
            }
        }

        Rectangle {
            id: editorSep1
            anchors.top: editorHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(6)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: root.isDarkTheme ? "#2a2a2e" : "#e0e0e0"
        }

        Rectangle {
            id: editorInputArea
            anchors.top:  editorSep1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: editorSep2.top
            anchors.topMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            anchors.bottomMargin: vpx(14)
            color: root.isDarkTheme ? "#111114" : "#ffffff"
            radius: vpx(8)
            border.width: collectionNameInput.activeFocus ? vpx(2) : vpx(1)
            border.color: collectionNameInput.activeFocus
                ? colors.primary
                : (root.isDarkTheme ? "#303036" : "#e0e0e0")

            Behavior on border.color { ColorAnimation { duration: 100 } }

            TextInput {
                id: collectionNameInput
                anchors.fill: parent
                anchors.margins: vpx(14)
                color: root.isDarkTheme ? "#ffffff" : "#212121"
                font.pixelSize: vpx(16)
                font.bold: true
                selectByMouse: true
                focus: true
                verticalAlignment: TextInput.AlignVCenter

                onAccepted: {
                    if (text.trim() !== "") {
                        root.createNewCollection();
                    }
                }
            }
        }

        Rectangle {
            id: editorSep2
            anchors.bottom: editorBtnArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: root.isDarkTheme ? "#2a2a2e" : "#e0e0e0"
        }

        Item {
            id: editorBtnArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: vpx(20)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(44)

            Rectangle {
                id: editorCreateBtn
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width - editorCancelBtn.width - vpx(10)
                color: mouseCreateBtn.containsMouse ? "#e0e0e0" : "#ffffff"
                radius: vpx(25)
                scale: mouseCreateBtn.containsMouse ? 1.02 : 1.0

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: "Create"
                    color: "#111111"
                    font.pixelSize: vpx(16)
                    font.bold: true
                }

                MouseArea {
                    id: mouseCreateBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.createNewCollection()
                }
            }

            Rectangle {
                id: editorCancelBtn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: vpx(100)
                color: mouseCancelBtn.containsMouse ? "#33ffffff" : "#22000000"
                radius: vpx(10)
                border.color: root.isDarkTheme ? "#55ffffff" : "#aaaaaa"
                border.width: vpx(1)

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: root.isDarkTheme ? "#ffffff" : "#212121"
                    font.pixelSize: vpx(14)
                    font.bold: true
                }

                MouseArea {
                    id: mouseCancelBtn
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showCollectionEditor = false
                }
            }
        }

        Keys.onPressed: function(event) {
            if (api.keys.isCancel(event)) {
                root.showCollectionEditor = false;
                createCollectionTopBtn.forceActiveFocus();
                event.accepted = true;
            }
        }
    }

    GameMenu {
        id: gameMenu
        visible: root.showGameMenu
        z: 10
        themeColors: root.colors
        isDarkTheme: root.isDarkTheme
        focusManager: focusManager

        onRenameCollection: function(collectionId) {
            root.customCollections = Utils.loadCustomCollections();
            for (var i = 0; i < root.customCollections.length; i++) {
                if (root.customCollections[i].id === collectionId) {
                    if (root.selectedCollectionId === collectionId) {
                        root.selectedCollectionName = root.customCollections[i].name;
                    }
                    break;
                }
            }
        }

        onCloseMenu: function() {
            root.showGameMenu = false;
            if (focusManager && focusManager.customCollections) {
                focusManager.customCollections.forceActiveFocus();
            }
        }

        onDeleteCollection: function(collectionId, collectionName) {
            root.collectionToDelete = collectionId;
            root.collectionToDeleteName = collectionName;
            root.showDeleteConfirm = true;
        }
    }

    Rectangle {
        id: deleteConfirm
        width: Math.min(vpx(420), parent.width * 0.52)
        height: Math.min(vpx(240), parent.height * 0.38)
        anchors.centerIn: parent
        color: root.isDarkTheme ? "#1c1c20" : "#f2f2f4"
        radius: vpx(20)
        visible: root.showDeleteConfirm
        z: 10
        focus: visible

        scale: 0.88
        opacity: 0.0

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: vpx(10)
            radius: vpx(18)
            samples: 35
            color: "black"
        }

        ParallelAnimation {
            id: deleteEntryAnim
            NumberAnimation { target: deleteConfirm; property: "scale";   from: 0.88; to: 1.0; duration: 220; easing.type: Easing.OutCubic }
            NumberAnimation { target: deleteConfirm; property: "opacity"; from: 0.0;  to: 1.0; duration: 200; easing.type: Easing.OutQuad  }
        }

        onVisibleChanged: {
            if (visible) {
                deleteEntryAnim.stop();
                deleteConfirm.scale   = 0.88;
                deleteConfirm.opacity = 0.0;
                deleteEntryAnim.start();
                deleteConfirmIndex = 0;
                Qt.callLater(function() { deleteConfirm.forceActiveFocus(); });
            }
        }

        Keys.onPressed: function(event) {
            if (api.keys.isAccept(event)) {
                if (deleteConfirmIndex === 0) {
                    mouseDeleteYes.clicked(null);
                } else {
                    mouseDeleteNo.clicked(null);
                }
                event.accepted = true;
            } else if (api.keys.isCancel(event)) {
                mouseDeleteNo.clicked(null);
                event.accepted = true;
            } else if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
                deleteConfirmIndex = deleteConfirmIndex === 0 ? 1 : 0;
                event.accepted = true;
            }
        }

        Item {
            id: deleteHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(22)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(52)

            Text {
                text: "Delete Collection"
                color: root.isDarkTheme ? "#ffffff" : "#212121"
                font.pixelSize: vpx(22)
                font.bold: true
                anchors.top: parent.top
            }

            Text {
                text: "\"" + root.collectionToDeleteName + "\""
                color: root.isDarkTheme ? "#ffffff" : "#212121"
                font.pixelSize: vpx(12)
                font.bold: true
                font.capitalization: Font.AllUppercase
                elide: Text.ElideRight
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }

        Rectangle {
            id: deleteSep1
            anchors.top: deleteHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(6)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: root.isDarkTheme ? "#2a2a2e" : "#e0e0e0"
        }

        Text {
            id: deleteBodyText
            anchors.top: deleteSep1.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: vpx(14)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            text: "This action cannot be undone. Are you sure?"
            color: root.isDarkTheme ? "#a0a0a0" : "#616161"
            font.pixelSize: vpx(13)
            wrapMode: Text.Wrap
        }

        Rectangle {
            id: deleteSep2
            anchors.bottom: deleteBtnArea.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin:vpx(14)
            anchors.leftMargin:  vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(1)
            color: root.isDarkTheme ? "#2a2a2e" : "#e0e0e0"
        }

        Item {
            id: deleteBtnArea
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: vpx(20)
            anchors.leftMargin: vpx(22)
            anchors.rightMargin: vpx(22)
            height: vpx(44)

            Rectangle {
                id: deleteYesBtn
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width - deleteNoBtn.width - vpx(10)
                color: mouseDeleteYes.containsMouse || deleteConfirmIndex === 0 ? "#e0e0e0" : "#ffffff"
                radius: vpx(25)
                scale: mouseDeleteYes.containsMouse || deleteConfirmIndex === 0 ? 1.02 : 1.0

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Text {
                    anchors.centerIn: parent
                    text: "Yes, Delete"
                    color: "#c62828"
                    font.pixelSize: vpx(15)
                    font.bold: true
                }

                MouseArea {
                    id: mouseDeleteYes
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var deletedIndex = -1;
                        for (var i = 0; i < root.customCollections.length; i++) {
                            if (root.customCollections[i].id === root.collectionToDelete) {
                                deletedIndex = i;
                                break;
                            }
                        }

                        Utils.removeCollection(root.collectionToDelete);
                        root.customCollections = Utils.loadCustomCollections();

                        var wasSelectedCollection = root.selectedCollectionId === root.collectionToDelete;

                        if (wasSelectedCollection) {
                            root.selectedCollectionId = -1;
                            root.selectedCollectionName = "All Games";
                            root.selectedSystemCollection = null;
                            root.currentCollectionGameTitles = [];
                        }

                        root.showDeleteConfirm = false;
                        root.collectionToDelete = -1;
                        root.collectionToDeleteName = "";

                        if (focusManager) {
                            if (root.customCollections.length === 0) {
                                focusManager.selectAllGames();
                            } else {
                                var newIndex = Math.min(deletedIndex, root.customCollections.length - 1);
                                focusManager.lastCustomIndex = newIndex;
                                if (focusManager.customCollections) {
                                    focusManager.customCollections.currentIndex = newIndex;
                                    focusManager.customCollections.forceActiveFocus();
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                id: deleteNoBtn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: vpx(100)
                color: mouseDeleteNo.containsMouse || deleteConfirmIndex === 1
                    ? "#33ffffff" : "#22000000"
                radius: vpx(10)
                border.color: root.isDarkTheme ? "#55ffffff" : "#aaaaaa"
                border.width: deleteConfirmIndex === 1 ? vpx(2) : vpx(1)

                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: "Keep it"
                    color: root.isDarkTheme ? "#ffffff" : "#212121"
                    font.pixelSize: vpx(14)
                    font.bold: true
                }

                MouseArea {
                    id: mouseDeleteNo
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.showDeleteConfirm = false;
                        root.collectionToDelete = -1;
                        root.collectionToDeleteName = "";

                        if (focusManager && focusManager.customCollections) {
                            focusManager.customCollections.forceActiveFocus();
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: colors.overlay
        visible: root.showCollectionEditor || root.showGameMenu || root.showDeleteConfirm || gameDetailLoader.active
        z: 9
        opacity: 1

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (gameDetailLoader.active) {
                    return;
                }

                if (root.showDeleteConfirm) {
                    root.showDeleteConfirm = false;
                    root.collectionToDelete = -1;
                    root.collectionToDeleteName = "";
                    if (focusManager && focusManager.customCollections) {
                        focusManager.customCollections.forceActiveFocus();
                    }
                } else {
                    root.showCollectionEditor = false;
                    root.showGameMenu = false;
                }
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }

    Keys.onPressed: function(event) {
        if (gameDetailLoader.active) { return; }
        if (root.showCollectionEditor || root.showGameMenu || root.showDeleteConfirm || root.showSortMenu) {
            return;
        }

        if (root.showCollectionEditor || root.showGameMenu || root.showDeleteConfirm) {
            return;
        }

        if (event.key === Qt.Key_Left) {
            focusManager.moveFocusLeft();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right) {
            focusManager.moveFocusRight();
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            focusManager.moveFocusUp();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            focusManager.moveFocusDown();
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
        visible: root.showSortMenu
        z: 29
        onClicked: {
            root.showSortMenu = false;
        }
    }

    SortMenu {
        id: sortMenuPopup
        anchors.right: root.right
        anchors.rightMargin: vpx(10)
        anchors.top: root.top
        anchors.topMargin: vpx(66)
        themeColors: root.colors
        isDarkTheme: root.isDarkTheme
        currentSort: root.sortOrder
        visible: root.showSortMenu
        z: 30

        onSortSelected: function(sortIndex) {
            root.sortOrder = sortIndex;
            root.showSortMenu = false;
        }

        onSortOrderChangedOnly: function(sortIndex) {
            root.sortOrder = sortIndex;
        }

        onCloseMenu: {
            root.showSortMenu = false;
            sortBtn.forceActiveFocus();
        }
    }

    Loader {
        id: gameDetailLoader
        anchors.fill: parent
        active: false
        z: 15
        sourceComponent: GameDetail {
            gameData: root.currentDetailGame
            detailColors: root.colors
            isDarkTheme: root.isDarkTheme

            onClose: root.closeGameDetail()
            onLaunchRequested: {
                if (root.currentDetailGame) {
                    Utils.launchGameFromCollection(root.currentDetailGame.title)
                }
                root.closeGameDetail()
            }
            onFavoriteToggled: {
                if (root.currentDetailGame) {
                    var newState = Utils.toggleGameFavorite(root.currentDetailGame.title)
                    if (newState !== null)
                        root.currentDetailGame.favorite = newState
                }
            }
        }

        onActiveChanged: {
            if (active) {
                Qt.callLater(function() {
                    if (gameDetailLoader.item) {
                        gameDetailLoader.item.forceActiveFocus()
                    }
                })
            }
        }
    }
}
