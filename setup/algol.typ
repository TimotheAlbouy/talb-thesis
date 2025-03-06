// algol.typ, version 0.0.2

#let _algol-block-is-unfinished = state(
  "_algol-block-is-unfinished", false
)
#let _algol-line-nb = counter("_algol-line-nb")
#let _algol-indent = state("_algol-indent", 0)

// function for setting the type of code block (unfinished or finished)
#let u(unfinished) = {
  _algol-block-is-unfinished.update(unfinished)
}

// enable line references
#let enable-line-ref(doc, line-numbering: "1") = {
  show ref: it => {
    let lb = it.target
    // line references must start with "line:"
    if str(lb).starts-with("line:") {
      // if line numbering is enabled
      if line-numbering != none {
        // format the line number
        let line-nb = link(lb, numbering(
          line-numbering,
          _algol-line-nb.at(lb).first()
        ))
        // if no supplement is provided
        if it.supplement == auto { [line~#line-nb] }
        // else, if the supplement is empty content
        else if it.supplement == [] { [#line-nb] }
        // else, if a nonempty supplement is provided
        else { [#it.supplement~#line-nb] }
      }
    } else { it }
  }

  doc
}

#let algol(
  body,
  boxed: true,
  line-numbering: it => text(size: .8em)[*#it*],
  indent-size: 1.3em,
  guide-style: .5pt + black
) = context box(
  inset: (left: .4em, right: .7em, top: 1.2em, bottom: .5em),
  stroke: if boxed { .5pt } else { 0pt },
{
  set align(left)

  _algol-line-nb.update(0)
  _algol-indent.update(0)

  let line-nb-box-width = if line-numbering != none {
    let actual-digits-width = measure(numbering(
      line-numbering,
      _algol-line-nb.final().first()
    )).width
    let ten-width = measure(numbering(
      line-numbering,10
    )).width
    calc.max(actual-digits-width, ten-width)
  } else { 0 }
  
  set list(
    indent: indent-size,
    marker: _algol-line-nb.step() + context {
      if line-numbering == none { return }
      let indent-level = _algol-indent.get()
      place(left,
        dx: indent-level * (-indent-size -.1em) + .4em,
        box(width: line-nb-box-width, height: .67em, align(
          right + bottom, _algol-line-nb.display(line-numbering)
        ))
      )
    }
  )

  show list: it => context {
    _algol-indent.update(n => n + 1)
    
    // _algol-block-is-unfinished.update(false)
    let unfinished = _algol-block-is-unfinished.get()
    let outset = (left: -.5em, top: .9em, bottom: .1em)
    let inset = (left: -.4em, top: -.8em, bottom: .3em)
    if unfinished {
      outset.bottom = .4em
      inset.bottom = -.2em
    }
    // code blocks of indentation level 0 do not have vertical guides
    let stroke = if _algol-indent.get() > 0 { guide-style } else { 0pt }
    block(
      stroke: (left: stroke), outset: outset, inset: inset, {
        it
        if not unfinished {
          let hook-length = .4em
          place(
            dx: -inset.left - outset.left,
            dy: inset.bottom + outset.bottom - guide-style.thickness/2,
            line(length: hook-length, stroke: stroke)
          )
        }
      },
    )

    _algol-indent.update(n => n - 1)
  }

  body
})

