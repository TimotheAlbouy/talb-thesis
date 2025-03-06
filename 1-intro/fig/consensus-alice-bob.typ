#import "../../setup.typ": *

#figure(canvas({
  import draw: *

  let img-folder = "../icon/"
  let hw-offset = 4
  let w-icon = 1cm
  let coeff = 1
  let txt-size = .8em

  // SLOW MESSAGE
  decorations.wave(
    line(
      (-5, 0),
      (-2.7, 0),
      // mark: (end: "straight")
    ),
    amplitude: .2, start: 50%,
    segments: 4
  )
  line(
    (-2.7, 0), (-2.3, 0),
    mark: (end: "straight")
  )
  content(
    (-5, 0), name: "alice1",
    image(img-folder+"female-4.png", width: w-icon)
  )
  content(
    (-1.5, 0), name: "bob1",
    image(img-folder+"male-2.png", width: w-icon)
  )
  letter((-4.3, 0))

  // EQUIV
  content((0, 0), text(size: 1.8em, $eq.triple$))

  // CRASH
  line(
    (1.5, 0), (2.75, 0),
    mark: (
      scale: 2,
      end: (symbol: "x", stroke: red + 2pt)
    )
  )
  content(
    (1.5, 0), name: "alice2",
    image(img-folder+"female-4.png", width: w-icon)
  )
  content(
    (1.5, 0), name: "explo",
    image(img-folder+"explosion.png", width: w-icon - .2cm)
  )
  content(
    (5, 0), name: "bob2",
    image(img-folder+"male-2.png", width: w-icon)
  )
  
}), caption: [
  From Bob's point of view, the case where Alice sent a slow message and the case where Alice crashed are indistinguishable in an asynchronous system
]) <fig:consensus-alice-bob>