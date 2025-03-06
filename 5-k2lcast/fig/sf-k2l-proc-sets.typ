#import "../../setup.typ": *

#canvas({
  import draw: *

  let set-w = 2.1cm
  let set-h = 4cm
  let set-i = .15cm // inter-set gap

  let stroke-w = 1.3pt

  let inner-set-h = (set-h - 4*set-i)/3

  // A SET
  content((0, 0), box(
    stroke: stroke-w, radius: 7pt,
    width: set-w, height: set-h,
    []
  ))
  content((0, -set-h/2 - .5cm), $A$)

  // B SET
  content((set-w + set-i, 0), box(
    stroke: stroke-w, radius: 7pt,
    width: set-w, height: set-h,
    []
  ))
  content((set-w + set-i, -set-h/2 - .5cm), $B$)

  // C SET
  content((2*(set-w + set-i), 0), box(
    stroke: stroke-w, radius: 7pt,
    width: set-w, height: set-h,
    []
  ))
  content((2*(set-w + set-i), -set-h/2 - .5cm), $C$)

  // NB SET
  content(((set-w + set-i)/2, inner-set-h + set-i), box(
    stroke: stroke-w + red,
    inset: 5pt, radius: 7pt,
    width: 2*set-w - set-i,
    height: inner-set-h,
    align(top + left, text(red, $NB$))
  ))

  // F SET
  content(((set-w + set-i)/2, 0), box(
    stroke: stroke-w + blue,
    inset: 5pt, radius: 7pt,
    width: 2*set-w - set-i,
    height: inner-set-h,
    align(top + left, text(blue, $F$))
  ))

  // U SET
  content((set-w + set-i, -inner-set-h - set-i), box(
    stroke: stroke-w + blue,
    inset: 5pt, radius: 7pt,
    width: 3*set-w,
    height: inner-set-h,
    align(top + right, text(blue, $U$))
  ))

  // NF SET
  content(((set-w + set-i)/2 + set-i/2, -inner-set-h - set-i), box(
    stroke: stroke-w + orange,
    inset: 5pt, radius: 7pt,
    width: 2*set-w - 2*set-i,
    height: inner-set-h - 2*set-i,
    align(top + left, text(orange, $NF$))
  ))

  // REMAINING SET
  content((2*(set-w + set-i), (inner-set-h + set-i)/2), box(
    stroke: stroke-w + red,
    inset: 5pt, radius: 7pt,
    width: set-w - 2*set-i,
    height: 2*inner-set-h + set-i,
    align(horizon + center, text(red)[remaining \ correct \ processes])
  ))
  
})