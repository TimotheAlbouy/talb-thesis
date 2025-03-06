#import "../../setup.typ": *

#algorithm(placement: auto, algol[
- *operation* $brbbroadcast(v,sn)$ *is* $broadcast$ $initm(v,sn)$. <line:b-brb:snd-bcast>

- *when* $initm(v,sn)$ is $received$ from $p_j$ *do*
  - *if* $p_i$ has not already broadcast some $echom(star,sn,j)$ *then*
    - $broadcast$ $echom(v,sn,j)$. <line:b-brb:rcv-init-bcast>

- *when* $echom(v,sn,j)$ is $received$ from strictly more than $(n+t)/2$ processes *do*
  - *if* $p_i$ has not already broadcast some $echom(star,sn,j)$ *then*
    - $broadcast$ $echom(v,sn,j)$;
  - *if* $p_i$ has not already broadcast some $readym(star,sn,j)$ *then*
    - $broadcast$ $readym(v,sn,j)$. <line:b-brb:quorum-echo-bcast-ready>

- *when* $readym(v,sn,j)$ is $received$ from at least $t+1$ processes *do*
  - *if* $p_i$ has not already broadcast some $readym(star,sn,j)$ *then*
    - $broadcast$ $readym(v,sn,j)$. <line:b-brb:quorum-ready-bcast-ready>

- *when* $readym(v,sn,j)$ is $received$ from at least $2t+1$ processes *do*
  - *if* $p_i$ has not already brb-delivered some $(star,sn,j)$ *then*
    - $brbdeliver(v,sn,j)$. <line:b-brb:quorum-ready-dlv>
],

caption: [
  Multi-shot version of Bracha's BRB algorithm ($n>3t$, code for $p_i$)
]) <alg:bracha-brb>