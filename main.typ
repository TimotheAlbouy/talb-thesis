// #import "setup/custom-ilm.typ": *
// #import "@preview/fauve-cdb:0.1.0": *
#import "setup/matisse-template/matisse-template.typ": *

#import "setup.typ": *
#import "setup/algol.typ": enable-line-ref

#show: enable-line-ref

#show: thmrules.with(qed-symbol: $square$)
#show: equate.with(breakable: true, number-mode: "label")
// show ref: equate
#set math.equation(numbering: "(1)")
#show ref: eq-refs-with-parentheses

#let jury-content = [
  #v(1em)
  #text(size: 1.3em)[*Composition du jury :*]
  
  #{
    set text(size: .92em)
    table(
      columns: 4,
      column-gutter: 2em,
      stroke: 0pt,
      inset: (x: 0pt, y: .5em),
      "Président :", "Cédric Tedeschi", "Professeur des universités", "Université de Rennes",
      "Rapporteurs :", "Alessia Milani", "Professeure des universités", "Université d'Aix-Marseille",
      "", "Giuliano Losa", "Ingénieur chercheur", "Stellar Foundation",
      "Examinatrice :", "Sara Tucci-Piergiovanni", "Cheffe de laboratoire", "CEA",
      // "Examinateurs :", "Sara Tucci-Piergiovanni", "Cheffe de laboratoire", "CEA",
      // "", "Cédric Tedeschi", "Professeur des universités", "Université de Rennes",
      "Dir. de thèse :", "François Taïani", "Professeur des universités", "Université de Rennes",
      "", "Davide Frey", "Chargé de recherche", "Inria Rennes"
    )
  }
]

#let abstract-fr = [
Cette thèse se penche sur les systèmes distribués tolérants les pannes, et s'intéresse plus particulièrement au problème de la diffusion fiable dans des environnements asynchrones sujets à des défaillances hybrides.
Elle introduit un nouveau modèle de calcul combinant des défaillances byzantines de processus avec un adversaire de messages.
Elle définit ensuite l'abstraction de _Diffusion Fiable Byzantine Tolérante aux Adversaires de Messages_ (_MBRB_) et prouve sa condition de résilience optimale.
Elle propose enfin trois algorithmes clés pour réaliser cette abstraction : un algorithme MBRB simple basé sur les signatures, une nouvelle primitive appelée $k2l$-cast pour des implémentations MBRB sans cryptographie, et un algorithme MBRB basé sur les codes correcteurs d'erreurs optimisant la complexité de communication.
Ces contributions font progresser la compréhension des systèmes distribués tolérants les pannes, et participent aux fondations nécessaires à la conception d'algorithmes répartis résilients et efficaces, avec des applications dans les infrastructures critiques, les systèmes financiers et les technologies blockchain.
]

#let abstract-en = [
This thesis explores fault-tolerant distributed systems.
It focuses more specifically on implementing reliable broadcast in asynchronous environments prone to hybrid failures.
We introduce a novel computing model combining Byzantine process failures with a message adversary.
We then define the _Message-Adversary-tolerant Byzantine Reliable Broadcast_ (_MBRB_) abstraction and prove its optimal resilience condition.
We present three key algorithms implementing this abstraction: a simple signature-based MBRB algorithm, a new primitive called $k2l$-cast for cryptography-free MBRB implementations, and an erasure-coding-based MBRB algorithm optimizing communication complexity.
These contributions advance the understanding of fault-tolerant distributed systems and provide a foundation for designing resilient and efficient distributed algorithms, with applications in critical infrastructures, financial systems, and blockchain technologies.
]

#show: matisse-thesis.with(
  author: "Timothé Albouy",
  affiliation: "IRISA (UMR 6074)",
  jury-content: jury-content,
  acknowledgements: [
    
  ],
  defense-place: "Rennes",
  defense-date: "16 décembre 2024",
  draft: false,
  // french info
  title-fr: [Fondations de la Coopération Fiable avec de l'Asynchronie, \ des Pannes Byzantines, et des Adversaires de Messages],
  keywords-fr: [
    Algorithmes distribués, Systèmes asynchrones, Diffusion fiable, Tolérance aux pannes byzantines, Adversaire de message.
    // Perte de messages, Attrition, Signatures numériques, Code d'effacement.
  ],
  abstract-fr: abstract-fr,
  // english info
  title-en: [Foundations of Reliable Cooperation under Asynchrony, \ Byzantine Faults, and Message Adversaries],
  keywords-en: [
    Distributed algorithms, Asynchronous systems, Reliable broadcast, Byzantine fault tolerance, Message adversary.
    // Message losses, Churn, Digital signatures, Erasure coding.
  ],
  abstract-en: abstract-en,
)

// Process- and Network-Fault Resilience in Asynchronous Distributed Systems
// Hybrid Fault Tolerance in Asynchronous Distributed Systems

// (Foundations of) Reliable Cooperation/Communication in the Presence of Hybrid Failures
// Foundations of Asynchronous Reliable Broadcast \ under Hybrid Faults
// Reliable Broadcast under Asynchrony, Byzantine Faults and Message Adversaries
// Diffusion Fiable avec de l'Asynchronie, des Pannes Byzantines et des Adversaires de Messages

// Foundations of Reliable Cooperation under Asynchrony, Byzantine Faults and Message Adversaries
// Foundations of Asynchronous Byzantine Reliable Broadcast under a Message Adversary
// Foundations of Reliable Cooperation under Asynchrony, Byzantine Faults and Message Adversaries

#show: handle-missing-refs

#let show-preamble = true
// #let show-preamble = false
#let show-appendix = true
// #let show-appendix = false

// beginning of the preamble
#if show-preamble {
  set page(header: none, numbering: none)
  
  pagebreak()
  align(right + horizon, text(size: 1.1em)[_À ma mère_])
  pagebreak()

  set heading(numbering: none, outlined: false)

  // setting the numbering to lower roman numerals
  set page(numbering: "i")
  counter(page).update(0)

  include "0-preamble/acks.typ"
  include "0-preamble/resume-francais.typ"

  outline(title: "Table of Contents", indent: auto)

  show outline.entry: it => {
    v(5mm, weak: true)
    it
  }
  
  outline(title: "Index of Figures", target: figure.where(supplement: [Figure]))
  outline(title: "Index of Tables", target: figure.where(supplement: [Table]))
  outline(title: "Index of Algorithms", target: figure.where(supplement: [Algorithm]))
  include "0-preamble/notations.typ"
  include "0-preamble/list-articles.typ" 
}

// beginning of the thesis' body
#counter(page).update(1)
#include "1-intro/intro.typ"
#include "2-bground/bground.typ"
#include "3-model/model.typ"
#include "4-sig-mbrb/sig-mbrb.typ"
#include "5-k2lcast/k2lcast.typ"
#include "6-coded-mbrb/coded-mbrb.typ"
#include "7-conclu/conclu.typ"

// beginning of the appendix
#if show-appendix {
  // resetting the heading counter to 0
  counter(heading).update(0)
  // headings numbering starts with a capital letter
  set heading(numbering: "A.1 ")
  // level-1 headings are called appendices
  show heading.where(level: 1): set heading(supplement: [Appendix])
  is-appendix.update(true)
  
  include "8-appendices/A-consensus.typ"
  include "8-appendices/B-sf-k2lcast-proof.typ"
  include "8-appendices/C-sf-mbrb-proofs.typ"
  include "8-appendices/D-c-mbrb-proof.typ"
}

#bibliography("bibliography.bib")
