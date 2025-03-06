// cetz-setup.typ, version 0.0.2

#import "@preview/cetz:0.3.3": canvas, draw, decorations, coordinate, vector

#let marrow(from, to) = draw.line(
  from, to,
  mark: (end: ">", scale: 1.5, fill: black),
  stroke: 1pt
)

#let letter(coord) = {
  let letter-hw = .25  // letter half height
  let letter-hh = .18  // letter half width
  let stroke = 1pt
  draw.rect(
    (rel: (-letter-hw, -letter-hh), to: coord),
    (rel: (letter-hw, letter-hh), to: coord),
    fill: white, stroke: stroke
  )
  draw.line(
    (rel: (-letter-hw, letter-hh), to: coord),
    coord,
    (rel: (letter-hw, letter-hh), to: coord),
    stroke: stroke
  )
}

#let openletter(coord) = {
  let letter-hw = .25  // letter half height
  let letter-hh = .18  // letter half width
  draw.line(
    (rel: (-letter-hw, letter-hh), to: coord),
    (rel: (0, 2*letter-hh), to: coord),
    (rel: (letter-hw, letter-hh), to: coord),
    (rel: (letter-hw, -letter-hh), to: coord),
    (rel: (-letter-hw, -letter-hh), to: coord),
    close: true, fill: white, stroke: 1pt
  )
  draw.line(
    (rel: (-letter-hw, letter-hh), to: coord),
    coord,
    (rel: (letter-hw, letter-hh), to: coord),
    close: true, fill: gray, stroke: .5pt
  )
}

#let proc(coord, name) = {
  let circle-r = .4  // circle radius
  let stroke = 2pt
  let color = gray
  draw.circle(
    coord, radius: circle-r, name: name,
    fill: color, stroke: stroke
  )
}

#let byz(coord, name) = {
  let circle-r = .4  // circle radius
  let stroke = 2pt + maroon //rgb("#FA0000")
  let color = red //rgb("#FA0303")
  // horns
  draw.line(
    (rel: (-2*circle-r/3, 0), to: coord),
    (rel: (-1.2*circle-r, 1.2*circle-r), to: coord),
    (rel: (0, circle-r/3), to: coord),
    (rel: (1.2*circle-r, 1.2*circle-r), to: coord),
    (rel: (2*circle-r/3, 0), to: coord),
    close: true, fill: color, stroke: stroke
  )
  // head
  draw.circle(
    coord, radius: circle-r, name: name,
    fill: color, stroke: stroke
  )
}

#let MA(coord, name) = {
  let circle-r = .8  // circle radius
  let stroke = 2pt + eastern
  let color = aqua
  // horns
  draw.line(
    (rel: (-2*circle-r/3, 0), to: coord),
    (rel: (-1.2*circle-r, 1.2*circle-r), to: coord),
    (rel: (0, circle-r/3), to: coord),
    (rel: (1.2*circle-r, 1.2*circle-r), to: coord),
    (rel: (2*circle-r/3, 0), to: coord),
    close: true, fill: color, stroke: stroke
  )
  // head
  draw.circle(
    coord, radius: circle-r, name: name,
    fill: color, stroke: stroke
  )
  // text
  draw.content(coord, text(eastern)[MA])
}

#let cross(coord) = {
  let offset = .2
  let stroke = 4pt + eastern
  draw.line(
    (rel: (-offset, offset), to: coord),
    (rel: (offset, -offset), to: coord),
    stroke: stroke
  )
  draw.line(
    (rel: (-offset, -offset), to: coord),
    (rel: (offset, offset), to: coord),
    stroke: stroke
  )
}

#let ledger-state(coord, bal1, bal2, sn1, sn2) = {
  import "../setup.typ": bal, sn

  let var-x = -1.5
  let pi-x = -.5
  let pj-x = .5

  let p-y = 1.5
  let bal-y = .5
  let sn-y = -.5
  
  draw.content((rel: (pi-x, p-y), to: coord), $p_i$)
  draw.content((rel: (pj-x, p-y), to: coord), $p_j$)

  draw.line(
    (rel: (var-x -.5, p-y -.6), to: coord),
    (rel: (pj-x +.5, p-y -.6), to: coord),
    stroke: txt-color
  )
    
  draw.content((rel: (var-x, bal-y), to: coord), $bal$)
  draw.content((rel: (pi-x, bal-y), to: coord), bal1)
  draw.content((rel: (pj-x, bal-y), to: coord), bal2)

  draw.content((rel: (var-x, sn-y), to: coord), $sn$)
  draw.content((rel: (pi-x, sn-y), to: coord), sn1)
  draw.content((rel: (pj-x, sn-y), to: coord), sn2)
}

#let callout(pos, txt, name, ptr-pos, color, ptr-side, txt-size) = {
  let stroke-width = 1.5pt
  let hw-ptr = .2
  
  draw.content(
    pos, [#text(txt, color, size: txt-size)], frame: "rect",
    name: name, stroke: color + stroke-width, padding: 5pt
  )
  draw.get-ctx(ctx => {
    let (x, y, ..) = pos
    // let bl = coordinate.resolve(ctx, name+".bottom-left")
    // let tr = coordinate.resolve(ctx, name+".top-right")
    let bl = coordinate.resolve-anchor(ctx, name+".south-west")
    let tr = coordinate.resolve-anchor(ctx, name+".north-east")
    let (width, height, ..) = vector.sub(tr, bl)
    let truc = width

    let ptr-corner-1 = (0, 0)
    let ptr-corner-2 = (0, 0)
    if ptr-side == "top" {
      ptr-corner-1 = (x - hw-ptr, y + height/2)
      ptr-corner-2 = (x + hw-ptr, y + height/2)
    } else if ptr-side == "right" {
      ptr-corner-1 = (x + width/2, y + hw-ptr)
      ptr-corner-2 = (x + width/2, y - hw-ptr)
    } else if ptr-side == "bottom" {
      ptr-corner-1 = (x - hw-ptr, y - height/2)
      ptr-corner-2 = (x + hw-ptr, y - height/2)
    } else if ptr-side == "left" {
      ptr-corner-1 = (x - width/2, y + hw-ptr)
      ptr-corner-2 = (x - width/2, y - hw-ptr)
    }

    draw.line(
      ptr-corner-1, ptr-pos, ptr-corner-2,
      stroke: color + stroke-width
    )
  })
}

// #let mbox(content, min-width: none, min-height: none, ..args) = context {
//   let normal-box = box(content, ..args)
//   // width
//   let width = measure(normal-box).width
//   if min-width != none {
//     width = calc.max(min-width.to-absolute(), width)
//   }
//   // height
//   let height = measure(normal-box).height
//   if min-height != none {
//     width = calc.max(min-width.to-absolute(), height)
//   }
//   // return
//   return box(width: width, height: height, content, ..args)
// }
