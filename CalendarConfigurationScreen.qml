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

	Text {
		id: enableNotificationsLabel
		width: isNxt ? 750 : 600
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
			pixelSize: isNxt ? 25 : 20
		}
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
		width: isNxt ? 750 : 600
		height: isNxt ? 44 : 35
		text: "Kleuren per kalender weergeven bij afspraken?"
		anchors {
			left: enableNotificationsLabel.left
			top: enableNotificationsLabel.bottom
			topMargin : 15
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 25 : 20
		}
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
		width: isNxt ? 750 : 600
		height: isNxt ? 44 : 35
		text: "Drie afspraken op tegel in dim stand?"
		anchors {
			left: enableColorsLabel.left
			top: enableColorsLabel.bottom
			topMargin : 15
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 25 : 20
		}
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
		width: isNxt ? 750 : 600
		height: isNxt ? 44 : 35
		text: "Ballonnen tonen op jaarlijkse afspraken?"
		anchors {
			left: enableColorsLabel.left
			top: enableDimExtendedLabel.bottom
			topMargin : 15
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 25 : 20
		}
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
			}
		}
	}

	Text {
		id: urlListLabel
		text: "Ingelezen kalenders:"
		anchors {
			left: enableDimExtendedLabel.left
			top: enableAnimationLabel.bottom
			topMargin : 30
		}
		font {
			family: qfont.regular.name
			pixelSize: isNxt ? 25 : 20
		}
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
