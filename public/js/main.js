function translations(lang) {
    var xmlHttp = new XMLHttpRequest();
    url = (window.location.protocol + "//" + window.location.hostname + ':9292' + '/api/translations/' + lang)

    xmlHttp.open("GET", url, false); // false for synchronous request
    xmlHttp.send(null);
    return xmlHttp.responseText;
}

const translation = JSON.parse(translations('en'));
const wrapper = document.getElementById("main-wrapper");

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