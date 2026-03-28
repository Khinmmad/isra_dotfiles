import app from "ags/gtk4/app"
import GLib from "gi://GLib?version=2.0"
import Sidebar from "./widgets/Sidebar"
import Bar from "./widgets/Bar"

const home = GLib.get_home_dir()
const css = (f: string) => GLib.build_filenamev([home, ".config", "ags", "styles", f])

app.start({
  css: css("sidebar.css"),
  main() {
    app.apply_css(css("bar.css"), false)
    Sidebar()
    Bar()
  },
})
