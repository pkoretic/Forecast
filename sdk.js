.pragma library

function getJSON(uri)
{
    return new Promise((resolve, reject) => {
       const xhr = new XMLHttpRequest();

       xhr.onreadystatechange = () => {
           if (xhr.readyState === XMLHttpRequest.DONE) {
               const { status, responseText } = xhr
               if(status === 200) {
                   resolve(JSON.parse(responseText))
               }
               else {
                   reject({ code: status, msg: responseText })
               }
           };
       }

       xhr.open("GET", uri)
       xhr.setRequestHeader('Accept', 'application/json');
       xhr.send()
   })
}

function timpestampToDay(timestamp)
{
    let d = new Date(timestamp * 1000)
    return d.toLocaleDateString(Qt.locale(), "ddd")
}

function temperatureToString(temp)
{
    return Math.round(temp) + "°C"
}
