import QtQuick 1.1
import qb.components 1.0
import BxtClient 1.0

Screen {
	id: wasteConfigurationScreen


	function showDialogWasteCollection() {
		if (!app.dialogShown) {
			qdialog.showDialog(qdialog.SizeLarge, "Afvalkalender mededeling", "Wijzigingen worden pas actief als U op de knop 'Opslaan' heeft gedrukt, rechtsboven op het scherm.\nDe tegel zal na 5-10 seconden worden ververst met de nieuwe informatie." , "Sluiten");
			app.dialogShown = true;
		}
	}

	screenTitle: "Kalender configuratie"

	onShown: {
		addCustomTopRightButton("Opslaan");
		enableNotificationsToggle.isSwitchedOn = (app.showNotificationSetting == "Yes");
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
			family: qfont.bold.name
			pixelSize: isNxt ? 30 : 24
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
}
