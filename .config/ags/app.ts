import app from "ags/gtk4/app"
import Sidebar from "./widgets/Sidebar"
import GLib from "gi://GLib?version=2.0"

const cssPath = GLib.build_filenamev([GLib.get_home_dir(), ".config", "ags", "styles", "sidebar.css"])

app.start({
  css: cssPath,
  main() {
    Sidebar()
  },
})