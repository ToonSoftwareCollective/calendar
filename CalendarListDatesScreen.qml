import QtQuick 1.1
import qb.components 1.0

Screen {
	id: calendarListDatesScreen
	screenTitle: "Kalender"

	onShown: {
		addCustomTopRightButton("Instellingen");
	}

	onCustomButtonClicked: {
		if (app.calendarConfigurationScreen) {
			 app.calendarConfigurationScreen.show();
		}
	}

//	onCustomButtonClicked: {
//		app.startOrRefresh();
//		hide();
//	}

	hasBackButton : true

	Rectangle {
		id: backgroundRect
		height: isNxt ? 500 : 388
		width: isNxt ? 900 : 700
		anchors {
			baseline: parent.top
			baselineOffset: isNxt ? 13 : 10
			left: parent.left
			leftMargin: 50
		}
		color: colors.contrastBackground

	       Flickable {
	            id: flickArea
	             anchors.fill: parent
	             contentWidth: backgroundRect.width / 2;
			contentHeight: backgroundRect.height
	             flickableDirection: Flickable.VerticalFlick
	             clip: true

	            
		 TextEdit{
	                  id: forecastText
	                   wrapMode: TextEdit.Wrap
	                   width:backgroundRect.width
	                   readOnly:true
			  color: colors.taWarningBox

				font {
					family: qfont.bold.name
					pixelSize: isNxt ? 20 : 16
				}

	                   text:  app.calendarListDates
	            }
	      }
	}

	StandardButton {
		id: btnRefreshCalendars
		width: isNxt ? 125 : 100
		text: "Verversen"
		anchors.right: backgroundRect.right
		anchors.top: backgroundRect.top
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			app.startOrRefresh();
		}
	}

}
