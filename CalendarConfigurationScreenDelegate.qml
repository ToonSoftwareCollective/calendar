import QtQuick 1.1
import BasicUIControls 1.0;

Rectangle
{
	width: parent.width
	color: colors.canvas

	Rectangle {
		id: colorBar
		height: isNxt ? 25 : 20
		width: isNxt ? 8 : 6
		color: urlColor
 	}

	Text {
		id: filterText
		text: urlName
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
}


