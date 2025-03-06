#import "../setup.typ": *

#heading(numbering: none, level: 1)[List of Articles]

#let doi(doiref) = {
  let doiurl = "https://doi.org/" + doiref
  [#smallcaps[doi]: #link(doiurl)[$mono(doiref)$]]
}

#let arxiv(arxivref) = {
  let arxivurl = "https://arxiv.org/abs/" + arxivref
  let arxivstr = "arXiv:" + arxivref
  [#link(arxivurl)[$mono(arxivstr)$]]
}

#heading(numbering: none, level: 2, outlined: false)[
  Publications included in this manuscript
]

#set list(marker: ([@AFRT23], [‣], [–]))

- Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2023), "Asynchronous Byzantine reliable broadcast with a message adversary." _Theoretical Computer Science_, 17 pages,
  #doi("10.1016/J.TCS.2023.114110").
  
  - *Conference version (Invited paper) @AFRT21:*
    
    Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2021), "Byzantine-tolerant reliable broadcast in the presence of silent churn," _Proc. 23rd Int'l Symposium on Stabilization, Safety, and Security of Distributed Systems (SSS'21)_, 13 pages, #doi("10.1007/978-3-030-91081-5_2").

#set list(marker: ([@AFRT22-1], [‣], [–]))
  
- Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2022), "A modular approach to construct signature-free BRB algorithms under a message adversary," _Proc. 26th Int'l Conference on Principles of Distributed Systems (OPODIS)_, 23 pages, #doi("10.4230/LIPIcs.OPODIS.2022.26").

  // - *Full arXiv version @AFRT22-2:*

  //  Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2022), "A modular approach to construct signature-free BRB algorithms under a message adversary," #arxiv("2204.13388").
    

#set list(marker: ([@AFGHRSTZ24-1], [‣], [–]))

- Timothé Albouy, Davide Frey, Ran Gelles, Carmit Hazay, Michel Raynal, Elad Michael Schiller, François Taïani, and Vassilis Zikas (2024), "Near-optimal communication Byzantine reliable broadcast under a message adversary," _Proc. 28th Int'l Conference on Principles of Distributed Systems (OPODIS)_, #doi("10.4230/LIPICS.OPODIS.2024.14").

  - *Brief announcement @AFGHRSTZ24-2:*

    Timothé Albouy, Davide Frey, Ran Gelles, Carmit Hazay, Michel Raynal, Elad Michael Schiller, François Taïani, and Vassilis Zikas (2024), "Brief announcement: Towards optimal communication Byzantine reliable broadcast under a message adversary," _Proc. 38th Int'l Symposium on Distributed Computing (DISC'24)_, 7 pages, #doi("10.4230/LIPIcs.DISC.2024.13"). #v(3em)

  // - *Full arXiv version @AFGHRSTZ24-3:*

  //   Timothé Albouy, Davide Frey, Ran Gelles, Carmit Hazay, Michel Raynal, Elad Michael Schiller, François Taïani, and Vassilis Zikas (2024), "Near-optimal communication Byzantine reliable broadcast under a message adversary," #arxiv("2312.16253").

#pagebreak()

#heading(numbering: none, level: 2, outlined: false)[
  Publications not included in this manuscript
]

#set list(marker: ([@AFGGNW24-1], [‣], [–]))

- Timothé Albouy, Antonio Fernández Anta, Chryssis Georgiou, Mathieu Gestin, Nicolas Nicolaou, and Junlang Wang (2024), "AMECOS: A modular event-based framework for concurrent object specification," _Proc. 28th Int'l Conference on Principles of Distributed Systems (OPODIS)_, #doi("10.4230/LIPICS.OPODIS.2024.4").

  // - *Full arXiv version @AFGGNW24-2:*

  //   Timothé Albouy, Antonio Fernández Anta, Chryssis Georgiou, Mathieu Gestin, Nicolas Nicolaou, and Junlang Wang (2024), "AMECOS: A modular event-based framework for concurrent object specification," #arxiv("2405.10057").

#set list(marker: ([@AFRT24], [‣], [–]))

- Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2024), "Good-case early-stopping latency of synchronous Byzantine reliable broadcast: the deterministic case," _Distributed Computing_, 23 pages, #doi("10.1007/s00446-024-00464-6").

  - *Conference version @AFRT22-2:*

    Timothé Albouy, Davide Frey, Michel Raynal, and François Taïani (2022), "Good-case early-stopping latency of synchronous Byzantine reliable broadcast: the deterministic case," _Proc. 36th Int'l Symposium on Distributed Computing (DISC)_, 22 pages, #doi("10.4230/LIPIcs.DISC.2022.4").

#heading(numbering: none, level: 2, outlined: false)[
  Other articles currently under submission
]

#set list(marker: [@AFGRT23])

- Timothé Albouy, Davide Frey, Mathieu Gestin, Michel Raynal, and François Taïani (2024), "Context-adaptive cooperation," #arxiv("2311.08776"). 

#set list(marker: [@AAFGRRT24])

- Timothé Albouy, Emmanuelle Anceaume, Davide Frey, Mathieu Gestin, Arthur Rauch, Michel Raynal, and François Taïani (2024), "Asynchronous BFT asset transfer: quasi-anonymous, light, and consensus-free," #arxiv("2405.18072").