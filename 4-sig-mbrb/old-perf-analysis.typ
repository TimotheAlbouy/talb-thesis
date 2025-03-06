#import "../setup.typ": *

In this section, we show the following theorem.

#theorem([MBRB-Performance])[
// This rule is a workaround to force the bullets to appear at the center of the first line of the list items.
// ref: https://github.com/typst/typst/issues/1204
#show list.item: it => context [
  #let marker = list.marker.at(0)
  #let height = measure[#it.body].height
  #box(height: height)[#marker #it.body] \
]
If _ #sb-mbrb-assum _ is satisfied and the sender is correct, _ @alg:sb-mbrb _ provides the following MBRB guarantees:

// Currently, we cannot have no delimiter for the cases function.
// This will come in the next release.
// ref: https://github.com/typst/typst/pull/4211

- $rtc = mat(delim: "{",
    2, &"if" d < (c-floor((n+t)/2))/(floor((n+t)/2)+1)", else"&;
    3, &"if" d < c-sqrt(c times (n+t)/2)", else"&;
    4, &"if" d < c-(n+t+2c)^2/(16c)", else"&;
    5, &"otherwise"&
  )$ communication steps,
  
- $omc = 2n^2$ messages sent overall,

- $bcc = O(n^2|v|+n^3 secp)$ bits sent overall.
]

The proof follows from the next lemmas.

#lemma[
$c-d > floor((n+t)/2)$.
] <lem:sufficient-for-quorum>

#proof[
We have the following:
$
  c-d &>= n-t-d
  = (2n-2t-2d)/2, &#[(by definition of $c$)] \
  
  &> (n+3t+2d-2t-2d)/2, #h(5em) &#[(by #sb-mbrb-assum)] \
  
  &> (n+t)/2 >= floor((n+t)/2). #qedhere
$
]

#lemma[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$, then at least $c-d-floor(d floor((n+t)/2)/(c-d-floor((n+t)/2)))$ correct processes mbrb-deliver $(v,sn,i)$ at most two communication steps later.
] <lem:amt-dlv-2-rnd>

#proof[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$, then it broadcasts its own signature $sig_i$ for $(v,sn,i)$ in a $bundlem(v,sn,i,{sig_i})$ message at @line:sb-mbrb:snd-bcast.
Let us denote by $K$ the set of correct processes that receive this $bundlem(v,sn,i,{sig_i})$ message from $p_i$ during the same communication step, and let $k$ be the number of processes in $K$, such that $c-d <= k = |K| <= c$ (by definition of the message adversary).
By construction of the algorithm, every process $p_x$ of $K$ passes the condition at @line:sb-mbrb:rcv-cond-no-snd, and therefore broadcasts a $bundlem(v,sn,i,{sig_x,sig_i})$ message, whether it be at @line:sb-mbrb:snd-bcast for $p_i$, or at @line:sb-mbrb:rcv-fwd for any other process of $K$.

Let $A$ and $B$ define two partitions of the set of all correct processes ($A union B$ is the set of all correct processes, and $A sect B = diameter$).
$A$ denotes the set of correct processes that receive strictly more than $(n+t)/2$ signatures for $(v,sn,i)$ from processes of $K$ two communication steps after $p_i$ mbrb-broadcast $(v,sn)$, while $B$ denotes the set of remaining correct processes of $K$ that receive at most $(n+t)/2$ signatures for $(v,sn,i)$ from processes of $K$ two communication steps after $p_i$ mbrb-broadcast $(v,sn)$.
Let $ell_2$ be the size of $A$: $ell_2 = |A|$.
By construction, $|B|=c-ell_2$.
Let $s_A$ and $s_B$ respectively denote the number of signatures for $(v,sn,i)$ from processes of $K$ received by processes of $A$ and $B$ at most two communication steps after $p_i$ mbrb-broadcast $(v,sn)$.
@fig:sb-mbrb-msg-dist-rnd2 represents the distribution of such signatures among processes of $K$, sorted by decreasing number of signatures received.
Each processes of $A$ can receive at most $k$ signatures (that is, all signatures) from processes of $K$, while each process of $B$ can receive at most $floor((n+t)/2)$ signatures from processes of $K$ two communication steps after $p_i$ mbrb-broadcasts $(v,sn)$.
In some parts of this proof, we use $q$ instead of $floor((n+t)/2)$ for simplicity.

#include "fig/sb-mbrb-msg-dist-rnd2.typ"

From these observations, we infer the following inequalities:
$
  ell_2 k &>= s_A, \
  
  (c-ell_2) q &>= s_B.
$

By the definition of the message adversary, a $bundlem(v,sn,i,{sig_x,sig_i})$ message broadcast by a correct process $p_x$ is eventually received by at least $c-d$ correct processes.
As a consequence, in total, the minimum number of signatures for $(v,sn,i)$ collectively received by correct processes as a result of broadcasts by processes in $K$ in the first two asynchronous communication steps is $k(c-d)$.
We thus have:
$
  s_A+s_B &>= k(c-d).
$
By combining the previous inequalities, we obtain:
$
  ell_2 k + (c-ell_2) q &>= k (c-d), \
  
  ell_2 k + c q - ell_2 q &>= k (c-d), \
  
  ell_2 k - ell_2 q &>= k (c-d) - c q, \
  
  ell_2 (k-q) &>= k (c-d) - c q. #<eq:l-fact-sup-k-fact>
$
By @lem:sufficient-for-quorum, we know that $k >= c-d > floor((n+t)/2) = q$, so we can rewrite @eq:l-fact-sup-k-fact into:
$
  ell_2 &>= (k (c-d) - c q)/(k-q). #<eq:min-l-with-k>
$

Let us define a function $f$ such that $f(k) = (k(c-d) - c q)/(k-q)$.
As we seek the lowest guaranteed value for $ell_2$, we want to find the minimum of $f$ on $k in [c-d,c]$.
To this end, let us first study the derivative of $f$.
The image $f(k)$ is of the form $u/v$, so we have:
$
  f'(k) &= (u' v - u v')/(v^2)
  
  = ((c-d)(k-q)-(k(c-d)-q c))/((k-q)^2), \
  
  &= ((c-d)(k-q)-k(c-d)+q c)/((k-q)^2)
  
  = (q c-q(c-d))/((k-q)^2)
  
  = (q d)/((k-q)^2).
$

As $q$ and $d$ are by definition positive, we know that $f'(k) = (q t)/((k-q)^2)$ is positive, or null when $d=0$.
Therefore, $f$ is monotonically increasing on $k in [c-d,c]$, and the minimum value for $ell_2$ can be found when $k$ is also minimum, that is when $k = c-d$.
Thus, when we replace $k$ by $c-d$ in @eq:min-l-with-k, we obtain:
$
  ell_2 &>= ((c-d)(c-d)-c q)/(c-d-q)
  
  = ((c-d)(c-d-q)-q d)/(c-d-q), \
  
  &>= c-d-(q d)/(c-d-q). #<eq:min-l-without-k>
$

Let us denote by $ell_(2,"min")$ the minimum number of correct processes that receive a quorum of strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$ two communication steps after $p_i$ mbrb-broadcast $(v,sn)$, such that $ell_(2,"min") <= ell_2 = |A|$.
As the right hand side of @eq:min-l-without-k is not always an integer, we have:
$
  ell_(2,"min") &= ceil(c-d-(q d)/(c-d-q))
  
  = c-d+ceil(-(q d)/(c-d-q)), \
  
  &= c-d-floor((q d)/(c-d-q)),
  #h(5em) &#[(as $forall x in RR, ceil(-x) = -floor(x)$)] \
  
  &= c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2))).
  &#[(by definition of $q$)]
$

Hence, at least $ell_(2,"min") = c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$ processes of $K$ receive strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$ two communication steps after $p_i$ mbrb-broadcasts $(v,sn)$.
For every process $p_a$ of $A$:
- If $p_a$ does not pass the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[] after receiving the last signature of the quorum in a $bundlem$ message, it is necessarily because $p_a$ already mbrb-delivered some $(star,sn,i)$, because processes of $K$ are correct and all their $bundlem$ messages include the signature for $(v,sn,i)$ by $p_i$.
  But let us remind that, as the sender $p_i$ is correct, it is impossible for $p_a$ to mbrb-deliver anything different from $(v,sn,i)$.
  Therefore, $p_a$ has already mbrb-delivered $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv.
    
- If $p_a$ passes the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[] after processing the last $bundlem(v,sn,i,{sig_i,sig_x})$ message of the quorum from a process $p_x$, then $p_a$ saves the signature $sig_x$ at @line:sb-mbrb:rcv-save-sigs, and after it passes the condition at @line:sb-mbrb:rcv-cond-dlv (as it has saved strictly more than $(n+t)/2$ signatures) and finally mbrb-delivers $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv.

Therefore, all processes of $A$, which are at least $ell_(2,"min") = c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$, mbrb-deliver $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv at most two communication steps after $p_i$ mbrb-broadcast $(v,sn)$.
]

#lemma[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$ and $d < c-sqrt(c times (n+t)/2)$, then at least $c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most three communication steps later.
] <lem:dlv-3-rnd-if-cond>

#proof[
Let us assume that a correct process $p_i$ mbrb-broadcasts $(v,sn)$ and that $d < c-sqrt(c times (n+t)/2)$.
Process $p_i$ must broadcast a first $bundlem(v,sn,i,{sig_i})$ message (where $sig_i$ is the signature of $(v,sn,i)$ by $p_i$) at @line:sb-mbrb:snd-bcast.
This initial message is received by at least $(c-d-1)$ other correct processes, due to our assumption on the message adversary.
This counts as a first communication step.
    
In the second communication step, each process $p_j$ of these $(c-d-1)$ correct processes broadcasts its own $bundlem(v,sn,i,{sig_j,sig_i})$ message (where $sig_j$ is the signature of $(v,sn,i)$ by $p_j$) at @line:sb-mbrb:rcv-fwd.
At the end of the second communication step, in total, at least $(c-d)$ distinct signatures for $(v,sn,i)$ have been created and broadcast by correct processes (counting that of $p_i$), resulting in at least $(c-d)^2$ receptions of said signatures by correct processes.
As there are $c$ correct processes, this means that, on average, each correct process has received at least $((c-d)^2)/c$ signatures by the end of the second communication step, and that at least one correct process, $p_k$, receives (and saves at @line:sb-mbrb:rcv-save-sigs) at least this number of signatures.

From the Lemma hypothesis $d < c-sqrt(c times (n+t)/2)$ and using simple algebraic transformations, we can derive $((c-d)^2)/c > (n+t)/2$.
Therefore, $p_k$ reaches a quorum of signatures, that is, it passes the condition at @line:sb-mbrb:rcv-cond-dlv and broadcasts this quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum, two communication steps after the mbrb-broadcast of $(v,sn)$ by $p_i$.
By definition of the message adversary, this quorum of signatures is received by $c-d$ correct processes, which save it at @line:sb-mbrb:rcv-save-sigs and thus pass the condition at @line:sb-mbrb:rcv-cond-dlv and finally mbrb-deliver $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv, three communication steps after the mbrb-broadcast of $(v,sn)$ by $p_i$. \
]

#lemma([MBRB-Time-cost])[
If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then $lmbrb = c-d$ correct processes mbrb-deliver $v$ from $p_i$ with sequence number $sn$ at most \
$rtc = mat(delim: "{",
    2, &"if" d < (c-floor((n+t)/2))/(floor((n+t)/2)+1)", else"&;
    3, &"if" d < c-sqrt(c times (n+t)/2)", else"&;
    >3, &"otherwise"&
  )$ communication steps later.
] <lem:sb-mbrb-time-cost>

#proof[
Let us consider a correct process $p_i$ that mbrb-broadcasts $(v,sn)$.
By exhaustion:

- Case where $d < (c - floor((n+t)/2))/(floor((n+t)/2) +1)$.
    
  By @lem:amt-dlv-2-rnd, at least $c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$ correct processes mbrb-deliver $(v,sn,i)$ two communication steps after $p_i$ has mbrb-broadcast $(v,sn)$.
  We have:
  $
    d &< (c - floor((n+t)/2))/(floor((n+t)/2)+1), &#[(case assumption)] \
    
    d floor((n+t)/2)+d &< c-floor((n+t)/2), &#[(as $floor((n+t)/2)+1 > 0$)] \
    
    d floor((n+t)/2) &< c-d-floor((n+t)/2), \
    
    (d floor((n+t)/2))/(c-d-floor((n+t)/2)) &< 1, &#[(as $c-d > floor((n+t)/2)$ by @lem:sufficient-for-quorum)] \
    
    floor((d floor((n+t)/2))/(c-d-floor((n+t)/2))) &<= 0, \
    
    c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2))) &>= c-d = lmbrb.
  $
  Hence, $lmbrb$ correct processes mbrb-deliver $(v,sn,i)$ at most two communication steps after $p_i$ has mbrb-broadcast $(v,sn)$.
    
- Case where $d < c-sqrt(c times (n+t)/2)$.
    
  @lem:dlv-3-rnd-if-cond applies and at least $c-d = lmbrb$ correct processes mbrb-deliver $(v,sn,i)$ at most three communication steps after $p_i$ has mbrb-broadcast $(v,sn)$. #qedhere
]

#lemma([MBRB-Message-cost])[
The mbrb-broadcast of a value $v$ by a correct process $p_i$ entails the sending of at most $omc = 2n^2$ messages by correct processes overall.
] <lem:sb-mbrb-msg-cost>

#proof[
The broadcast of a message by a correct process at @line:sb-mbrb:snd-bcast entails its forwarding by at most $n-1$ other correct processes at @line:sb-mbrb:rcv-fwd.
As each broadcast by correct processes corresponds to the sending of $n$ messages, then at most $n^2$ messages are sent in a first step.

In a second step, at least one correct process reaches a quorum of signatures and passes the condition at @line:sb-mbrb:rcv-cond-dlv, and then broadcasts this quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum.
Upon receiving this quorum, every correct process also passes the condition at @line:sb-mbrb:rcv-cond-dlv (if it has not done it already) and broadcasts the message containing the quorum at @line:sb-mbrb:rcv-bcast-quorum.
Hence, at most $n^2$ messages are also sent in this second step, which amounts to a maximum of $omc = 2n^2$ messages sent in total.
]

#include "fig/sb-mbrb-msg-dist.typ"

#lemma([MBRB-Communication-cost])[
The mbrb-broadcast of a value $v$ by a correct process $p_i$ entails the sending of at most $bcc=O(n^2|v|+n^3 secp)$ bits by correct processes overall.
] <lem:sb-mbrb-comm-cost>

#proof[
Let us first characterize the size of the different data structures included in the $bundlem$ messages of @alg:sb-mbrb.
Firstly, $|v|$ denotes the size of the applicative value $v$.
We assume the size of the sequence number $sn$ to be constant, hence it is asymptotically negligible.
The identity $i$ of the sender is encoded in $O(log n)$ bits.
Finally, the set of signatures $sigs$ contains at most a quorum of $O(n)$ signature (of $O(secp)$ bits), implicitly accompanied by the signer's identity (of $O(log n)$ bits).
This amounts to $O(n (secp + log n))$ bits for a set $sigs$.
Hence, a $bundlem$ message has $O(|v| + log n + n (secp + log n))$ bits in total, which we can simplify to $O(|v| + n secp)$, since we have $secp = Omega(log n)$ by assumption (see @sec:sig-mbrb-prelim).

Since correct processes communicate $O(n^2)$ overall (see @lem:sb-mbrb-msg-cost), it means that they send $bcc = O(n^2|v| + n^3 secp)$ bits overall. 
]
