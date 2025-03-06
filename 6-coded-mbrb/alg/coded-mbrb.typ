#import "../../setup.typ": *

// -------------------------------------------- //
// ------------ CODED MBRB HELPERS ------------ //
// -------------------------------------------- //

#algorithm(placement: bottom, algol[
- *function* $computeFragVC(v)$ *is*
  - $(tilde(v)_1, ..., tilde(v)_n) <- eccsplit(v)$; <line:c-mbrb:comp-split>
  - $(C, pi_1, ..., pi_n) <- vccommit(tilde(v)_1, ..., tilde(v)_n)$; <line:c-mbrb:comp-frag-vc-commit>
  - $rreturn$ $(C, (tilde(v)_j, pi_j, j)_(j in [n]))$.

- *function* $isValid(C,fragtuples,sigs,isThreshSig)$ *is*
  - *if* $not isThreshSig$ *then* #u(true)
    - *if* $exists (sigma_x, x) in sigs: not tsverifyshare(C, sigma_x, x)$ *then* $rreturn$ $ffalse$;
    - *if* $(star, s) in.not sigs$ *then* $rreturn$ $ffalse$;
  - *else if* $not tsverify(C, sigs)$ *then* $rreturn$ $ffalse$; #u(false)
  - $fragtuples <- fragtuples \\ {bot}$;
  - *if* $exists (tilde(v)_x, pi_x, x) in fragtuples: not vcverify(C, pi_x, tilde(v)_x, x)$ *then* $rreturn$ $ffalse$;
  - $rreturn$ $ttrue$.

- *function* $getThreshSig(C)$ *is*
  - $sigs_C <- {"all saved signature shares for" C}$;
  - $rreturn$ $Sigma_C <- mat(delim: "{",
      &"the threshold signature saved for" C, &"if it exists, else"&;
      &tscombine(sigs_C), &"if" |sigs_C|>(n+t)/2 ","&;
      & bot, &"otherwise"&
    )$. <line:c-mbrb-helpers:get-tsig-ret>

- *operation* $mbrbbroadcast(v)$ *is* #rcomment[only executed by the sender $p_s$] <line:c-mbrb:mbrb>
  - $(C, (tilde(v)_j, pi_j, j)_(j in [n])) <- computeFragVC(v)$; <line:c-mbrb:snd-compute-frag-vc>
  - $sig_s <- (tssignshare_s (C), s)$; <line:c-mbrb:snd-sign>
  - $comm(m_1, ..., m_n)$ *where* $m_j=sendm(C, (tilde(v)_j, pi_j), sig_s)$. <line:c-mbrb:snd-comm> //<line:c-mbrb-helpers:end>

],

caption: [
  Helper functions and $mbrbbroadcast$ operation of Coded MBRB
]) <alg:coded-mbrb-helpers>

// ------------------------------------------- //
// ------------ CODED MBRB PHASES ------------ //
// ------------------------------------------- //

#algorithm(placement: auto, algol[

#context {
  // let line-end-helpers = _algol-line-nb.at(<line:c-mbrb-helpers:end>)
  let line-end-helpers = _algol-line-nb.at(<line:c-mbrb:snd-comm>)
  _algol-line-nb.update(line-end-helpers)
}

#v(-.4em)
#h(1.4em)#box(stroke: .5pt, inset: .3em)[_Phase I: Value dissemination_]
- *when* $sendm(C', (tilde(v)_j, pi_j), sig_s)$ *is* $received$ *from* $p_s$ *do* <line:c-mbrb:rcv-send>
  - *if* $not isValid(C', {(tilde(v)_i, pi_i, i)}, {sig_s}, isThreshSig = ffalse})$ *then* $rreturn$; <line:c-mbrb:rcv-send-isvalid>
  - *if* $p_i$ already executed @line:c-mbrb:rcv-send-bcast or signed some commitment $C'' != C'$ *then* $rreturn$; <line:c-mbrb:rcv-send-cond-other-vc>
  - $sig_i <- (tssignshare_i (C'), i)$; <line:c-mbrb:rcv-send-sign>
  - save $tilde(v)_i$, $sig_s$, and $sig_i$ for $C'$; <line:c-mbrb:rcv-send-save>
  - $broadcast$ $forwardm(C', (tilde(v)_i, pi_i, i), {sig_s, sig_i})$. <line:c-mbrb:rcv-send-bcast>

- *when* $forwardm(C', fragtuple_j, sigs_j={sig_s, sig_j})$ *is* $received$ *from* $p_j$ *do* <line:c-mbrb:rcv-forward>
  - *if* $not isValid(C', {fragtuple_j}, sigs_j, isThreshSig = ffalse})$ *then* $rreturn$; <line:c-mbrb:rcv-forward-isvalid>
  - *if* $p_i$ already signed some commitment $C'' != C'$ *then* $rreturn$; <line:c-mbrb:rcv-forward-cond-other-vc>
  - save $sigs_j$ for $C'$; <line:c-mbrb:rcv-forward-save-sigs>
  - *if* $fragtuple_j != bot$ *then* <line:c-mbrb:rcv-forward-cond-frag>
    - $(tilde(v)_j, pi_j, j) <- fragtuple_j$; <line:c-mbrb:rcv-forward-destruct-tuple>
    - save $tilde(v)_j$ for $C'$; <line:c-mbrb:rcv-forward-save-frag>
  - *if* no $forwardm$ message sent yet *then* <line:c-mbrb:rcv-forward-cond-no-msg>
    - $sig_i <- (tssignshare_i (C'), i)$; <line:c-mbrb:rcv-forward-sign>
    - save $sig_i$ for $C'$; <line:c-mbrb:rcv-forward-save-own-sig>
    - $broadcast$ $forwardm(C', bot, {sig_s, sig_i})$. <line:c-mbrb:rcv-forward-bcast>
    
#h(1.4em)#box(stroke: .5pt, inset: .3em)[_Phase II: Reaching quorum and termination_]
#v(.4em)
- *when* $mat(delim: "{",
    &exists C: getThreshSig(C) != bot and |{"saved" tilde(v)_j "for" C}| >= k;
    & and "no value mbrb-delivered yet"
  )$ *do* <line:c-mbrb:quorum> #v(.7em)
  - $v <- eccreconstruct(tilde(v)_1, ..., tilde(v)_n)$, $mat(delim: "{",
      &"where" tilde(v)_j #[are taken from @line:c-mbrb:quorum] ;
      &"when a fragment is missing, use" bot
    )$; <line:c-mbrb:quorum-reconstruct>
  - $(C', (tilde(v)'_j, pi'_j, j)_j) <- computeFragVC(v)$; <line:c-mbrb:quorum-comp-frag-vc>
  - *if* $C != C'$ *then* $rreturn$; <line:c-mbrb:quorum-cond-diff-vc>
  - $Sigma_C <- getThreshSig(C)$; <line:c-mbrb:quorum-get-tsig>
  - $comm(m_1, ..., m_n)$ *where* $m_j=bundlem(C, (tilde(v)'_i, pi'_i, i), (tilde(v)'_j, pi'_j, j), Sigma_C)$; <line:c-mbrb:quorum-comm>
  - $mbrbdeliver(v)$. <line:c-mbrb:quorum-dlv>
    

- *when* $bundlem(C', (tilde(v)'_j, pi'_j, j), fragtuple'_i, Sigma)$ $received$ *from* $p_j$ *do* <line:c-mbrb:rcv-bundle>
  - *if* $not isValid(C', {(tilde(v)'_j, pi'_j, j), fragtuple'_i}, Sigma, isThreshSig = ttrue)$ *then* $rreturn$; <line:c-mbrb:rcv-bundle-isvalid>
  - save $tilde(v)'_j$ and $Sigma$ for $C'$; <line:c-mbrb:rcv-bundle-save-other>
  - *if* no $bundlem$ message sent yet *and* $fragtuple'_i != bot$ *then* <line:c-mbrb:rcv-bundle-cond-no-bundle>
    - $(tilde(v)'_i, pi'_i, i) <- fragtuple'_i$; <line:c-mbrb:rcv-bundle-destruct-tuple>
    - save $tilde(v)'_i$ for $C'$; <line:c-mbrb:rcv-bundle-save-own>
    - $broadcast$ $bundlem(C', (tilde(v)'_i, pi'_i, i), bot, Sigma)$. <line:c-mbrb:rcv-bundle-bcast>
],

caption: [
  Phases of the Coded MBRB algorithm (code for $p_i$, single-shot, single-sender, $n>3t+2d$, $k<=n-t-2d$, threshold for the TS scheme $tau=floor((n+t)/2)+1$)
]) <alg:coded-mbrb>