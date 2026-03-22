import Astal from "gi://Astal?version=4.0"
import Gtk from "gi://Gtk?version=4.0"
import { createState, createEffect } from "gnim"
import app from "ags/gtk4/app"
import MusicPlayer from "./MusicPlayer"

const [visible, setVisible] = createState(false)
export const toggleSidebar = () => setVisible((v: boolean) => !v)

export default function Sidebar() {
  const win = new Astal.Window({
    name: "sidebar",
    application: app,
    anchor: 2 | 4 | 16,  // TOP=2, RIGHT=4, BOTTOM=16
    exclusivity: 0,       // 0=normal, 1=exclusive, 2=ignore
    layer: 3,             // OVERLAY=3
    visible: false,
  })

  createEffect(() => {
    win.visible = visible()
  })

  const header = new Gtk.Box({ spacing: 8 })
  const title = new Gtk.Label({ label: "  Panel", hexpand: true })
  const closeBtn = new Gtk.Button()
  const closeIcon = new Gtk.Image({ iconName: "window-close-symbolic" })
  closeBtn.set_child(closeIcon)
  closeBtn.get_style_context().add_class("close-btn")
  closeBtn.connect("clicked", () => {
  win.visible = false
  setVisible(false)
})
  header.append(title)
  header.append(closeBtn)

  const music = MusicPlayer()

  const content = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 16,
    widthRequest: 320,
  })
  content.get_style_context().add_class("sidebar-container")
  content.append(header)
  content.append(music)

  win.set_child(content)
  return win
}
