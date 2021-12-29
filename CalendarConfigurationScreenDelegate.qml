import QtQuick 2.1
import BasicUIControls 1.0;
import qb.components 1.0

Rectangle
{
	width: parent.width
	color: colors.canvas

	Rectangle {
		id: colorBar
		height: isNxt ? 40 : 20
		width: isNxt ? 8 : 6
		color: urlColor
 	}

	Text {
		id: filterText
		text: (urlFriendlyName !== "-") ? urlFriendlyName : "handmatig geconfigureerd - " + urlName.substring(0,25) + "..."
		width: isNxt ? 350 : 280
		anchors {
			top: colorBar.top
			topMargin: isNxt ? 5 : 4
			left: colorBar.right
			leftMargin: 10
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 15 : 12
		}

	}

	IconButton {
		id: deleteButton
		anchors.top: filterText.top
		anchors.left: filterText.right
		anchors.leftMargin: 10
		anchors.topMargin: -5
		leftClickMargin: 3
		bottomClickMargin: 5
		iconSource: "qrc:/tsc/minus.png"
		visible: !urlExisting
		onClicked: {
			var index = app.calendarSettingsJson['Calendar_URL'].indexOf(urlName);
			if (index !== -1) {
			  app.calendarSettingsJson['Calendar_URL'].splice(index, 1);
			  app.saveSettings();
			  getPublicCalendars();
			}
		}
	}

	IconButton {
		id: addButton
		anchors.top: deleteButton.top
		anchors.left: deleteButton.right
		anchors.leftMargin: 10
		anchors.topMargin: -5
		leftClickMargin: 3
		bottomClickMargin: 5
		iconSource: "qrc:/tsc/plus.png"
		visible: urlExisting
		onClicked: {
			app.calendarSettingsJson['Calendar_URL'].push(urlName)
		  	app.saveSettings();
    			getPublicCalendars();
		}
	}
}


