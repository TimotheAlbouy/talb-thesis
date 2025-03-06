#import "@preview/hydra:0.6.0": hydra

#import "cover-bg.typ": cover-bg
#import "abstracts-bg.typ": abstracts-bg

#let school-color-recto = blue
#let school-color-verso = rgb("0054a0")

// workaround for: https://github.com/typst/typst/issues/466
#let balanced-cols(n-cols, gutter: 11pt, body) = layout(bounds => context {
  // Measure the height of the container of the text if it was single 
  // column, full width
  let text-height = measure(box(
    width: (bounds.width - (n-cols - 1) *  gutter) / n-cols,
    body
  )).height

  // Recompute the height of the new container. Add a few points to avoid the 
  // second column being longer than the first one
  let balanced-height = text-height/n-cols + text.size/2

  box(
    height: balanced-height, 
    columns(n-cols, gutter: gutter, body)
  )
})

#let cover(
  title-en: "",
  title-fr: "",
  author: "",
  affiliation: "",
  defense-place: "",
  defense-date: "",
  jury-content: []
) = {
  set page(
    // custom margins
    margin: (left: 20mm, right: 20mm, top: 30mm, bottom: 30mm),
    // original margins
    // margin: (left: 20mm, right: 20mm, top: 30mm, bottom: 30mm),
    header: none,
    numbering: none,
    background: image("assets/cover-bg.svg")
  )
  set text(font: "TeX Gyre Heros", fill: black)

  // let normal-size = 1.2em
  
  // place(dx: -20mm, dy: -50mm, image("./assets/image-fond-garde.png", width: 21cm))
  // place(dx: -20mm, dy: 30mm, cover-bg(school-color-recto))
  place(dx: 110mm, dy: -15mm, image("./assets/UR.png", width: 6cm))
  place(dx: 0mm, dy: -15mm, image("assets/logo.png", width: 7.5cm))

  v(2.1cm)
  text(size: 2em, smallcaps[Thèse de doctorat de])
  v(2.25cm)
  
  set text(fill: white)
  text(size: 1.5em, smallcaps[l'Université de Rennes])
  v(.01cm)
  text(size: 1.2em)[
    #smallcaps[École Doctorale N° 601] \
    _Mathématiques, Télécommunications, Informatique, \
    Signal, Systèmes, Électronique_ \
    Spécialité : _Informatique_ \
    #v(.1cm) #h(.6cm) Par \
  ]
  
  // Add a blue background with the width of the page
  context { 
    let y-start = locate(<cover:title-en>).position().y - 1cm
    let y-end = locate(<cover:defense-info>).position().y + measure(query(<cover:defense-info>).first()).height + .5cm
    let height = 5em

    place(
      top + left, float: false,
      dy: y-start - page.margin.top,
      dx: -page.margin.left,
      block(
        width: page.width,
        height: y-end - y-start,
        fill: school-color-recto
      )
    )
  }

  // Author name
  v(0em)
  h(.6cm)
  text(size: 1.9em)[*#author* \ ]
  v(.1cm)
  
  // Title + defense info block
  text(size: 1.6em)[*#title-en* <cover:title-en>]
  parbreak()
  text(size: 1.4em, title-fr)
  parbreak()
  
  text(size: 1.1em)[
    *Thèse présentée et soutenue à #defense-place, le #defense-date* \
    *Unité de recherche : #affiliation*
    <cover:defense-info>
  ]


  set text(fill: black)
  
  v(.5em)
  jury-content
  
  pagebreak()
  set page(background: none)
  // pagebreak()
}

#let abstracts(
  title-fr: "", keywords-fr: "", abstract-fr: [],
  title-en: "", keywords-en: "", abstract-en: [],
) = {

  set page(
    numbering: none,
    header: none,
  )

  pagebreak()
  pagebreak(to: "even")

  set page(
    margin: (
      left: 20mm, right: 30mm,
      top: 30mm, bottom: 30mm
    ),
    background: image("assets/abstracts-bg.svg")
  )
  set text(font: "TeX Gyre Heros", fill: black)
  
  // place(dx: -20mm, dy: -65mm, abstracts-bg(school-color-verso))
  place(dx: 100mm, dy: -15mm, image("./assets/UR.png", width: 6cm))
  place(dx: 0mm, dy: -15mm, image("assets/logo.png", width: 7.5cm))

  v(2cm)
  line(length: 100%, stroke: .2cm + school-color-verso)
  v(.4cm)

  [
    #show linebreak: none
    #text(school-color-verso)[*Titre :*] #title-fr
  ]
  
  [

    *Mots clés :* #keywords-fr
  ]

  balanced-cols(2,gutter: 11pt)[*Résumé :* #abstract-fr]

  v(1cm)
  line(length: 100%, stroke: .2cm + school-color-verso)
  v(.4cm)

  [
    #show linebreak: none
    #text(school-color-verso)[*Title:*] #title-en
  ]

  [
    
    *Keywords:* #keywords-en
  ]

  balanced-cols(2, gutter: 11pt)[*Abstract:* #abstract-en]
}

#let matisse-thesis(
  jury-content: [],
  author: "",
  affiliation: "",
  title-en: "",
  title-fr: "",
  keywords-fr: "",
  keywords-en: "",
  abstract-en: [],
  abstract-fr: [],
  acknowledgements: [],
  defense-place: "",
  defense-date: "",
  draft: true,
  body,
) = {
  
  // ------------ GENERAL SETTINGS ------------ //
  
  let draft-string = ""
  if draft { draft-string = "DRAFT - " }
  set document(
    author: author,
    title: draft-string + title-en
  )
  set par(justify: true)
  set text(font: "New Computer Modern", fill: black, lang: "en")
  
  // ------------ PAGE ------------ //
  
  set page("a4",
    // ------------ GENERAL ------------ //
    margin: (outside: 20mm, inside: 30mm, top: 50mm, bottom: 50mm),
    // ------------ PAGE NUMBER ------------ //
    // numbering: (..numbers) => text(
    //   font: "New Computer Modern", size: 4.5mm,
    //   numbering("1", numbers.pos().at(0))
    // ),
    numbering: "1",
    number-align: center,
    // ------------ HEADER ------------ //
    header: context {
      // disable linebreaks in header
      show linebreak: none
      
      // get the current page number
      let current-page = here().page()
      // let current-page = counter(page).get().first()
      
      // if the page starts a level-1 heading, display nothing
      let all-lvl1 = query(heading.where(level: 1))
      if all-lvl1.any(it => it.location().page() == current-page) {
        return
      }
        
      // if the page is odd
      if calc.odd(current-page) {
        // display the last level-1 heading
        let header-content = hydra(1,
          display: (_, it) => {
            if it.numbering != none {
              let nb = counter(heading).at(it.location())
              let nb-fmt = numbering(it.numbering, ..nb)
              [#it.supplement #nb-fmt -- _ #it.body _]
            } else { emph(it.body) }
          }
        )
        text(0.35cm, header-content)
      }

      // if the page is even
      else {
        // display last level-2 heading (current page included)
        let header-content = hydra(2, use-last: true,
          display: (_, it) => {
            if it.numbering == none [_ #it.body _]
            else {
              let nb = counter(heading).at(it.location())
              let nb-fmt = numbering(
                it.numbering.replace(" ", "."),
                ..nb
              )
              [_ #nb-fmt #it.body _]
            }
          }
        )
        align(right, text(0.35cm, header-content))
      }

      // horizontal rule
      v(-.3cm)
      line(length: 100%, stroke: .2mm)
    }
  )

  // ------------ HEADINGS ------------ //
  
  // for the thesis' body:
  // 1. headings are normally numbered
  // (there is a small space after the last number)
  set heading(numbering: "1.1 ")
  // 2. level-1 headings are called chapters
  show heading.where(level: 1): set heading(supplement: [Chapter])
  
  // for level-1 headings
  show heading.where(level: 1): it => context {
    // always start on odd pages
    pagebreak(to: "odd")
    set align(right)
    v(-.8cm)
    // if numbering is enabled, display level-1 heading number
    if it.numbering != none {
      let sec-nb = counter(heading).get().first()
      let fmt-nb = numbering(heading.numbering, sec-nb)
      text(
        smallcaps[#heading.supplement #fmt-nb \ ],
        size: .45cm, weight: "regular", font: "New Computer Modern",
      )
      v(0cm)
    }
    // level-1 heading name
    text(smallcaps(it.body), font: "TeX Gyre Heros", size: .9cm)
    set align(left)
    // horizontal rule
    v(.7cm)
    line(length: 100%, stroke: .2mm)
    v(.7cm)
  }

  // ------------ FIGURES ------------ //
  
  show figure.caption: it => box(
    inset: (left: 1em, right: 1em),
    align(left, it)
  )

  // ------------ OUTLINES ------------ //

  // justify outline entries
  show outline.entry: set par(justify: true)
  
  show outline: out => {    
    show outline.entry.where(level: 1): ent => {
      // for the table of contents
      if out.target == selector(heading) {
        block(above: 1.2em)[*#ent*]
      }
      // for other types of outlines
      else {
        link(
          ent.element.location(),
          [#ent.prefix(): #h(.5em) #ent.inner()]
        )
      }
    }
    out
  }
  
  // disable linebreaks in outlines
  show outline.entry: it => {
    show linebreak: none
    it
  }

  // ------------ MATH ------------ //
  // will be available in 0.12
  // show math.equation: it => {
  //   // small caps with a compliant font
  //   show smallcaps: set text(font: "Libertinus Serif")
  //   it
  // }

  // ------------ FOOTNOTES ------------ //
  show footnote.entry: it => {
    let loc = it.note.location()
    numbering(
      "1. ",
      ..counter(footnote).at(loc),
    )
    it.note.body
  }

  // ------------ BIBLIOGRAPHY ------------ //
  set bibliography(style: "association-for-computing-machinery")

  // ------------ COVER PAGE ------------ //
  cover(
    title-en: draft-string + title-en,
    title-fr: draft-string + title-fr,
    author: author,
    affiliation: affiliation,
    defense-place: defense-place,
    defense-date: defense-date,
    jury-content: jury-content
  )
  
  // ------------ BODY ------------ //
  body

  // ------------ ABSTRACT ------------ //
  abstracts(
    title-fr: title-fr, keywords-fr: keywords-fr, abstract-fr: abstract-fr,
    title-en: title-en, keywords-en: keywords-en, abstract-en: abstract-en,
  )
}
