function clock(){
    let wrapper = document.getElementById("wrapper");
    
    let clock = document.createElement("div");
    clock.classList.add("clock");
    wrapper.appendChild(clock);
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
    }, 500)
}

clock()