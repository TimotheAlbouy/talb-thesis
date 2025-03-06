#import "../../setup.typ": *

#canvas({
  import draw: *
  
  let A-h = 3.1
  let B-h = 2
  let C-h = 1.2

  let A-w = 1.5
  let AB-w = 3
  let ABC-w = 4.5

  // AXES
  line((0, -.25), (0, A-h + 1.4), mark: (end: "straight"))
  content(
    (-1, A-h + 1),
    align(center)[\# msgs \ received]
  )
  line((-.25, 0), (ABC-w + .5, 0), mark: (end: "straight"))
  content(
    (ABC-w + 1.1, .1),
    align(center)[\# corr. \ procs]
  )

  // A SET
  content((-1, A-h), $k_U sp k_F$)
  line((-.2, A-h), (A-w, A-h), (A-w, -.2))
  content((A-w, -.4), $ell_e$)
  decorations.brace(
    (A-w - .1, -.1),
    (.1, -.1),
    stroke: 1pt, amplitude: .2
  )
  content((A-w/2, -.65), $A$)
  content((A-w/2, A-h/2), $w_A^c$)

  // B SET
  content((-.8, B-h), $q_d sm 1$)
  line((-.2, B-h), (0, B-h))
  line((0, B-h), (A-w, B-h), stroke: (dash: "dashed"))
  line((A-w, B-h), (AB-w, B-h), (AB-w, 0))
  line((AB-w, 0), (AB-w, -1), stroke: (dash: "dashed"))
  content((AB-w, -1.1), $k_F sp k_NF sp k_NB$)
  decorations.brace(
    (AB-w - .1, -.1),
    (A-w + .1, -.1),
    stroke: 1pt, amplitude: .2
  )
  content(((A-w + AB-w)/2, -.65), $B$)
  content(((A-w + AB-w)/2, B-h/2), $w_B^c$)

  // C SET
  content((-.8, C-h), $q_f sm 1$)
  line((-.2, C-h), (0, C-h))
  line((0, C-h), (AB-w, C-h), stroke: (dash: "dashed"))
  line((AB-w, C-h), (ABC-w, C-h), (ABC-w, -.2))
  content((ABC-w, -.4), $c$)
  decorations.brace(
    (ABC-w - .1, -.1),
    (AB-w + .1, -.1),
    stroke: 1pt, amplitude: .2
  )
  content(((ABC-w + AB-w)/2, -.65), $C$)
  content(((AB-w + ABC-w)/2, C-h/2), $w_C^c$)

})

