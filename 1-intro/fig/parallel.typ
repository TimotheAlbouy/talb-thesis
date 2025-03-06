#import "../../setup.typ": *

#figure(canvas({
  let x-offset = 5
  let y-offset = .8

  // BOXES
  
  draw.content(
    (0, 0),
    // mbox(inset: .5em, stroke: 1.5pt, min-width: 2cm)[
    //   #set align(center)
    //   Problem's \ data
    // ],
    align(center)[Problem's \ data],
    frame: "rect", stroke: 1.5pt, padding: .5em,
    name: "input"
  )

  draw.content(
    (x-offset, 1.5*y-offset),
    mbox(inset: .5em, stroke: 1pt, min-width: 2cm)[Worker $1$],
    name: "worker-1"
  )

  draw.content(
    (x-offset, 0),
    text($dots.v$, size: 1.5em)
  )

  draw.content(
    (x-offset, -1.5*y-offset),
    mbox(inset: .5em, stroke: 1pt, min-width: 2cm)[Worker $n$],
    name: "worker-n"
  )

  draw.content(
    (2*x-offset, 0),
    // mbox(inset: .5em, stroke: 1.5pt, min-width: 2cm)[
    //   #set align(center)
    //   Unified \ result
    // ],
    align(center)[Unified \ result],
    frame: "rect", stroke: 1.5pt, padding: .5em,
    name: "output"
  )

  // LEFT ARROWS

  draw.line(
    "input", "worker-1.west",
    mark: (end: "straight")
  )

  draw.line(
    "input", (x-offset - 1, y-offset/2),
    mark: (end: "straight")
  )

  draw.line(
    "input", (x-offset - 1, -y-offset/2),
    mark: (end: "straight")
  )

  draw.line(
    "input", "worker-n.west",
    mark: (end: "straight")
  )

  // RIGHT ARROWS

  draw.line(
    "worker-1.east", "output",
    mark: (end: "straight")
  )

  draw.line(
    (x-offset + 1, y-offset/2), "output",
    mark: (end: "straight")
  )

  draw.line(
    (x-offset + 1, -y-offset/2), "output",
    mark: (end: "straight")
  )

  draw.line(
    "worker-n.east", "output",
    mark: (end: "straight")
  )

  // CHUNKS

  draw.content(
    (x-offset/2, y-offset),
    box(stroke: 1pt, inset: .2em, fill: white)[
      #set align(center)
      #set text(size: .8em)
      in chunk $1$
    ]
  )

  draw.content(
    (x-offset/2, -y-offset),
    box(stroke: 1pt, inset: .2em, fill: white)[
      #set align(center)
      #set text(size: .8em)
      in chunk $n$
    ]
  )

  draw.content(
    (1.5*x-offset, y-offset),
    box(stroke: 1pt, inset: .2em, fill: white)[
      #set align(center)
      #set text(size: .8em)
      out chunk $1$
    ]
  )

  draw.content(
    (1.5*x-offset, -y-offset),
    box(stroke: 1pt, inset: .2em, fill: white)[
      #set align(center)
      #set text(size: .8em)
      out chunk $n$
    ]
  )
  
}), caption: [
  A parallel program strives to divide the problem into several independent chunks processed in parallel by multiple workers and reassembled in a unified result
]) <fig:parallel>