import QtQuick 2.1
import qb.components 1.0
import BxtClient 1.0

Screen {
	id: wasteConfigurationScreen

	screenTitle: "Kalender configuratie"

	onShown: {
		addCustomTopRightButton("Opslaan");
		enableNotificationsToggle.isSwitchedOn = (app.showNotificationSetting == "Yes");
		enableColorsToggle.isSwitchedOn = (app.showColorsSetting == "Yes");
		enableAnimationToggle.isSwitchedOn = (app.showAnimationSetting == "Yes");
		enableDimExtendedToggle.isSwitchedOn = (app.showDimTileExtended == "Yes");
		refreshIntervalLabel.inputText = app.refreshIntervalInMinutes;
		urlModel.clear();

		for (var i = 0; i < app.calendarSettingsJson['Calendar_URL'].length; i++) {
			var colorStr = i.toString();
			if (i > 9) colorStr = "9";
			urlModel.append({urlName: app.calendarSettingsJson['Calendar_URL'][i], urlColor: app.colorCodes(colorStr)});
		}
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
		width: isNxt ? 500 : 400
		height: isNxt ? 44 : 35
		text: "Afspraak reminders weergeven als notificaties?"
		anchors {
			left: parent.left
			leftMargin : 30
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
		width: isNxt ? 500 : 400
		height: isNxt ? 44 : 35
		text: "Kleuren per kalender weergeven bij afspraken?"
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
		id: enableColorsToggle
		height: isNxt ? 45 : 36
		anchors.left: enableNotificationsLabel.right
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
		width: isNxt ? 500 : 400
		height: isNxt ? 44 : 35
		text: "Drie afspraken op tegel in dim stand?"
		anchors {
			left: enableColorsLabel.left
			top: enableColorsLabel.bottom
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
		width: isNxt ? 500 : 400
		height: isNxt ? 44 : 35
		text: "Ballonnen tonen op jaarlijkse afspraken?"
		anchors {
			left: enableColorsLabel.left
			top: enableDimExtendedLabel.bottom
			topMargin : 10
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
			left: enableColorsLabel.left
			top: enableAnimationLabel.bottom
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
		text: "Ingelezen kalenders:"
		anchors {
			left: refreshIntervalLabel.left
			top: refreshIntervalLabel.bottom
			topMargin : 30
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 20 : 15		}
	}

	Rectangle {
		id: gridBack
		height: isNxt ? 375 : 300
		width: isNxt ? 1024 : 800
		color: colors.canvas
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
		cellWidth: gridBack.width
		cellHeight: isNxt ? 35 : 28

		interactive: false
		flow: GridView.TopToBottom

		anchors {
			fill: gridBack
		}
	}

	ListModel {
		id: urlModel
	}
}
