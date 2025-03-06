#import "../../setup.typ": *

#algorithm(algol[
- *init:* $obj_W <- SigFreeK2LCast(q_d = floor((n+3t)/2)+1, q_f = floor((n+t)/2)+1, single=ffalse)$.
  
- *operation* $mbrbbroadcast(v,sn)$ *is* $broadcast$ $initm(v,sn)$. <line:ir-mbrb:mbrb>

- *when* $initm(v,sn)$ is $received$ from $p_j$ *do* $obj_W.k2lcast(witnessm(v),(sn,j))$. <line:ir-mbrb:witness>

- *when* $(witnessm(v),(sn,j))$ is $obj_W.k2ldelivered$ *do* $mbrbdeliver(v,sn,j)$. <line:ir-mbrb:dlv>
],

caption: [
  Multi-shot $k2l$-cast-based reconstruction of Imbs-Raynal's BRB algorithm (code for $p_i$)
]) <alg:imbs-raynal-mbrb>