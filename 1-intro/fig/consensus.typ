#import "../../setup.typ": *

#figure(placement: auto, canvas({
  import draw: *

  let img-folder = "../icon/"
  let hw-offset = 4
  let w-icon = 1cm
  let coeff = 1
  let txt-size = .8em

  let coffee-color = rgb("#C04F17")
  let tea-color = rgb("#C6DC67")
  
  // LEFT SIDE

  content(
    name: "1b", (-1.5*coeff - hw-offset, 0),
    image(img-folder+"female-4.png", width: w-icon)
    // text(w-icon)[👩🏾‍🦱]
  )
  content(
    (-hw-offset, coeff), name: "2b",
    image(img-folder+"male-2.png", width: w-icon)
    // text(w-icon)[👨🏻]
  )
  content(
    (1.5*coeff - hw-offset, 0), name: "3b",
    image(img-folder+"female-3.png", width: w-icon)
    // text(w-icon)[👩🏽]
  )
  content(
    (coeff - hw-offset, -1.5*coeff), name: "4b",
    image(img-folder+"male-4.png", width: w-icon)
    // text(w-icon)[👨🏿‍🦱]
  )
  content(
    (-coeff - hw-offset, -1.5*coeff), name: "5b",
    image(img-folder+"female-1.png", width: w-icon)
    // text(w-icon)[👩🏻‍🦰]
  )

  callout(
    (-1.5*coeff - hw-offset, coeff +.1), "COFFEE", "c1b",
    (-1.5*coeff - hw-offset, .6), coffee-color, "bottom", txt-size
  )
  callout(
    (1.6 - hw-offset, coeff), "COFFEE", "c2b",
    "2b.east", coffee-color, "left", txt-size
  )
  callout(
    (1.5*coeff + 1.3 - hw-offset, 0), "TEA", "c3b",
    "3b.east", tea-color, "left", txt-size
  )
  callout(
    (coeff + 1.6 - hw-offset, -1.5*coeff), "COFFEE", "c4b",
    "4b.east", coffee-color, "left", txt-size
  )
  callout(
    (-coeff - 1.3 - hw-offset, -1.5*coeff), "TEA", "c4b",
    "5b.west", tea-color, "right", txt-size
  )

  // MIDDLE ARROW

  let len-arrow = 1.6
  let x-offset-arrow = .7
  line(
    (-len-arrow/2 + x-offset-arrow, -.5),
    (len-arrow/2 + x-offset-arrow, -.5),
    mark: (end: ">", size: .4), stroke: 7pt + black
  )

  // RIGHT SIDE

  content(
    (-1.5*coeff + hw-offset, 0), name: "1a",
    image(img-folder+"female-4.png", width: w-icon)
  )
  content(
    (hw-offset, coeff), name: "2a",
    image(img-folder+"male-2.png", width: w-icon)
  )
  content(
    (1.5*coeff + hw-offset, 0), name: "3a",
    image(img-folder+"female-3.png", width: w-icon)
  )
  content(
    (coeff + hw-offset, -1.5*coeff), name: "4a",
    image(img-folder+"male-4.png", width: w-icon)
  )
  content(
    (-coeff + hw-offset, -1.5*coeff), name: "5a",
    image(img-folder+"female-1.png", width: w-icon)
  )

  content(
    (hw-offset, -.8),
    image(img-folder+"handshake.png", width: w-icon)
  )
  content(
    (hw-offset, -.2), text([COFFEE],
    coffee-color, size: txt-size)
  )
  
}), caption: [
  In consensus, all participants can propose a value, and everyone eventually decides one of the proposed values (here, the majority rule is used)
]) <fig:consensus>