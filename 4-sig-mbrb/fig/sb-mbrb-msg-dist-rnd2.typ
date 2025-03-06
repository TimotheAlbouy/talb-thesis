#import "../../setup.typ": *

#let r2-color = orange
#let r3-color = green
#let r4-color = blue

#figure(canvas({
  import draw: *
  
  let A-h = 2.5
  let B-h = 1.5

  let A-w = 3
  let AB-w = 6

  // axes
  line((0, -.25), (0, A-h + .5), mark: (end: "straight"))
  content(
    (-1.8, A-h),
    align(center)[\# received \ signatures]
  )
  line((-.25, 0), (AB-w + .5, 0), mark: (end: "straight"))
  content(
    (AB-w + 1.5, 0),
    align(center)[\# correct \ processes]
  )

  // A SET
  content((-.4, A-h), $ell_1$)
  line((-.1, A-h), (A-w, A-h), (A-w, -.1))
  content((A-w, -.4), $a$)
  decorations.brace(
    (A-w - .1, -.1),
    (.1, -.1),
    stroke: 1pt, amplitude: .2
  )
  content((A-w/2, -.65), $A$)
  content((A-w/2, A-h/2), $s_A$)
  
  // B SET
  content((-1.15, B-h), $floor((n+t)/2) = q$)
  line((0, B-h), (-.1, B-h))
  line((0, B-h), (A-w, B-h), stroke: (dash: "dashed"))
  line((A-w, B-h), (AB-w, B-h), (AB-w, -.1))
  content((AB-w, -.4), $c$)
  decorations.brace(
    (AB-w - .1, -.1),
    (A-w + .1, -.1),
    stroke: 1pt, amplitude: .2
  )
  content(((AB-w + A-w)/2, -.65), $B$)
  content(((AB-w + A-w)/2, B-h/2), $s_B$)
  
}),

caption: [
  Distribution of signatures among processes of $A$ and $B$ two rounds after $p_i$ mbrb-broadcast $(v,sn)$
]) <fig:sb-mbrb-msg-dist-rnd2>

