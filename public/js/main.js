function translations(lang) {
    var xmlHttp = new XMLHttpRequest();
    url = (window.location.protocol + "//" + window.location.hostname + ':9292' + '/api/translations/' + lang)

    xmlHttp.open("GET", url, false); // false for synchronous request
    xmlHttp.send(null);
    return xmlHttp.responseText;
}

const translation = JSON.parse(translations('en'));
const wrapper = document.getElementById("main-wrapper");

//*** This code is copyright 2002-2016 by Gavin Kistner, !@phrogz.net
//*** It is covered under the license viewable at http://phrogz.net/JS/_ReuseLicense.txt
Date.prototype.customFormat = function (formatString) {
    var YYYY, YY, MMMM, MMM, MM, M, DDDD, DDD, DD, D, hhhh, hhh, hh, h, mm, m, ss, s, ampm, AMPM, dMod, th;
    YY = ((YYYY = this.getFullYear()) + "").slice(-2);
    MM = (M = this.getMonth() + 1) < 10 ? ('0' + M) : M;
    MMM = (MMMM = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][M - 1]).substring(0, 3);
    DD = (D = this.getDate()) < 10 ? ('0' + D) : D;
    DDD = (DDDD = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"][this.getDay()]).substring(0, 3);
    th = (D >= 10 && D <= 20) ? 'th' : ((dMod = D % 10) == 1) ? 'st' : (dMod == 2) ? 'nd' : (dMod == 3) ? 'rd' : 'th';
    formatString = formatString.replace("#YYYY#", YYYY).replace("#YY#", YY).replace("#MMMM#", MMMM).replace("#MMM#", MMM).replace("#MM#", MM).replace("#M#", M).replace("#DDDD#", DDDD).replace("#DDD#", DDD).replace("#DD#", DD).replace("#D#", D).replace("#th#", th);
    h = (hhh = this.getHours());
    if (h == 0) h = 24;
    if (h > 12) h -= 12;
    hh = h < 10 ? ('0' + h) : h;
    hhhh = hhh < 10 ? ('0' + hhh) : hhh;
    AMPM = (ampm = hhh < 12 ? 'am' : 'pm').toUpperCase();
    mm = (m = this.getMinutes()) < 10 ? ('0' + m) : m;
    ss = (s = this.getSeconds()) < 10 ? ('0' + s) : s;
    return formatString.replace("#hhhh#", hhhh).replace("#hhh#", hhh).replace("#hh#", hh).replace("#h#", h).replace("#mm#", mm).replace("#m#", m).replace("#ss#", ss).replace("#s#", s).replace("#ampm#", ampm).replace("#AMPM#", AMPM);
};

// Creates a time component with time and date and puts it in the slim document
function timeComponent() {
    let timeComponent = document.createElement("div");
    timeComponent.classList.add("time-component");
    let clock = document.createElement("div");
    clock.classList.add("clock");
    let date = document.createElement("div");
    date.classList.add("date");
    timeComponent.appendChild(clock);
    timeComponent.appendChild(date);
    wrapper.appendChild(timeComponent);
    let days_hash = {
        0: "sun",
        1: "mon",
        2: "tue",
        3: "wen",
        4: "thu",
        5: "fri",
        6: "sat"
    };
    let months_hash = {
        1: "jan",
        2: "feb",
        3: "mar",
        4: "apr",
        5: "may",
        6: "june",
        7: "july",
        8: "aug",
        9: "sep",
        10: "oct",
        11: "nov",
        12: "dec"
    };
    let update = setInterval(function () {
        let time = new Date();
        let hours = time.getHours();
        // Adds a zero if single digit number
        if (hours < 10) {
            hours = ("0" + hours);
        }
        let minutes = time.getMinutes();
        if (minutes < 10) {
            minutes = ("0" + minutes);
        }
        let seconds = time.getSeconds();
        if (seconds < 10) {
            seconds = ("0" + seconds);
        }
        clock.innerHTML = (hours + ":" + minutes + ":" + seconds);
        transl = translation['time'];
        let day = transl[days_hash[time.getDay()]];
        let day_of_month = time.getDate();
        let month = transl[months_hash[time.getMonth() + 1]];
        let year = time.getFullYear();

        date.innerHTML = (day + " " + day_of_month + " " + month + " " + year);
    }, 500)
}

function weatherComponent(data) {
    console.log("Weather data recieved")
    if (document.querySelector('.weather-component') != null) {
        var weatherComponent = document.querySelector('.weather-component');
        weatherComponent.innerHTML = '';
    } else {
        var weatherComponent = document.createElement('div');
        weatherComponent.classList.add('weather-component');
    }
    let currentWeather = document.createElement('div');
    currentWeather.classList.add('current-weather');
    let upcomingWeather = document.createElement('div');
    upcomingWeather.classList.add('upcoming-weather');
    wrapper.appendChild(weatherComponent);
    weatherComponent.appendChild(currentWeather);
    weatherComponent.appendChild(upcomingWeather);
    console.log("datan:")
    console.log(data);

    let currentTemp = document.createElement('div');
    currentTemp.classList.add('current-temp');
    currentWeather.appendChild(currentTemp);
    currentTemp.innerHTML = data[0].temp

    let currentSymbol = document.createElement('div');
    currentSymbol.classList.add('symbol')
    currentSymbol.classList.add('current-symbol')
    currentWeather.appendChild(currentSymbol);
    currentSymbolImage = document.createElement('img');
    currentSymbolImage.src = `img/weather/${data[0].symbol}.svg`;
    console.log(data[0].symbol)
    currentSymbolImage.classList.add('symbol');
    currentSymbol.appendChild(currentSymbolImage);
}

timeComponent()


function calendarComponent(data) {
    if (document.querySelector('.calendar-component') != null) {
        var calendarComponent = document.querySelector('.calendar-component');
        calendarComponent.innerHTML = '';
    } else {
        var calendarComponent = document.createElement('div');
        calendarComponent.classList.add('calendar-component');
    }
    var collection = document.createElement('div');
    collection.classList.add('calendar-list');

    dayDate = new Date;
    dayDate.setHours(0, 0, 0, 0);
    dayDateOffSett = new Date;
    dayDateOffSett.setDate(dayDateOffSett.getDate() + 1);
    dayDateOffSett.setHours(0, 0, 0, 59);

    for (iterations = 0; iterations < 5; iterations++) {
        day = document.createElement('div');
        day.classList.add('day');
        header = document.createElement('p');
        header.innerHTML = (new Date(Date.parse(dayDate))).customFormat("#DDD# #D# #MMM#");
        day.append(header);

        for (i = 0; i < data.length; i++) {
            temp = isDate(dayDate, data[i])
            if (temp != false) {
                day.append(temp)
            }
        };
        collection.append(day);
        dayDate.setDate(dayDate.getDate() + 1);
    }
    calendarComponent.append(collection);
    wrapper.append(calendarComponent);
}

// Takes a Date object as an object and a calendarEntry as a hash
function isDate(object, calendarEntry) {
    temp = calendarEntry.start_time
    temp = new Date(temp)
    temp.setHours(0)
    temp.setMinutes(0)
    startTime = Date.parse(temp)
    temp = calendarEntry.end_time
    temp = new Date(temp)
    temp.setHours(0)
    temp.setMinutes(0)
    endTime = Date.parse(temp)
    now = Date.parse(object)
    if (now >= startTime && now <= endTime) {
        // It "is" today
        event = document.createElement('div');
        event.classList.add('event');

        if (isAllDay(calendarEntry, object) == 'All Day') {
            // Render as all day event
            times = document.createElement('div');
            times.classList.add('times')
            times.innerHTML = 'All Day';
            title = document.createElement('p');
            title.innerHTML = calendarEntry.summary
            event.append(times)
            event.append(title)
            return event
        } else {
            if (endTime.getHours() == 00 && endTime.getMinutes() == 00) {
                return false
                // TODO: Refine the method of not rendering edge cases
                // 
                // If the event ends at 00:00 it will be displayed as a ending "today" when the expected behaviour would be to have it render the previous day and have the end time be 24:00
            }

            // Render this as a non all day event
            times = document.createElement('div');
            times.classList.add('times')
            if (beginsDate(calendarEntry, object)) {
                startTime = document.createElement('div');
                startTime.innerHTML = (new Date(Date.parse(calendarEntry.start_time))).customFormat('#hhhh# : #mm#');
                times.append(startTime);
            }
            if (endsDate(calendarEntry, object)) {
                endTime = document.createElement('div');
                endTime.innerHTML = (new Date(Date.parse(calendarEntry.end_time))).customFormat('#hhhh# : #mm#');
                times.append(endTime);
            }
            title = document.createElement('p');
            title.innerHTML = calendarEntry.summary
            event.append(times)
            event.append(title)
            return event
        }
    } else {
        // Do not render this day
        return false
    }
}

function isAllDay(calendarEntry, object = nil) {
    object.setHours(0)
    object.setMinutes(0)
    object.setSeconds(0)
    let objectOffset = new Date(object)
    objectOffset.setDate(objectOffset.getDate() + 1)
    startTime = new Date(Date.parse(calendarEntry.start_time))
    endTime = new Date(Date.parse(calendarEntry.end_time))
    if (Date.parse(startTime) <= Date.parse(object) && Date.parse(endTime) >= Date.parse(objectOffset)) {
        return 'All Day'
    } else {
        return false
    }
}

function beginsDate(calendarEntry, object) {
    let time = new Date(calendarEntry.start_time)
    if (time.getDate() == object.getDate() && time.getMonth() == object.getMonth()) {
        console.log('Start this date')
        return true
    } else {
        return false
    }
}

function endsDate(calendarEntry, object) {
    let time = new Date(calendarEntry.end_time)
    if (time.getDate() == object.getDate() && time.getMonth() == object.getMonth()) {
        console.log('Ends this date')
        return true
    } else {
        return false
    }
}