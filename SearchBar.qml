import QtQuick 2.15
import QtGraphicalEffects 1.12

Rectangle {
    id: searchBar
    color: colors.rightpanel

    property string searchText: ""
    property var searchColors: ({})

    signal searchChanged(string text)

    Row {
        anchors.fill: parent
        anchors.margins: vpx(12)
        spacing: vpx(10)

        Item {
            width: vpx(24)
            height: vpx(24)
            anchors.verticalCenter: parent.verticalCenter

            Image {
                id: searchIcon
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
                        font.pixelSize: vpx(20)
                    }
                }
            }

            ColorOverlay {
                anchors.fill: searchIcon
                source: searchIcon
                color: searchColors.text
            }
        }

        Rectangle {
            width: parent.width - vpx(80)
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

            Item {
                width: vpx(20)
                height: vpx(20)
                anchors.centerIn: parent

                Image {
                    id: clearIcon
                    anchors.fill: parent
                    source: "assets/icons/close.svg"
                    fillMode: Image.PreserveAspectFit

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        visible: parent.status !== Image.Ready

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: "white"
                            font.pixelSize: vpx(16)
                            font.bold: true
                        }
                    }
                }

                ColorOverlay {
                    anchors.fill: clearIcon
                    source: clearIcon
                    color: "white"
                }
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

    function forceActiveFocus() {
        searchInput.forceActiveFocus();
    }
}
