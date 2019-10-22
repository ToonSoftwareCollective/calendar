import QtQuick 1.1
import qb.components 1.0

Screen {
	id: calendarListDatesScreen
	screenTitle: "Kalender"

	onShown: {
		addCustomTopRightButton("Instellingen");

			// populate gridview first page

			navigatePage(0);
	}

	function navigatePage(page) {

		var startItem = (page * 16) + 1;
		calendarModel.clear();					// clear datamodel
		var tmp = app.calendarDatesString.split("\n");		
		var tmpAppointmentTime	= "";
		var counter = 0;
		for (var i = startItem; i < tmp.length; i++) {

			if (tmp[i].length > 20) {
				if ((tmp[i].slice(11, 16) == "00:00") && (tmp[i].slice(30, 35) == "23:59")) { //all day event
					tmpAppointmentTime= " ";
				} else {
					tmpAppointmentTime= tmp[i].slice(11, 16) + " - " + tmp[i].slice(30, 35);
				}
				calendarModel.append({appointmentDate: tmp[i].slice(0, 10), appointmentTitle: tmp[i].slice(57,tmp[i].length-1), appointmentColor: app.colorCodes(tmp[i].slice(56,57)), appointmentTime: tmpAppointmentTime});
				counter = counter +1;
				if (counter == 16) i = tmp.length;		//end loop, max 16 items per page
			}
		}
		widgetNavBar.pageCount = Math.ceil (tmp.length / 16);
		
	}

	onCustomButtonClicked: {
		if (app.calendarConfigurationScreen) {
			 app.calendarConfigurationScreen.show();
		}
	}

	hasBackButton : true


	Rectangle {
		id: gridBack
		height: isNxt ? 480 : 384
		width: isNxt ? 984 : 760
		anchors {
			top: parent.top
			topMargin: isNxt ? 45 : 36
			left: parent.left
			leftMargin: 20
		}
       		visible: true
	}

	GridView {
		id: calendarListView

		model: 	calendarModel
		delegate: CalendarListDatesScreenDelegate {}
		cellWidth: gridBack.width / 2
		cellHeight: isNxt ? 60 : 48

		interactive: false
		flow: GridView.TopToBottom

		anchors {
			fill: gridBack
		}
	}

	ListModel {
		id: calendarModel
	}

	StandardButton {
		id: btnRefreshCalendars
		width: isNxt ? 125 : 100
		text: "Verversen"
		anchors.right: gridBack.right
		anchors.bottom: gridBack.top
		anchors.bottomMargin: 5
		leftClickMargin: 3
		bottomClickMargin: 5
		onClicked: {
			hide();
			app.startOrRefresh();
		}
	}

	DottedSelector {
		id: widgetNavBar
		width: isNxt ? 625 : 500
		anchors {
			horizontalCenter: parent.horizontalCenter
			bottom: gridBack.top
		}
		maxPageCount: 14
		pageCount: 1
//		shadowBarButtons: true
		onNavigate: navigatePage(page)
	}

}
