// ------------ GENERAL ------------ //

#let mbox(content, min-width: none, min-height: none, ..args) = context {
  let normal-box = box(content, ..args)
  // width
  let width = measure(normal-box).width
  if min-width != none {
    width = calc.max(min-width.to-absolute(), width)
  }
  // height
  let height = measure(normal-box).height
  if min-height != none {
    width = calc.max(min-width.to-absolute(), height)
  }
  // return
  return box(width: width, height: height, content, ..args)
}

#let missing-refs-are-handled = state(
  "missing-refs-are-handled", false
)

#let pageref(label, supplement: [page]) = context {
  if missing-refs-are-handled.get() and query(label).len() == 0 {
    text(red)[*???*]
  } else {
    link(label)[#supplement~#counter(page).at(label).first()]
  }
}

#let handle-missing-refs(body) = {
  missing-refs-are-handled.update(true)
  show ref: it => {
    // get first character of the label
    let first_char = str(it.target).at(0)
    // if the ref is present
    // or if the first character of the label is upper case (it is a citation) 
    if query(it.target).len() > 0 or upper(first_char) == first_char {
      it
    }
    // otherwise, the ref is missing
    else { text(red)[*???*] }
  }
  body
}

#import "@preview/subpar:0.2.1"

// ------------ MATH ------------ //

#import "@preview/ctheorems:1.1.3": *
#import "@preview/equate:0.3.1": equate

#let eq-refs-with-parentheses(it) = {
  // let eq = math.equation
  // let el = it.element
  // if el != none and el.func() == eq {
  let lb = it.target
  if str(lb).starts-with("eq:") {
    let eq-nb = counter(math.equation).at(lb).at(0) - 1
    link(lb, $(#eq-nb)$)
  } else { it }
}

// ctheorems broke with typst 0.12, in the meantime I'm using a custom proof environment
// ORIGINAL PROOF (< 0.12)
#let prf-base = thmproof.with(
  titlefmt: strong,
  separator: [*.*#h(0.2em)],
  inset: 0pt
)
#let proof = prf-base("proof", "Proof")
#let proof-sketch = prf-base("proof-sketch", "Proof sketch")
// CUSTOM PROOF (>= 0.12)
// #let proof(body, auto-qed: true) = [
//   *Proof.* #body
//   #if auto-qed [#h(1fr)$square$]
// ]
// #let proof-sketch(body) = [
//   *Proof sketch.* #body
// ]

#let proof-of(lbl, body) = [
  #let nameref = ref(lbl)
  *Proof of #nameref.* #body
  #h(1fr) $square_(#[#nameref])$
]

#let thm-base = thmbox.with(
  base: none,
  titlefmt: strong,
  namefmt: x => [(#x)],
  separator: [*.*#h(0.2em)],
  bodyfmt: x => emph(x),
  inset: 1em,
  fill: rgb("#e8e8f8"),
)

// #let thm-name = state("thm-name")
// #let thm-body = state("thm-body")
// #let thm-base = thmbox.with(
//   base: none,
//   titlefmt: strong,
//   namefmt: x => {
//     thm-name.update(x)
//     [(#x)]
//   },
//   separator: [*.*#h(0.2em)],
//   bodyfmt: x => {
//     thm-body.update(x)
//     emph(x)
//   },
//   inset: 1em,
//   fill: rgb("#e8e8f8"),
// )

// #let cthm-base = thmbox.with(
//   base: none,
//   titlefmt: strong,
//   namefmt: x => [(#x)],
//   separator: [*.*#h(0.2em)],
//   bodyfmt: emph,
//   // inset: 0pt,
//   fill: rgb("#e8e8f8"),
// )
// #let thm-base(..args1) = {
//   let cthm-base = cthm-fmt(..args1)
//   return (body, ..args2) => {
//     let name = none
//     if args2.pos() != () and args2.pos().len() > 0 {
//       name = args2.pos().first()
//     }
//     thm-body.update(body)
//     return cthm-base(body, name, ..args2)
//   }
// }

// #let plain-thm = thm-base("", "")

// #let restate-thm(label) = context {
//   let body = thm-body.at(label)
//   let name = thm-name.at(label)
//   plain-thm(number: ref(label), body)
// }

#let theorem = thm-base("theorem", "Theorem")
#let lemma = thm-base("lemma", "Lemma")
#let definition = thm-base("definition", "Definition")
#let fact = thm-base("fact", "Fact")
#let corollary = thm-base("corollary", "Corollary")

#let observation = thmbox(
  "observation", "Observation",
  base: "lemma",
  titlefmt: strong,
  namefmt: x => [(#x)],
  separator: [*.*#h(0.2em)],
  bodyfmt: x => emph(x),
  // outset: .2em,
  inset: .7em,
  fill: rgb("#fff0b8"),
)

#let sp = $class("normal", +)$
#let sm = $class("normal", -)$
#let se = $class("normal", =)$

#let is-appendix = state("is-appendix", false)
#let proof-in-apx(label) = context if not is-appendix.get() [
  _(Proof in #ref(label).)_
]

// equation tag
#let tag(c, l: 2em) = $#h(l) & #[(#c)]$

// ------------ ALGORITHMS ------------ //

#let algorithm = figure.with(
  kind: "algorithm",
  supplement: [Algorithm]
)

// #import "@preview/algorithmic:0.1.0"
// #import algorithmic: algorithm
#import "setup/algol.typ": algol, u, _algol-line-nb

#let lcomment(c) = [$triangle.small.r$ _ #c _]
#let rcomment(c) = [#h(1fr) $triangle.small.r$ _ #c _]

// ------------ DRAWINGS ------------ //

#import "setup/cetz-setup.typ": *

// ------------ SYMBOLS/ABBREVIATIONS ------------ //

#let ie = [_i.e._,]
#let eg = [_e.g._,]
#let etc = [_etc._]
#let etal = [_et al._]

// BASIC

#let read = $sans("read")$
#let write = $sans("write")$

#let send = $sans("send")$
#let receive = $sans("receive")$
#let received = $sans("received")$
#let broadcast = $sans("broadcast")$

#let sn = $italic("sn")$
#let sig = $italic("sig")$
#let sigs = $italic("sigs")$

#let avg = $italic("avg")$

#let ttrue = $mono("true")$
#let ffalse = $mono("false")$

#let rreturn = $sans("return")$

#let sc(body) = text(font: "Libertinus Serif", smallcaps(body))

#let msgm = sc[msg]

#let secp = $lambda$

// BRB

#let brbbroadcast = $sans("brb_broadcast")$
#let brbdeliver = $sans("brb_deliver")$

#let initm = sc[init]
#let echom = sc[echo]
#let readym = sc[ready]
#let witnessm = sc[witness]

// MBRB

#let mbrbbroadcast = $sans("mbrb_broadcast")$
#let mbrbdeliver = $sans("mbrb_deliver")$

#let lmbrb = $ell_italic("MBRB")$
#let rtc = $delta$
#let omc = $mu$
#let bcc = $kappa$

// SB-MBRB

#let bundlem = sc[bundle]

// #let mbrbassum = [MBRB-Assumption]
#let sb-mbrb-assumption = thm-base(
  "sb-MBRB-assumption",
  [sb-MBRB-Assumption]
)
#let sb-mbrb-assum = link(<assum:sb-mbrb>)[sb-MBRB-Assumption]

// K2L-CAST

#let k2l = $k 2 ell$
#let obj = $italic("obj")$

#let k2lcast = $k2l#math.sans("_cast")$
#let k2ldeliver = $k2l#math.sans("_deliver")$
#let k2ldelivered = $k2l#math.sans("_delivered")$

// #let K2LCast = $sans("K2LCast")$
#let SigFreeK2LCast = $sans("SigFreeK2LCast")$
#let SigBasedK2LCast = $sans("SigBasedK2LCast")$

#let single = $italic("single")$
#let id = $italic("id")$
#let nodpty = $delta$
#let endorsem = sc[endorse]

#let NB = $italic("NB")$
#let NF = $italic("NF")$

#let sf-k2l-assumption = thm-base(
  "sf-k2l-assumption",
  [sf-$k2l$-Assumption]
)
#let sb-k2l-assumption = thm-base(
  "sb-k2l-assumption",
  [sb-$k2l$-Assumption]
)

#let b87-assumption = thm-base(
  "b87-assumption",
  [B87-Assumption]
)
#let b87assum = link(<assum:b87>)[B87-Assumption]
#let ir16-assumption = thm-base(
  "ir16-assumption",
  [IR16-Assumption]
)
#let ir16assum = link(<assum:ir16>)[IR16-Assumption]

#let checkdelivery = $sans("check_delivery")$

// CODED MBRB

#let comm = $sans("comm")$
#let sendm = sc("send")
#let forwardm = sc("forward")

#let computeFragVC = $sans("compute_frag_vec_commit")$
#let isValid = $sans("is_valid")$

#let getThreshSig = $sans("get_thresh_sig")$

#let isThreshSig = $italic("isThreshSig")$
#let fragtuple = $italic("fragtuple")$
#let fragtuples = $italic("fragtuples")$

#let ECC = $sans("ECC")$
#let eccsplit = $sans("ecc_split")$
#let eccreconstruct = $sans("ecc_reconstruct")$
#let kECC = $k_ECC$

#let vccommit = $sans("vc_commit")$
#let vcverify = $sans("vc_verify")$
#let Commitment = $sans("Commitment")$

#let tssignshare = $sans("ts_sign_share")$
#let tsverifyshare = $sans("ts_verify_share")$
#let tscombine = $sans("ts_combine")$
#let tsverify = $sans("ts_verify")$

#let Bsnd = $B_sans("send")$
#let Brcv = $B_sans("recv")$
#let Bkrcv = $B_(k,sans("recv"))$
#let nbundle = $\#bundlem$

#let c-mbrb-assumption = thm-base(
  "c-MBRB-assumption",
  [c-MBRB-Assumption]
)
#let c-mbrb-assum = link(<assum:c-mbrb>)[c-MBRB-Assumption]

// ------------ COMMANDS ------------ //

#let paragraph(title) = [*#title* #h(1em)]

#let epigraph(quote, author) = align(right, box(width: 50%)[
  #set align(left)
  #quote
  #line(length: 100%)
  #v(-.7em)
  #align(right)[_ #author _]
])

// ------------ ANNOTATIONS ------------ //

#let annote = true
#let annote = false

#let comment(body, color, initials) = {
  if not annote { return [] }
  return {
    box(
      text($sans(initials)$, white, size: .5em),
      inset: 3pt, fill: color
    )
    text(color)[
      #box(
        text($triangle.filled.r$, size: .8em),
        baseline: -.8mm
      )
      _ #body _
      #box(
        text($triangle.filled.l$, size: .8em),
        baseline: -.8mm
      )
    ]
  }
}

#let insert(body, color) = {
  if not annote { return body }
  return text(body, color)
}


#let ta(body) = insert(body, red)
#let df(body) = insert(body, green)
#let ft(body) = insert(body, blue)

#let TA(body) = comment(body, red, "TA")
#let DF(body) = comment(body, green, "DF")
#let FT(body) = comment(body, blue, "FT")

#let AR(body) = comment(body, teal, "AR")

// #let SA(body) = comment(body, teal, "SA")