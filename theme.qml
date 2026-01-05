import QtQuick 2.0
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.12
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

    function createNewCollection() {
        if (collectionNameInput.text.trim() !== "") {
            var newId = Utils.createCollection(collectionNameInput.text.trim());
            customCollections = Utils.loadCustomCollections();
            showCollectionEditor = false;
            console.log("Colección creada:", collectionNameInput.text.trim());
        }
    }

    Component.onCompleted: {
        customCollections = Utils.loadCustomCollections();
        selectedCollectionId = -1;
        selectedCollectionName = "All Games";
        selectedSystemCollection = null;
        currentCollectionGameTitles = [];
        console.log("Theme iniciado con All Games");
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a1a"
    }

    Rectangle {
        id: leftPanel
        width: parent.width * 0.22
        height: parent.height * 0.90
        anchors {
            left: parent.left
            leftMargin: vpx(10)
            top: parent.top
            topMargin: vpx(10)
            bottom: parent.bottom
            bottomMargin: vpx(60)
        }
        color: "#2c2c2c"
        radius: 10

        Column {
            anchors.fill: parent
            spacing: 15

            Rectangle {
                width: parent.width
                height: vpx(45)
                color: root.selectedCollectionId === -1 && root.selectedSystemCollection === null ? "#3a6ea5" : "#2c2c2c"
                border.color: "#3a6ea5"
                border.width: vpx(1)
                radius: 10

                Row {
                    anchors.centerIn: parent
                    spacing: vpx(10)

                    Text {
                        text: "🎮"
                        font.pixelSize: vpx(24)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "All Games (" + api.allGames.count + ")"
                        color: "white"
                        font.pixelSize: vpx(15)
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

            SystemCollections {
                id: systemCollections
                width: parent.width
                height: (parent.height - vpx(50)) / 2

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
                height: parent.height / 2 //(parent.height - vpx(62)) / 2
                customCollections: root.customCollections
                selectedCollectionId: root.selectedCollectionId

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
            }
        }
    }

    Rectangle {
        id: topBarContainer
        anchors {
            left: leftPanel.right
            right: parent.right
            top: parent.top
        }
        height: vpx(80)
        color: "#1a1a1a"

        SearchBar {
            id: searchBar
            anchors {
                fill: parent
                margins: vpx(10)
            }

            onSearchChanged: function(text) {
                gamesGrid.searchFilter = text;
            }
        }
    }

    GamesGrid {
        id: gamesGrid
        anchors {
            left: leftPanel.right
            right: parent.right
            top: topBarContainer.bottom
            bottom: parent.bottom
        }
        selectedCollectionId: root.selectedCollectionId
        selectedCollectionName: root.selectedCollectionName
        collectionGameTitles: root.currentCollectionGameTitles
        systemCollection: root.selectedSystemCollection
        isAllGamesSelected: root.isAllGamesSelected

        onGameRightClicked: function(game, x, y) {
            root.currentGameForMenu = game;
            root.menuX = x;
            root.menuY = y;
            root.showGameMenu = true;
        }
    }

    Rectangle {
        id: collectionEditor
        width: parent.width * 0.35
        height: parent.height * 0.28
        anchors.centerIn: parent
        color: "#2c2c2c"
        border.color: "#3a6ea5"
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
            spacing: vpx(20)
            width: parent.width * 0.85

            Text {
                text: "New Collection"
                font.bold: true
                font.pixelSize: vpx(20)
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Rectangle {
                width: parent.width
                height: vpx(45)
                color: "#1a1a1a"
                border.color: "#555"
                border.width: vpx(2)
                radius: vpx(6)

                TextInput {
                    id: collectionNameInput
                    anchors.fill: parent
                    anchors.margins: vpx(10)
                    color: "white"
                    font.pixelSize: vpx(16)
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
                spacing: vpx(15)
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: vpx(120)
                    height: vpx(45)
                    color: mouseCreateBtn.containsMouse ? "#4CAF50" : "#2E7D32"
                    radius: vpx(8)
                    border.color: "#66BB6A"
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Create"
                        color: "white"
                        font.bold: true
                        font.pixelSize: vpx(15)
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
                    width: vpx(120)
                    height: vpx(45)
                    color: mouseCancelBtn.containsMouse ? "#f44336" : "#c62828"
                    radius: vpx(8)
                    border.color: "#ef5350"
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "white"
                        font.bold: true
                        font.pixelSize: vpx(15)
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

    // GameMenu independiente
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

        onGameAddedToCollection: function(collectionId) {
            root.customCollections = Utils.loadCustomCollections();
            if (root.selectedCollectionId === collectionId) {
                // Actualizar la lista de títulos si estamos en esa colección
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
            // Actualizar la lista de títulos de la colección actual
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
        }
    }

    Rectangle {
        id: deleteConfirm
        width: parent.width * 0.35
        height: parent.height * 0.22
        anchors.centerIn: parent
        color: "#2c2c2c"
        border.color: "#f44336"
        border.width: vpx(3)
        radius: vpx(12)
        visible: root.showDeleteConfirm
        z: 10

        Column {
            anchors.centerIn: parent
            spacing: vpx(20)
            width: parent.width * 0.85

            Text {
                width: parent.width
                text: "¿Eliminar colección:\n\"" + root.collectionToDeleteName + "\"?"
                color: "white"
                font.pixelSize: vpx(17)
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
            }

            Row {
                spacing: vpx(15)
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    width: vpx(120)
                    height: vpx(45)
                    color: mouseDeleteYes.containsMouse ? "#f44336" : "#c62828"
                    radius: vpx(8)
                    border.color: "#ef5350"
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "Sí"
                        color: "white"
                        font.bold: true
                        font.pixelSize: vpx(15)
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
                    width: vpx(120)
                    height: vpx(45)
                    color: mouseDeleteNo.containsMouse ? "#666" : "#444"
                    radius: vpx(8)
                    border.color: "#888"
                    border.width: vpx(2)

                    Text {
                        anchors.centerIn: parent
                        text: "No"
                        color: "white"
                        font.bold: true
                        font.pixelSize: vpx(15)
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
        color: "#CC000000"
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
