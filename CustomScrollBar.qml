import QtQuick 2.15

Item {
    id: root

    property Item flickable: null
    property color thumbColor: "#5a8ec5"

    property alias listView: root.flickable
    property int columns: 1

    anchors.right:  parent ? parent.right  : undefined
    anchors.top:    parent ? parent.top    : undefined
    anchors.bottom: parent ? parent.bottom : undefined

    width: vpx(8)
    visible: {
        if (!flickable) return false;
        return flickable.contentHeight > flickable.height + 1;
    }

    readonly property real visibleRatio: {
        if (!flickable || flickable.contentHeight <= 0) return 1.0;
        return Math.min(1.0, flickable.height / flickable.contentHeight);
    }

    readonly property real thumbHeight: Math.max(vpx(20), visibleRatio * root.height)

    readonly property real trackRange: root.height - thumbHeight

    readonly property real scrollRatio: {
        if (!flickable || flickable.contentHeight <= flickable.height) return 0.0;
        return Math.max(0.0, Math.min(1.0,
            flickable.contentY / (flickable.contentHeight - flickable.height)
        ));
    }

    readonly property real thumbY: scrollRatio * trackRange
    property bool isHovered: false
    property bool isDragging: false

    z: 99

    Rectangle {
        id: track
        anchors.fill: parent
        color: "transparent"
        radius: width / 2
    }

    Rectangle {
        id: thumb
        width: (root.isDragging || root.isHovered) ? vpx(8) : vpx(3)
        height: root.thumbHeight
        x: (root.width - width) / 2
        y: root.thumbY

        color: root.isDragging ? Qt.lighter(root.thumbColor, 1.25) : root.thumbColor
        radius: width / 2
        opacity: root.isDragging ? 1.0 : (root.isHovered ? 0.9 : 0.75)

        Behavior on width   { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 150 } }
        Behavior on color   { ColorAnimation  { duration: 120 } }
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.isDragging ? Qt.ClosedHandCursor : Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton
        preventStealing: true

        property real dragStartMouseY: 0

        onEntered: root.isHovered = true
        onExited:  { if (!root.isDragging) root.isHovered = false; }

        onPressed: function(mouse) {
            if (!root.flickable) return;
            var thumbTop    = root.thumbY;
            var thumbBottom = thumbTop + root.thumbHeight;

            if (mouse.y >= thumbTop && mouse.y <= thumbBottom) {
                root.isDragging  = true;
                dragStartMouseY  = mouse.y - thumbTop;
            } else {
                _scrollToRatio(_mouseToRatio(mouse.y - root.thumbHeight / 2));
            }
        }

        onReleased: {
            root.isDragging = false;
            if (!containsMouse) root.isHovered = false;
        }

        onPositionChanged: function(mouse) {
            if (!root.isDragging || !root.flickable) return;
            _scrollToRatio(_mouseToRatio(mouse.y - dragStartMouseY));
        }

        function _mouseToRatio(thumbY) {
            var clamped = Math.max(0, Math.min(root.trackRange, thumbY));
            return root.trackRange > 0 ? clamped / root.trackRange : 0;
        }

        function _scrollToRatio(ratio) {
            if (!root.flickable) return;

            if (root.columns <= 1) {
                var maxY = root.flickable.contentHeight - root.flickable.height;
                root.flickable.contentY = ratio * maxY;
            } else {
                var totalItems = root.flickable.count;
                if (totalItems <= 0) return;
                var targetIndex = Math.round(ratio * (totalItems - 1));
                targetIndex = Math.max(0, Math.min(totalItems - 1, targetIndex));
                var rowStart = Math.floor(targetIndex / root.columns) * root.columns;
                root.flickable.currentIndex = rowStart;
                root.flickable.positionViewAtIndex(rowStart, GridView.Beginning);
            }
        }
    }
}
