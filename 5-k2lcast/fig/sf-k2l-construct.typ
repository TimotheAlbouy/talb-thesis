#import "../../setup.typ": *

#figure(canvas({
  import draw: *

  let y-offset = 2.6
  let min-w = 8.5em

  // BOXES

  content(
    (0, 2*y-offset), name: "sys",
    // mbox(stroke: .5pt, inset: 5pt, min-width: min-w)[
    //   #set align(center)
    //   Underlying system \
    //   $angle.l n,t,d,c angle.r$
    // ],
    align(center)[Underlying system \ $angle.l n,t,d,c angle.r$],
    frame: "rect", stroke: .5pt,
    padding: (top: 4pt, left: 5pt, right: 5pt)
  )

  content(
    (0, y-offset), name: "impl",
    // mbox(stroke: .5pt, inset: 5pt, min-width: min-w)[
    //   #set align(center)
    //   Implementation \
    //   $angle.l q_d,q_f,single angle.r$
    // ],
    align(center)[Implementation \ $angle.l q_d,q_f,single angle.r$],
    frame: "rect", stroke: .5pt,
    padding: (top: 4pt, left: 11pt, right: 11pt)
  )

  content(
    (0, 0), name: "obj",
    // mbox(stroke: .5pt, inset: 5pt, min-width: min-w)[
    //   #set align(center)
    //   $k2l$-cast object \
    //   $angle.l k',k,ell,nodpty angle.r$
    // ],
    align(center)[$k2l$-cast object \ $angle.l k',k,ell,nodpty angle.r$],
    frame: "rect", stroke: .5pt,
    padding: (top: 4pt, left: 13pt, right: 13pt)
  )

  // ARROWS

  draw.line(
    "sys.south", "impl",
    mark: (end: "straight")
  )

  draw.line(
    "impl", "obj",
    mark: (end: "straight")
  )

  // TRANSITIONS

  content(
    (0, 1.5*y-offset),
    box(
      stroke: .5pt, inset: 4pt,
      fill: white, radius: 7pt,
      [sf-$k2l$-Assumps. 1-4]
    )
  )

  content(
    (0, y-offset/2),
    box(
      stroke: .5pt, inset: 4pt,
      fill: white, radius: 7pt,
      [@th:sf-k2l-correctness]
    )
  )
  
}), caption: [
  From the system parameters to a $k2l$-cast implementation
]) <fig:sf-k2l-construct>
