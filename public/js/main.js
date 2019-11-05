function translations(lang){
    var xmlHttp = new XMLHttpRequest();
    url = (window.location.protocol + "//" + window.location.hostname + ':4567' + '/api/translations/' + lang)

    xmlHttp.open( "GET", url, false ); // false for synchronous request
    xmlHttp.send( null );
    return xmlHttp.responseText;
}

function timeComponent(){
    let wrapper = document.getElementById("wrapper");
    
    let clock = document.createElement("div");
    clock.classList.add("clock");
    let date = document.createElement("div");
    date.classList.add("date");
    wrapper.appendChild(clock);
    wrapper.appendChild(date)
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
        let day = time.getDay();
        let day_of_month = time.getDate();
        let month = time.getMonth();
        let year = time.getFullYear();

        date.innerHTML = (day + " " + day_of_month + " " + month + " " + year);
    }, 500)
}

translations = JSON.parse(translations('sv'))
console.log(translations)
timeComponent()

