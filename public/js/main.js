function translations(lang){
    var xmlHttp = new XMLHttpRequest();
    url = (window.location.protocol + "//" + window.location.hostname + ':9292' + '/api/translations/' + lang)

    xmlHttp.open( "GET", url, false ); // false for synchronous request
    xmlHttp.send( null );
    return xmlHttp.responseText;
}

const transl = JSON.parse(translations('sv'));

function timeComponent(transl){
    let wrapper = document.getElementById("main-wrapper");
    let timeComponent = document.createElement("div");
    timeComponent.classList.add("time-component");
    let clock = document.createElement("div");
    clock.classList.add("clock");
    let date = document.createElement("div");
    date.classList.add("date");
    timeComponent.appendChild(clock);
    timeComponent.appendChild(date);
    wrapper.appendChild(timeComponent);
    let update = setInterval(function(){
        let time = new Date();
        let hours = time.getHours();
        if (hours < 10){
            hours = ("0"+ hours);
        }
        let minutes = time.getMinutes();
            if (minutes < 10){
                minutes = ("0"+ minutes);
            }
        let seconds = time.getSeconds();
                if (seconds < 10){
                    seconds = ("0"+ seconds);
                }
        clock.innerHTML = (hours + ":" + minutes + ":" + seconds);
        transl = transl['time']
        let days_hash = {1: "mon", 2: "tue", 3: "wen", 4: "thu", 5: "fri", 6: "sat", 7: "sun"};
        let months_hash = {1: "jan", 2: "feb", 3: "mar", 4: "apr", 5: "may", 6: "june", 7: "july", 8: "aug", 9: "sep", 10: "oct", 11: "nov", 12: "dec"};
        let day = transl[days_hash[time.getDay()]];
        let day_of_month = time.getDate(); 
        let month = transl[months_hash[time.getMonth() + 1]]
        let year = time.getFullYear();

        date.innerHTML = (day + " " + day_of_month + " " + month + " " + year);
    }, 500)
}

timeComponent(transl)