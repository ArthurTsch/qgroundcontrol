import QtQuick 2.11
import QtQuick.Layouts 1.11

import QGroundControl.ScreenTools 1.0
import QGroundControl.Controls 1.0
import QGroundControl.Palette 1.0
import QGroundControl 1.0
import QGroundControl.Specific 1.0


Item {
    id: _root
    width: contentColumn.width
    height: contentColumn.height

    property bool forceKeepingOpen: _pageReady && pageLoader.item.forceConfirmation && !_armed

    signal closeView()

    property bool _pageReady: pageLoader.status === Loader.Ready
    property int _currentIndex: 0
    property int _pagesCount: QGroundControl.corePlugin.startupPages.length
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property bool _armed: _activeVehicle && _activeVehicle.armed

    function doneOrJumpToNext() {
        if(_currentIndex < _pagesCount - 1)
            _currentIndex += 1
        else {
            _root.closeView()
            QGroundControl.firstTimeStart = false
        }
    }

    Column {
        id: contentColumn
        anchors.centerIn: parent
        spacing: ScreenTools.defaultFontPixelHeight * 1
        padding: spacing

        QGCLabel {
            text: qsTr("Welcome to " + QGroundControl.appName)
            color: qgcPal.text
            font.family: ScreenTools.demiboldFontFamily
            font.pointSize: ScreenTools.mediumFontPointSize
        }
        Rectangle {
            height: 1
            color: qgcPal.windowShade
            width: _pageReady ? pageLoader.item.width : 0
        }

        // Page content loader
        Loader {
            id: pageLoader
            source: QGroundControl.corePlugin.startupPages[_currentIndex]
        }

        Connections {
            target: _pageReady ? pageLoader.item : null
            onCloseView: doneOrJumpToNext()
        }

        QGCButton {
            property string _acknowledgeText: _pagesCount <= 1 ? qsTr("Next") : qsTr("Done")

            text: (_pageReady && pageLoader.item && pageLoader.item.doneText) ? pageLoader.item.doneText : _acknowledgeText
            onClicked: doneOrJumpToNext()
        }
    }
}
