import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: searchBar

    property string searchText: ""
    property var searchColors: ({})

    property bool isExpanded: false
    property int collapsedWidth: vpx(52)
    property int expandedWidth: vpx(450)

    signal searchChanged(string text)
    signal moveToSortMenu()

    width: isExpanded ? expandedWidth : collapsedWidth
    height: vpx(44)

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: searchColors.inputBg || "#0f0f0f"
        radius: vpx(10)
        border.color: searchInput.activeFocus ? (searchColors.primary || "#3a6ea5") : (searchColors.inputBorder || "#303030")
        border.width: vpx(2)
        opacity: isExpanded ? 1.0 : 0.0
        clip: true

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        TextInput {
            id: searchInput
            anchors {
                left: parent.left
                right: clearBtn.left
                top: parent.top
                bottom: parent.bottom
                leftMargin: vpx(46)
                rightMargin: vpx(6)
            }
            color: searchColors.text || "#ffffff"
            font.pixelSize: vpx(15)
            selectByMouse: true
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            enabled: isExpanded
            visible: isExpanded

            Text {
                anchors.fill: parent
                text: "Title, Publisher, Developer, Genre..."
                color: searchColors.textTertiary || "#707070"
                font.pixelSize: vpx(15)
                verticalAlignment: Text.AlignVCenter
                visible: parent.text === ""
            }

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Right) {
                    if (text.length === 0 || cursorPosition === text.length) {
                        searchBar.moveToSortMenu();
                        event.accepted = true;
                        return;
                    }
                }
                else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    searchBar.searchText = text.trim();
                    searchBar.searchChanged(text.trim());
                    event.accepted = true;
                }
                else if (event.key === Qt.Key_Escape) {
                    searchBar.collapse();
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            id: clearBtn
            width: vpx(28)
            height: vpx(28)
            anchors {
                right: parent.right
                rightMargin: vpx(52)
                verticalCenter: parent.verticalCenter
            }
            color: clearMouseArea.containsMouse ? (searchColors.error || "#f44336") : "transparent"
            radius: vpx(14)
            opacity: isExpanded && searchInput.text !== "" ? 1.0 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "white"
                font.pixelSize: vpx(14)
                font.bold: true
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchInput.text = ""
                    searchBar.searchText = ""
                    searchBar.searchChanged("")
                    searchInput.forceActiveFocus()
                }
            }
        }
    }

    Rectangle {
        id: toggleBtn
        width: vpx(44)
        height: vpx(44)
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        color: toggleMouseArea.containsMouse || isExpanded
        ? (searchColors.primary || "#3a6ea5")
        : "transparent"
        radius: vpx(10)
        /*border.color: isExpanded
        ? (searchColors.primary || "#3a6ea5")
        : (searchColors.inputBorder || "#303030")
        border.width: vpx(2)*/

        Behavior on color {
            ColorAnimation { duration: 180 }
        }

        scale: toggleMouseArea.containsMouse ? 1.08 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 130 }
        }

        Item {
            width: vpx(22)
            height: vpx(22)
            anchors.centerIn: parent

            Image {
                id: searchIconImg
                anchors.fill: parent
                source: "assets/icons/search.svg"
                fillMode: Image.PreserveAspectFit

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    visible: parent.status !== Image.Ready
                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: vpx(18)
                    }
                }
            }

            ColorOverlay {
                anchors.fill: searchIconImg
                source: searchIconImg
                color: colors.text
            }
        }

        MouseArea {
            id: toggleMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (isExpanded) {
                    searchBar.collapse()
                } else {
                    searchBar.expand()
                }
            }
        }
    }

    function expand() {
        isExpanded = true
        Qt.callLater(function() { searchInput.forceActiveFocus() })
    }

    function collapse() {
        searchInput.text = ""
        searchBar.searchText = ""
        searchBar.searchChanged("")
        isExpanded = false
        searchInput.focus = false
    }

    function clear() {
        searchInput.text = ""
        searchText = ""
        searchChanged("")
    }

    function focusSearch() { expand() }
    function forceActiveFocus() { expand() }
}
