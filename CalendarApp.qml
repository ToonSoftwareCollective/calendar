import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0
import FileIO 1.0
import "calendar.js" as CalendarJS

// Application to show Google (and other) calendar ICS files on Toon

App {
	id: calendarApp


	property url tileUrl : "CalendarTile.qml"
 	property CalendarListDatesScreen calendarListDatesScreen 
	property url calendarListDatesScreenUrl : "CalendarListDatesScreen.qml"
	property CalendarConfigurationScreen calendarConfigurationScreen 
	property url calendarConfigurationScreenUrl : "CalendarConfigurationScreen.qml"
	property url thumbnailIcon: "./drawables/calendar.png"

	// values to show on the tile for the next three appointments

	property string calendarDatesString
	property string calendarDateNext1Label : "even geduld a.u.b"
	property string calendarDateNext1Time
	property string calendarDateNext1LabelDim : "even geduld a.u.b"
	property string calendarDateNext1DateDim
	property string calendarDateNext2Label
	property string calendarDateNext2Time
	property string calendarDateNext3Label
	property string calendarDateNext3Time

	// other variables

	property string endDateFirstAppointment		// used to calculate the interval for the timer to trigger the next screen refresh
	property int offsetNoticationTimer		// number of miiliseconds till the next notification (reminder) is is to be shown
	property string textNotification		// text of notification to show
	property string calendarListDates		// all upcoming meetings in one text block
	property bool showNotification			// is there a notification to show
	property string showNotificationSetting : "Yes"	// parameters from the userSettings.json file
	property variant calendarSettingsJson : {
		'ShowNotifications': "Yes",
		'Calendar_URL': []
	}
	property int numberOfCalendersToRead		// to keep track whether I am done with processing of the last calender

	FileIO {
		id: userSettingsFile
		source: "file:///qmf/qml/apps/calendar/userSettings.json"
 	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: "Kalender", thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", calendarListDatesScreenUrl, this, "calendarListDatesScreen");
		registry.registerWidget("screen", calendarConfigurationScreenUrl, this, "calendarConfigurationScreen");
		notifications.registerType("kalender", notifications.prio_HIGHEST, Qt.resolvedUrl("drawables/notification-update.svg"), calendarListDatesScreenUrl , {"categoryUrl": calendarListDatesScreenUrl }, "Kalender notificaties");
		notifications.registerSubtype("kalender", "herinnering", calendarListDatesScreenUrl , {"categoryUrl": calendarListDatesScreenUrl });
	}

	Component.onCompleted: {
		endFirstAppointmentTimer.start();	// kickoff timer for the first processing (delayed start of the app to allow Toon's to complete the boot process)
		var now = new Date();
	}

	function sendNotification() {
		notifications.send("kalender", "herinnering", false, "Kalender herinnering: "+ textNotification, "category=herinnering");
	}

	function calcAlarmOffsetInMs(trigger) {		// calculates milliseconds of the notifiction ahead of the start of the appointment
	
		// find start of string for days, hours, minutes and seconds, example of the trigger: -P0DT0H20M0S

		var iP = trigger.indexOf("P");
		var iD = trigger.indexOf("D");
		var iT = trigger.indexOf("T");
		var iH = trigger.indexOf("H");
		var iM = trigger.indexOf("M");
		var iS = trigger.indexOf("S");
		var signTrigger = 1;
		if (trigger.substring(0,1) == "-") signTrigger = -1;
		
		// calc values for each item if present

		var vD = 0;
		var vH = 0;
		var vM = 0;
		var vS = 0;

		if (iD > 0) vD = trigger.substring(iP+1,iD) * signTrigger;
		if (iH > 0) vH = trigger.substring(iT+1,iH) * signTrigger;
		if (iM > 0) vM = trigger.substring(iH+1,iM) * signTrigger;
		if (iS > 0) vS = trigger.substring(iM+1,iS) * signTrigger;

		return ((((((vD * 24) + vH) * 60) + vM) * 60) + vS) * 1000;
	}

	function saveSettings() {				// writes back userSettings.json withthe new shownotifcation setting (URL's are untouched)
 		var tmpcalendarSettingsJson = {
			"ShowNotifications" : showNotificationSetting,
			"Calendar_URL" : calendarSettingsJson['Calendar_URL']
		}
  		var doc3 = new XMLHttpRequest();
   		doc3.open("PUT", "file:///HCBv2/qml/apps/calendar/userSettings.json");
   		doc3.send(JSON.stringify(tmpcalendarSettingsJson));
	}

	function startOrRefresh() {				// called by 'Verversen' button on screen
		endFirstAppointmentTimer.stop();
		readCalendars();
	}

	function readCalendars() {

		// re-read settings (URL's can be changed in the mean time by the user)

		try {
			calendarSettingsJson = JSON.parse(userSettingsFile.read());
			showNotificationSetting = calendarSettingsJson['ShowNotifications'];
		} catch(e) {
			qdialog.showDialog(qdialog.SizeLarge, "Kalender mededeling", "Er is een fout opgetreden bij het lezen van de file /qmf/qml/apps/calendar/userSettings.json" , "Sluiten");
		}

		// clear tile labels

		calendarDatesString = "";
		calendarDateNext1Label = "ophalen kalenders";
		calendarListDates  = "ophalen kalenders";
		calendarDateNext1Time = "";
		calendarDateNext1LabelDim = "ophalen kalenders";
		calendarDateNext1DateDim = "";
		calendarDateNext2Label = "";
		calendarDateNext2Time = "";
		calendarDateNext3Label = "";
		calendarDateNext3Time = "";

		// start reading each calendar

		numberOfCalendersToRead = calendarSettingsJson['Calendar_URL'].length
		for (var i = 0; i < calendarSettingsJson['Calendar_URL'].length; i++) {
			readGoogleCalendar(calendarSettingsJson['Calendar_URL'][i]);
		}
	}

	function readGoogleCalendar(calendarURL) {		// function to read a single ICS calendar file

		// bunch of meaningless counters

		var h = 0;
		var i = 0;
		var j = 0;
		var jj = 0;
		var k = 0;
		var l = 0;
		var m = 0;
		var n = 0;
		var o = 0;
		var p = 0;
		var q = 0;
		var r = 0;

		// init variables for this calendar

		var dateFrom = "";
		var dateTo = "";
		var googleDates = [];
		var triggerTxt = "";
		var recurrenceTxt = "";
		var correctionUTC = "0";

		var toDayStr = nowFormatted();		// calculate yyyy-mm-ddThh:mm for now() to filter out old entries later on

		var xmlhttp = new XMLHttpRequest();	
		xmlhttp.onreadystatechange=function() {
	
			if (xmlhttp.readyState == XMLHttpRequest.DONE) {

				var aNode = xmlhttp.responseText;

				j = aNode.indexOf("BEGIN:VEVENT");		// find first appointment
				h = aNode.indexOf("DTSTART", j);
				i = aNode.indexOf(":", h);			// when not in UTC, need to skip timezone info

				if ( i > 0 ) {					
					while (i > 0) {				// loop through all appointments int he ICS file

							// index this event

						jj= aNode.indexOf("DTEND", i);		
						j = aNode.indexOf(":", jj);		// find end date of appoitment
						k = aNode.indexOf("SUMMARY", j);	// appointment title
						l = aNode.indexOf("\n", k);		// end of title
						m = aNode.indexOf("END:VEVENT", i);	// last line of this appoitmment
						n = aNode.indexOf("BEGIN:VALARM", i);	// find reminder setting (n must be lower then m to be valid)
						p = aNode.indexOf("RRULE", i);		// find recurrence setting (p must be lower then m to be valid)

							// extract reminder data from ICS file (many dfferent formats possible, only supporting the ones with a relative time to the start date of the appointment)
							// currently want triggerTxt to have a length of 15 (needed for extracting data on the screen, will be obsolete after the full rewrite of the screen

						triggerTxt = "                    ";
						if ((n > 0) && (n < m)) {	// process reminder
							o = aNode.indexOf("TRIGGER", n);
							if ((o > 0) && (o < m)) {		//trigger for this event
								triggerTxt = aNode.substring(o+8, aNode.indexOf("END:VALARM", o) - 2) + "              ";
							}
						}
						triggerTxt = triggerTxt.substring(0, 15);

							// extract recurrence data from ICS file

						recurrenceTxt = "NONE";
						if ((p > 0) && (p < m)) {
							q = aNode.indexOf("\n", p)
							if ((q > 0) && (q < m)) {		// recurrence string
								recurrenceTxt = aNode.substring(p+6, q-1);
							}
						}

							// calculate correct format for the date/time of the appointment (all day events are treated differently),UTC dates have a trailing 'Z'

						if (aNode.substring(i+16, i+17) == "Z") {
							correctionUTC = "1";
						} else {
							correctionUTC = "0";
						}

						if (aNode.substring(h+8, h+18) == "VALUE=DATE") {  // full day events, no time provided
							var tmp = convertDateToLocale(aNode.substring(i+1, i+5), aNode.substring(i+5, i+7), aNode.substring(i+7, i+9), "12", "00", recurrenceTxt, correctionUTC);
							dateFrom = tmp.substring(0,10) + "T00:00";
							var tmp2 = convertDateToLocale(aNode.substring(i+1, i+5), aNode.substring(i+5, i+7), aNode.substring(i+7, i+9), "12", "00", recurrenceTxt, correctionUTC);
							dateTo = tmp2.substring(0,10) + "T23:59";
						} else {
							dateFrom = convertDateToLocale(aNode.substring(i+1, i+5), aNode.substring(i+5, i+7), aNode.substring(i+7, i+9), aNode.substring(i+10, i+12), aNode.substring(i+12, i+14), recurrenceTxt, correctionUTC);
							dateTo = convertDateToLocale(aNode.substring(j+1, j+5), aNode.substring(j+5, j+7), aNode.substring(j+7, j+9), aNode.substring(j+10, j+12), aNode.substring(j+12, j+14), recurrenceTxt, correctionUTC);
						}

							// only store in the array if end date of appointment is in the future, add (*) for recurring items to the title

						if (toDayStr < dateTo) {
							if (recurrenceTxt == "NONE") {
								googleDates.push(dateFrom + " - " + dateTo + " - " + triggerTxt + " - " + aNode.substring(k+8, l));
							} else {
								googleDates.push(dateFrom + " - " + dateTo + " - " + triggerTxt + " - (*) " + aNode.substring(k+8, l));
							}
						}

							// find next appointment (skip other ICS entries)

						j = aNode.indexOf("BEGIN:VEVENT", i);
						if (j > 0) {
							h = aNode.indexOf("DTSTART", j);
							if (h > 0) {
								i = aNode.indexOf(":", h);
							} else {
								i = -1;		// exit the loop processing entries
							}
						} else {
							i = -1;			// exit the loop processing entries

						}
					}
				}

				// add to the calendarDatesString shown in the screen

				for (i = 0; i < googleDates.length; i++) {
					calendarDatesString = calendarDatesString + googleDates[i] + "\n";
				}

				// when this one was the last calendar to read, start sorting en processing the results

				numberOfCalendersToRead = numberOfCalendersToRead - 1;
				if (numberOfCalendersToRead == 0) {
					sortCalendarDates();
					processCollectedCalendarDates();
				}

			}
		} 
		xmlhttp.open("GET", calendarURL, true);
		xmlhttp.send();
	}
	
	function dayNumbers(shortName) {
		switch (shortName) {
			case "MO": return 1;
			case "TU": return 2;
			case "WE": return 3;
			case "TH": return 4;
			case "FR": return 5;
			case "SA": return 6;
			case "SU": return 0;
			default: break;
		}
	}


	function convertDateToLocale(strYear, strMonth, strDay, strHour, strMinutes, recurrenceTxt, correctionUTC) {

		var dateLocal = new Date(strYear, parseInt(strMonth, 10) - 1, strDay, strHour, strMinutes, 0);
//	var timezoneOffset = dateLocal.getTimezoneOffset();

		console.log("********** datelocal/input:" + dateLocal + "/" + strYear + strMonth + strDay + strHour + strMinutes + correctionUTC + recurrenceTxt);
		if (correctionUTC == "1") {
			dateLocal.setMinutes(dateLocal.getMinutes() - dateLocal.getTimezoneOffset());
			console.log("********** datelocal corr:" + dateLocal);
		}

		var now = new Date();
		var i = 0;
		var j = 0;
		var k = 0;
		var recCounter = 999999;		//arbitrary max value
		var recInterval = 1;			//default value INTERVAL tag
		var recBydayList = [];			//list of days in the week to repeat in WEEKLY recurring items
		var recByday = false;			//flag for list of days in the week to repeat in WEEKLY recurring items
		var recBydaySource = "";

		// extract COUNTER value from the recurrence string if existing

		i = recurrenceTxt.indexOf("COUNT");

		if (i > -1) {				
			j = recurrenceTxt.indexOf(";", i);		// value ends either with ';' possibly
			k = recurrenceTxt.length;

			if ((j < k) && ( j > 0)) {
				recCounter = parseInt(recurrenceTxt.substring(i+6, j));	
			} else {
				recCounter = parseInt(recurrenceTxt.substring(i+6, k));	
			}
		}	

		// extract INTERVAL value from the recurrence string if existing

		i = recurrenceTxt.indexOf("INTERVAL");

		if (i > -1) {				
			j = recurrenceTxt.indexOf(";", i);		// value ends either with ';' possibly
			k = recurrenceTxt.length;

			if ((j < k) && ( j > 0)) {
				recInterval = parseInt(recurrenceTxt.substring(i+9, j));	
			} else {
				recInterval = parseInt(recurrenceTxt.substring(i+9, k));	
			}
		}	

		// extract BYDAY value from the recurrence string if existing

		i = recurrenceTxt.indexOf("BYDAY");

		if (i > -1) {				
			j = recurrenceTxt.indexOf(";", i);		// value ends either with ';' possibly
			k = recurrenceTxt.length;

			if ((j < k) && ( j > 0)) {
				recBydaySource = recurrenceTxt.substring(i+6, j);	
			} else {
				recBydaySource = recurrenceTxt.substring(i+6, k);	
			}

				// create array with all days specified and translate these to numbers 0 through 6 (Mon - Sun)

			var sourceDays = recBydaySource.split(",");
			for (var j = 0; j < sourceDays.length; j++) {
				recBydayList.push(dayNumbers(sourceDays[j]));
			}
			recByday = (sourceDays.length > 1);
		}	

		// apply yearly recurring setting (take into account the INTERVAL and COUNT tags)
		// is either later on this year or next year

		i = recurrenceTxt.indexOf("FREQ=YEARLY");

		if (i > -1 ) {
			while ((now > dateLocal) && (recCounter > 0)) {
				for (var j = 0; j < recInterval; j++) {
					dateLocal.setFullYear(dateLocal.getFullYear() + 1);
				}
				recCounter = recCounter - 1;
			}
		}

		// apply weekly recurring setting (take into account the INTERVAL and COUNT tags)
		// keep adding 7 days until date is in the future (todo :or max counter has been reached)

		i = recurrenceTxt.indexOf("FREQ=WEEKLY");

		if (i > -1 ) {

			console.log("******** recByday:" + recByday);

			if (recByday) {			// if BYDAY tag is used, skip to first day specified						

				if ((recByday) && (recBydayList.length > 0)) {
					while ((recBydayList.indexOf(dateLocal.getDay()) < 0) || (now > dateLocal)) {
						dateLocal.setDate(dateLocal.getDate() + 1);
						console.log("******** add day:" + dateLocal);
					}						
				}

			} else {
				while ((now > dateLocal) && (recCounter > 0)) {

					for (var j = 0; j < recInterval; j++) {
						dateLocal.setDate(dateLocal.getDate() + 7);
						console.log("********* recurring skip: " + j + "/" + dateLocal);
					}
					recCounter = recCounter - 1;
				}
			}
			console.log("********* recurring skip end: " + dateLocal);
		}

		// apply monthly recurring setting (take into account the INTERVAL and COUNT tags)
		// keep adding a month until date is in the future (todo: or max counter has been reached)

		i = recurrenceTxt.indexOf("FREQ=MONTHLY");

		if (i > -1 ) {
			while ((now > dateLocal) && (recCounter > 0)) {
				for (var j = 0; j < recInterval; j++) {
					dateLocal.setMonth(dateLocal.getMonth() + 1);
				}
				recCounter = recCounter - 1;
			}
		}

		// apply daily recurring setting (take into account the INTERVAL and COUNT tags)
		// is eithert today or tomorrow (todo: or max counter has been reached)

		i = recurrenceTxt.indexOf("FREQ=DAILY");

		if (i > -1 ) {
			while ((now > dateLocal) && (recCounter > 0)) {
				for (var j = 0; j < recInterval; j++) {
					dateLocal.setDate(dateLocal.getDate() + 1);
				}
				recCounter = recCounter - 1;
			}
		}

		// add trailing zeroes to month/day/hours/minutes

		var strMonNew = dateLocal.getMonth() + 1;
		if (strMonNew < 10) {
			strMonNew = "0" + strMonNew;
		}
		var strDayNew = dateLocal.getDate();
		if (strDayNew < 10) {
			strDayNew = "0" + strDayNew;
		}
		var strHoursNew = dateLocal.getHours();
		if (strHoursNew < 10) {
			strHoursNew = "0" + strHoursNew;
		}	
		var strMinutesNew = dateLocal.getMinutes();
		if (strMinutesNew < 10) {
			strMinutesNew = "0" + strMinutesNew;
		}

		// skip item when the resulting date is after the date provided in the 'UNTIL' tag
		// entries will be filtered out automatically lateron when processing calendarDatesString

		i = recurrenceTxt.indexOf("UNTIL=");

		if (i > -1) {
			var dateUntil = new Date(Date.UTC(recurrenceTxt.substring(i+6, i+10), recurrenceTxt.substring(i+10, i+12) - 1, recurrenceTxt.substring(i+12, i+14), recurrenceTxt.substring(i+15, i+17), recurrenceTxt.substring(i+17, i+19), 0));
			if (dateUntil < now) {
				return ("1900-01-01T01:01");
			}
			if (dateUntil < dateLocal) {
				return ("1900-01-01T01:01");
			}
		}

		// return appointment date after applying the recurring settings

		console.log("********** calculated date:" + dateLocal.getFullYear() + "-" + strMonNew + "-" + strDayNew + "T" + strHoursNew + ":" + strMinutesNew);

		return (dateLocal.getFullYear() + "-" + strMonNew + "-" + strDayNew + "T" + strHoursNew + ":" + strMinutesNew);
	}

	function sortCalendarDates() {

		// sort the collected dates from different calendarsd

		var listDates = calendarDatesString.split("\n");
		var tmp = CalendarJS.sortArray(listDates);
		calendarDatesString = "";
		for (var i = 0; i < tmp.length; i++) {
			calendarDatesString = calendarDatesString + tmp[i] + "\n";
		}
	}

	function nowFormatted() {		// get now() in the format of the ICS files
		var now = new Date();
		var strMon = now.getMonth() + 1;
		if (strMon < 10) {
			strMon = "0" + strMon;
		}
		var strDay = now.getDate();
		if (strDay < 10) {
			strDay = "0" + strDay;
		}
		var strHours = now.getHours();
		if (strHours < 10) {
			strHours = "0" + strHours;
		}
		var strMinutes = now.getMinutes();
		if (strMinutes < 10) {
			strMinutes = "0" + strMinutes;
		}
		return now.getFullYear() + "-" + strMon + "-" + strDay + "T" + strHours + ":" + strMinutes;
	}

	function processCollectedCalendarDates() {

		// calculate yyyy-mm-ddThh:mm for now() to ignore old entries
		var toDayStr = nowFormatted();

		calendarListDates = "";
		var thisOffset = 0;
		textNotification = "";
		var counter = 0;
		var i = 0;
		offsetNoticationTimer = 9007199254740992; //max value
		var endDate = new Date();
		var nowDate = new Date();
		var calendarfile= new XMLHttpRequest();
		showNotification = false;

		var response = calendarDatesString.split("\n");

		for (i = 0; i < response.length; i++) {

			console.log("********** today check:" + toDayStr + "/" + response[i].slice(19, 35));

			if ( toDayStr <= response[i].slice(19, 35) ) {   //skip passed entries

					// check for earliest notification time and text to display

				if (response[i].slice(38, 53) !== "              ") {
					endDate = new Date(Date.UTC(response[i].slice(0, 4), response[i].slice(5, 7) - 1, response[i].slice(8, 10), response[i].slice(11, 13), response[i].slice(14, 16), 0));
					thisOffset = endDate - nowDate + calcAlarmOffsetInMs(response[i].slice(38, 53)) - 3600000;
					if ((thisOffset < offsetNoticationTimer) && (thisOffset > 0)) {
						offsetNoticationTimer = thisOffset;
						textNotification = response[i].slice(56,response[i].length-1);
						showNotification = true;
					}
				}
				if (counter < 20) {
					calendarListDates = calendarListDates + addCalendarListEntry(response[i]);
				}
				if (counter == 2) {
					calendarDateNext3Label = response[i].slice(8, 10) + "-" + response[i].slice(5, 7) + ": " + response[i].slice(56,response[i].length-1);
					if ((response[i].slice(11, 16) == "00:00") && (response[i].slice(30, 35) == "23:59")) {
						calendarDateNext3Time = " ";
					} else {
						calendarDateNext3Time = response[i].slice(11, 16) + " - " + response[i].slice(30, 35);
					}
				}
				if (counter == 1) {
					calendarDateNext2Label = response[i].slice(8, 10) + "-" + response[i].slice(5, 7) + ": " + response[i].slice(56,response[i].length-1);
					if ((response[i].slice(11, 16) == "00:00") && (response[i].slice(30, 35) == "23:59")) {
						calendarDateNext2Time = " ";
					} else {
						calendarDateNext2Time = response[i].slice(11, 16) + " - " + response[i].slice(30, 35);
					}
				}
				if (counter == 0) {
					calendarDateNext1Label = response[i].slice(8, 10) + "-" + response[i].slice(5, 7) + ": " + response[i].slice(56,response[i].length-1);
					if ((response[i].slice(11, 16) == "00:00") && (response[i].slice(30, 35) == "23:59")) {
						calendarDateNext1Time = " ";
					} else {
						calendarDateNext1Time = response[i].slice(11, 16) + " - " + response[i].slice(30, 35);
					}
					calendarDateNext1LabelDim = response[i].slice(56,response[i].length-1);
					if (calendarDateNext1LabelDim .length > 20) {
						calendarDateNext1LabelDim = calendarDateNext1LabelDim.slice(0,20) + "...";
					}
					calendarDateNext1DateDim = response[i].slice(8, 10) + " " + fullMonth(response[i].slice(5, 7));
					endDateFirstAppointment = response[i].slice(19,35);
				}
				counter = counter + 1;
			}
		}

		if ((showNotification === true) && (showNotificationSetting == "Yes")) {
			notificationsTimer.stop();
			notificationsTimer.interval = offsetNoticationTimer;
			notificationsTimer.start();
		}

		endFirstAppointmentTimer.interval = getMSecTillEndTimeNextAppointment();
		endFirstAppointmentTimer.start();
	}
	

	function addCalendarListEntry(newEntry) {

		if ((newEntry.slice(11, 16) == "00:00") && (newEntry.slice(30, 35) == "23:59")) { //all day event
			return "  " + newEntry.slice(0, 10) + " " + newEntry.slice(56,newEntry.length-1) + "\n\n";
		} else {
			return "  " + newEntry.slice(0, 10) + " " + newEntry.slice(56,newEntry.length-1) + "\n                       " + newEntry.slice(11, 16) + " - " + newEntry.slice(30, 35) + "\n";
		}
	}

	function fullMonth(monthNum) {			// convert the month number to long description for the tile in dim state
		switch (monthNum) {
			case "01": return "januari";
			case "02": return "februari";
			case "03": return "maart";
			case "04": return "april";
			case "05": return "mei";
			case "06": return "juni";
			case "07": return "juli";
			case "08": return "augustus";
			case "09": return "september";
			case "10": return "oktober";
			case "11": return "november";
			case "12": return "december";
			default: break;
		}
		return "error_month";
	}

	/// calculates miliseconds till end date of next appointment (to refresh the tile and calendar file)

	function getMSecTillEndTimeNextAppointment() {
		var now = new Date();
		var nowUtc = Date.UTC(now.getFullYear(), now.getMonth(), now.getDate(), now.getHours(), now.getMinutes(), now.getSeconds(),now.getMilliseconds());
		var endAppointment = Date.UTC(endDateFirstAppointment.slice(0,4), endDateFirstAppointment.slice(5,7) - 1, endDateFirstAppointment.slice(8,10), endDateFirstAppointment.slice(11,13), endDateFirstAppointment.slice(14,16), 1, 0);
		if ((endAppointment - nowUtc) < 60000) {
			return 60000;	// minimal refresh interval is one minute
		} else {
			return endAppointment - nowUtc;
		}
	}

	Timer {
		id: endFirstAppointmentTimer		// timer is started in the onCompleted() function, after that when first appoitment is ending
		repeat: false
		running: false
		interval: isNxt ? 20000 : 150000	//wait 20 sec (Toon 2) or 150 ec (Toon 1) after reboot before reading ics file for the first time
		onTriggered: {
			readCalendars();		//get new calender update
		}
	}
	Timer {
		id: notificationsTimer
		repeat: false
		running: false
		onTriggered: {
			sendNotification();
		}
	}
}
