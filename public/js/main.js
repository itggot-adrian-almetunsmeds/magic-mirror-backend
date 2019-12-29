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