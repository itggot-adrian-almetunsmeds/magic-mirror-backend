
function Time(){
    var today = new Data();
    let time = today.getHours() + ":" + today.getMinutes();
    let date = today.getDate() + " " + today.getMonth() + " " + today.getYear();
    let element1 = document.createElement('h2').innerHTML = time
    let element2 = document.createElement('h3').innerHTML = date
    
}