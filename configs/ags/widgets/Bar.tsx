import Astal from "gi://Astal?version=4.0"
import Gtk from "gi://Gtk?version=4.0"
import GLib from "gi://GLib?version=2.0"
import Mpris from "gi://AstalMpris"
import { createState, createEffect, createComputed, createBinding } from "gnim"
import app from "ags/gtk4/app"
import { toggleSidebar } from "./Sidebar"

function exec(cmd: string): string {
  try {
    const [, stdout] = GLib.spawn_command_line_sync(cmd)
    return new TextDecoder().decode(stdout as any).trim()
  } catch { return "" }
}

function poll<T>(ms: number, fn: () => T, init: T) {
  const [val, setVal] = createState<T>(init)
  setVal(fn())
  setInterval(() => setVal(fn()), ms)
  return val
}

const WORKSPACE_ICONS: Record<number, string> = {
  1: "", 2: "", 3: "", 4: "", 5: "",
  6: "󰙯", 7: "󰊗", 8: "󰖟", 9: "󰘓", 10: "󰍹",
}

// ─── Workspaces ────────────────────────────────────────────────────────────
function Workspaces() {
  const workspaces = poll(500, () => {
    try { return JSON.parse(exec("hyprctl workspaces -j")) as { id: number }[] } catch { return [] }
  }, [] as { id: number }[])
  const focused = poll(300, () => {
    try { return JSON.parse(exec("hyprctl activewindow -j"))?.workspace?.id ?? 1 } catch { return 1 }
  }, 1)

  const box = new Gtk.Box({ spacing: 4 })
  box.get_style_context().add_class("workspaces")

  createEffect(() => {
    let child = box.get_first_child()
    while (child) { const next = child.get_next_sibling(); box.remove(child); child = next }
    workspaces()
      .sort((a: any, b: any) => a.id - b.id)
      .forEach((w: { id: number }) => {
        const btn = new Gtk.Button()
        btn.set_child(new Gtk.Label({ label: WORKSPACE_ICONS[w.id] ?? String(w.id) }))
        btn.get_style_context().add_class("ws-btn")
        if (w.id === focused()) btn.get_style_context().add_class("active")
        btn.connect("clicked", () => GLib.spawn_command_line_async(`hyprctl dispatch workspace ${w.id}`))
        box.append(btn)
      })
  })
  return box
}

// ─── CPU con sparkline ──────────────────────────────────────────────────────
function Cpu() {
  // Historial de 8 valores para la gráfica
  const history: number[] = new Array(8).fill(0)

  const cpuVal = poll(1500, () => {
    const out = exec(`bash -c "top -bn1 | grep 'Cpu' | awk '{print int($2+$4)}'"`).split("\n")[0]
    const v = parseInt(out) || 0
    history.shift()
    history.push(v)
    return v
  }, 0)

  const box = new Gtk.Box({ spacing: 6 })
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-cpu")

  // Mini gráfica — 8 barras verticales
  const sparkBox = new Gtk.Box({ spacing: 2, valign: Gtk.Align.CENTER })
  const bars: Gtk.Box[] = history.map(() => {
    const b = new Gtk.Box()
    b.get_style_context().add_class("cpu-spark")
    b.widthRequest = 4
    b.heightRequest = 18
    return b
  })
  bars.forEach(b => sparkBox.append(b))

  const lbl = new Gtk.Label()

  createEffect(() => {
    const v = cpuVal()
    lbl.label = `${v}%`
    const max = Math.max(...history, 1)
    bars.forEach((b, i) => {
      const h = Math.max(3, Math.round((history[i] / max) * 18))
      b.heightRequest = h
      b.valign = Gtk.Align.END
    })
  })

  box.append(sparkBox)
  box.append(lbl)
  return box
}

// ─── RAM ──────────────────────────────────────────────────────────────────
function Memory() {
  const usage = poll(5000, () => {
    const out = exec(`bash -c "free | awk '/Mem:/{printf \\"%.0f\\", $3/$2*100}'"`)
    return parseInt(out) || 0
  }, 0)

  const box = new Gtk.Box({ spacing: 6 })
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-memory")

  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = ` RAM ${usage()}%` })
  box.append(lbl)
  return box
}

// ─── Temperature ──────────────────────────────────────────────────────────
function Temperature() {
  const temp = poll(5000, () => {
    const out = exec(`bash -c "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"`)
    return Math.round(parseInt(out) / 1000)
  }, 0)

  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-temp")
  const lbl = new Gtk.Label()
  createEffect(() => {
    const t = temp()
    lbl.label = ` ${t}°C`
    const ctx = lbl.get_style_context()
    ctx.remove_class("critical")
    if (t >= 80) ctx.add_class("critical")
  })
  box.append(lbl)
  return box
}

// ─── Volume ───────────────────────────────────────────────────────────────
function Volume() {
  const vol = poll(1000, () => {
    const out = exec(`bash -c "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1"`)
    const muted = exec(`bash -c "pactl get-sink-mute @DEFAULT_SINK@ | grep -c yes"`) === "1"
    const pct = parseInt(out) || 0
    const icon = muted ? "󰝟" : pct > 50 ? "󰕾" : "󰖀"
    return `${icon} ${pct}%`
  }, "󰖀 --%")

  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-volume")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = vol() })

  const scroll = new Gtk.EventControllerScroll()
  scroll.flags = Gtk.EventControllerScrollFlags.VERTICAL
  scroll.connect("scroll", (_: any, _dx: number, dy: number) => {
    if (dy < 0) GLib.spawn_command_line_async("pactl set-sink-volume @DEFAULT_SINK@ +5%")
    else GLib.spawn_command_line_async("pactl set-sink-volume @DEFAULT_SINK@ -5%")
  })
  box.add_controller(scroll)
  box.append(lbl)
  return box
}

// ─── Network ──────────────────────────────────────────────────────────────
function Network() {
  const net = poll(5000, () => {
    const wifi = exec(`bash -c "iwgetid -r 2>/dev/null"`)
    if (wifi) {
      const s = exec(`bash -c "awk 'NR==3{print int($3*100/70)}' /proc/net/wireless 2>/dev/null || echo 0"`)
      return `󰤨 ${s}%`
    }
    const eth = exec(`bash -c "ip link show | grep -c 'state UP' 2>/dev/null || echo 0"`)
    return parseInt(eth) > 0 ? "󰈀" : "󰤭"
  }, "󰤭")

  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-network")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = net() })
  box.append(lbl)
  return box
}

// ─── Battery ──────────────────────────────────────────────────────────────
function Battery() {
  const bat = poll(30000, () => {
    const cap = exec(`bash -c "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo -1"`)
    if (cap === "-1" || cap === "") return null
    const status = exec(`bash -c "cat /sys/class/power_supply/BAT0/status 2>/dev/null"`)
    const pct = parseInt(cap)
    const icon = status === "Charging" ? "󰂄" : pct > 80 ? "󰁹" : pct > 50 ? "󰁾" : pct > 20 ? "󰁼" : "󰁺"
    return `${icon} ${pct}%`
  }, null as string | null)

  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-battery")
  const lbl = new Gtk.Label()
  createEffect(() => { const v = bat(); box.visible = v !== null; if (v) lbl.label = v })
  box.append(lbl)
  return box
}

// ─── Separador visual ─────────────────────────────────────────────────────
function Sep() {
  const sep = new Gtk.Box()
  sep.get_style_context().add_class("sep")
  sep.widthRequest = 1
  sep.heightRequest = 20
  sep.valign = Gtk.Align.CENTER
  return sep
}

// ─── Music ────────────────────────────────────────────────────────────────
function Music() {
  const mpris = Mpris.get_default()
  const players = createBinding(mpris, "players")
  const player = createComputed(() => {
    const list = players()
    return list.find((p: any) => p.busName?.includes("spotify")) ?? list[0] ?? null
  })
  const label = createComputed(() => {
    const p = player()
    if (!p) return "󰝛 No music"
    const t = createBinding(p, "title")()
    const a = createBinding(p, "artist")()
    const status = createBinding(p, "playbackStatus")()
    const icon = status === 0 ? "󰝚" : "󰏤"
    return `${icon} ${(a ?? "").slice(0, 18)} - ${(t ?? "").slice(0, 22)}`
  })

  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-music")
  const lbl = new Gtk.Label({ ellipsize: 3 })
  createEffect(() => { lbl.label = label() })

  const gc1 = new Gtk.GestureClick(); gc1.set_button(1)
  gc1.connect("pressed", () => toggleSidebar())
  box.add_controller(gc1)

  const gc3 = new Gtk.GestureClick(); gc3.set_button(3)
  gc3.connect("pressed", () => player()?.next())
  box.add_controller(gc3)

  const scroll = new Gtk.EventControllerScroll()
  scroll.flags = Gtk.EventControllerScrollFlags.VERTICAL
  scroll.connect("scroll", (_: any, _dx: number, dy: number) => {
    if (dy < 0) player()?.next(); else player()?.previous()
  })
  box.add_controller(scroll)

  box.append(lbl)
  return box
}

// ─── Power ────────────────────────────────────────────────────────────────
function PowerButton() {
  const btn = new Gtk.Button()
  btn.get_style_context().add_class("pill-power")
  btn.set_child(new Gtk.Label({ label: "⏻" }))
  btn.connect("clicked", () =>
    GLib.spawn_command_line_async(`${GLib.get_home_dir()}/.config/hypr/scripts/power-menu.sh`)
  )
  return btn
}

// ─── Clock con fecha ──────────────────────────────────────────────────────
function Clock() {
  const DAYS = ["DOM","LUN","MAR","MIÉ","JUE","VIE","SÁB"]
  const MONTHS = ["ENE","FEB","MAR","ABR","MAY","JUN","JUL","AGO","SEP","OCT","NOV","DIC"]

  const time = poll(1000, () => exec(`date "+%I:%M %p"`), "--:--")
  const date = poll(60000, () => {
    const d = new Date()
    return `${DAYS[d.getDay()]} ${d.getDate()} ${MONTHS[d.getMonth()]}`
  }, "")

  const box = new Gtk.Box({ orientation: Gtk.Orientation.VERTICAL, spacing: 0, valign: Gtk.Align.CENTER })
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-clock")

  const timeLbl = new Gtk.Label()
  timeLbl.get_style_context().add_class("clock-time")
  const dateLbl = new Gtk.Label()
  dateLbl.get_style_context().add_class("clock-date")

  createEffect(() => { timeLbl.label = time() })
  createEffect(() => { dateLbl.label = date() })

  box.append(timeLbl)
  box.append(dateLbl)
  return box
}

// ─── Bar ──────────────────────────────────────────────────────────────────
export default function Bar() {
  const win = new Astal.Window({
    name: "bar",
    application: app,
    anchor: 2 | 4 | 8,
    exclusivity: 1,
    layer: 1,
    visible: true,
    heightRequest: 44,
  })

  const left = new Gtk.Box({ spacing: 4 })
  left.get_style_context().add_class("bar-section")
  left.append(Workspaces())

  const center = new Gtk.Box({ spacing: 2 })
  center.get_style_context().add_class("bar-section")
  ;[Cpu(), Memory(), Temperature(), Sep(), Volume(), Network(), Battery()].forEach(w => center.append(w))

  const right = new Gtk.Box({ spacing: 4 })
  right.get_style_context().add_class("bar-section")
  ;[Music(), PowerButton(), Clock()].forEach(w => right.append(w))

  const cb = new Gtk.CenterBox()
  cb.get_style_context().add_class("bar")
  cb.set_start_widget(left)
  cb.set_center_widget(center)
  cb.set_end_widget(right)

  win.set_child(cb)
  return win
}
