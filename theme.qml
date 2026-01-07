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
    property var currentGameForMenu: null
    property bool showDeleteConfirm: false
    property int collectionToDelete: -1
    property string collectionToDeleteName: ""
    property bool isAllGamesSelected: selectedCollectionId === -1 && selectedSystemCollection === null
    property int menuX: 0
    property int menuY: 0
    property bool isDarkTheme: true
    property var colors: isDarkTheme ? darkColors : lightColors

    property var darkColors: ({
        "background": "#0a0a0a",
        "panel": "#151515",
        "menucolor": "#090909",
        "panelBorder": "#252525",
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
        "background": "#f5f5f5",
        "panel": "#ffffff",
        "menucolor": "#ebebeb",
        "panelBorder": "#e0e0e0",
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
        "tileImageBg": "#fafafa",
        "overlay": "#CC000000"
    })

    function createNewCollection() {
        if (collectionNameInput.text.trim() !== "") {
            var newId = Utils.createCollection(collectionNameInput.text.trim());
            customCollections = Utils.loadCustomCollections();
            showCollectionEditor = false;
            //console.log("Colección creada:", collectionNameInput.text.trim());
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

        //console.log("Theme iniciado con All Games");
    }

    Rectangle {
        anchors.fill: parent
        color: colors.background

        RadialGradientOverlay {
            anchors.fill: parent
            isDarkTheme: customCollectionsContainer.isDarkTheme
            opacityMultiplier: 0.7
            radius: customCollectionsContainer.radius
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: vpx(10)
        spacing: vpx(10)

        Rectangle {
            id: leftPanel
            Layout.preferredWidth: parent.width * 0.22
            Layout.preferredHeight: parent.height * 0.97
            color: colors.panel
            radius: 10
            border.color: colors.panelBorder
            border.width: vpx(1)

            RadialGradient {
                anchors.fill: parent
                horizontalOffset: parent.width * 0.5
                verticalOffset: parent.height * 0.5
                visible: root.isDarkTheme
                gradient: Gradient {
                    GradientStop { position: 0.0; color: isDarkTheme ? "#20ffffff" : "#15ffffff" }
                    GradientStop { position: 0.5; color: isDarkTheme ? "#08ffffff" : "#05ffffff" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                z: 0

                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: leftPanel.width
                        height: leftPanel.height
                        radius: 10
                    }
                }
            }

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
                        radius: vpx(8)

                        Row {
                            anchors.centerIn: parent
                            spacing: vpx(8)

                            Text {
                                text: "🎮"
                                font.pixelSize: vpx(20)
                                anchors.verticalCenter: parent.verticalCenter
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
                        radius: vpx(8)

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

                                ColorOverlay {
                                    anchors.fill: parent
                                    source: parent
                                    color: "#ffffff"
                                    visible: parent.visible
                                }
                            }

                            Image {
                                id: darkIcon
                                anchors.fill: parent
                                mipmap: true
                                source: "assets/icons/dark.svg"
                                visible: !root.isDarkTheme

                                ColorOverlay {
                                    anchors.fill: parent
                                    source: parent
                                    color: "#212121"
                                    visible: parent.visible
                                }
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
                    isDarkTheme: root.isDarkThem

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

                    onCollectionSelected: function(collectionId, collectionName, gameTitles) {
                        root.selectedCollectionId = collectionId;
                        root.selectedCollectionName = collectionName;
                        root.selectedSystemCollection = null;
                        root.currentCollectionGameTitles = gameTitles;
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
            spacing: vpx(10)

            Rectangle {
                id: topBarContainer
                Layout.fillWidth: true
                Layout.preferredHeight: vpx(80)
                color: "transparent"

                SearchBar {
                    id: searchBar
                    anchors {
                        fill: parent
                        margins: vpx(10)
                    }
                    searchColors: root.colors

                    onSearchChanged: function(text) {
                        gamesGrid.searchFilter = text;
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
                color: "transparent"
                themeColors: root.colors
                isDarkTheme: root.isDarkTheme

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

        onGameAddedToCollection: function(collectionId) {
            root.customCollections = Utils.loadCustomCollections();
            if (root.selectedCollectionId === collectionId) {
                for (var i = 0; i < root.customCollections.length; i++) {
                    if (root.customCollections[i].id === collectionId) {
                        var titles = [];
                        for (var j = 0; j < root.customCollections[i].games.length; j++) {
                            titles.push(root.customCollections[i].games[j].title);
                        }
                        root.currentCollectionGameTitles = titles;
                        break;
                    }
                }
            }
        }

        onGameRemovedFromCollection: function() {
            root.customCollections = Utils.loadCustomCollections();
            for (var i = 0; i < root.customCollections.length; i++) {
                if (root.customCollections[i].id === root.selectedCollectionId) {
                    var titles = [];
                    for (var j = 0; j < root.customCollections[i].games.length; j++) {
                        titles.push(root.customCollections[i].games[j].title);
                    }
                    root.currentCollectionGameTitles = titles;
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
            gameMenu.isCollectionContext = false;
            gameMenu.contextCollectionId = -1;
            gameMenu.contextCollectionName = "";
        }

        onDeleteCollection: function(collectionId, collectionName) {
            root.collectionToDelete = collectionId;
            root.collectionToDeleteName = collectionName;
            root.showDeleteConfirm = true;
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
                    color: mouseDeleteYes.containsMouse ? colors.error : colors.errorDark
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
                            Utils.removeCollection(root.collectionToDelete);
                            root.customCollections = Utils.loadCustomCollections();

                            if (root.selectedCollectionId === root.collectionToDelete) {
                                root.selectedCollectionId = -1;
                                root.selectedCollectionName = "All Games";
                                root.selectedSystemCollection = null;
                                root.currentCollectionGameTitles = [];
                            }

                            root.showDeleteConfirm = false;
                            root.collectionToDelete = -1;
                            root.collectionToDeleteName = "";
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
                    color: mouseDeleteNo.containsMouse ? colors.inputBorder : colors.panelBorder
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
        visible: root.showCollectionEditor || root.showGameMenu || root.showDeleteConfirm
        z: 9
        opacity: 0

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.showCollectionEditor = false;
                root.showGameMenu = false;
                root.showDeleteConfirm = false;
                root.collectionToDelete = -1;
                root.collectionToDeleteName = "";
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        Component.onCompleted: opacity = 1
    }
}
