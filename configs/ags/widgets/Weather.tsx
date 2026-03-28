import { createState } from "gnim"
import { fetch } from "gnim/fetch"

const CITY = "San+Julian+Jalisco"

const weatherIcons: Record<number, string> = {
  113: "☀️", 116: "⛅", 119: "☁️", 122: "☁️",
  143: "🌫️", 176: "🌦️", 200: "⛈️", 227: "🌨️",
  230: "❄️", 263: "🌦️", 293: "🌦️", 296: "🌧️",
  353: "🌦️", 356: "🌧️", 386: "⛈️", 389: "⛈️",
}

function getIcon(code: number): string {
  return weatherIcons[code] ?? "🌡️"
}

export default function Weather() {
  const [temp, setTemp] = createState("--")
  const [desc, setDesc] = createState("Cargando...")
  const [icon, setIcon] = createState("⏳")
  const [humidity, setHumidity] = createState("--")
  const [wind, setWind] = createState("--")
  const [feels, setFeels] = createState("--")

  async function fetchWeather() {
    try {
      const res = await fetch(`https://wttr.in/${CITY}?format=j1`)
      const data = await res.json()
      const cur = data.current_condition[0]
      setTemp(`${cur.temp_C}°C`)
      setFeels(`Sensación ${cur.FeelsLikeC}°C`)
      setDesc(cur.weatherDesc[0].value)
      setIcon(getIcon(parseInt(cur.weatherCode)))
      setHumidity(`${cur.humidity}%`)
      setWind(`${cur.windspeedKmph}km/h`)
    } catch (e) {
      setDesc(`Error: ${e}`)
    }
  }

  fetchWeather()
  setInterval(fetchWeather, 30 * 60 * 1000)

  return <box cssClasses={["weather-widget"]} orientation={1} spacing={12}>
    <box spacing={8}>
      <label cssClasses={["weather-title"]} label="🌤  Clima" hexpand={true} />
      <label cssClasses={["weather-city"]} label="Mexico City" />
    </box>
    <box cssClasses={["weather-current"]} spacing={12}>
      <label cssClasses={["weather-icon-big"]} label={icon} />
      <box orientation={1} spacing={2}>
        <label cssClasses={["weather-temp"]} label={temp} halign={1} />
        <label cssClasses={["weather-desc"]} label={desc} halign={1} />
        <label cssClasses={["weather-feels"]} label={feels} halign={1} />
      </box>
    </box>
    <box cssClasses={["weather-details"]} spacing={16} halign={3}>
      <box orientation={1} spacing={2} halign={3}>
        <label label="💧" />
        <label cssClasses={["weather-detail-val"]} label={humidity} />
        <label cssClasses={["weather-detail-lbl"]} label="Humedad" />
      </box>
      <box orientation={1} spacing={2} halign={3}>
        <label label="💨" />
        <label cssClasses={["weather-detail-val"]} label={wind} />
        <label cssClasses={["weather-detail-lbl"]} label="Viento" />
      </box>
    </box>
  </box>
}
