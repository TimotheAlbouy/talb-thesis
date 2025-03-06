#import "../../setup.typ": *

#algorithm(algol[
- *init:* $obj_E <- SigFreeK2LCast(q_d = floor((n+t)/2)+1, q_f = t+1, single=ttrue)$; \
  #h(2.15em) $obj_R <- SigFreeK2LCast(q_d = 2t+d+1, q_f = t+1, single=ttrue)$.
  
- *operation* $mbrbbroadcast(v,sn)$ *is* $broadcast$ $initm(v,sn)$. <line:b-mbrb:mbrb>

- *when* $initm(v,sn)$ is $received$ from $p_j$ *do* $obj_E.k2lcast(echom(v),(sn,j))$. <line:b-mbrb:echo>

- *when* $(echom(v),(sn,j))$ is $obj_E.k2ldelivered$ *do* $obj_R.k2lcast(readym(v),(sn,j))$. <line:b-mbrb:ready>

- *when* $(readym(v),(sn,j))$ is $obj_R.k2ldelivered$ *do* $mbrbdeliver(v,sn,j)$. <line:b-mbrb:dlv>
],

caption: [
  Multi-shot $k2l$-cast-based reconstruction of Bracha's BRB algorithm (code for $p_i$)
]) <alg:bracha-mbrb>