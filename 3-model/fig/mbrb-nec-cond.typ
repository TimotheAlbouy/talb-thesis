#import "../../setup.typ": *

#figure(placement: auto, canvas({
  import draw: *

  let Q1-coord = (-2, 1)
  let Q2-coord = (2, 1)
  let Q3-coord = (0, 3)
  let D1-coord = (-3.5, 3)
  let D2-coord = (3.5, 3)

  // Q1 -> Q2
  let q1-to-q2-y = Q1-coord.at(1) + .4
  decorations.wave(
    line(
      (Q1-coord.at(0), q1-to-q2-y),
      (0, q1-to-q2-y),
      // mark: (end: "straight")
    ),
    amplitude: .2, start: 50%,
    segments: 4
  )
  line(
    (0, q1-to-q2-y), (.4, q1-to-q2-y),
    mark: (end: "straight")
  )
  content((-.3, q1-to-q2-y + .35), $v$)

  // Q2 -> Q1
  let q2-to-q1-y = Q1-coord.at(1) - .4
  decorations.wave(
    line(
      (Q2-coord.at(0), q2-to-q1-y),
      (0, q2-to-q1-y),
      // mark: (end: "straight")
    ),
    amplitude: .2, start: 50%,
    segments: 4
  )
  line(
    (0, q2-to-q1-y), (-.4, q2-to-q1-y),
    mark: (end: "straight")
  )
  content((.3, q2-to-q1-y + .35), $v'$)

  // Q1
  circle(
    Q1-coord, radius: (1, .75),
    fill: white,
    name: "Q1"
  )
  content(Q1-coord, $Q_1$)

  // Q2
  circle(
    Q2-coord, radius: (1, .75),
    fill: white,
    name: "Q2"
  )
  content(Q2-coord, $Q_2$)

  // Q3 (BYZANTINES)
  draw.line(
    (rel: (-.7, 0), to: Q3-coord),
    (rel: (-1.1, 1), to: Q3-coord),
    (rel: (0, .3), to: Q3-coord),
    (rel: (1.1, 1), to: Q3-coord),
    (rel: (.7, 0), to: Q3-coord),
    close: true, fill: red, stroke: maroon
  )
  circle(
    Q3-coord, radius: (1, .75),
    fill: red, stroke: maroon,
    name: "Q3"
  )
  content(Q3-coord, $Q_3$)

  // D1
  circle(
    D1-coord, radius: (1, .75),
    fill: white,
    name: "D1"
  )
  content(D1-coord, $D_1$)

  // D1
  circle(
    D2-coord, radius: (1, .75),
    fill: white,
    name: "D2"
  )
  content(D2-coord, $D_2$)

  // Q3 <-> Q1
  line(
    "Q3", "Q1",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q3-coord.at(0)+Q1-coord.at(0))/2 - .15,
      (Q3-coord.at(1)+Q1-coord.at(1))/2 + .25,
    ),
    $v$
  )

  // Q3 <-> Q2
  line(
    "Q3", "Q2",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q3-coord.at(0)+Q2-coord.at(0))/2 + .15,
      (Q3-coord.at(1)+Q2-coord.at(1))/2 + .25,
    ),
    $v'$
  )

  // Q3 <-> D1
  line(
    "Q3", "D1",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q3-coord.at(0)+D1-coord.at(0))/2,
      (Q3-coord.at(1)+D1-coord.at(1))/2 + .3,
    ),
    $v$
  )

  // Q1 <-> D1
  line(
    "Q1", "D1",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q1-coord.at(0)+D1-coord.at(0))/2 - .3,
      (Q1-coord.at(1)+D1-coord.at(1))/2 - .1,
    ),
    $v$
  )

  // Q3 <-> D2
  line(
    "Q3", "D2",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q3-coord.at(0)+D2-coord.at(0))/2,
      (Q3-coord.at(1)+D2-coord.at(1))/2 + .3,
    ),
    $v'$
  )

  // Q2 <-> D2
  line(
    "Q2", "D2",
    mark: (start: "straight", end: "straight")
  )
  content(
    (
      (Q2-coord.at(0)+D2-coord.at(0))/2 + .3,
      (Q2-coord.at(1)+D2-coord.at(1))/2 - .1,
    ),
    $v'$
  )

  // D1 -> Q2
  let d1-to-q2-end = (
    (Q2-coord.at(0)+1.75*D1-coord.at(0))/2.75,
    (Q2-coord.at(1)+1.75*D1-coord.at(1))/2.75,
  )
  line(
    "D1", d1-to-q2-end,
    mark: (scale: 2, end: (
      stroke: red + 2pt,
      symbol: "x"
    ))
  )
  content(
    (rel: (-.7, .05), to: d1-to-q2-end),
    $v$
  )

  // D2 -> Q2
  let d2-to-q1-end = (
    (Q1-coord.at(0)+1.75*D2-coord.at(0))/2.75,
    (Q1-coord.at(1)+1.75*D2-coord.at(1))/2.75,
  )
  line(
    "D2", d2-to-q1-end,
    mark: (scale: 2, end: (
      stroke: red + 2pt,
      symbol: "x"
    ))
  )
  content(
    (rel: (.7, .05), to: d2-to-q1-end),
    $v'$
  )

  // DELIVER V
  content(
    (-5.5, 1.5),
    // box(inset: 4pt)[mbrb-deliver $v$],
    [mbrb-deliver $v$],
    frame: "rect", stroke: 0pt, padding: 4pt,
    name: "dlv-v"
  )
  line(
    "D1", "dlv-v",
    stroke: (dash: "dashed"),
    mark: (end: "straight")
  )
  line(
    "Q1", "dlv-v",
    stroke: (dash: "dashed"),
    mark: (end: "straight")
  )

  // DELIVER V'
  content(
    (5.5, 1.5),
    // box(inset: 4pt)[mbrb-deliver $v'$],
    [mbrb-deliver $v'$],
    frame: "rect", stroke: 0pt, padding: 4pt,
    name: "dlv-v'"
  )
  line(
    "D2", "dlv-v'",
    stroke: (dash: "dashed"),
    mark: (end: "straight")
  )
  line(
    "Q2", "dlv-v'",
    stroke: (dash: "dashed"),
    mark: (end: "straight")
  )
  
}),

caption: [
  Commmunication between the different sets of processes of execution $E$ leading to a MBRB-No-duplicity violation (the red crosses represent the messages suppressed by the message adversary)
]) <fig:mbrb-nec-cond>