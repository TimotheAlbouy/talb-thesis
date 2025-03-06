#import "../setup.typ": *

= List of Acronyms and Notations

// #align(center, table(
//   columns: 2, align: horizon + center, row-gutter: (0pt, 0pt, 0pt, 3pt, 0pt),
//   [*Acronyms*], [*Meaning*],
//   [BRB], [Byzantine-tolerant reliable broadcast],
//   [MA], [Message adversary],
//   [MBRB], [MA- and Byzantine-tolerant reliable broadcast],
//   [*Notations*], [*Meaning*],
//   $n$, [number of processes in the system],
//   $t$, [upper bound on the number of Byzantine processes],
//   $d$, [power of the message adversary],
//   $c$, [effective number of correct processes in a run ($n-t <= c <= n$)],
//   $secp$, [security parameter of the cryptographic primitives],
//   $p_i$, [process of the system with identity $i$],
//   $v$, [applicative value],
//   $sn$, [sequence number],
//   $m$, [implementation message],
//   $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
//   $rtc$, [time complexity of MBRB],
//   $omc$, [message complexity of MBRB],
//   $bcc$, [communication complexity of MBRB],
//   $star$, [unspecified value],
//   $bot$, [sentinel (null) value],
//   $epsilon$, [negligible value],
// ))

#let general-tables = table(
  columns: 2, align: horizon + center, row-gutter: (0pt, 0pt, 0pt, 3pt, 0pt),
  // ACRONYMS
  [*Acronyms*], [*Meanings*],
  [BRB], [Byzantine reliable broadcast],
  [MA], [Message adversary],
  [MBRB], [MA-tolerant BRB],
  // GENERAL NOTATIONS
  [*General \ notations*], [*Meanings*],
  $n$, [nb of processes in the system],
  $t$, [max nb of \ Byzantine processes],
  $d$, [power of the MA],
  $c$, [effective nb of correct \ processes ($n-t <= c <= n$)],
  $secp$, [security parameter of the \ cryptographic primitives],
  $p_i$, [process of the system \ with identity $i$],
  $v$, [applicative value],
  $sn$, [sequence number],
  $m$, [implementation message],
  $lmbrb$, [min nb of correct processes \ that mbrb-deliver a value],
  $rtc$, [time cost of MBRB],
  $omc$, [message cost of MBRB],
  $bcc$, [communication cost \ of MBRB],
  $p_s$, [sender process of MBRB],
  $star$, [unspecified value],
  $bot$, [sentinel (null) value],
  $epsilon$, [negligible value],
)

#let specific-tables = table(
  columns: 2, align: horizon + center, row-gutter: (0pt, 0pt, 0pt, 0pt, 0pt, 0pt, 0pt, 3pt, 0pt),
  [*Notations of \ @sec:k2l-cast*], [*Meanings*],
  $k$, [min nb of correct processes that $k2l$-cast a value],
  $ell$, [min nb of correct processes that $k2l$-deliver a value],
  $k'$, [min nb of correct $k2l$-casts if there is a correct $k2l$-delivery],
  $nodpty$, [$ttrue$ if no-duplicity is \ guaranteed, $ffalse$ otherwise],
  $q_d$, [size of the \ $k2l$-delivery quorum],
  $q_f$, [size of the \ forwarding quorum],
  $single$, [$ttrue$ iff only 1 value can be endorsed, $ffalse$ otherwise],
  //
  [*Notations of \ @sec:coded-mbrb*], [*Meanings*],
  $k$, [reconstruction threshold of the erasure code ($k$ out of $n$)],
  $tilde(v)_i$, [$i$#super[th] fragment of value $v$],
  $Sigma$, [threshold signature (TS)],
  $tau$, [threshold of the TS scheme (set to $tau = floor((n+t)/2)+1$)],
  $sigma_i$, [signature share of the \ TS scheme by process $p_i$],
  [$sig_i$, $sigs$], [$(sigma_i, i)$ pair, set of $sig_i$ pairs],
  $C$, [vector commitment (VC)],
  $pi_i$, [proof of inclusion of \ fragment $tilde(v)_i$ in a VC]
)

#align(center, grid(columns: 2, column-gutter: 1em,
  general-tables, specific-tables
))