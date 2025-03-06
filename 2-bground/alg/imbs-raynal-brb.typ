#import "../../setup.typ": *

#algorithm(algol[
- *operation* $brbbroadcast(v,sn)$ *is* $broadcast$ $initm(v,sn)$. <line:ir-brb:snd-bcast>

- *when* $initm(v,sn)$ is $received$ from $p_j$ *do*
  - *if* $p_i$ has not already broadcast some $witnessm(star,sn,j)$ *then*
    - $broadcast$ $witnessm(v,sn,j)$. <line:ir-brb:rcv-init-bcast>

- *when* $witnessm(v,sn,j)$ is $received$ from at least $n-2t$ processes *do*
  - *if* $p_i$ has not already broadcast some $witnessm(star,sn,j)$ *then*
    - $broadcast$ $witnessm(v,sn,j)$. <line:ir-brb:quorum1-witness-fwd>

- *when* $witnessm(v,sn,j)$ is $received$ from at least $n-t$ processes *do*
  - *if* $p_i$ has not already brb-delivered some $(star,sn,j)$ *then*
    - $brbdeliver(v,sn,j)$. <line:ir-brb:quorum2-witness-dlv>
],

caption: [
  Multi-shot version of Imbs-Raynal's BRB algorithm ($n>5t$, code for $p_i$)
]) <alg:imbs-raynal-brb>