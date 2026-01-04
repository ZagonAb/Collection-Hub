import QtQuick 2.0

Rectangle {
    id: searchBar
    color: "#2c2c2c"
    border.color: "#444"
    border.width: vpx(2)
    radius: vpx(8)

    property string searchText: ""
    signal searchChanged(string text)

    Row {
        anchors.fill: parent
        anchors.margins: vpx(12)
        spacing: vpx(10)

        Text {
            text: "🔍"
            font.pixelSize: vpx(24)
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: parent.width - vpx(100)
            height: parent.height
            color: "#1a1a1a"
            radius: vpx(6)
            border.color: searchInput.activeFocus ? "#3a6ea5" : "#555"
            border.width: vpx(2)

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: vpx(12)
                anchors.rightMargin: vpx(12)
                color: "white"
                font.pixelSize: vpx(16)
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                clip: true

                Text {
                    anchors.fill: parent
                    text: "Search and press Enter..."
                    color: "#888"
                    font.pixelSize: vpx(16)
                    verticalAlignment: Text.AlignVCenter
                    visible: parent.text === ""
                }

                Keys.onReturnPressed: {
                    searchBar.searchText = text.trim();
                    searchBar.searchChanged(text.trim());
                }

                onTextChanged: {
                    if (text.trim() === "" && searchBar.searchText !== "") {
                        searchBar.searchText = "";
                        searchBar.searchChanged("");
                    }
                }

                Keys.onEscapePressed: {
                    text = "";
                    searchBar.searchText = "";
                    searchBar.searchChanged("");
                    focus = false;
                }
            }
        }

        Rectangle {
            width: vpx(46)
            height: vpx(46)
            color: clearMouseArea.containsMouse ? "#f44336" : "#444"
            radius: vpx(6)
            visible: searchInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            border.color: clearMouseArea.containsMouse ? "#ef5350" : "#666"
            border.width: vpx(2)

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "white"
                font.pixelSize: vpx(20)
                font.bold: true
            }

            MouseArea {
                id: clearMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    searchInput.text = "";
                    searchBar.searchText = "";
                    searchBar.searchChanged("");
                    searchInput.focus = false;
                }

                onEntered: parent.scale = 1.05
                onExited: parent.scale = 1.0
            }

            Behavior on scale {
                NumberAnimation { duration: 150 }
            }
        }
    }

    function clear() {
        searchInput.text = "";
        searchText = "";
        searchChanged("");
    }

    function focusSearch() {
        searchInput.forceActiveFocus();
    }
}
