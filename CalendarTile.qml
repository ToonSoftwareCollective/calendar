import QtQuick 2.1
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: !dimState
	}

	Rectangle {
		id: colorBar1
		height: isNxt ? 40 : 32
		width: isNxt ? 8 : 6
		color: app.calendarDate1Color
		anchors {
			top: calendardatenext.top
			topMargin: 5
			left: parent.left
			leftMargin: isNxt ? calendardatenext.left - 12 : calendardatenext.left - 10
		}
       		visible: !dimState && (app.showColorsSetting == "Yes")
	}

	Rectangle {
		id: colorBar2
		height: isNxt ? 40 : 32
		width: isNxt ? 8 : 6
		color: app.calendarDate2Color
		anchors {
			top: calendardatenext2.top
			topMargin: 5
			left: parent.left
			leftMargin: isNxt ? calendardatenext2.left - 12 : calendardatenext2.left - 10
		}
       		visible: !dimState && (app.showColorsSetting == "Yes")
	}

	Rectangle {
		id: colorBar3
		height: isNxt ? 40 : 32
		width: isNxt ? 8 : 6
		color: app.calendarDate3Color
		anchors {
			top: calendardatenext3.top
			topMargin: 5
			left: parent.left
			leftMargin: isNxt ? calendardatenext3.left - 12 : calendardatenext3.left - 10
		}
       		visible: !dimState && (app.showColorsSetting == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: !dimState || (app.showDimTileExtended == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState || (app.showDimTileExtended == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: !dimState || (app.showDimTileExtended == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState || (app.showDimTileExtended == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: !dimState || (app.showDimTileExtended == "Yes")
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
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: !dimState || (app.showDimTileExtended == "Yes")
	}

// DIM state fields

	 Text {
		id: calendardatenextDimText
 		text: app.calendarDateNext1LabelDim
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 62 : 50
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: dimState && (app.showDimTileExtended == "No")
	}

	Text {
		id: calendardatenextDimDate
		text: app.calendarDateNext1DateDim
		anchors {
			baseline: calendardatenextDimText.bottom
			baselineOffset: isNxt ? 50 : 40
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.waTileTextColor : colors.waTileTextColor
       		visible: dimState && (app.showDimTileExtended == "No")
	}

	Text {
		id: calendardatenexttypeDimTime
		text:  app.calendarDateNext1Time
		anchors {
			baseline: calendardatenextDimDate.bottom
			baselineOffset: isNxt ? 25 : 20
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 22 : 18
		}
		color: (typeof dimmableColors !== 'undefined') ? dimmableColors.clockTileColor : colors.clockTileColor
        	visible: dimState && (app.showDimTileExtended == "No")
	}

}
