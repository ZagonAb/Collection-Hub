import QtQuick 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: searchBar
    color: searchColors.panel
    border.color: searchColors.panelBorder
    border.width: vpx(2)
    radius: vpx(8)

    property string searchText: ""
    property var searchColors: ({})

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
            color: searchColors.inputBg
            radius: vpx(6)
            border.color: searchInput.activeFocus ? searchColors.primary : searchColors.inputBorder
            border.width: vpx(2)

            TextInput {
                id: searchInput
                anchors.fill: parent
                anchors.leftMargin: vpx(12)
                anchors.rightMargin: vpx(12)
                color: searchColors.text
                font.pixelSize: vpx(16)
                selectByMouse: true
                verticalAlignment: TextInput.AlignVCenter
                clip: true

                Text {
                    anchors.fill: parent
                    text: "Search and press Enter..."
                    color: searchColors.textTertiary
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
            width: vpx(36)
            height: vpx(36)
            color: clearMouseArea.containsMouse ? searchColors.error : searchColors.panelBorder
            radius: vpx(6)
            visible: searchInput.text !== ""
            anchors.verticalCenter: parent.verticalCenter
            border.color: clearMouseArea.containsMouse ? searchColors.errorLight : searchColors.inputBorder
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
