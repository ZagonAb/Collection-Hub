import QtQuick 2.0
import SortFilterProxyModel 0.2
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
        height: parent.height
        color: "#2c2c2c"
        border.color: "#444"
        border.width: vpx(2)

        Column {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                width: parent.width
                height: vpx(60)
                color: root.selectedCollectionId === -1 && root.selectedSystemCollection === null ? "#3a6ea5" : "#2c2c2c"
                border.color: "#444"
                border.width: vpx(1)

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

            Rectangle {
                width: parent.width
                height: vpx(2)
                color: "#444"
            }

            SystemCollections {
                id: systemCollections
                width: parent.width
                height: (parent.height - vpx(62)) / 2

                onCollectionSelected: function(collection) {
                    root.selectedSystemCollection = collection;
                    root.selectedCollectionId = -1;
                    root.selectedCollectionName = collection.name;
                    root.currentCollectionGameTitles = [];
                    customCollectionsView.selectedCollectionId = -1;
                    searchBar.clear();
                    gamesGrid.searchFilter = "";
                    console.log("Seleccionada colección del sistema:", collection.name);
                }
            }

            Rectangle {
                width: parent.width
                height: vpx(2)
                color: "#444"
            }

            CustomCollections {
                id: customCollectionsView
                width: parent.width
                height: (parent.height - vpx(62)) / 2
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
                    console.log("Seleccionada colección personalizada:", collectionName);
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
        height: vpx(70)
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
                text: "Nueva Colección"
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
                        text: "Crear"
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
                        text: "Cancelar"
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

    Rectangle {
        id: gameMenu
        width: parent.width * 0.25
        height: menuColumn.height + vpx(20)
        x: Math.min(root.menuX, parent.width - width - vpx(10))
        y: Math.min(root.menuY, parent.height - height - vpx(10))
        color: "#2c2c2c"
        border.color: "#3a6ea5"
        border.width: vpx(3)
        radius: vpx(12)
        visible: root.showGameMenu
        z: 10

        property string gameTitle: root.currentGameForMenu ? root.currentGameForMenu.title : ""
        property bool isInCurrentCollection: {
            if (root.selectedCollectionId === -1) return false;
            return Utils.isGameInCollection(root.selectedCollectionId, gameTitle);
        }

        Column {
            id: menuColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: vpx(12)
            spacing: vpx(6)

            Rectangle {
                width: parent.width
                height: vpx(50)
                color: "transparent"

                Text {
                    anchors.fill: parent
                    text: gameMenu.gameTitle
                    color: "white"
                    font.bold: true
                    font.pixelSize: vpx(15)
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                height: vpx(2)
                width: parent.width
                color: "#555"
                radius: vpx(1)
            }

            Column {
                width: parent.width
                spacing: vpx(6)
                visible: (root.selectedCollectionId === -1 || root.selectedSystemCollection !== null) && root.customCollections.length > 0

                Text {
                    text: "Añadir a colección:"
                    color: "#AAA"
                    font.pixelSize: vpx(12)
                    font.italic: true
                }

                Repeater {
                    model: root.customCollections

                    Rectangle {
                        width: parent.width
                        height: vpx(40)
                        color: mouseAddTo.containsMouse ? "#3a6ea5" : "transparent"
                        radius: vpx(6)

                        property bool alreadyInCollection: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: vpx(10)
                            spacing: vpx(10)

                            Text {
                                text: parent.parent.alreadyInCollection ? "✓" : "+"
                                color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                                font.pixelSize: vpx(16)
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.name
                                color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                                font.pixelSize: vpx(13)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: mouseAddTo
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: parent.alreadyInCollection ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                            enabled: !parent.alreadyInCollection
                            onClicked: {
                                if (root.currentGameForMenu) {
                                    var success = Utils.addGameToCollection(
                                        modelData.id,
                                        root.currentGameForMenu
                                    );

                                    if (success) {
                                        root.customCollections = Utils.loadCustomCollections();
                                    }
                                }
                            }
                            onEntered: if (enabled) parent.scale = 1.03
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
            }

            Text {
                width: parent.width
                height: vpx(40)
                text: "Crea una colección primero"
                color: "#888"
                font.pixelSize: vpx(13)
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: (root.selectedCollectionId === -1 || root.selectedSystemCollection !== null) && root.customCollections.length === 0
            }

            Column {
                width: parent.width
                spacing: vpx(6)
                visible: root.selectedCollectionId !== -1 && root.selectedSystemCollection === null

                Rectangle {
                    width: parent.width
                    height: vpx(45)
                    color: mouseRemove.containsMouse ? "#f44336" : "transparent"
                    radius: vpx(6)
                    visible: gameMenu.isInCurrentCollection
                    border.color: mouseRemove.containsMouse ? "#ef5350" : "transparent"
                    border.width: vpx(2)

                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: vpx(10)
                        spacing: vpx(10)

                        Text {
                            text: "✕"
                            color: "white"
                            font.pixelSize: vpx(16)
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Quitar de: " + root.selectedCollectionName
                            color: "white"
                            font.pixelSize: vpx(13)
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    MouseArea {
                        id: mouseRemove
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (root.currentGameForMenu && root.selectedCollectionId !== -1) {
                                var success = Utils.removeGameFromCollection(
                                    root.selectedCollectionId,
                                    root.currentGameForMenu.title
                                );

                                if (success) {
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
                                root.showGameMenu = false;
                            }
                        }
                        onEntered: parent.scale = 1.03
                        onExited: parent.scale = 1.0
                    }

                    Behavior on scale {
                        NumberAnimation { duration: 150 }
                    }
                }

                Text {
                    text: "Añadir a otra colección:"
                    color: "#AAA"
                    font.pixelSize: vpx(12)
                    font.italic: true
                    visible: root.customCollections.length > 1
                }

                Repeater {
                    model: root.customCollections

                    Rectangle {
                        width: parent.width
                        height: vpx(40)
                        color: mouseAddOther.containsMouse ? "#3a6ea5" : "transparent"
                        radius: vpx(6)
                        visible: modelData.id !== root.selectedCollectionId

                        property bool alreadyInCollection: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: vpx(10)
                            spacing: vpx(10)

                            Text {
                                text: parent.parent.alreadyInCollection ? "✓" : "+"
                                color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                                font.pixelSize: vpx(16)
                                font.bold: true
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: modelData.name
                                color: parent.parent.alreadyInCollection ? "#4CAF50" : "white"
                                font.pixelSize: vpx(13)
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            id: mouseAddOther
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: parent.alreadyInCollection ? Qt.ForbiddenCursor : Qt.PointingHandCursor
                            enabled: !parent.alreadyInCollection
                            onClicked: {
                                if (root.currentGameForMenu) {
                                    var success = Utils.addGameToCollection(
                                        modelData.id,
                                        root.currentGameForMenu
                                    );

                                    if (success) {
                                        root.customCollections = Utils.loadCustomCollections();
                                    }
                                }
                            }
                            onEntered: if (enabled) parent.scale = 1.03
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
            }

            Rectangle {
                height: vpx(2)
                width: parent.width
                color: "#555"
                radius: vpx(1)
            }

            Rectangle {
                width: parent.width
                height: vpx(45)
                color: mouseLaunch.containsMouse ? "#4CAF50" : "transparent"
                radius: vpx(6)
                border.color: mouseLaunch.containsMouse ? "#66BB6A" : "transparent"
                border.width: vpx(2)

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(10)
                    spacing: vpx(10)

                    Text {
                        text: "▶"
                        color: "white"
                        font.pixelSize: vpx(16)
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Lanzar juego"
                        color: "white"
                        font.pixelSize: vpx(13)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: mouseLaunch
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.currentGameForMenu) {
                            root.currentGameForMenu.launch();
                            root.showGameMenu = false;
                        }
                    }
                    onEntered: parent.scale = 1.03
                    onExited: parent.scale = 1.0
                }

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
            }

            Rectangle {
                width: parent.width
                height: vpx(45)
                color: mouseClose.containsMouse ? "#666" : "transparent"
                radius: vpx(6)

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: vpx(10)
                    spacing: vpx(10)

                    Text {
                        text: "✕"
                        color: "white"
                        font.pixelSize: vpx(16)
                        font.bold: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "Cerrar"
                        color: "white"
                        font.pixelSize: vpx(13)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: mouseClose
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showGameMenu = false
                    onEntered: parent.scale = 1.03
                    onExited: parent.scale = 1.0
                }

                Behavior on scale {
                    NumberAnimation { duration: 150 }
                }
            }
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
