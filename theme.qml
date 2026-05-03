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
        "background": "#151519",
        "panel": "#28282c",
        "rightpanel": "#222226",
        "menucolor": "#090909",
        "panelBorder": "#28282c",
        "primary": "#3a6ea5",
        "primaryHover": "#5a8ec5",
        "text": "#ffffff",
        "textSecondary": "#a0a0a0",
        "textTertiary": "#707070",
        "success": "#4CAF50",
        "successDark": "#2E7D32",
        "successLight": "#66BB6A",
        "error": "#f44336",
        "errorDark": "#c62828",
        "errorLight": "#ef5350",
        "inputBg": "#0f0f0f",
        "inputBorder": "#303030",
        "separator": "#252525",
        "tileBg": "#1a1a1a",
        "tileBorder": "#252525",
        "tileImageBg": "#0f0f0f",
        "overlay": "#DD000000"
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
                        width: parent.width - vpx(48)
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

                    Rectangle {
                        width: vpx(40)
                        height: vpx(40)
                        color: themeToggleMouseArea.containsMouse ? colors.primary : "transparent"
                        border.color: colors.panelBorder
                        border.width: vpx(1)
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
                            onEntered: parent.scale = 1.05
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
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
                            gameMenu.isCollectionContext = true;
                            gameMenu.contextCollectionId = collectionId;
                            gameMenu.contextCollectionName = collectionName;
                            root.currentGameForMenu = null;
                            root.menuX = x;
                            root.menuY = y;
                            root.showGameMenu = true;
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
                        root.showSortMenu = true;
                    }
                }

                Rectangle {
                    id: sortBtn
                    anchors {
                        right: parent.right
                        rightMargin: vpx(10)
                        verticalCenter: parent.verticalCenter
                    }
                    width: vpx(44)
                    height: vpx(44)
                    color: root.showSortMenu ? colors.primary : (sortBtnMouse.containsMouse ? colors.primary : "transparent")
                    border.color: root.showSortMenu ? colors.primary : colors.panelBorder
                    border.width: vpx(2)
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
                            }
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 120 }
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

                onGameRightClicked: function(game, x, y) {
                    if (root.showGameMenu) {
                        root.showGameMenu = false;
                    } else {
                        gameMenu.isCollectionContext = false;
                        gameMenu.contextCollectionId = -1;
                        gameMenu.contextCollectionName = "";
                        root.currentGameForMenu = game;
                        root.menuX = x;
                        root.menuY = y;
                        root.showGameMenu = true;
                    }
                }
            }
        }
    }

    Rectangle {
        id: collectionEditor
        width: parent.width * 0.25
        height: parent.height * 0.20
        anchors.centerIn: parent
        color: colors.panel
        border.color: colors.primary
        border.width: vpx(3)
        radius: vpx(12)
        visible: root.showCollectionEditor
        z: 10

        onVisibleChanged: {
            if (visible) {
                collectionNameInput.forceActiveFocus();
                collectionNameInput.selectAll();
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Math.max(vpx(15), collectionEditor.height * 0.06)
            width: parent.width * 0.85

            Text {
                text: "New Collection"
                font.bold: true
                font.pixelSize: Math.max(vpx(16), collectionEditor.height * 0.08)
                color: colors.text
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: Math.max(vpx(40), collectionEditor.height * 0.18)
                color: colors.inputBg
                border.color: colors.inputBorder
                border.width: vpx(2)
                radius: vpx(6)

                TextInput {
                    id: collectionNameInput
                    anchors.fill: parent
                    anchors.margins: vpx(10)
                    color: colors.text
                    font.pixelSize: Math.max(vpx(14), parent.height * 0.35)
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

            Row {
                spacing: Math.max(vpx(12), collectionEditor.width * 0.04)
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: Math.max(vpx(100), collectionEditor.width * 0.35)
                    height: Math.max(vpx(40), collectionEditor.height * 0.16)
                    color: mouseCreateBtn.containsMouse ? colors.success : colors.successDark
                    radius: vpx(8)
                    border.color: colors.successLight
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Create"
                        color: "white"
                        font.bold: true
                        font.pixelSize: Math.max(vpx(13), parent.height * 0.32)
                    }

                    MouseArea {
                        id: mouseCreateBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.createNewCollection()
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }

                Rectangle {
                    width: Math.max(vpx(100), collectionEditor.width * 0.35)
                    height: Math.max(vpx(40), collectionEditor.height * 0.16)
                    color: mouseCancelBtn.containsMouse ? colors.error : colors.errorDark
                    radius: vpx(8)
                    border.color: colors.errorLight
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "white"
                        font.bold: true
                        font.pixelSize: Math.max(vpx(13), parent.height * 0.32)
                    }

                    MouseArea {
                        id: mouseCancelBtn
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.showCollectionEditor = false
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }

    GameMenu {
        id: gameMenu
        visible: root.showGameMenu
        z: 10
        currentGame: root.currentGameForMenu
        selectedCollectionId: root.selectedCollectionId
        selectedCollectionName: root.selectedCollectionName
        selectedSystemCollection: root.selectedSystemCollection
        customCollections: root.customCollections
        menuX: root.menuX
        menuY: root.menuY
        themeColors: root.colors
        isDarkTheme: root.isDarkTheme
        focusManager: focusManager

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

        onGameRemovedFromCollection: function() {
            root.customCollections = Utils.loadCustomCollections();
            for (var i = 0; i < root.customCollections.length; i++) {
                if (root.customCollections[i].id === root.selectedCollectionId) {
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

        onLaunchGame: function() {
            if (root.currentGameForMenu) {
                Utils.launchGameFromCollection(root.currentGameForMenu.title);
                root.showGameMenu = false;
            }
        }

        onCloseMenu: function() {
            root.showGameMenu = false;
            var wasCollectionContext = gameMenu.isCollectionContext;
            gameMenu.isCollectionContext = false;
            gameMenu.contextCollectionId = -1;
            gameMenu.contextCollectionName = "";

            if (focusManager) {
                if (wasCollectionContext) {
                    if (focusManager.customCollections) {
                        focusManager.customCollections.forceActiveFocus();
                    }
                } else if (focusManager.gamesGrid) {
                    focusManager.gamesGrid.forceActiveFocus();
                }
            }
        }

        onDeleteCollection: function(collectionId, collectionName) {
            root.collectionToDelete = collectionId;
            root.collectionToDeleteName = collectionName;
            root.showDeleteConfirm = true;
        }

        onShowGameDetails: function() {
            gameMenu.showDetails = true;
        }
    }

    Rectangle {
        id: deleteConfirm
        width: parent.width * 0.25
        height: parent.height * 0.20
        anchors.centerIn: parent
        color: colors.panel
        border.color: colors.error
        border.width: vpx(3)
        radius: vpx(12)
        visible: root.showDeleteConfirm
        z: 10
        focus: visible

        onVisibleChanged: {
            if (visible) {
                deleteConfirmIndex = 0;
                Qt.callLater(function() {
                    deleteConfirm.forceActiveFocus();
                });
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

        Column {
            anchors.centerIn: parent
            spacing: Math.max(vpx(15), deleteConfirm.height * 0.08)
            width: parent.width * 0.85

            Text {
                width: parent.width
                text: "Delete collection:\n\"" + root.collectionToDeleteName + "\"?"
                color: colors.text
                font.pixelSize: Math.max(vpx(14), deleteConfirm.height * 0.08)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Row {
                spacing: Math.max(vpx(12), deleteConfirm.width * 0.04)
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: Math.max(vpx(100), deleteConfirm.width * 0.35)
                    height: Math.max(vpx(40), deleteConfirm.height * 0.2)
                    color: mouseDeleteYes.containsMouse || deleteConfirmIndex === 0 ?
                    colors.error : colors.errorDark
                    radius: vpx(8)
                    border.color: colors.errorLight
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Yes"
                        color: "white"
                        font.bold: true
                        font.pixelSize: Math.max(vpx(13), parent.height * 0.32)
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
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }

                Rectangle {
                    width: Math.max(vpx(100), deleteConfirm.width * 0.35)
                    height: Math.max(vpx(40), deleteConfirm.height * 0.2)
                    color: mouseDeleteNo.containsMouse || deleteConfirmIndex === 1 ?
                    colors.inputBorder : colors.panelBorder
                    radius: vpx(8)
                    border.color: colors.inputBorder
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "No"
                        color: colors.text
                        font.bold: true
                        font.pixelSize: Math.max(vpx(13), parent.height * 0.32)
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
                        onEntered: parent.scale = 1.05
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
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
            searchBar.forceActiveFocus();
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
