import QtQuick 2.1
import BasicUIControls 1.0;

Rectangle
{
	width: parent.width
	color: colors.canvas

	function formatTitle() {
		if (appointmentTitle.length > 38) {
			return appointmentTitle.substring(0,38)
		} else {
			return appointmentTitle
		}
	}

	Rectangle {
		id: colorBar
		height: isNxt ? 53 : 42
		width: isNxt ? 8 : 6
		anchors {
			top: parent.top
			topMargin: 3
		}
		color: appointmentColor
       		visible: (app.showColorsSetting == "Yes")
	}

	Text {
		id: labelDate
		text: appointmentDate
		anchors {
			top: colorBar.top
			left: colorBar.right
			leftMargin: 10
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 16
		}

	}

	Text {
		id: labelTitle
		text: formatTitle()
		anchors {
			top: colorBar.top
			left: labelDate.right
			leftMargin: 10
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 16
		}

	}

	Text {
		id: labelTime
		text: appointmentTime
		anchors {
			top: labelTitle.bottom
			left: labelTitle.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 16
		}

	}

	Rectangle {
		id: gridLine
		height: 2
		width: parent.width
		color: colors.canvas
		anchors {
			top: labelTime.bottom
			topMargin: 2
			left: parent.left
		}
	}

}


