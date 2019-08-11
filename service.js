.import "sdk.js" as SDK

// fill in openweather appid
const appid = ''
const baseUrl = 'http://api.openweathermap.org'

if (!appid)  {
    throw new Error("missing proper weather api configuration")
}

function getIconUrl(id)
{
    return `http://openweathermap.org/img/w/${id}.png`;
}

function getForecast(city)
{
    const uri = `${baseUrl}/data/2.5/forecast/daily?q=${city}&units=metric&appid=${appid}`;
    return SDK.getJSON(uri)
}
