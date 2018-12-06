import QtQuick 1.1
import qb.components 1.0


Tile {
	id: wastecollectionTile

	property bool dimState: screenStateController.dimmedColors

	onClicked: {
		if (app.calendarListDatesScreen)
			app.calendarListDatesScreen.show();
	}

	
	Text {
		id: tiletitle
		text: "Kalender"
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 30 : 24
			left: parent.left
			leftMargin: isNxt ? 80 : 64

		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 25 : 20
		}
		color: colors.waTileTextColor
       		visible: !dimState
	}

	Text {
		id: calendardatenext
		text: app.calendarDateNext1Label
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 62 : 50
			left: parent.left
			leftMargin: isNxt ? 10 : 8
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.waTileTextColor
       		visible: !dimState
	}

	Text {
		id: calendardatenexttype
		text:  app.calendarDateNext1Time
		anchors {
			baseline: calendardatenext.bottom
			baselineOffset: isNxt ? 13 : 10
			left: tiletitle.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: colors.clockTileColor
        	visible: !dimState
	}

	Text {
		id: calendardatenext2
		text: app.calendarDateNext2Label
		anchors {
			baseline: calendardatenexttype.bottom
			baselineOffset: isNxt ? 25 : 20
			left: calendardatenext.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.waTileTextColor
       	visible: !dimState
	}

	Text {
		id: calendardatenext2type
		text: app.calendarDateNext2Time
		anchors {
			baseline: calendardatenext2.bottom
			baselineOffset: isNxt ? 13 : 10
			left: tiletitle.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: colors.clockTileColor
        	visible: !dimState
	}

	Text {
		id: calendardatenext3
		text: app.calendarDateNext3Label
		anchors {
			baseline: calendardatenext2type.bottom
			baselineOffset: isNxt ? 25 : 20
			left: calendardatenext.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.waTileTextColor
       	visible: !dimState
	}

	Text {
		id: calendardatenext3type
		text: app.calendarDateNext3Time
		anchors {
			baseline: calendardatenext3.bottom
			baselineOffset: isNxt ? 13 : 10
			left: tiletitle.left
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 18 : 15
		}
		color: colors.clockTileColor
        	visible: !dimState
	}

// DIM state fields

	Text {
		id: calendardatenextDimDate
		text: app.calendarDateNext1DateDim
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 62 : 50
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.waTileTextColor
       		visible: dimState
	}

	 Text {
		id: calendardatenextDimText
 		text: app.calendarDateNext1LabelDim
		anchors {
			baseline: calendardatenextDimDate.bottom
			baselineOffset: isNxt ? 25 : 20
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.waTileTextColor
       		visible: dimState
	}

	Text {
		id: calendardatenexttypeDimTime
		text:  app.calendarDateNext1Time
		anchors {
			baseline: calendardatenextDimText.bottom
			baselineOffset: isNxt ? 25 : 20
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: colors.clockTileColor
        	visible: dimState
	}

}
