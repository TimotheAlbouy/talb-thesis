#import "../../setup.typ": *

#algorithm(placement: top, algol(indent-size: 1.2em)[
- *object* $SigBasedK2LCast(q_d)$ *is*
 
  - *operation* $k2lcast(v,id)$ *is*
    - *if* $(star,id)$ not already signed by $p_i$ *then* <line:sb-k2l:k2l-cond>
      - $sig_i$ $<-$ signature of $(v,id)$ by $p_i$; <line:sb-k2l:k2l-sign>
      - $sigs_i <- {"all valid signatures for" (m,id) "broadcast by" p_i} union {sig_i}$; <line:sb-k2l:k2l-agg-sigs>
      - $broadcast$ $bundlem(v,id,sigs_i)$; <line:sb-k2l:k2l-bcast>
      - $checkdelivery()$. <line:sb-k2l:k2l-chk>

  - *when* $bundlem(v,id,sigs)$ *is* $received$ *do* <line:sb-k2l:rcv>
    - *if* $sigs$ contains valid signatures for $(v,id)$ not already broadcast by $p_i$ *then* <line:sb-k2l:rcv-cond>
      - $sigs_i <- {"all valid signatures for" (v,id) "broadcast by" p_i}$ \
        #h(2.8em) $union {"all valid signatures for" (v,id) "in" sigs}$; <line:sb-k2l:rcv-agg-sigs>
      - $broadcast$ $bundlem(v,id,sigs_i)$; <line:sb-k2l:rcv-bcast>
      - $checkdelivery()$. <line:sb-k2l:rcv-chk>

  - *internal operation* $checkdelivery()$ *is*
    - *if* $p_i$ broadcast at least $q_d$ valid signatures for $(v,id)$ \
      #h(1em) *and* no $(star,id)$ $k2l$-delivered yet *then* <line:sb-k2l:chk-cond>
      $k2ldeliver(m,id)$. <line:sb-k2l:dlv>
],

caption: [
  Signature-based $k2l$-cast (code for $p_i$)
]) <alg:sb-k2lcast>