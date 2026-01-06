// RadialGradientOverlay.qml
import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: root

    property bool isDarkTheme: true
    property real opacityMultiplier: 1.0
    property real radius: 0

    // Propiedades de color para diferentes intensidades
    property color lightStrong: "#40ffffff"
    property color lightMedium: "#20ffffff"
    property color lightWeak: "#10ffffff"
    property color darkStrong: "#30ffffff"
    property color darkMedium: "#15ffffff"
    property color darkWeak: "#08ffffff"

    // Elemento para la máscara (necesario para radius)
    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: root.radius
        visible: false
    }

    RadialGradient {
        anchors.fill: parent
        horizontalOffset: parent.width * 0.5
        verticalOffset: parent.height * 0.5
        gradient: Gradient {
            GradientStop {
                position: 0.0;
                color: root.isDarkTheme ?
                Qt.lighter(root.darkStrong, root.opacityMultiplier) :
                Qt.lighter(root.lightStrong, root.opacityMultiplier)
            }
            GradientStop {
                position: 0.5;
                color: root.isDarkTheme ?
                Qt.lighter(root.darkMedium, root.opacityMultiplier) :
                Qt.lighter(root.lightMedium, root.opacityMultiplier)
            }
            GradientStop {
                position: 1.0;
                color: "transparent"
            }
        }
        z: 0

        layer.enabled: root.radius > 0
        layer.effect: OpacityMask {
            maskSource: maskRect
        }
    }
}
