import QtQuick 2.15
import QtGraphicalEffects 1.12
import "utils.js" as Utils
import "qrc:/qmlutils" as PegasusUtils

Rectangle {
    id: gameMenu

    width: parent.width * 0.18
    height: Math.min(menuColumn.height + vpx(25), parent.height * 0.8)

    property var themeColors: ({})
    property bool isDarkTheme: true
    property var currentGame: null
    property string gameTitle: currentGame ? currentGame.title : ""
    property int selectedCollectionId: -1
    property string selectedCollectionName: ""
    property var selectedSystemCollection: null
    property var customCollections: []
    property int menuX: 0
    property int menuY: 0
    property bool isCollectionContext: false
    property int contextCollectionId: -1
    property string contextCollectionName: ""
    property int highlightedIndex: -1
    property bool showDetails: false
    property var gameDetailsLoader: null

    signal gameAddedToCollection(int collectionId)
    signal gameRemovedFromCollection()
    signal launchGame()
    signal closeMenu()
    signal deleteCollection(int collectionId, string collectionName)
    signal showGameDetails()

    property bool isInCurrentCollection: {
        if (selectedCollectionId === -1) return false;
        return Utils.isGameInCollection(selectedCollectionId, gameTitle);
    }

    property var focusManager: null
    property int currentMenuIndex: 0
    property int menuItemCount: {
        var count = 0;

        if (!isCollectionContext) {
            count += 1;
            count += 1;
            if (customCollections.length > 0) {
                count += customCollections.length;
            }
            if (selectedCollectionId !== -1 &&
                selectedSystemCollection === null && isInCurrentCollection) {
                count += 1;
                }
        }

        if (isCollectionContext) {
            count += 1;
        }

        count += 1;

        return count;
    }

    color: root ? root.colors.menucolor || root.colors.panel || "#2c2c2c" : "#2c2c2c"
    border.color: themeColors.primary || "#3a6ea5"
    border.width: vpx(3)
    radius: vpx(12)
    z: 20

    onMenuXChanged: updatePosition()
    onMenuYChanged: updatePosition()
    onShowDetailsChanged: {
        if (showDetails) {
            loadGameDetails();
            updatePosition();
        } else if (gameDetailsLoader) {
            gameDetailsLoader.active = false;
        }
    }

    onCurrentGameChanged: {
        if (showDetails && gameDetailsLoader && gameDetailsLoader.item) {
            showDetails = false;
            gameDetailsLoader.active = false;
        }
    }

    function updatePosition() {
        if (parent) {
            var targetX = menuX;
            var targetY = menuY + vpx(15);

            if (showDetails && gameDetailsLoader && gameDetailsLoader.item) {
                var detailsWidth = gameDetailsLoader.item.width;
                var totalWidth = width + detailsWidth + vpx(5);

                if (menuX + totalWidth > parent.width - vpx(10)) {
                    targetX = menuX - totalWidth + vpx(10);
                } else {
                    targetX = menuX;
                }
            } else {
                targetX = menuX - width - vpx(2);
            }

            x = Math.max(vpx(10), Math.min(targetX, parent.width - width - vpx(10)));
            y = Math.max(vpx(10), Math.min(targetY, parent.height - height - vpx(10)));

            if (showDetails && gameDetailsLoader && gameDetailsLoader.item) {
                positionDetailsPanel();
            }
        }
    }

    function loadGameDetails() {
        if (!gameDetailsLoader) {
            gameDetailsLoader = detailsLoaderComponent.createObject(gameMenu.parent, {
                "z": 21
            });
        }
        gameDetailsLoader.active = true;
        if (gameDetailsLoader.item) {
            gameDetailsLoader.item.gameData = currentGame;
        }
        updatePosition();
    }

    function getItemAtIndex(index) {
        var currentIdx = 0;

        if (!isCollectionContext) {
            if (index === currentIdx) return launchGameBtn;
            currentIdx++;

            if (index === currentIdx) return showDetailsBtn;
            currentIdx++;

            if (customCollections.length > 0) {
                if (index >= currentIdx && index < currentIdx + customCollections.length) {
                    return collectionsListView.itemAtIndex(index - currentIdx);
                }
                currentIdx += customCollections.length;
            }

            if (selectedCollectionId !== -1 &&
                selectedSystemCollection === null && isInCurrentCollection) {
                if (index === currentIdx) return removeFromCollectionBtn;
                currentIdx++;
                }
        }

        if (isCollectionContext) {
            if (index === currentIdx) return deleteCollectionBtn;
            currentIdx++;
        }

        if (index === currentIdx) return closeBtn;

        return null;
    }

    function highlightCurrentItem() {
        highlightedIndex = currentMenuIndex;
    }

    function activateCurrentItem() {
        var item = getItemAtIndex(currentMenuIndex);
        if (item === launchGameBtn) {
            gameMenu.launchGame();
        } else if (item === showDetailsBtn) {
            if (showDetails) {
                gameMenu.showDetails = false;
            } else {
                gameMenu.showGameDetails();
            }
        } else if (item === removeFromCollectionBtn) {
            var success = Utils.removeGameFromCollection(selectedCollectionId, currentGame.title);
            if (success) {
                gameMenu.gameRemovedFromCollection();
                gameMenu.closeMenu();
            }
        } else if (item === deleteCollectionBtn) {
            gameMenu.deleteCollection(contextCollectionId, contextCollectionName);
            gameMenu.closeMenu();
        } else if (item === closeBtn) {
            gameMenu.closeMenu();
        } else if (collectionsListView.visible) {
            var listIndex = currentMenuIndex - 2;
            if (!isCollectionContext && listIndex >= 0 && listIndex < customCollections.length) {
                var modelData = customCollections[listIndex];
                var hasGame = Utils.isGameInCollection(modelData.id, gameMenu.gameTitle);

                if (!hasGame) {
                    var success = Utils.addGameToCollection(modelData.id, currentGame);
                    if (success) {
                        gameMenu.gameAddedToCollection(modelData.id);
                    }
                }
            }
        }
    }

    function positionDetailsPanel() {
        if (!gameMenu.parent || !gameDetailsLoader || !gameDetailsLoader.item) return;

        var detailsPanel = gameDetailsLoader.item;
        var detailsX = gameMenu.x + gameMenu.width + vpx(5);
        var detailsY = gameMenu.y;

        if (detailsX + detailsPanel.width > gameMenu.parent.width - vpx(10)) {
            detailsX = gameMenu.x - detailsPanel.width - vpx(5);
        }

        detailsY = Math.max(vpx(10), Math.min(detailsY, gameMenu.parent.height - detailsPanel.height - vpx(10)));

        detailsPanel.x = detailsX;
        detailsPanel.y = detailsY;
    }

    Keys.onPressed: function(event) {
        if (api.keys.isAccept(event)) {
            if (showDetails && currentMenuIndex === 1) {
                showDetails = false;
                forceActiveFocus();
                event.accepted = true;
            } else {
                activateCurrentItem();
                event.accepted = true;
            }
        } else if (api.keys.isCancel(event)) {
            if (showDetails) {
                showDetails = false;
                forceActiveFocus();
            } else {
                closeMenu();
            }
            event.accepted = true;
        } else if (event.key === Qt.Key_Up) {
            currentMenuIndex = Math.max(0, currentMenuIndex - 1);
            highlightCurrentItem();
            event.accepted = true;
        } else if (event.key === Qt.Key_Down) {
            currentMenuIndex = Math.min(menuItemCount - 1, currentMenuIndex + 1);
            highlightCurrentItem();
            event.accepted = true;
        } else if (event.key === Qt.Key_Left && showDetails) {
            showDetails = false;
            forceActiveFocus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Right && !showDetails && currentMenuIndex === 1) {
            gameMenu.showGameDetails();
            event.accepted = true;
        }
    }

    onVisibleChanged: {
        if (visible) {
            currentMenuIndex = 0;
            highlightedIndex = -1;
            showDetails = false;
            forceActiveFocus();
            Qt.callLater(function() {
                highlightedIndex = 0;
            });
        } else {
            highlightedIndex = -1;
            showDetails = false;
            if (gameDetailsLoader) {
                gameDetailsLoader.active = false;
            }
        }
    }

    RadialGradientOverlay {
        anchors.fill: parent
        isDarkTheme: gameMenu.isDarkTheme
        opacityMultiplier: 0.5
        radius: gameMenu.radius
        visible: gameMenu.isDarkTheme
    }

    Column {
        id: menuColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: vpx(10)
        spacing: vpx(6)

        Rectangle {
            width: parent.width
            height: vpx(35)
            color: "transparent"

            Text {
                anchors.fill: parent
                anchors.leftMargin: vpx(5)
                text: isCollectionContext ? contextCollectionName : gameMenu.gameTitle
                color: themeColors.text || "white"
                font.bold: true
                font.pixelSize: vpx(13)
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                maximumLineCount: 2
                verticalAlignment: Text.AlignVCenter
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
        }

        Rectangle {
            id: launchGameBtn
            width: parent.width
            height: vpx(35)
            visible: !isCollectionContext
            color: mouseLaunch.containsMouse || highlightedIndex === 0 ?
            themeColors.success || "#4CAF50" :
            "transparent"
            radius: vpx(5)
            border.color: mouseLaunch.containsMouse || highlightedIndex === 0 ?
            themeColors.successLight || "#66BB6A" :
            "transparent"
            border.width: vpx(1)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Item {
                    width: vpx(16)
                    height: vpx(16)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: launchIcon
                        anchors.fill: parent
                        source: "assets/icons/play.svg"
                        fillMode: Image.PreserveAspectFit
                        mipmap:  true

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            visible: parent.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: "â–¶"
                                color: mouseLaunch.containsMouse ? "white" : themeColors.text || "white"
                                font.pixelSize: vpx(12)
                            }
                        }
                    }

                    ColorOverlay {
                        anchors.fill: launchIcon
                        source: launchIcon
                        color: mouseLaunch.containsMouse ? "white" : themeColors.text || "white"
                    }
                }

                Text {
                    text: "Launch Game"
                    color: mouseLaunch.containsMouse ? "white" : themeColors.text || "white"
                    font.pixelSize: vpx(12)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseLaunch
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    gameMenu.launchGame();
                }
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        Rectangle {
            id: showDetailsBtn
            width: parent.width
            height: vpx(35)
            visible: !isCollectionContext
            color: mouseShowDetails.containsMouse || highlightedIndex === 1 || showDetails ?
            themeColors.primary || "#3a6ea5" :
            "transparent"
            radius: vpx(5)
            border.color: (mouseShowDetails.containsMouse || highlightedIndex === 1 || showDetails) ?
            themeColors.primaryHover || "#5a8ec5" :
            "transparent"
            border.width: vpx(1)

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Item {
                    width: vpx(16)
                    height: vpx(16)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: detailsIcon
                        anchors.fill: parent
                        source: "assets/icons/info.svg"
                        fillMode: Image.PreserveAspectFit
                        mipmap: true

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            visible: parent.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: showDetails ? "ⓘ" : "ⓘ"
                                color: (mouseShowDetails.containsMouse || highlightedIndex === 1 || showDetails) ? "white" : themeColors.text || "white"
                                font.pixelSize: vpx(12)
                            }
                        }
                    }

                    ColorOverlay {
                        anchors.fill: detailsIcon
                        source: detailsIcon
                        color: (mouseShowDetails.containsMouse || highlightedIndex === 1 || showDetails) ? "white" : themeColors.text || "white"
                    }
                }

                Text {
                    text: showDetails ? "Hide Details" : "Show Details"
                    color: (mouseShowDetails.containsMouse || highlightedIndex === 1 || showDetails) ? "white" : themeColors.text || "white"
                    font.pixelSize: vpx(12)
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseShowDetails
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (showDetails) {
                        gameMenu.showDetails = false;
                    } else {
                        gameMenu.showGameDetails();
                    }
                }
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        Column {
            width: parent.width
            spacing: vpx(4)
            visible: customCollections.length > 0 && !isCollectionContext

            Text {
                text: {
                    if (selectedCollectionId !== -1 && selectedSystemCollection === null) {
                        return "Collections:";
                    } else {
                        return "Add to Collection:";
                    }
                }
                color: themeColors.textSecondary || "#AAA"
                font.pixelSize: vpx(10)
                font.bold: true
                anchors.left: parent.left
                anchors.leftMargin: vpx(5)
            }

            Rectangle {
                width: parent.width
                height: Math.min(customCollections.length * vpx(30), vpx(150))
                color: "transparent"

                ListView {
                    id: collectionsListView
                    anchors.fill: parent
                    model: customCollections
                    clip: true
                    spacing: vpx(3)
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        width: parent.width - vpx(15)
                        height: vpx(28)
                        color: collectionMouse.containsMouse || isHighlighted ?
                        themeColors.primary || "#3a6ea5" :
                        "transparent"
                        radius: vpx(4)
                        anchors.margins: vpx(10)

                        property bool isCurrentCollection: selectedCollectionId === modelData.id
                        property bool hasGame: Utils.isGameInCollection(modelData.id, gameMenu.gameTitle)
                        property bool isHighlighted: {
                            if (isCollectionContext) return false;
                            var baseIndex = 2;
                            var listIndex = baseIndex + index;
                            return highlightedIndex === listIndex;
                        }

                        anchors.horizontalCenter: parent.horizontalCenter

                        Row {
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: vpx(8)
                            spacing: vpx(6)
                            width: parent.width - vpx(16)

                            Rectangle {
                                width: vpx(16)
                                height: vpx(16)
                                radius: vpx(8)
                                color: {
                                    if (hasGame) return themeColors.success || "#4CAF50";
                                    if (isCurrentCollection) return themeColors.primary || "#3a6ea5";
                                    return "transparent";
                                }
                                border.color: themeColors.inputBorder || "#555"
                                border.width: vpx(1)
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    text: {
                                        if (hasGame) return "✓";
                                        if (isCurrentCollection) return "+";
                                        return "+";
                                    }
                                    color: {
                                        if (isHighlighted || collectionMouse.containsMouse) return "white";
                                        if (hasGame) return "white";
                                        if (isCurrentCollection) return "white";
                                        return themeColors.text || "white";
                                    }
                                    font.pixelSize: vpx(10)
                                    font.bold: true
                                }
                            }

                            Column {
                                width: parent.width - vpx(22)
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: vpx(0)

                                Text {
                                    width: parent.width
                                    text: modelData.name
                                    color: {
                                        if (isHighlighted || collectionMouse.containsMouse) return "white";
                                        if (hasGame) return themeColors.success || "#4CAF50";
                                        if (isCurrentCollection) return themeColors.primary || "#3a6ea5";
                                        return themeColors.text || "white";
                                    }
                                    font.pixelSize: vpx(11)
                                    font.bold: hasGame || isCurrentCollection
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: modelData.games.length + " games"
                                    color: isHighlighted || collectionMouse.containsMouse ? "white" : themeColors.text || "#888"
                                    font.pixelSize: vpx(8)
                                }
                            }
                        }

                        MouseArea {
                            id: collectionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: {
                                if (hasGame && !isCurrentCollection) return Qt.ForbiddenCursor;
                                if (hasGame && isCurrentCollection) return Qt.ForbiddenCursor;
                                return Qt.PointingHandCursor;
                            }

                            enabled: !hasGame

                            onClicked: {
                                if (!hasGame) {
                                    var success = Utils.addGameToCollection(
                                        modelData.id,
                                        currentGame
                                    );
                                    if (success) {
                                        gameMenu.gameAddedToCollection(modelData.id);
                                    }
                                }
                            }
                            onEntered: if (enabled) parent.scale = 1.02
                            onExited: parent.scale = 1.0
                        }

                        Behavior on scale {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: vpx(3)
                    color: themeColors.inputBorder || "#555"
                    radius: vpx(1)
                    visible: collectionsListView.contentHeight > collectionsListView.height
                    opacity: 0.5
                }
            }

            Text {
                width: parent.width
                height: vpx(30)
                text: "Create a collection first"
                color: themeColors.textTertiary || "#888"
                font.pixelSize: vpx(11)
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: customCollections.length === 0
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
            visible: (!isCollectionContext && customCollections.length > 0) ||
            (!isCollectionContext && selectedCollectionId !== -1 && selectedSystemCollection === null)
        }

        Rectangle {
            id: removeFromCollectionBtn
            width: parent.width
            height: vpx(35)
            visible: !isCollectionContext &&
            selectedCollectionId !== -1 &&
            selectedSystemCollection === null &&
            isInCurrentCollection
            color: mouseRemoveFromCollection.containsMouse || isRemoveHighlighted ?
            themeColors.error || "#f44336" :
            "transparent"
            radius: vpx(5)
            border.color: mouseRemoveFromCollection.containsMouse || isRemoveHighlighted ?
            themeColors.errorLight || "#ef5350" :
            themeColors.error || "#f44336"
            border.width: vpx(1)

            property bool isRemoveHighlighted: {
                var idx = 2;
                if (!isCollectionContext && customCollections.length > 0) {
                    idx += customCollections.length;
                }
                return highlightedIndex === idx;
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Text {
                     text: "−"
                    color: mouseRemoveFromCollection.containsMouse || removeFromCollectionBtn.isRemoveHighlighted ?
                    "white" : themeColors.error || "#f44336"
                    font.pixelSize: vpx(16)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Remove from Collection"
                    color: mouseRemoveFromCollection.containsMouse || removeFromCollectionBtn.isRemoveHighlighted ?
                    "white" : themeColors.error || "#f44336"
                    font.pixelSize: vpx(12)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseRemoveFromCollection
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    var success = Utils.removeGameFromCollection(
                        selectedCollectionId,
                        currentGame.title
                    );
                    if (success) {
                        gameMenu.gameRemovedFromCollection();
                        gameMenu.closeMenu();
                    }
                }
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
            visible: isCollectionContext ||
            (!isCollectionContext && selectedCollectionId !== -1 && selectedSystemCollection === null && isInCurrentCollection)
        }

        Rectangle {
            id: deleteCollectionBtn
            width: parent.width
            height: vpx(35)
            visible: isCollectionContext
            color: mouseDeleteCollection.containsMouse || isDeleteHighlighted ?
            themeColors.error || "#f44336" :
            "transparent"
            radius: vpx(5)
            border.color: mouseDeleteCollection.containsMouse || isDeleteHighlighted ?
            themeColors.errorLight || "#ef5350" :
            themeColors.error || "#f44336"
            border.width: vpx(1)

            property bool isDeleteHighlighted: {
                if (isCollectionContext) {
                    return highlightedIndex === 0;
                }
                return false;
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Item {
                    width: vpx(14)
                    height: vpx(14)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: deleteCollectionIcon
                        anchors.fill: parent
                        source: "assets/icons/trash.svg"
                        fillMode: Image.PreserveAspectFit

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            visible: parent.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: "🗑"
                                color: mouseDeleteCollection.containsMouse || deleteCollectionBtn.isDeleteHighlighted ?
                                "white" : themeColors.error || "#f44336"
                                font.pixelSize: vpx(12)
                            }
                        }
                    }

                    ColorOverlay {
                        anchors.fill: deleteCollectionIcon
                        source: deleteCollectionIcon
                        color: mouseDeleteCollection.containsMouse || deleteCollectionBtn.isDeleteHighlighted ?
                        "white" : themeColors.error || "#f44336"
                    }
                }

                Text {
                    text: "Delete Collection"
                    color: mouseDeleteCollection.containsMouse || deleteCollectionBtn.isDeleteHighlighted ?
                    "white" : themeColors.error || "#f44336"
                    font.pixelSize: vpx(12)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseDeleteCollection
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    gameMenu.deleteCollection(contextCollectionId, contextCollectionName);
                    gameMenu.closeMenu();
                }
                onEntered: parent.scale = 1.02
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }

        Rectangle {
            height: vpx(1)
            width: parent.width
            color: themeColors.separator || "#555"
            radius: vpx(1)
            visible: isCollectionContext
        }

        Rectangle {
            id: closeBtn
            width: parent.width
            height: vpx(35)
            color: mouseClose.containsMouse || isCloseHighlighted ?
            themeColors.error || "#f44336" :
            "transparent"
            radius: vpx(5)
            border.color: mouseClose.containsMouse || isCloseHighlighted ?
            themeColors.errorLight || "#ef5350" :
            themeColors.error || "#f44336"
            border.width: vpx(1)

            property bool isCloseHighlighted: {
                return highlightedIndex === menuItemCount - 1;
            }

            Row {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: vpx(8)
                spacing: vpx(8)

                Item {
                    width: vpx(14)
                    height: vpx(14)
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: closeIcon
                        anchors.fill: parent
                        source: "assets/icons/close.svg"
                        fillMode: Image.PreserveAspectFit

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            visible: parent.status !== Image.Ready

                            Text {
                                anchors.centerIn: parent
                                text: "âœ•"
                                color: mouseClose.containsMouse || closeBtn.isCloseHighlighted ?
                                "white" : themeColors.error || "#f44336"
                                font.pixelSize: vpx(12)
                                font.bold: true
                            }
                        }
                    }

                    ColorOverlay {
                        anchors.fill: closeIcon
                        source: closeIcon
                        color: mouseClose.containsMouse || closeBtn.isCloseHighlighted ?
                        "white" : themeColors.error || "#f44336"
                    }
                }

                Text {
                    text: "Close"
                    color: mouseClose.containsMouse || closeBtn.isCloseHighlighted ?
                    "white" : themeColors.error || "#f44336"
                    font.pixelSize: vpx(12)
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mouseClose
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: gameMenu.closeMenu()
                onEntered: {
                    parent.scale = 1.02;
                    for (var i = 0; i < parent.children.length; i++) {
                        var row = parent.children[i];
                        if (row.objectName === "row" || row instanceof Row) {
                            for (var j = 0; j < row.children.length; j++) {
                                var textItem = row.children[j];
                                if (textItem instanceof Text) {
                                    textItem.color = "white";
                                }
                            }
                        }
                    }
                }
                onExited: {
                    parent.scale = 1.0;
                    for (var i = 0; i < parent.children.length; i++) {
                        var row = parent.children[i];
                        if (row.objectName === "row" || row instanceof Row) {
                            for (var j = 0; j < row.children.length; j++) {
                                var textItem = row.children[j];
                                if (textItem instanceof Text) {
                                    textItem.color = themeColors.error || "#f44336";
                                }
                            }
                        }
                    }
                }
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }

    Component {
        id: detailsLoaderComponent

        Loader {
            id: detailsLoader
            active: false
            width: vpx(350)
            height: vpx(580)
            z: 21

            sourceComponent: showDetails ? detailsComponent : null

            onLoaded: {
                if (item) {
                    item.gameData = currentGame;
                    gameMenu.positionDetailsPanel();
                }
            }

            onActiveChanged: {
                if (!active && item) {
                    item.destroy();
                }
            }
        }
    }

    Component {
        id: detailsComponent

        Rectangle {
            property var gameData: null

            function formatLastPlayed(lastPlayedStr) {
                if (!lastPlayedStr || lastPlayedStr === "Never") return "Never";

                var date = new Date(lastPlayedStr);
                if (isNaN(date.getTime())) return "Never";

                var day = date.getDate();
                var month = date.getMonth() + 1;
                var year = date.getFullYear().toString().slice(-2);

                var hours = date.getHours();
                var minutes = date.getMinutes();
                var ampm = hours >= 12 ? 'p.m.' : 'a.m.';
                hours = hours % 12;
                hours = hours ? hours : 12;
                minutes = minutes < 10 ? '0' + minutes : minutes;

                return day + "/" + month + "/" + year + " | " + hours + ":" + minutes + " " + ampm;
            }

            function formatReleaseDate(gameData) {
                if (!gameData || !gameData.release) return "Unknown";

                var date = gameData.release;
                if (!date || !date.valueOf || isNaN(date.valueOf())) return "Unknown";

                var day = date.getDate();
                var month = date.getMonth() + 1;
                var year = date.getFullYear();

                return day + "/" + month + "/" + year;
            }

            function formatRating(ratingValue) {
                if (ratingValue === undefined || ratingValue === null) return "N/A";

                var numericRating = parseFloat(ratingValue);
                if (isNaN(numericRating)) return "N/A";

                var percentage = Math.round(numericRating * 100);
                return percentage + "%";
            }

            function getFirstGenre(gameData) {
                if (!gameData || !gameData.genre) return "Unknown";
                var cleanedGenres = Utils.cleanAndSplitGenres(gameData.genre);
                return cleanedGenres.length > 0 ? cleanedGenres[0] : "Unknown";
            }

            width: vpx(350)
            height: {
                var baseHeight = vpx(400);
                if (gameData && gameData.description) {
                    baseHeight += vpx(180);
                }

                return Math.min(baseHeight, parent ? parent.height * 0.85 : baseHeight);
            }
            color: themeColors.panel || "#1a1a1a"
            border.color: themeColors.primary || "#3a6ea5"
            border.width: vpx(3)
            radius: vpx(12)
            z: 21
            clip: true

            RadialGradientOverlay {
                anchors.fill: parent
                isDarkTheme: gameMenu.isDarkTheme
                opacityMultiplier: 0.5
                radius: parent.radius
                visible: gameMenu.isDarkTheme
            }

            Column {
                anchors.fill: parent
                anchors.margins: vpx(15)
                spacing: vpx(12)

                Text {
                    width: parent.width
                    text: gameData ? gameData.title : ""
                    color: themeColors.text || "white"
                    font.bold: true
                    font.pixelSize: vpx(18)
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                }

                Rectangle {
                    width: parent.width
                    height: vpx(1)
                    color: themeColors.separator || "#555"
                    radius: vpx(1)
                }

                Grid {
                    width: parent.width
                    columns: 2
                    columnSpacing: vpx(15)
                    rowSpacing: vpx(8)

                    Text {
                        width: parent.width * 0.4
                        text: "Publisher:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        width: parent.width * 0.6
                        text: gameData ? (gameData.publisher || "N/A") : "N/A"
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                        wrapMode: Text.Wrap
                    }

                    Text {
                        text: "Developer:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: gameData ? (gameData.developer || "N/A") : "N/A"
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                        wrapMode: Text.Wrap
                    }

                    Text {
                        text: "Release Date:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: formatReleaseDate(gameData)
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                    }

                    Text {
                        text: "Genre:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: getFirstGenre(gameData)
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                        wrapMode: Text.Wrap
                    }

                    Text {
                        text: "Players:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: gameData ? (gameData.players || "N/A") : "N/A"
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                    }

                    Text {
                        text: "Rating:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: formatRating(gameData ? gameData.rating : null)
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                    }

                    Text {
                        text: "Play Count:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: gameData ? (gameData.playCount || "0") : "0"
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                    }

                    Text {
                        text: "Play Time:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: gameData && gameData.playTime ?
                        Math.floor(gameData.playTime / 3600) + "h " +
                        Math.floor((gameData.playTime % 3600) / 60) + "m" :
                        "0h 0m"
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                    }

                    Text {
                        text: "Last Played:"
                        color: themeColors.textSecondary || "#AAA"
                        font.pixelSize: vpx(12)
                        font.bold: true
                    }

                    Text {
                        text: formatLastPlayed(gameData ? gameData.lastPlayed : null)
                        color: themeColors.text || "white"
                        font.pixelSize: vpx(12)
                        wrapMode: Text.Wrap
                    }
                }

                Rectangle {
                    width: parent.width
                    height: vpx(1)
                    color: themeColors.separator || "#555"
                    radius: vpx(1)
                    visible: gameData && gameData.description
                }

                Column {
                    width: parent.width
                    spacing: vpx(8)
                    visible: gameData && gameData.description

                    Text {
                        text: "DESCRIPTION"
                        color: themeColors.primary || "#3a6ea5"
                        font.pixelSize: vpx(14)
                        font.bold: true
                    }

                    Item {
                        id: scrollContainer
                        width: parent.width
                        height: vpx(150)
                        clip: true

                        PegasusUtils.AutoScroll {
                            id: autoscroll
                            anchors.fill: parent
                            pixelsPerSecond: 15
                            scrollWaitDuration: 3000

                            Item {
                                width: autoscroll.width
                                height: descripText.height

                                Text {
                                    id: descripText
                                    width: parent.width
                                    text: gameData ? gameData.description : ""
                                    wrapMode: Text.WordWrap
                                    lineHeight: 1.4
                                    font.pixelSize: vpx(12)
                                    color: themeColors.text || "white"
                                }
                            }
                        }
                    }
                }

                Item {
                    width: parent.width
                    height: vpx(20)
                    visible: !gameData || !gameData.description

                    Text {
                        anchors.centerIn: parent
                        text: "No description available"
                        color: themeColors.textTertiary || "#707070"
                        font.pixelSize: vpx(12)
                        font.italic: true
                    }
                }
            }
        }
    }
}
