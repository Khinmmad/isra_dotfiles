import Gtk from "gi://Gtk?version=4.0"
import { createBinding, createComputed } from "gnim"
import Mpris from "gi://AstalMpris"

const mpris = Mpris.get_default()

export default function MusicPlayer() {
  const players = createBinding(mpris, "players")

  const player = createComputed(() => {
    const list = players()
    return list.find((p: any) => p.busName.includes("spotify")) ?? list[0] ?? null
  })

  const title = createComputed(() => player()?.title ?? "Sin reproducción")
  const artist = createComputed(() => player()?.artist ?? "")
  const coverArt = createComputed(() => player()?.coverArt ?? "audio-x-generic")
  const length = createComputed(() => player()?.length ?? 1)
  const position = createComputed(() => player()?.position ?? 0)
  const volume = createComputed(() => player()?.volume ?? 0.5)
  const isPlaying = createComputed(() => player()?.playbackStatus === 0)

  // Re-bind cuando cambia el player activo
  const titleBound = createComputed(() => {
    const p = player()
    if (!p) return "Sin reproducción"
    return createBinding(p, "title")()
  })

  const artistBound = createComputed(() => {
    const p = player()
    if (!p) return ""
    return createBinding(p, "artist")()
  })

  const statusBound = createComputed(() => {
    const p = player()
    if (!p) return 1
    return createBinding(p, "playbackStatus")()
  })

  const positionBound = createComputed(() => {
    const p = player()
    if (!p) return 0
    return createBinding(p, "position")()
  })

  const lengthBound = createComputed(() => {
    const p = player()
    if (!p) return 1
    return createBinding(p, "length")()
  })

  return <box
    cssClasses={["music-player"]}
    orientation={1}
    spacing={8}
    visible={players.as((p: any[]) => p.length > 0)}>

    <box orientation={1} cssClasses={["track-info"]} spacing={2}>
      <label
        cssClasses={["track-title"]}
        label={titleBound}
        ellipsize={3}
        maxWidthChars={28}
      />
      <label
        cssClasses={["track-artist"]}
        label={artistBound}
        ellipsize={3}
        maxWidthChars={28}
      />
    </box>

    <slider
      cssClasses={["progress-bar"]}
      hexpand={true}
      min={0}
      max={lengthBound}
      value={positionBound}
      onChangeValue={(self: any) => {
        const p = player()
        if (p) p.position = self.value
      }}
    />

    <box cssClasses={["controls"]} halign={Gtk.Align.CENTER} spacing={16}>
      <button cssClasses={["ctrl-btn"]} onClicked={() => player()?.previous()}>
        <image iconName="media-skip-backward-symbolic" />
      </button>

      <button cssClasses={["ctrl-btn", "play-pause"]} onClicked={() => player()?.play_pause()}>
        <image iconName={statusBound.as((s: any) =>
          s === 0
            ? "media-playback-pause-symbolic"
            : "media-playback-start-symbolic"
        )} />
      </button>

      <button cssClasses={["ctrl-btn"]} onClicked={() => player()?.next()}>
        <image iconName="media-skip-forward-symbolic" />
      </button>
    </box>

    <box cssClasses={["volume-row"]} spacing={8}>
      <image iconName="audio-volume-medium-symbolic" />
      <slider
        cssClasses={["volume-slider"]}
        hexpand={true}
        min={0}
        max={1}
        value={createComputed(() => {
          const p = player()
          if (!p) return 0.5
          return createBinding(p, "volume")()
        })}
        onChangeValue={(self: any) => {
          const p = player()
          if (p) p.volume = self.value
        }}
      />
    </box>
  </box>
}
