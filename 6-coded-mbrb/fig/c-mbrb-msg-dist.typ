#import "../../setup.typ": *

#figure(placement: auto, canvas({
  import draw: *
  
  let Bsnd-h = 2.5
  let k-1-h = 1.5

  let A-w = 3
  let AB-w = 6

  // axes
  line((0, -.25), (0, Bsnd-h + .5), mark: (end: "straight"))
  content(
    (-2.6, Bsnd-h),
    align(center)[\# received \ $bundlem$]
  )
  line((-.25, 0), (AB-w + .5, 0), mark: (end: "straight"))
  content(
    (AB-w + 1.5, 0),
    align(center)[\# correct \ processes]
  )

  // LEFT BLOCK
  content((-.8, Bsnd-h), $|Bsnd|$)
  line((-.1, Bsnd-h), (A-w, Bsnd-h), (A-w, -.1))
  content((A-w, -.4), $|Bkrcv|$)
  
  // RIGHT BLOCK
  content((-.7, k-1-h), $k-1$)
  line((0, k-1-h), (-.1, k-1-h))
  line((0, k-1-h), (A-w, k-1-h), stroke: (dash: "dashed"))
  line((A-w, k-1-h), (AB-w, k-1-h), (AB-w, -.1))
  content((AB-w, -.4), $|Brcv|$)
  
}), caption: [
  Distribution of distinct $bundlem$ messages received by correct processes; combining @obs:sketch-Brcv-Bsnd-quorums and #c-mbrb-assum shows that $|Bsnd| > k-1$
]) <fig:c-mbrb-msg-dist>

