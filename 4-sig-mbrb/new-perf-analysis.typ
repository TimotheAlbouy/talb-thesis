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
If _ #sb-mbrb-assum _ is satisfied and the sender is correct, _ @alg:sb-mbrb _ provides the following _MBRB_ guarantees:

- $rtc = mat(delim: "{",
    2, &"if" d = 0", else"&;
    3, &"if" d < c-sqrt(c times (n+t)/2)", else"&;
    4, &"if" d < c-(n+t+2c)^2/(16c)", else"&;
    5, &"otherwise"&
  )$ communication rounds,
  
- $omc = 2n^2$ messages sent overall,

- $bcc = O(n^2|v|+n^3 secp)$ bits sent overall.
]

The proof of this theorem follows from the subsequent lemmas (@lem:sufficient-for-quorum[Lemmas] to @lem:sb-mbrb-comm-cost[]).
For analyzing the time cost of our asynchronous algorithm, #ie the number of _communication rounds_ it requires to terminate, let us recall from @sec:mbrb that we rely on the common approach which assumes that the algorithm executes in a synchronous environment~@CR93.

#lemma[
$c-d > (n+t)/2$.
] <lem:sufficient-for-quorum>

#proof[
We have the following:
$
  c-d &>= n-t-d
  = (2n-2t-2d)/2 &#[(by definition of $c$)] \
  
  &> (n+3t+2d-2t-2d)/2 #h(5em) &#[(by #sb-mbrb-assum)] \
  
  &> (n+t)/2. #qedhere
$
]

#lemma[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$, then at least $c-d-floor(d floor((n+t)/2)/(c-d-floor((n+t)/2)))$ correct processes mbrb-deliver $(v,sn,i)$ at most two rounds later.
] <lem:amt-dlv-2-rnd>

#proof[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$, then it broadcasts its own signature $sig_i$ for $(v,sn,i)$ in a $bundlem(v,sn,i,{sig_i})$ message at @line:sb-mbrb:snd-bcast.
Let us denote by $L_1$ the set of correct processes that receive this $bundlem(v,sn,i,{sig_i})$ message from $p_i$ by the end of the first round, and let $ell_1$ be the number of processes in $L_1$, such that $c-d <= ell_1 = |L_1| <= c$ (by definition of the message adversary).
// #FT[Collision of notation with the $ell_1$ used in coded MBRB. Can you use a different notation?]
By construction of the algorithm, every process $p_x$ of $L_1$ passes the condition at @line:sb-mbrb:rcv-cond-no-snd, and therefore broadcasts a $bundlem(v,sn,i,{sig_x,sig_i})$ message, whether it be at @line:sb-mbrb:snd-bcast for $p_i$, or at @line:sb-mbrb:rcv-fwd for any other process of $L_1$.

Let $A$ and $B$ define two partitions of the set of all correct processes ($A union B$ is the set of all correct processes, and $A inter B = diameter$).
The set $A$ denotes the correct processes that receive strictly more than $(n+t)/2$ signatures for $(v,sn,i)$ from processes of $L_1$ two rounds after $p_i$ mbrb-broadcast $(v,sn)$, while the set $B$ denotes the remaining correct processes of $L_1$ that receive at most $(n+t)/2$ signatures for $(v,sn,i)$ from processes of $L_1$ two rounds after $p_i$ mbrb-broadcast $(v,sn)$.
Let $a$ be the size of $A$: $a = |A|$.
By construction, $|B|=c-a$.
Let $s_A$ and $s_B$ respectively denote the number of signatures for $(v,sn,i)$ from processes of $L_1$ received by processes of $A$ and $B$ at most two rounds after $p_i$ mbrb-broadcast $(v,sn)$.
@fig:sb-mbrb-msg-dist-rnd2 represents the distribution of such signatures among the processes of $L_1$, sorted by decreasing number of signatures received.
// #FT[with 'the', the text implies 'all the processes of $L_1$', without 'the' meaning is more 'some processes of $L_1$']
Each processes of $A$ can receive at most $ell_1$ signatures (that is, all signatures) from processes of $L_1$, while each process of $B$ can receive at most $floor((n+t)/2)$ signatures from processes of $L_1$ two rounds after $p_i$ mbrb-broadcasts $(v,sn)$.
In some parts of this proof, we use $q$ as a shorthand for $floor((n+t)/2)$ for concision.

#include "fig/sb-mbrb-msg-dist-rnd2.typ"

From these observations, we infer the following inequalities:
$
  ell_1 a &>= s_A, \
  
  (c-a) q &>= s_B.
$

By the definition of the message adversary, a $bundlem(v,sn,i,{sig_x,sig_i})$ message broadcast by a correct process $p_x$ is eventually received by at least $c-d$ correct processes.
As a consequence, in total, the minimum number of signatures for $(v,sn,i)$ collectively received by correct processes as a result of broadcasts by processes in $L_1$ in the first two asynchronous rounds is $ell_1(c-d)$.
We thus have:
$
  s_A+s_B &>= ell_1(c-d).
$
By combining the previous inequalities, we obtain:
$
  ell_1 a + (c-a) q &>= ell_1 (c-d), \
  
  ell_1 a + c q - a q &>= ell_1 (c-d), \
  
  ell_1 a - a q &>= ell_1 (c-d) - c q, \
  
  a (ell_1-q) &>= ell_1 (c-d) - c q. #<eq:a-fact-sup-l1-fact>
$
By @lem:sufficient-for-quorum, we know that $ell_1 >= c-d > floor((n+t)/2) = q$, so we can rewrite @eq:a-fact-sup-l1-fact into:
$
  a &>= (ell_1 (c-d) - c q)/(ell_1-q). #<eq:min-a-with-l1>
$

// Let us define a function $f$ such that $f(ell_1) = (ell_1(c-d) - c q)/(ell_1-q)$.
To find the lowest guaranteed value for $a$ depending on $ell_1 in [c-d,c]$, let us study the partial derivative w.r.t. $ell_1$ of the right-hand side of @eq:min-a-with-l1:
// we want to find the minimum of $f$ on $ell_1 in [c-d,c]$.
// To this end, let us first study the derivative of $f$.
// The image $f(ell_1)$ is of the form $u/v$, so we have:
$
  partial/(partial ell_1) (ell_1 (c-d) - c q)\/(ell_1-q) &= ((c-d)(ell_1-q)-(ell_1(c-d)-q c))/((ell_1-q)^2) \
  
  &= ((c-d)(ell_1-q)-ell_1(c-d)+q c)/((ell_1-q)^2)
  
  = (q c-q(c-d))/((ell_1-q)^2)
  
  = (q d)/((ell_1-q)^2).
$

As $q$ and $d$ are by definition positive, we know that the above derivative is positive, or zero when $d=0$.
Therefore, $(ell_1 (c-d) - c q)/(ell_1-q)$ is monotonically increasing on $ell_1 in [c-d,c]$, and its minimum value can be found when $ell_1$ is also minimum, that is, when $ell_1 = c-d$.
Thus, when we replace $ell_1$ by $c-d$ in @eq:min-a-with-l1, we obtain:
$
  a &>= ((c-d)(c-d)-c q)/(c-d-q)
  
  = ((c-d)(c-d-q)-q d)/(c-d-q), \
  
  a &>= c-d-(q d)/(c-d-q). #<eq:min-a-without-l1>
$

// Let us denote by $a_"min"$ the minimum number of correct processes#FT[To show the above expression is indeed the minimum, we'd need to show it can indeed be reached in some executions. To work around this caveat, you could just say $a_"min"$ denotes the right-hand side of Equation @eq:min-l-without-l1.] that receive a quorum of strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$ two rounds after $p_i$ mbrb-broadcast $(v,sn)$, such that $a_"min" <= a = |A|$.
#ta[Let us denote by $a_"min"$ the lower bound on the number of correct processes that receive a quorum of strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$ two rounds after $p_i$ mbrb-broadcast $(v,sn)$, such that $a_"min" <= a = |A|$.]
As the right-hand side of @eq:min-a-without-l1 is not always an integer, we have:
$
  a_"min" &= ceil(c-d-(q d)/(c-d-q))
  
  = c-d+ceil(-(q d)/(c-d-q)) \
  
  &= c-d-floor((q d)/(c-d-q))
  &#[(as $forall x in RR, ceil(-x) = -floor(x)$)] \
  
  &= c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2))).
  &#[(by definition of $q$)]
$

Hence, at least $a_"min" = c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$ processes of $L_1$ receive strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$ two rounds after $p_i$ mbrb-broadcasts $(v,sn)$.
For every process $p_y$ of $A$:
- If $p_y$ does not pass the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[] after receiving the last signature of the quorum in a $bundlem$ message, it is necessarily because $p_y$ already mbrb-delivered some $(star,sn,i)$, since processes of $L_1$ are correct and all their $bundlem$ messages include the signature for $(v,sn,i)$ by $p_i$.
  But let us recall that, as the sender $p_i$ is correct, it is impossible for $p_y$ to mbrb-deliver anything different from $(v,sn,i)$.
  Therefore, $p_y$ has already mbrb-delivered $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv.
    
- If $p_y$ passes the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[] after processing the last $bundlem(v,sn,i,{sig_i,sig_x})$ message of the quorum from a process $p_x$, then $p_y$ saves the signature $sig_x$ at @line:sb-mbrb:rcv-save-sigs, and after it passes the condition at @line:sb-mbrb:rcv-cond-dlv (as it has saved strictly more than $(n+t)/2$ signatures) and finally mbrb-delivers $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv.

Therefore, all processes of $A$, which are at least $a_"min" = c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$, mbrb-deliver $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv at most two rounds after $p_i$ mbrb-broadcast $(v,sn)$.
]

#paragraph[Analysis of subsequent communication rounds]
In the following, we use another approach to find the conditions on the message adversary power, $d$, for which @alg:sb-mbrb terminates in 3, 4, or 5 rounds at the latest.
Namely, we focus on the set of correct processes that receive the sender's signature by the end of round 2, and we analyze the average number of distinct signatures received by this set of processes by the end of rounds 2, 3, and 4.
Finally, we rely on the pigeonhole principle to show that, if the average of some round $x$ is greater than the quorum threshold $(n+t)/2$, then at least one correct process has passed this threshold, and can therefore forward this quorum of signatures to at least $lmbrb=c-d$ correct processes, which will then mbrb-deliver the value in round $x+1$.
Interestingly, we show that, if the MBRB sender is correct, @alg:sb-mbrb terminates in at most 5 rounds, even in the worst possible case.

Let $L_1$, $L_2$, $L_3$, and $L_4$ denote the set of correct processes that receive the sender's signature for the first time at the latest by the end of rounds 1, 2, 3 and 4, respectively, and therefore broadcast their own signature at the start of the following round.
We have $L_1 subset.eq L_2 subset.eq L_3 subset.eq L_4$.

#ta[
To show that $lmbrb$ correct processes deliver the value at the latest during some communication round $x in {3,4,5}$, let us remark that it is sufficient to prove that there exists some correct process $p_j$ which observed a quorum of signatures at the latest during the previous round $x-1$, as $p_j$ then disseminates this quorum of signatures to at least $lmbrb=c-d$ other correct processes at @line:sb-mbrb:rcv-bcast-quorum. 
Hence, in the following developments, we analyze the conditions on $d$ under which such a correct process exists in $L_2$.
]

#include "fig/sb-mbrb-msg-dist.typ"

The variables $avg_2$, $avg_3$, and $avg_4$ denote the average number of signatures received by processes of $L_2$ by the end of rounds 2, 3 and 4, respectively.
Let $ell_1 = |L_1|$, $ell_2 = |L_2|$, $ell_3 = |L_3|$ and $ell_4 = |L_4|$.
Assuming that a correct process $p_i$ mbrb-broadcasts $(v,sn)$ and that $n=100$, @fig:sb-mbrb-msg-dist represents the worst-case distribution of signatures for $(v,sn)$ that are received by correct processes by the end of rounds 2, 3, and 4.
We have:
$ c-d <= ell_1 <= ell_2 <= ell_3 <= ell_4 <= c. #<eq:var-frame> $

@fig:sb-mbrb-msg-dist illustrates the special case $n=100$, $t=10$, $d=34$, $c=n-t$, $ell_1=c-d$, $ell_2=70$, $ell_3=82$, and $ell_4=c$.
Moreover, the orange, green, and blue areas represent the sets of signatures sent and received during round 2, 3, and 4, respectively.
As before, we note $q=floor((n+t)/2)$ the (exclusive) quorum threshold.
We can understand from this illustration how to find lower bounds for the values of $avg_2$, $avg_3$, and $avg_4$.

#paragraph[$bold(avg_2)$ lower bound]
First, $avg_2$ is the average number of signatures sent by processes of $L_1$ that are received by the processes of $L_2$.
The set of all signatures sent and received during round 2 corresponds to the orange area of @fig:sb-mbrb-msg-dist.
// #FT[I'd put a capital letter at 'round' when used this way (as for figures), e.g. Round 1, Round 2, ...]
By the definition of the MA, we have the following lower bound:
$ avg_2 &>= (ell_1 (c-d))/ell_2. #<eq:avg2> $


#paragraph[$bold(avg_3)$ lower bound]
Similarly, $avg_3$ equals the average number of signatures received by processes of $L_2$ during round 2 (#ie $avg_2$) plus the average number of signatures sent by processes of $L_2 \\ L_1$ (which received the sender's signature for the first time during round 2) that are received by processes of $L_2$.
In the worst case, the adversary uses the processes of $L_3 \\ L_2$ to "absorb" the maximum amount of signatures sent during this round (#ie each process of $L_3 \\ L_2$ receives the signature of every process of $L_2 \\ L_1$).
However, the remaining signatures must still be distributed among the processes of $L_2$, hence $avg_3 >= avg_2$.
// #FT[Here why is the inequality strict? Why not $avg_3 ≥ avg_2$?]
The set of all signatures sent and received during round 3 is shown as a green area in @fig:sb-mbrb-msg-dist.
Combining all the constraints just discussed on this set of signatures yields the following lower bound on $avg_3$:
$ avg_3 &>= avg_2 + ((ell_2-ell_1) (c-d) - (ell_3-ell_2)(ell_2-ell_1))/ell_2. #<eq:avg3> $

#paragraph[$bold(avg_4)$ lower bound]
Finally, $avg_4$ equals $avg_3$ plus the average number of signatures sent by processes of $L_3 \\ L_2$ that are received by processes of $L_2$.
Similarly, in the worst case, the adversary uses all processes of $L_4 \\ L_2$ to "absorb" the maximum amount of signatures sent during round 3 (#ie each process of $L_4 \\ L_2$ receives the signature of every process of $L_3 \\ L_2$).
The set of all signatures sent and received during round 4 corresponds to the blue area of @fig:sb-mbrb-msg-dist.
The previous constraints yield the following lower bound:
$ avg_4 &>= avg_3 + ((ell_3-ell_2) (c-d) - (ell_4-ell_2)(ell_3-ell_2))/ell_2. #<eq:avg4> $


We now analyze in @lem:avg2-ge to @lem:avg4-quorum the sufficient conditions on $d$ for which $avg_2$, $avg_3$, and $avg_4$ are strictly above the quorum threshold $q=(n+t)/2$.
#ta[These sufficient conditions on $d$ can then be reused to ensure delivery in the round that follows: informally, @lem:dlv-next-round shows that, if $avg_x>q$ where $x in {2,3,4}$, then @alg:sb-mbrb terminates at the latest in round $x+1$.]
// #FT[Maybe guide the reader a little bit more by explaining you'll do this by first lower bounding each average, and using then the Pigeon-hole principle on each bound to derive a sufficient condition on $d$ to ensure delivery in the round that follows.]

#lemma[
$avg_2 >= ((c-d)^2)/c$.
] <lem:avg2-ge>

#proof[
We have the following:
$
  avg_2 &>= (ell_1 (c-d))/ell_2 &#[(by @eq:avg2)] \
  &>= ((c-d)(c-d))/ell_2 #h(3em) &#[(by @eq:var-frame, and as $c-d>=0$)] \
  &= ((c-d)^2)/ell_2.
$
Moreover, we can see that $((c-d)^2)/ell_2$ is minimal when $ell_2$ is maximal, #ie when $ell_2=c$.
Therefore, $avg_2 >= ((c-d)^2)/c$.
]

#lemma[
If $d < c-sqrt(c times (n+t)/2)$, then $avg_2 > (n+t)/2$.
] <lem:avg2-quorum>

#proof[
Let us assume $d < c-sqrt(c times (n+t)/2)$.
Using simple algebraic transformations, we see that
$
d < c-sqrt(c times (n+t)/2) <==> ((c-d)^2)/c > (n+t)/2. $
As $avg_2 >= ((c-d)^2)/c$ by @lem:avg2-ge, we can conclude that $avg_2 >= (n+t)/2$.
]

#lemma[
$avg_3 >= ell_2-ell_3 + (ell_3(c-d))/ell_2$.
] <lem:avg3-ge>

#proof[
We have the following:
$
  avg_3 &>= avg_2 + ((ell_2-ell_1) (c-d) - (ell_3-ell_2)(ell_2-ell_1))/ell_2 &#[(by @eq:avg3)] \
  
  &= avg_2 + ((ell_2-ell_1) (c-d-ell_3+ell_2))/ell_2 \
  
  &= c-d-ell_3+ell_2 + avg_2 + (ell_1(d-c+ell_3-ell_2))/ell_2 \
  
  &>= c-d-ell_3+ell_2 + (ell_1(c-d) + ell_1(d-c+ell_3-ell_2))/ell_2 #h(2em) &#[(by @eq:avg2)] \
  
  &= c-d-ell_3+ell_2 + (ell_1(ell_3-ell_2))/ell_2 \
  
  &>= c-d-ell_3+ell_2 + ((c-d)(ell_3-ell_2))/ell_2 &#[(by @eq:var-frame, and as $ell_3-ell_2>=0$)] \
  
  &= ell_2-ell_3 + (ell_3(c-d))/ell_2.
  #qedhere
$
]

#lemma[
If $d < c-(n+t+2c)^2/(16c)$, then $avg_3 > (n+t)/2$.
] <lem:avg3-quorum>

#proof[
Let us assume $d < c-(n+t+2c)^2/(16c)$.
By @lem:avg3-ge, we have $avg_3 >= ell_2-ell_3 + (ell_3(c-d))/ell_2$.
To show that the lemma assumption implies $avg_3 > (n+t)/2$, we have to find the minimum of $avg_3$ depending on the unknown variables $ell_2$ and $ell_3$, to prove that even in the worst case this minimum is greater than $(n+t)/2$.

Let us note by $f$ the lower bound of $avg_3$, such that $f=ell_2-ell_3 + (ell_3(c-d))/ell_2$.
We first find the partial derivative of $f$ on $ell_3$:
$
  (partial f)/(partial ell_3) = -1 + (c-d)/ell_2 <= -1 + (c-d)/(c-d) <= 0.
$
Therefore, for a fixed $ell_2$, $f$ monotonically decreases when $ell_3$ increases, hence $f$ is minimal when $ell_3$ is maximal, #ie when $ell_3=c$.
Let us note $g$ the new formula obtained by substituting $c$ for $ell_3$ in $f$:
$
  avg_3 >= f >= g = ell_2-c + (c(c-d))/ell_2.
$

We now find the partial derivative of $g$ on $ell_2$:
$
  (partial g)/(partial ell_2) = 1 - (c(c-d))/(ell_2^2).
$

Let us analyze the sign of this derivative:

$
  & 1 - (c(c-d))/(ell_2^2) >= 0 \
  <==>& 1 >= (c(c-d))/(ell_2^2) \
  <==>& ell_2^2 >= (c(c-d)) #h(3em) &#[(as $ell_2^2>=0$)] \
  <==>& ell_2 >= sqrt(c(c-d)). &#[(as the square root function is strictly increasing and $ell_2>=0$)]
$

By substituting $sqrt(c(c-d))$ for $ell_2$ in $g$ we get $sqrt(c(c-d))-c + (c(c-d))/sqrt(c(c-d)) = 2 sqrt(c(c-d)) - c$.
We therefore have the following variations.

#align(center, block(breakable: false, table(columns: 2, inset: 8pt, align: horizon + center,
  // LINE 1
  $ell_2$, [$c$ #h(6em) $sqrt(c(c-d))$ #h(6em) $c-d$],
  // LINE 2
  $(partial g)/(partial ell_2)$, [$-$ #h(5em) $0$ #h(5em) $+$ #h(1em) ],
  // LINE 3
  $g$, [
    #box(baseline: -.5em, canvas({
      draw.line((0, 1), (1.5, 0), mark: (end: "straight"))
    }))
    #h(1em)
    $2 sqrt(c(c-d)) - c$
    #h(1em)
    #box(baseline: -.5em, canvas({
      draw.line((0, 0), (1.5, 1), mark: (end: "straight"))
    }))
  ],
)))

Hence, we have $avg_3 >= g >= 2 sqrt(c(c-d)) - c$.
Moreover, simple algebraic transformations let us see that $d < c-(n+t+2c)^2/(16c) <==> 2 sqrt(c(c-d)) - c > (n+t)/2$.
Therefore, if the lemma assumption is satisfied, then $avg_3 > (n+t)/2$.
]

#lemma[
$avg_4 > (n+t)/2$.
] <lem:avg4-quorum>

#proof[
We have the following:
$
  avg_4 &>= avg_3 + ((ell_3-ell_2) (c-d) - (ell_4-ell_2)(ell_3-ell_2))/ell_2 &#[(by @eq:avg4)] \
  &= avg_3 + ((ell_3-ell_2) (c-d-ell_4+ell_2))/ell_2 \
  &>= avg_3 + ((ell_3-ell_2) (c-d-c+ell_2))/ell_2 #h(5em) &#[(by @eq:var-frame, and as $ell_3-ell_2 >= 0$)] \
  &= avg_3 + ((ell_3-ell_2) (ell_2-d))/ell_2
  = ell_3-ell_2+d + avg_3 - (d ell_3)/ell_2 \
  &>= d + (ell_3(c-d) - d ell_3)/ell_2 &#[(by @lem:avg3-ge)] \
  &= d + (ell_3(c-2d))/ell_2.
$

Let us remark that the minimum of $d + (ell_3(c-2d))/ell_2$ can be found when $ell_2$ is maximal and $ell_3$ is minimal.
By @eq:var-frame, as we have $ell_2 <= ell_3$, this minimum is reached when $ell_2=ell_3$.
Hence, $avg_4 >= d + (ell_3(c-2d))/ell_2 >= d + (ell_2(c-2d))/ell_2 = c-d$, which is strictly greater than $(n+t)/2$ by @lem:sufficient-for-quorum.
]

#lemma[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$ and $avg_x > (n+t)/2$ for $x in {2,3,4}$, then at least $c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most $x+1$ rounds later.
] <lem:dlv-next-round>

#proof[
Let us assume that a correct process $p_i$ mbrb-broadcasts $(v,sn)$ and that $avg_x > (n+t)/2$ for some $x in {2,3,4}$.
If $avg_x$ is strictly greater than the quorum threshold $(n+t)/2$, then, by the pigeonhole principle, some correct process $p_j in L_2$ receives a $bundlem(v,sn,i,sigs)$ message at @line:sb-mbrb:rcv by the end of round $x$, where $sigs$ contains at least a quorum of signatures.
#ta[
We prove that, in any case, $p_j$ must broadcast a quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum.
- Case 1: $p_j$ already mbrb-delivered some value $v'$ with sequence number $sn$ from $p_i$.
  By MBRB-No-duplicity, we have $v'=v$.
  Therefore, before mbrb-delivering $v$ with $sn$ from $p_i$ at @line:sb-mbrb:rcv-dlv, $p_j$ must have broadcast a $bundlem(v,sn,i,sigs')$ message where $sigs$ contains at least a quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum.
- Case 2: $p_j$ did not already mbrb-deliver any value with sequence number $sn$ from $p_i$.
  Then, after receiving the $bundlem(v,sn,i,sigs)$ message, $p_j$ saves all valid signatures of $sigs$ at @line:sb-mbrb:rcv-save-sigs, passes the condition at @line:sb-mbrb:rcv-cond-dlv (as $|sigs|>(n+t)/2$), and forward this quorum of signatures to the network in a $bundlem$ message at @line:sb-mbrb:rcv-bcast-quorum.
Therefore, $p_i$ necessarily broadcasts a $bundlem$ message containing a quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum.
]
By the definition of the message adversary, this $bundlem$ message is received by at least $c-d$ correct processes at @line:sb-mbrb:rcv, by the end of round $x+1$.
All these $c-d$ correct processes then save all signatures in $sigs$ at @line:sb-mbrb:rcv-save-sigs, pass the condition at @line:sb-mbrb:rcv-cond-dlv and mbrb-deliver $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv (as MBRB-No-duplicity ensures no other value $v' != v$ is mbrb-delivered for this sender $p_i$ and sequence number $sn$).
]

#lemma([MBRB-Time-cost])[
In #emph[@alg:sb-mbrb], if a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then $lmbrb = c-d$ correct processes mbrb-deliver $v$ from $p_i$ with sequence number $sn$ at most $rtc$ communication rounds later, where: \
$ rtc = mat(delim: "{",
  2, &"if" d = 0", else"&;
  3, &"if" d < c-sqrt(c times (n+t)/2)", else"&;
  4, &"if" d < c-(n+t+2c)^2/(16c)", else"&;
  5, &"otherwise"&
). $
] <lem:sb-mbrb-time-cost>

#proof[
Let us consider a correct process $p_i$ that mbrb-broadcasts $(v,sn)$.
By exhaustion:

- Case where $d = 0$.
    
  By @lem:amt-dlv-2-rnd, at least $c-d-floor((d floor((n+t)/2))/(c-d-floor((n+t)/2)))$ correct processes mbrb-deliver $(v,sn,i)$ two rounds after $p_i$ has mbrb-broadcast $(v,sn)$.
  By replacing $d$ by $0$, in this formula, we obtain that all $c$ correct processes mbrb-deliver $(v,sn,i)$ at most 2 rounds after $p_i$ has mbrb-broadcast $(v,sn)$.
    
- Case where $d < c-sqrt(c times (n+t)/2)$.

  If $d < c-sqrt(c times (n+t)/2)$, @lem:avg2-quorum applies and thus $avg_2 > (n+t)/2$.
  Then, @lem:dlv-next-round states that at least $lmbrb=c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most 3 rounds after $p_i$ has mbrb-broadcast $(v,sn)$.

- Case where $d < c-(n+t+2c)^2/(16c)$.

  If $d < c-(n+t+2c)^2/(16c)$, @lem:avg3-quorum applies and thus $avg_3 > (n+t)/2$.
  Then, @lem:dlv-next-round states that at least $lmbrb=c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most 4 rounds after $p_i$ has mbrb-broadcast $(v,sn)$.

- Remaining case.

  @lem:avg4-quorum always applies and thus $avg_4 > (n+t)/2$.
  Then, @lem:dlv-next-round states that at least $lmbrb=c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most 5 rounds after $p_i$ has mbrb-broadcast~$(v,sn)$.
  #qedhere
]

#ta[
#paragraph[Tightness conjecture]
@lem:sb-mbrb-time-cost shows that the previous constraints on $d$ are sufficient conditions for @alg:sb-mbrb to terminate (#ie $lmbrb$ correct processes mbrb-deliver the value mbrb-broadcast by a correct sender) in at most 2, 3, 4, or 5 rounds, respectively.
// #FT[I've use a present tense. It's an "eternal truth", so continues to hold.]
We conjecture that these conditions are also necessary for @alg:sb-mbrb, as the upper bounds on $d$ that we have obtained were constructed by considering the worst-case strategy of the message adversary, where the received signatures are evenly distributed among the correct processes of $L_2$ to delay the delivery by a correct process for as long as possible.
One angle of attack for proving this conjecture could be to show that the first correct process that observes a quorum of signatures (and thus mbrb-delivers the sender's value) is necessarily a process of $L_2$ (#ie a process that has seen the sender's signature at the latest during round 2), which seems to be verified according to numerical tests we have performed.

// We can show that, for every round $x in {2,3,4}$, the average of signatures received by processes of $L_2$ is always strictly greater than the average of signatures received by the other correct processes that are not in $L_2$.
// , therefore the first correct process to mbrb-deliver is always a process from $L_2$.
// #TA[Do we have to prove this? The rest of the analysis holds without this]
// #FT[It's not clear to me what this is the case. Also the statement can be confusing: we don't know if it's true only during round 2, or at each subsequent round (which is what you mean I think.)]
// For this reason, we only consider in this proof the average number of signatures received by processes of $L_2$.

#figure(placement: auto,
  image("plot/sb-mbrb-good-case-latency-max-d.svg", width: 78%),
  caption: [Maximum values of $d$ depending on $t$ for a termination in at most 2 rounds (in black), 3 rounds (in orange), 4 rounds (in green), or 5 rounds (in blue), assuming $n=100$ and $c=n-t$]
) <fig:sb-mbrb-gcl-max-d>

#paragraph[Visualization of the upper bounds of $bold(d)$]
In @fig:sb-mbrb-gcl-max-d, we illustrate the _inclusive_ upper bounds of $d$ depending on $t$ for obtaining a termination of @alg:sb-mbrb in at most 2, 3, 4, or 5 rounds (@lem:sb-mbrb-time-cost).
#footnote[
  Recall that, by "@alg:sb-mbrb terminates in at most $x$ rounds" where $x in {2, 3, 4, 5}$, we mean that, if a correct sender $p_i$ mbrb-broadcasts some $(v,sn)$, then at least $lmbrb=c-d$ correct processes mbrb-deliver $(v,sn,i)$ at most $x$ rounds later.
]
We consider the case $n=100$ and $c=n-t$, hence, by #sb-mbrb-assum, we have $0 <= t <= 33$ and $0 <= d <= 49$.
The values of these upper bounds are taken directly from @lem:sb-mbrb-time-cost
#footnote[
  Given the _exclusive_ upper bounds on $d$ of @lem:sb-mbrb-time-cost, we find the corresponding _inclusive_ upper bounds by observing that $forall d in NN, x in RR: d < x <==> d <= ceil(x)-1$.
]:
- the black line represents the fact that @alg:sb-mbrb terminates in at most 2 rounds if $d=0$;
- the orange steps represent the fact that @alg:sb-mbrb terminates in at most 3 rounds if $0 < d <= ceil(c-sqrt(c times (n+t)/2))-1$;
- the green steps represent the fact that @alg:sb-mbrb terminates in at most 4 rounds if $ceil(c-sqrt(c times (n+t)/2))-1 < d <= ceil(c-(n+t+2c)^2/(16c)) - 1$;
- the blue steps represent the fact that @alg:sb-mbrb terminates in at most 5 rounds in the worst case, #ie if $ceil(c-(n+t+2c)^2/(16c)) - 1 < d <= ceil((n-3t)/2)-1$.
  The _exclusive_ upper-bound of $d < (n-3t)/2$ is derived from #sb-mbrb-assum, which states that $n>3t+2d$.
]

#lemma([MBRB-Message-cost])[
In #emph[@alg:sb-mbrb], the mbrb-broadcast of a value $v$ by a correct process $p_i$ entails the sending of at most $omc = 2n^2$ messages by correct processes overall.
] <lem:sb-mbrb-msg-cost>

#proof[
The broadcast of a message by a correct process at @line:sb-mbrb:snd-bcast entails its forwarding by at most $n-1$ other correct processes at @line:sb-mbrb:rcv-fwd.
As each broadcast by correct processes corresponds to the sending of $n$ messages, then at most $n^2$ messages are sent in a first step.

In a second step, at least one correct process reaches a quorum of signatures and passes the condition at @line:sb-mbrb:rcv-cond-dlv, and then broadcasts this quorum of signatures at @line:sb-mbrb:rcv-bcast-quorum.
Upon receiving this quorum, every correct process also passes the condition at @line:sb-mbrb:rcv-cond-dlv (if it has not done it already) and broadcasts the message containing the quorum at @line:sb-mbrb:rcv-bcast-quorum.
Hence, at most $n^2$ messages are also sent in this second step, which amounts to a maximum of $omc = 2n^2$ messages sent in total.
]

#lemma([MBRB-Communication-cost])[
In #emph[@alg:sb-mbrb], the mbrb-broadcast of a value $v$ by a correct process $p_i$ entails the sending of at most $bcc=O(n^2|v|+n^3 secp)$ bits by correct processes overall.
] <lem:sb-mbrb-comm-cost>

#proof[
Let us first characterize the size of the different data structures included in the $bundlem$ messages of @alg:sb-mbrb.
Firstly, $|v|$ denotes the size of the applicative value $v$.
We assume the size of the sequence number $sn$ to be constant, hence it is #ta[negligible in the following analysis].
// #FT[I'd drop 'symptotically negligible'. 'Asymptotically' could refer to several limit behavior, including sending arbitrary large numbers of messages, in which case $sn$ would not be asymptotically negligible.]
The identity $i$ of the sender is encoded in $O(log n)$ bits.
Finally, the set of signatures $sigs$ contains at most a quorum of $O(n)$ signature (of $O(secp)$ bits), implicitly accompanied by the signer's identity (of $O(log n)$ bits).
This amounts to $O(n (secp + log n))$ bits for a set $sigs$.
Hence, a $bundlem$ message has $O(|v| + log n + n (secp + log n))$ bits in total, which we can simplify to $O(|v| + n secp)$, since we have $secp = Omega(log n)$ by assumption (see @sec:sig-mbrb-prelim).

Since correct processes communicate $O(n^2)$ messages overall (see @lem:sb-mbrb-msg-cost), it means that they send $bcc = O(n^2|v| + n^3 secp)$ bits overall. 
]
