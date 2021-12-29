import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

Screen {
	id: wasteConfigurationScreen

	property url calendarIndexUrl : "https://raw.githubusercontent.com/ToonSoftwareCollective/calendar_public_calendars/main/public_calendars.json"
	property variant calendarsNameArray: []
	property variant calendarsLinkArray: []
	property variant calendarsActiveArray: []
	property variant availableCalendars: {}
	property string colorStr

	screenTitle: "Kalender configuratie"

	onShown: {
		addCustomTopRightButton("Opslaan");
		enableNotificationsToggle.isSwitchedOn = (app.showNotificationSetting == "Yes");
		enableColorsToggle.isSwitchedOn = (app.showColorsSetting == "Yes");
		enableAnimationToggle.isSwitchedOn = (app.showAnimationSetting == "Yes");
		enableDimExtendedToggle.isSwitchedOn = (app.showDimTileExtended == "Yes");
		refreshIntervalLabel.inputText = app.refreshIntervalInMinutes;
		getPublicCalendars()
	}

	function getPublicCalendars(){

		//get list of public calendars

		var j = app.calendarSettingsJson['Calendar_URL'].length;
		var friendlyName  = "" ;
		var http = new XMLHttpRequest();
		var newColor = 0;
		http.onreadystatechange=function() {
			if (http.readyState === 4){
				if (http.status === 200 || http.status === 300  || http.status === 302) {
					calendarsNameArray= [];
					calendarsLinkArray= [];
					availableCalendars = JSON.parse(http.responseText)
					var tmpArray = availableCalendars.public_calendars
					urlModel.clear();
					
					for (var i = 0; i < app.calendarSettingsJson['Calendar_URL'].length; i++) {
						colorStr = i.toString();
						if (i > 9) colorStr = "9";
						friendlyName  = "-";
						for (var k in tmpArray) {
							 if (tmpArray[k].link == app.calendarSettingsJson['Calendar_URL'][i]) {
								 friendlyName = tmpArray[k].friendlyName;
							}
						}
						urlModel.append({urlName: app.calendarSettingsJson['Calendar_URL'][i], urlFriendlyName: friendlyName, urlColor: app.colorCodes(colorStr), urlExisting: 0});
					}

					j = parseInt(colorStr);

					for (var i in tmpArray){
						if (app.calendarSettingsJson['Calendar_URL'].indexOf(tmpArray[i].link) < 0) {
							j = j + 1;
							colorStr = j.toString();
							if (j > 9) colorStr = "9";
							urlModel.append({urlName: tmpArray[i].link, urlFriendlyName: tmpArray[i].friendlyName, urlColor: app.colorCodes(colorStr), urlExisting: -1});
						}
					}
				}
			}
		}
		http.open("GET",calendarIndexUrl, true)
		http.send()
	}

	onCustomButtonClicked: {
		hide();
		app.saveSettings();
	}

	function saveRefreshIntervalLabel(text) {

		if (text) {
			app.refreshIntervalInMinutes = parseInt(text);
			refreshIntervalLabel.inputText = app.refreshIntervalInMinutes;
		}
	}


	function validateRefreshIntervalLabel(text, isFinalString) {
		if (isFinalString) {
			if (parseInt(text) > 9)
				return null;
			else
				return {title: "Ongeldige invoer", content: "aantal minuten moet minimaal 10 zijn"};
		}
		return null;
	}


	Text {
		id: enableNotificationsLabel
		width: isNxt ? 400 : 320
		height: isNxt ? 44 : 35
		text: "Herinneringen weergeven als notificaties?"
		anchors {
			left: parent.left
			leftMargin : 10
			top: parent.top
			topMargin : 30
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 15		}
	}

	OnOffToggle {
		id: enableNotificationsToggle
		height: isNxt ? 45 : 36
		anchors.left: enableNotificationsLabel.right
		anchors.leftMargin: 10
		anchors.top: enableNotificationsLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.showNotificationSetting = "Yes"
			} else {
				app.showNotificationSetting = "No"
			}
		}
	}

	Text {
		id: enableColorsLabel
		width: isNxt ? 400 : 320
		height: isNxt ? 44 : 35
		text: "Kalenderkleuren weergeven bij afspraken?"
		anchors {
			left: enableNotificationsToggle.right
			leftMargin: isNxt ? 15 : 12
			top: enableNotificationsLabel.top
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 15		}
	}

	OnOffToggle {
		id: enableColorsToggle
		height: isNxt ? 45 : 36
		anchors.left: enableColorsLabel.right
		anchors.leftMargin: 10
		anchors.top: enableColorsLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.showColorsSetting = "Yes"
			} else {
				app.showColorsSetting = "No"
			}
		}
	}

	Text {
		id: enableDimExtendedLabel
		width: isNxt ? 400 : 320
		height: isNxt ? 44 : 35
		text: "Drie regels op tegel in dim stand?"
		anchors {
			left: enableNotificationsLabel.left
			top: enableNotificationsLabel.bottom
			topMargin : 10
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 15		}
	}

	OnOffToggle {
		id: enableDimExtendedToggle
		height: isNxt ? 45 : 36
		anchors.left: enableDimExtendedLabel.right
		anchors.leftMargin: 10
		anchors.top: enableDimExtendedLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.showDimTileExtended = "Yes"
			} else {
				app.showDimTileExtended = "No"
			}
		}
	}

	Text {
		id: enableAnimationLabel
		width: isNxt ? 400 : 320
		height: isNxt ? 44 : 35
		text: "Ballonnen tonen (jaarlijks)?"
		anchors {
			left: enableDimExtendedToggle.right
			top: enableDimExtendedLabel.top
			leftMargin: isNxt ? 15 : 12
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 15		}
	}

	OnOffToggle {
		id: enableAnimationToggle
		height: isNxt ? 45 : 36
		anchors.left: enableAnimationLabel.right
		anchors.leftMargin: 10
		anchors.top: enableAnimationLabel.top
		leftIsSwitchedOn: false
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.showAnimationSetting = "Yes"
			} else {
				app.showAnimationSetting = "No"
				if (app.animationStarted) {  // switch off animation if we started it before
   					animationscreen.animationRunning= false;
					app.animationStarted = false;
				}
			}
		}
	}

	EditTextLabel4421 {
		id: refreshIntervalLabel
		width: isNxt ? 575 : 460
		height: isNxt ? 44 : 35
		leftTextAvailableWidth: isNxt ? 500 : 400
		leftText: "Ververs interval in minuten:"

		anchors {
			left: enableDimExtendedLabel.left
			top: enableDimExtendedLabel.bottom
			topMargin : 10
		}

		onClicked: {
			qnumKeyboard.open("Voer het aantal minuten in:", refreshIntervalLabel.inputText, app.refreshIntervalLabel, 1 , saveRefreshIntervalLabel, validateRefreshIntervalLabel);
			qnumKeyboard.maxTextLength = 2;
			qnumKeyboard.state = "num_integer_clear_backspace";
		}
	}

	Text {
		id: urlListLabel
		text: "Bechikbare kalenders:"
		anchors {
			left: refreshIntervalLabel.left
			top: refreshIntervalLabel.bottom
			topMargin : 30
		}
		font {
			family: qfont.bold.name
			pixelSize: isNxt ? 20 : 15		}
	}

	Rectangle {
		id: gridBack
		height: isNxt ? 265 : 210
		width: isNxt ? 1000 : 780
		color: "#FFFFFF"
		anchors {
			top: urlListLabel.bottom
			topMargin: 20
			left: urlListLabel.left
		}
       		visible: true
	}

	GridView {
		id: urlListGridView

		model: urlModel
		delegate: CalendarConfigurationScreenDelegate {}

		cellWidth: isNxt ? 500 : 400
		cellHeight: isNxt ? 50 : 40

		interactive: false
		flow: GridView.TopToBottom

		anchors {
			fill: gridBack
			topMargin: 10
			leftMargin: 10
		}
	}

	ListModel {
		id: urlModel
	}
}
