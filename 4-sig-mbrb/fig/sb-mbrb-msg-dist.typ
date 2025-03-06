#import "../../setup.typ": *

#let r2-color = orange
#let r3-color = green
#let r4-color = blue

#figure(placement: auto, canvas({
  let scale = .1
  
  // model parameters
  let n = 100
  let t = 10
  let d = 34
  let q = calc.floor((n + t)/2)
  
  // worst case
  let c = n - t
  let l1 = c - d
  let l4 = c

  // free execution parameters
  let l2 = 70
  let l3 = 82

  // averages of #msgs received by L2 by the end of round 2/3/4, resp.
  let avg2 = (l1 * (c - d)) / l2
  let avg3 = avg2 + ((l2 - l1) * (c - d - l3 + l2)) / l2
  let avg4 = avg3 + ((l3 - l2) * (c - d - l4 + l2)) / l2

  // round 4
  draw.rect(
    (0, avg3*scale), (l2*scale, avg4*scale),
    stroke: 0pt, fill: r4-color.lighten(80%)
  )
  draw.line(
    (-.2, avg4*scale), (l2*scale, avg4*scale), (l2*scale, avg3*scale),
    stroke: r4-color
  )
  draw.content((-.7, avg4*scale), text(r4-color)[$avg_4$])
  draw.rect(
    (l2*scale, (l2 - l1)*scale), (l3*scale, (l3 - l1)*scale),
    stroke: 0pt, fill: r4-color.lighten(80%)
  )
  draw.line(
    (l2*scale, (l3 - l1)*scale), (l3*scale, (l3 - l1)*scale), (l3*scale, (l2 - l1)*scale),
    stroke: r4-color
  )
  draw.rect(
    (l3*scale, 0), (l4*scale, (l3 - l2)*scale),
    stroke: 0pt, fill: r4-color.lighten(80%)
  )
  draw.line(
    (l3*scale, (l3 - l2)*scale), (l4*scale, (l3 - l2)*scale), (l4*scale, -.2),
    stroke: r4-color
  )
  draw.content((l4*scale, -.4), text(r4-color)[$ell_4$])

  // round 3
  draw.rect(
    (0, avg2*scale), (l2*scale, avg3*scale),
    stroke: 0pt, fill: r3-color.lighten(80%)
  )
  draw.line(
    (-.2, avg3*scale), (l2*scale, avg3*scale), (l2*scale, avg2*scale),
    stroke: r3-color
  )
  draw.content((-.7, avg3*scale), text(r3-color)[$avg_3$])
  draw.rect(
    (l2*scale, 0), (l3*scale, (l2 - l1)*scale),
    stroke: 0pt, fill: r3-color.lighten(80%)
  )
  draw.line(
    (l2*scale, (l2 - l1)*scale), (l3*scale, (l2 - l1)*scale), (l3*scale, -.2),
    stroke: r3-color
  )
  draw.content((l3*scale, -.4), text(r3-color)[$ell_3$])

  // round 2
  draw.rect(
    (0, 0), (l2*scale, avg2*scale),
    stroke: 0pt, fill: r2-color.lighten(80%)
  )
  draw.line(
    (-.2, avg2*scale), (l2*scale, avg2*scale), (l2*scale, -.2),
    stroke: r2-color
  )
  draw.content((-.7, avg2*scale), text(r2-color)[$avg_2$])
  draw.content((l2*scale, -.4), text(r2-color)[$ell_2$])

  // axes
  draw.line((0, -.25), (0, avg4*scale + 1.5), mark: (end: "straight"))
  draw.content(
    (-1.3, avg4*scale + 1),
    align(center)[\# received \ signatures]
  )
  draw.line((-.25, 0), (n*scale + .5, 0), mark: (end: "straight"))
  draw.content(
    (n*scale + 1.8, 0),
    align(center)[\# processes]
  )
  draw.line((l1*scale, .2), (l1*scale, -.2))
  draw.content((l1*scale, -.4), $ell_1$)
  draw.line((n*scale, .2), (n*scale, -.2))
  draw.content((n*scale, -.4), $n$)

  // quorum threshold
  draw.line(
    (-1.3, q*scale), (n*scale -1, q*scale),
    stroke: (dash: "dashed")
  )
  draw.content((-1.6, q*scale))[$q$]

  // parameters box
  draw.content(
    (n*scale, avg4*scale - .7),
    box(
      inset: (top: .9em, left: .5em, right: .5em, bottom: .5em), stroke: 1pt, fill: white
    )[
      $n &= #n,
      t = #t,
      d = #d, \
      c &= n sm t = #(n - t), \
      q &= floor((n+t)/2) = #q, \
      ell_1 &= c sm d = #(c - d),
      text(#r2-color, ell_2 = #l2), \
      text(#r3-color, ell_3 &= #l3),
      text(#r4-color, ell_4 = c = #c).$
    ]
  )

  // rectangle areas
  // draw.content(
  //   (l2/2*scale, avg2/2*scale),
  //   text(r2-color)[$ell_1(c-d)$]
  // )
  // draw.content(
  //   (l2/2*scale, (avg3+avg2)/2*scale),
  //   text(r3-color)[$(ell_2-ell_1)(c-d) - $]
  // )
  // draw.content(
  //   (l3*scale + 2, (l2 - l1)*scale + .8),
  //   text(r3-color)[$(ell_2 - ell_1)(ell_3 - ell_2)$]
  // )

}),

caption: [
  Worst-case distribution of signatures received by correct processes ($n=100$), after a $mbrbbroadcast()$ execution by a correct process, at the end of rounds 2 (in orange), 3 (in green), and 4 (in blue)
  // (#text(r2-color, "in orange"))
  // (#text(r3-color, "in green"))
  // (#text(r4-color, "in blue"))
  // The chosen values of the different variables are given in the box.
]) <fig:sb-mbrb-msg-dist>

