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

function poll<T>(intervalMs: number, fn: () => T, initial: T) {
  const [val, setVal] = createState<T>(initial)
  setVal(fn())
  setInterval(() => setVal(fn()), intervalMs)
  return val
}

const WORKSPACE_ICONS: Record<number, string> = {
  1: "", 2: "", 3: "", 4: "", 5: "",
  6: "󰙯", 7: "󰊗", 8: "󰖟", 9: "󰘓", 10: "󰍹",
}

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
        const lbl = new Gtk.Label({ label: WORKSPACE_ICONS[w.id] ?? String(w.id) })
        btn.set_child(lbl)
        btn.get_style_context().add_class("ws-btn")
        if (w.id === focused()) btn.get_style_context().add_class("active")
        btn.connect("clicked", () => GLib.spawn_command_line_async(`hyprctl dispatch workspace ${w.id}`))
        box.append(btn)
      })
  })
  return box
}

function Clock() {
  const time = poll(1000, () => exec(`date "+%I:%M %p"`), "--:--")
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-clock")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = time() })
  box.append(lbl)
  return box
}

function Cpu() {
  const usage = poll(2000, () => {
    const out = exec(`bash -c "top -bn1 | grep 'Cpu' | awk '{print int($2+$4)}'"`).split("\n")[0]
    return `  ${out}%`
  }, " --%")
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-cpu")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = usage() })
  box.append(lbl)
  return box
}

function Memory() {
  const usage = poll(5000, () => {
    const out = exec(`bash -c "free | awk '/Mem:/{printf \\"%.0f\\", $3/$2*100}'"`)
    return ` RAM ${out}%`
  }, " RAM --%")
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-memory")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = usage() })
  box.append(lbl)
  return box
}

function Temperature() {
  const temp = poll(5000, () => {
    const out = exec(`bash -c "cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0"`)
    const c = Math.round(parseInt(out) / 1000)
    return ` ${c}°C`
  }, " --°C")
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-temp")
  const lbl = new Gtk.Label()
  createEffect(() => {
    lbl.label = temp()
    const t = parseInt(temp().replace(/\D/g, ""))
    const ctx = lbl.get_style_context()
    ctx.remove_class("critical")
    if (t >= 80) ctx.add_class("critical")
  })
  box.append(lbl)
  return box
}

function Volume() {
  const vol = poll(1000, () => {
    const out = exec(`bash -c "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+(?=%)' | head -1"`)
    const muted = exec(`bash -c "pactl get-sink-mute @DEFAULT_SINK@ | grep -c yes"`) === "1"
    const icon = muted ? "󰝟" : parseInt(out) > 50 ? "󰕾" : "󰖀"
    return `${icon} ${out}%`
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

function Network() {
  const net = poll(5000, () => {
    const wifi = exec(`bash -c "iwgetid -r 2>/dev/null"`)
    if (wifi) {
      const strength = exec(`bash -c "awk 'NR==3{print int($3*100/70)}' /proc/net/wireless 2>/dev/null || echo 0"`)
      return `󰤨 ${strength}%`
    }
    const eth = exec(`bash -c "ip link show | grep -c 'state UP' 2>/dev/null || echo 0"`)
    if (parseInt(eth) > 0) return "󰈀"
    return "󰤭"
  }, "󰤭")
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-network")
  const lbl = new Gtk.Label()
  createEffect(() => { lbl.label = net() })
  box.append(lbl)
  return box
}

function Battery() {
  const bat = poll(30000, () => {
    const cap = exec(`bash -c "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo -1"`)
    if (cap === "-1" || cap === "") return null
    const status = exec(`bash -c "cat /sys/class/power_supply/BAT0/status 2>/dev/null"`)
    const charging = status === "Charging"
    const pct = parseInt(cap)
    const icon = charging ? "󰂄" : pct > 80 ? "󰁹" : pct > 50 ? "󰁾" : pct > 20 ? "󰁼" : "󰁺"
    return `${icon} ${pct}%`
  }, null as string | null)
  const box = new Gtk.Box()
  box.get_style_context().add_class("pill")
  box.get_style_context().add_class("pill-battery")
  const lbl = new Gtk.Label()
  createEffect(() => {
    const v = bat()
    box.visible = v !== null
    if (v) lbl.label = v
  })
  box.append(lbl)
  return box
}

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
    return `${icon} ${(a ?? "").slice(0, 20)} - ${(t ?? "").slice(0, 25)}`
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

function PowerButton() {
  const btn = new Gtk.Button()
  btn.get_style_context().add_class("pill")
  btn.get_style_context().add_class("pill-power")
  btn.set_child(new Gtk.Label({ label: "⏻" }))
  btn.connect("clicked", () =>
    GLib.spawn_command_line_async(`${GLib.get_home_dir()}/.config/hypr/scripts/power-menu.sh`)
  )
  return btn
}

export default function Bar() {
  const win = new Astal.Window({
    name: "bar",
    application: app,
    anchor: 2 | 4 | 8,
    exclusivity: 1,
    layer: 1,
    visible: true,
    visible: true,
    heightRequest: 36,
  })

  const left = new Gtk.Box({ spacing: 4 })
  left.get_style_context().add_class("bar-section")
  left.append(Workspaces())

  const center = new Gtk.Box({ spacing: 4 })
  center.get_style_context().add_class("bar-section")
  ;[Volume(), Network(), Cpu(), Memory(), Temperature(), Battery()].forEach(w => center.append(w))

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
