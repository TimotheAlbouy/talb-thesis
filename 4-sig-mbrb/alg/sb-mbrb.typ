#import "../../setup.typ": *

#algorithm(algol[
// - *init:* $sigs_i <- diameter$.
  
- *operation* $mbrbbroadcast(v,sn)$ *is*
  - save signature for $(v,sn,i)$ by $p_i$; <line:sb-mbrb:snd-save-own-sig>
  - $broadcast$ $bundlem(v,sn,i,{"all saved signatures for" (v,sn,i)})$. <line:sb-mbrb:snd-bcast>

- *when* $bundlem(v,sn,j,sigs)$ *is* $received$ *do* <line:sb-mbrb:rcv>
  - *if* $p_i$ already mbrb-delivered some $(star,sn,j)$ *then* $rreturn$; <line:sb-mbrb:rcv-cond-alrdy-dlv>
  - *if* $sigs$ does not contain the valid signature of $(v,sn,j)$ by $p_j$ *then* $rreturn$; <line:sb-mbrb:rcv-cond-no-snd>
  - save all unsaved valid signatures for $(v,sn,j)$ of $sigs$; <line:sb-mbrb:rcv-save-sigs>
  - *if* $p_i$ did not already sign some $(star,sn,j)$ *then* <line:sb-mbrb:rcv-cond-fwd>
    - save signature for $(v,sn,j)$ by $p_i$; <line:sb-mbrb:rcv-save-own-sig>
    - $broadcast$ $bundlem(v,sn,j,{"all saved signatures for" (v,sn,j)})$; <line:sb-mbrb:rcv-fwd>
  - *if* strictly more than $(n+t)/2$ signatures for $(v,sn,j)$ are saved *then* <line:sb-mbrb:rcv-cond-dlv>
    - $broadcast$ $bundlem(v,sn,j,{"all saved signatures for" (v,sn,j)})$; <line:sb-mbrb:rcv-bcast-quorum>
    - $mbrbdeliver$ $(v,sn,j)$. <line:sb-mbrb:rcv-dlv>
],

caption: [
  A signature-based implementation of the MBRB communication abstraction ($n>3t+2d$, code for $p_i$)
]) <alg:sb-mbrb>

// - *if* $(*,sn,j)$ not already mbrb-delivered <line:sb-mbrb:rcv-cond-vld> \
//   #h(.4em) *and* $sigs$ contains the valid signature for $(m,sn,j)$ by $p_j$ *then*