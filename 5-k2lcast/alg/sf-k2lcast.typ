#import "../../setup.typ": *

#let step-line(length, name) = [
  % #box(line(length: length), baseline: -3pt)
  #name
  #box(line(length: length), baseline: -3pt) %
]

#algorithm(algol(indent-size: 1em)[
- *object* $SigFreeK2LCast(q_d,q_f,single)$ *is*
 
  - *operation* $k2lcast(v,id)$ *is* <line:sb-k2l:k2l>
    - *if* $endorsem(star,id)$ not already broadcast *then* <line:sf-k2l:cond-bcast>
      - $broadcast$ $endorsem(v, id)$. <line:sf-k2l:bcast>

  - *when* $endorsem(v,id)$ *is* $received$ *do*
    - #step-line(7.4em)[forwarding step] <line:sf-k2l:begin-fwd>
    - *if* $endorsem(v,id)$ received from at least $q_f$ processes *and* \
      #h(1em) ($not single$ *or* $endorsem(v,id)$ not broadcast yet) *then* <line:sf-k2l:cond-fwd>
      - $broadcast$ $endorsem(v,id))$; <line:sf-k2l:fwd>
    - #step-line(8em)[delivery step] <line:sf-k2l:begin-dlv>
    - *if* $endorsem(v,id)$ received from at least $q_d$ processes *and* \
      #h(1em) no $(star,id)$ $k2l$-delivered yet *then* <line:sf-k2l:cond-dlv>
      - $k2ldeliver(v,id)$. <line:sf-k2l:dlv>
],

caption: [
  Signature-free $k2l$-cast (code for $p_i$)
]) <alg:sf-k2lcast>