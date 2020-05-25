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

var randomMsg = ['Good Morning', 'Good Evening', 'Good Afternoon', 'Good Night', 'Morning', 'Looking Good', 'Have a god day', 'Is the weather any good today?']

function randomMessage() {
    var holder

    if (document.querySelector('.random-message') != null) {
        holder = document.querySelector('.random-message')
        holder.innerHTML = ''
    } else {
        holder = document.createElement('div')
        holder.classList.add('random-message')
    }
    let content = document.createElement('h1')
    content.innerHTML = randomMsg[Math.floor(Math.random() * randomMsg.length)]
    holder.append(content)
    wrapper.append(holder)
}

setInterval(randomMessage, 8000)

function initiateNews() {
    setInterval(newsToggle, 10000)
}

function newsToggle() {
    
}


function newsComponent() {
    var holder

    if (document.querySelector('.news') != null) {
        holder = document.querySelector('.news')
        holder.innerHTML = ''
    } else {
        holder = document.createElement('div')
        holder.classList.add('news')
    }

    temp = document.createElement('h1')
    temp.innerHTML = news['title']
    holder.append(temp)

    temp = document.createElement('h3')
    temp.innerHTML = news['source']
    holder.append(temp)

    wrapper.append(holder)
}


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
    if (document.querySelector('.weather-component') != null) {
        var weather_component = document.querySelector('.weather-component');
        weather_component.innerHTML = '';
    } else {
        var weather_component = document.createElement('div');
        weather_component.classList.add('weather-component');
    }

    for (element in data) {
        let holder = document.createElement('div')
        if (element == 0) {
            holder.classList.add('current')
        }
        temp = document.createElement('img')
        temp.src = `img/weather/${data[element].symbol}.svg`;
        holder.append(temp)
        temp = document.createElement('span')
        temp.innerHTML = data[element].temp.split(' ')[0] + "&#176;C"
        holder.append(temp)
        temp = document.createElement('span')
        x = new Date(data[element].time)
        // console.log(x.getDate())
        // console.log(new Date().getDate())
        if (x.getDate() == new Date().getDate()) {
            temp.innerHTML = x.customFormat("#hh#:#mm#")
        } else {
            temp.innerHTML = x.customFormat("#DDD# #hh#:#mm#")
        }
        holder.append(temp)
        temp = document.createElement('span')
        temp.innerHTML = data[element].wind_speed
        holder.append(temp)
        weather_component.append(holder)
    }
    wrapper.append(weather_component)
}

timeComponent()


function publicTransit(data) {
    if (document.querySelector('.traffic-component') != null) {
        var trafficComponent = document.querySelector('.traffic-component');
        trafficComponent.innerHTML = '';
    } else {
        var trafficComponent = document.createElement('div');
        trafficComponent.classList.add('traffic-component');
    }
    var collection = document.createElement('div');
    collection.classList.add('transit-list');
    for (var element in data[1]) {
        if (element < 5) {
            holder = document.createElement('div')
            temp = document.createElement('span')
            temp.innerHTML = data[1][element].line
            holder.append(temp)
            temp = document.createElement('span')
            temp.innerHTML = data[1][element].direction
            temp.classList.add('scroll-hidden')
            holder.append(temp)
            temp = document.createElement('span')

            if (data[1][element].rtTime == null && data[1][element]['time'].substr(0, 2) < new Date().getHours()) {
                reserve = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, data[1][element]['time'].substr(0, 2), data[1][element]['time'].substr(3, 2))
                now_ = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate(), new Date().getHours(), new Date().getMinutes())
            } else if (data[1][element].rtTime == null) {
                reserve = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, data[1][element]['time'].substr(0, 2), data[1][element]['time'].substr(3, 2))
                now_ = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, new Date().getHours(), new Date().getMinutes())
            } else if (data[1][element]['rtTime'].substr(0, 2) < new Date().getHours()) {
                reserve = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, data[1][element]['rtTime'].substr(0, 2), data[1][element]['rtTime'].substr(3, 2))
                now_ = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate(), new Date().getHours(), new Date().getMinutes())
            } else {
                reserve = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, data[1][element]['rtTime'].substr(0, 2), data[1][element]['rtTime'].substr(3, 2))
                now_ = new Date(new Date().getFullYear() + 1, new Date().getMonth() + 1, new Date().getDate() + 1, new Date().getHours(), new Date().getMinutes())
            }

            delta = reserve - now_
            delta = delta * 10 ** -3 / 60
            temp.innerHTML = delta

            if (delta < 200) {
                holder.append(temp)
                collection.append(holder)
            }

        }
    }
    trafficComponent.append(collection)
    wrapper.append(trafficComponent)
}


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
        eventList = document.createElement('div');
        eventList.classList.add('event-list');

        for (i = 0; i < data.length; i++) {
            temp = isDate(dayDate, data[i])
            if (temp != false) {
                eventList.append(temp)
            }
        };
        day.append(eventList)
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
            times.classList.add('times');
            pTag = document.createElement('p');
            pTag.innerHTML = 'All Day';
            times.append(pTag)
            title = document.createElement('p');
            title.innerHTML = calendarEntry.summary
            event.append(times)
            event.append(title)
            return event
        } else {
            if (endTime.getHours() == 00 && endTime.getMinutes() == 00) {
                return false
                // TODO [#31]: Refine the method of not rendering edge cases
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
        return true
    } else {
        return false
    }
}

function endsDate(calendarEntry, object) {
    let time = new Date(calendarEntry.end_time)
    if (time.getDate() == object.getDate() && time.getMonth() == object.getMonth()) {
        return true
    } else {
        return false
    }
}

function checkConnection() {
    var today = new Date();
    var image = new Image();
    image.src = 'https://www.google.com/chrome/static/images/chrome-logo.svg?' + today.getHours() + ':' + today.getMinutes() + ':' + today.getSeconds();
    setTimeout
        (
            function () {
                if (!image.complete || !image.naturalWidth) {
                    addError('No network connection detected. Last online: ' + today.getHours() + ":" + today.getMinutes(), 400);
                } else {
                    removeError(400);
                }
            },
            1000
        );
}

setInterval(function () {
    checkConnection()
}, 10000);


function removeError(id) {
    if (document.getElementById(id) != null) {
        element = document.getElementById(id)
        element.parentNode.removeChild(element)
        if (document.querySelectorAll('.error_content').length == 1) {
            document.querySelector('#error_bar').classList.remove('scroll')
        }
        if (document.querySelector('#error_bar').innerHTML == '') {
            document.getElementById('holder').classList.add('hidden');
        }
    }
}

function addError(error, id) {
    if (document.getElementById(id) == null) {
        let h = document.getElementById('error_bar');
        o = document.createElement('span');
        o.classList.add('error_content');
        o.innerHTML = error
        o.id = id
        h.append(o)
        document.getElementById('holder').classList.remove('hidden')
        if (document.querySelectorAll('.error_content').length > 1) {
            document.querySelector('#error_bar').classList.add('scroll')
        }
    }
}