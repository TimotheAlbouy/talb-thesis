#import "../../setup.typ": *

#figure(canvas({
  import draw: *

  let img-folder = "../icon/"
  let w-icon = 1cm

  let x-procs = 3.75
  let y-procs = 1.5

  content(
    (x-procs, y-procs), name: "p1",
    image(img-folder+"male-3.png", width: w-icon),
    frame: "rect", stroke: 0pt, padding: -.3em,
  )
  content(
    (x-procs, 0), name: "p2",
    image(img-folder+"female-2.png", width: w-icon),
    frame: "rect", stroke: 0pt, padding: -.3em,
  )
  content(
    (x-procs, -y-procs), name: "p3",
    image(img-folder+"male-2.png", width: w-icon),
    frame: "rect", stroke: 0pt, padding: -.3em,
  )

  marrow((0, 0), "p1")
  marrow((0, 0), "p2")
  marrow((0, 0), "p3")

  letter((x-procs/2 -.1, y-procs/2))
  letter((x-procs/2 -.1, 0))
  letter((x-procs/2 -.1, -y-procs/2))

  content(
    (0, 0), name: "snd",
    image(img-folder+"female-4.png", width: w-icon),
    frame: "rect", stroke: 0pt, padding: -.3em,
  )

  content(
    (-2.5, 0),
    // box(inset: .3em)[sender],
    [sender],
    frame: "rect", stroke: 0pt, padding: .3em,
    name: "snd-lbl"
  )
  line(
    "snd-lbl", "snd",
    stroke: (dash: "dashed"), mark: (end: "straight")
  )

  content(
    (x-procs+3.5, 0),
    // box(inset: .3em)
    [deliverers],
    frame: "rect", stroke: 0pt, padding: .3em,
    name: "dlv-lbl"
  )
  line(
    "dlv-lbl.north-west", "p1",
    stroke: (dash: "dashed"), mark: (end: "straight")
  )
  line(
    "dlv-lbl", "p2",
    stroke: (dash: "dashed"), mark: (end: "straight")
  )
  line(
    "dlv-lbl.south-west", "p3",
    stroke: (dash: "dashed"), mark: (end: "straight")
  )

  openletter((x-procs + 1.2, y-procs))
  content((x-procs + 1.7, y-procs + .1), $v$)
  openletter((x-procs + 1.2, 0))
  content((x-procs + 1.7, .3), $v$)
  openletter((x-procs + 1.2, -y-procs))
  content((x-procs + 1.7, -y-procs + .1), $v$)
}),

caption: [
  Reliable broadcast guarantees that everyone eventually _delivers_ the same value from the sender, even in the presence of failures (on the sender or other processes)
]
) <fig:rbcast>