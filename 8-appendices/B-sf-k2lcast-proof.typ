#import "../setup.typ": *

= Proof of the \ Signature-Free $k2l$-cast \ Implementation (@alg:sf-k2lcast)

#let lval = $ceil(c(1-d/(c-q_d+1)))$

== Safety of @alg:sf-k2lcast <sec:sf-k2lcast-safety>

#lemma[
If a correct process $p_i$ $k2l$-delivers $(v,id)$, then at least $(q_f-n+c)$ correct processes have broadcast _$endorsem(v,id)$_ at @line:sf-k2l:bcast.
] <lem:n-bcast-if-kldv>

#proof[
If $p_i$ $k2l$-delivers $(v,id)$ at @line:sf-k2l:dlv, then it received $q_d$ copies of $endorsem(v,id)$ (because of the predicate at @line:sf-k2l:cond-dlv).
The effective number of Byzantine processes in the system is $n-c$, such that $0 <= n-c <= t$.
Therefore, $p_i$ must have received at least $q_d-n+c$ (which is strictly positive because $q_d >= q_f > t >= n-c$ by @assum:base) messages $endorsem(v,id)$ that correct processes broadcast, either during a $k2lcast(v,id)$ invocation at @line:sf-k2l:bcast, or during a forwarding step at @line:sf-k2l:fwd.
There are two cases.

- If no correct process has forwarded $endorsem(v,id)$ at @line:sf-k2l:fwd, then at least $q_d-n+c >= q_f-n+c$ (as $q_d >= q_f$ by @assum:base) correct processes have broadcast $endorsem(v,id)$ at @line:sf-k2l:bcast.
  
- If at least one correct process forwarded $endorsem(v,id)$, then let us consider $p_j$, the first correct process that forwards $endorsem(v,id)$.
  Because of the predicate at @line:sf-k2l:cond-fwd, $p_j$ must have received at least $q_f$ distinct copies of the $endorsem(v,id)$ message, out of which at most $n-c$ have been broadcast by Byzantine processes, and at least $q_f-n+c$ (which is strictly positive because $q_f > t >= n-c$ by @assum:base) have been sent by correct processes.
  Moreover, as $p_j$ is the first correct process that forwards $endorsem(v,id)$, all of the $q_f-n+c$ $endorsem$ messages it receives from correct processes must have been sent at @line:sf-k2l:bcast. #qedhere
]

#lemma([$k2l$-Validity])[
If a correct process $p_i$ $k2l$-delivers a value $v$ with identity $id$, then at least $k'=q_f-n+c$ correct processes have $k2l$-cast $v$ with $id$.
] <lem:sf-k2l-validity>

#proof[
The condition at @line:sf-k2l:cond-bcast implies that the correct processes that broadcast $endorsem(v,id)$ at @line:sf-k2l:bcast constitute a subset of those that $k2l$-cast $(v,id)$.
Thus, by @lem:n-bcast-if-kldv, their number is at least $k'=q_f-n+c$.
]

#lemma([$k2l$-No-duplication])[
A correct process $p_i$ $k2l$-delivers a value $v$ with identity $id$ at most once.
] <lem:sf-k2l-no-duplication>

#proof[
This property derives trivially from the predicate at @line:sf-k2l:cond-dlv.
]

#lemma([$k2l$-Conditional-no-duplicity])[
If the Boolean $nodpty = ((q_f > (n+t)/2) or (single and q_d > (n+t)/2))$ is $ttrue$, then no two different correct processes $k2l$-deliver different values with the same identity $id$.
] <lem:sf-kl-conditional-no-duplicity>

#proof[
Let $p_i$ and $p_j$ be two correct processes that respectively $k2l$-deliver $(v,id)$ and $(v',id)$. We want to prove that, if the predicate $((q_f > (n+t)/2) or (single and q_d > (n+t)/2))$ is satisfied, then $v=v'$.
There are two cases. 

- Case $(q_f > (n+t)/2)$.
  
  We denote by $A$ and $B$ the sets of correct processes that have respectively broadcast $endorsem(v,id)$ and $endorsem(v',id)$ at @line:sf-k2l:bcast.
  By @lem:n-bcast-if-kldv, we know that $|A| >= q_f-n+c > (n+t)/2-n+c$ and $|B| >= q_f-n+c > (n+t)/2-n+c$.
  As $A$ and $B$ contain only correct processes, we have $|A inter B| > 2((n+t)/2-n+c)-c = t-n+c >= t-t = 0$.
  Hence, at least one correct process $p_x$ has broadcast both $endorsem(v,id)$ and $endorsem(v',id)$ at @line:sf-k2l:bcast}.
  But because of the predicate at @line:sf-k2l:cond-bcast, $p_x$ broadcasts at most one message $endorsem(star,id)$ at @line:sf-k2l:bcast.
  We conclude that $v$ is necessarily equal to $v'$.

- Case $(single and q_d > (n+t)/2)$.
  
  Thanks to the predicate at @line:sf-k2l:cond-dlv, we can assert that $p_i$ and $p_j$ must have respectively received at least $q_d$ distinct copies of $endorsem(v,id)$ and $endorsem(v',id)$, from two sets of processes, that we respectively denote $A$ and $B$, such that $|A| >= q_d > (n+t)/2$ and $|B| >= q_d > (n+t)/2$.
  We have $|A inter B| > 2(n+t)/2-n = t$.
  Hence, at least one correct process $p_x$ has broadcast both $endorsem(v,id)$ and $endorsem(v',id)$.
  But because of the predicates at @line:sf-k2l:cond-bcast[lines] and @line:sf-k2l:cond-fwd[], and as $single = ttrue$, $p_x$ broadcasts at most one message $endorsem(star,id)$, either during a $k2lcast(v,id)$ invocation at @line:sf-k2l:bcast or during a forwarding step at @line:sf-k2l:fwd.
  We conclude that $v$ is necessarily equal to $v'$. #qedhere
]

== Liveness of @alg:sf-k2lcast <sec:sf-k2lcast-liveness>

// #plain-thm(number: [@lem:l-fact-min])[
// $ell_e times (k_U+k_F-q_d+1) >= (k_U+k_F)(c-d-q_d+q_f) - c(q_f-1) - k_NB (q_d-q_f)$.
// ]
#lemma(number: [@lem:l-fact-min[]])[
$ell_e times (k_U+k_F-q_d+1) >= (k_U+k_F)(c-d-q_d+q_f) - c(q_f-1) - k_NB (q_d-q_f)$.
]

// #restate-thm(<lem:l-fact-min>)

#proof[
Combining @eq:sup-on-wAc, @eq:sup-on-wBc, @eq:sup-on-wCc and @eq:sup-all-witness yields:

// Typst 0.11.1 does not have an \intertext{} replacement yet
// REF: https://github.com/typst/typst/issues/1079
$
  (k_U+k_F)ell_e + (q_d-1)&(k_NF+k_NB+k_F-ell_e) + \
  & #h(5em) (q_f-1)(c-k_NF-k_NB-k_F) >= (k_U+k_F)(c-d), \
  
  ell_e times (k_U+k_F-q_d+1) &>= (k_U+k_F)(c-d) - (q_d-1)(k_NF+k_NB+k_F) - \
  & #h(13.5em) (q_f-1)(c-k_NF-k_NB-k_F), \
  
  &>= (k_U+k_F)(c-d) - (q_d-q_f)(k_NF+k_NB+k_F) - c(q_f-1).
$

Using @assum:base, we have $q_d-q_f >= 0$.
By definition, we also have $k_NF <= k_U$, which yields:

$
  ell_e times (k_U+k_F-q_d+1) &>= (k_U+k_F)(c-d) - (q_d-q_f)(k_U+k_F+k_NB) - c(q_f-1), \
  
  &>= (k_U+k_F)(c-d-q_d+q_f) - c(q_f-1) - k_NB (q_d-q_f). #qedhere
$
]

#lemma(number: [@lem:k2lcast-if-fwd[]])[
If no correct process $k2l$-casts $(v',id)$ with $v' != v$, then no correct process forwards _$endorsem(v',id)$_ at @line:sf-k2l:begin-fwd (and then $k_NB = 0$).
]

#proof[
Assume there is a correct process that broadcasts $endorsem(v',id)$ at @line:sf-k2l:fwd} with $v' != v$.
Let us consider the first such process $p_i$.
To execute @line:sf-k2l:fwd, $p_i$ must first receive $q_f$ messages $endorsem(v',id)$ from distinct processes.
Since $q_f > t$ (@assum:base), at least one of these processes, $p_j$, is correct.
Since $p_i$ is the first correct process to forward $endorsem(v',id)$ at @line:sf-k2l:fwd, the $endorsem(v',id)$ message of $p_j$ must come from @line:sf-k2l:bcast}, and $p_j$ must have $k2l$-cast $(v',id)$.
We have assumed that no correct process $k2l$-cast $v' != v$, therefore $v'=v$. Contradiction.

We conclude that, under these assumptions, no correct process broadcasts $endorsem(v',id)$ with $v' != v$, be it at @line:sf-k2l:bcast (by assumption) or at @line:sf-k2l:fwd (shown by this proof).
As a result, $k_NB = 0$. \
]

#lemma([$k2l$-Local-delivery], number: [@lem:sf-k2l-local-delivery[]])[
If at least $k=floor((c(q_f-1))/(c-d-q_d+q_f))+1$ correct processes $k2l$-cast a value $v$ with identity $id$ and no correct process $k2l$-casts any value $v'$ with identity $id$ such that $v != v'$, then at least one correct process $p_i$ $k2l$-delivers $v$ with identity $id$.
]

#proof[
Let us assume that no correct process $k2l$-casts $(v',id)$ with $v' != v$.
No correct process therefore broadcasts $endorsem(v',id)$ with $v' != v$ at @line:sf-k2l:bcast.
@lem:k2lcast-if-fwd also applies and no correct process forwards $endorsem(v',id)$ with $v != v$ at @line:sf-k2l:fwd either, so $k_NB = 0$.
Because no correct process broadcasts $endorsem(v',id)$ with $v' != v$ whether at @line:sf-k2l:bcast[lines] or~@line:sf-k2l:fwd[], a correct process receives at most $t$ messages $endorsem(v',id)$ (all coming from Byzantine processes).
As by @assum:base, $t < q_d$, no correct process $k2l$-delivers $(v',id)$ with $v' != v$ at @line:sf-k2l:dlv.

We now prove the contraposition of the Lemma.
Let us assume no correct process $k2l$-delivers $(v,id)$.
Since, by our earlier observations, no correct process $k2l$-delivers $(v',id)$ with $v' != v$ either, the condition at @line:sf-k2l:cond-dlv implies that no correct process ever receives at least $q_d$ $endorsem(v,id)$, and therefore $ell_e = 0$.
By @lem:l-fact-min we have $c(q_f-1) >= (k_U+k_F)(c-d-q_d+q_f)$. 
@assum:base implies that $c-d-q_d >= 0 <==> c-d-q_d+q_f > 0$ (as $q_f >= t+1 >= 1$), leading to $k_U+k_F <= (c(q_f-1))/(c-d-q_d+q_f)$.
Because of the condition at @line:sf-k2l:cond-bcast, a correct process $p_j$ that has $k2l$-cast $(m,id)$ but has not broadcast $endorsem(v,id)$ at @line:sf-k2l:bcast has necessarily broadcast $endorsem(v,id)$ at @line:sf-k2l:fwd.
We therefore have $k_I <= k_U + k_F$, which gives $k_I <= (c(q_f-1))/(c-d-q_d+q_f$.
By contraposition, if $k_I > (c(q_f-1))/(c-d-q_d+q_f)$, then at least one correct process must $k2l$-deliver $(v,id)$.
Hence, we have $k = floor((c(q_f-1))/(c-d-q_d+q_f)) + 1$.
]

#lemma(number: [@lem:single-if-kNB[]])[
$(single = ffalse) ==> (k_NB = 0)$.
]

#proof[
Let us consider a correct process $p_i in A union B$.
If we assume $p_i in.not F$, $p_i$ never executes @line:sf-k2l:fwd by definition.
Because $p_i in A union B$, $p_i$ has received at least $q_f$ messages $endorsem(v,id)$, and therefore did not fulfill the condition at @line:sf-k2l:cond-fwd when it received its $q_f$#super[th] message $endorsem(v,id)$.
As $single = ffalse$ by Lemma assumption, to falsify this condition, $p_i$ must have had already broadcast $endorsem(v,id)$ when this happened.
Because $p_i$ never executes @line:sf-k2l:fwd, this implies that $p_i$ broadcasts $endorsem(v,id)$ at @line:sf-k2l:bcast, and therefore $p_i in NF$.
This reasoning proves that $A union B \\ F subset.eq NF$.
As the sets $F$, $NF$ and $NB$ partition $A union B$, this shows that $NB=diameter$, and $k_NB=|diameter|=0$.
]

#lemma(number: [@lem:polynom-if-one[]])[
If at least one correct process $k2l$-delivers $(v,id)$ and $x=k_U+k_F$ (the number of correct processes that broadcast _$endorsem(v,id)$_ at @line:sf-k2l:bcast or~@line:sf-k2l:fwd[]), then $x >= q_d-t$ and $x^2 - x(c-d+q_f-1-k_NB) >= -(c-k_NB)(q_f-1)$.
]

#proof[
Let us write $w_A^b$ the total number of $endorsem(v,id)$ messages from Byzantine processes received by the processes of $A$, and $w_A=w_A^c+w_A^b$ the total of number $endorsem(v,id)$ messages received by the processes of $A$, whether these $endorsem$ messages originated from correct or Byzantine senders.
By definition, 
$w_A^b <= t ell_e$ and $w_A >= q_d ell_e$.
By combining these two inequalities with @eq:sup-on-wAc on $w_A^c$ we obtain:

$
  q_d ell_e <= w_A = w_A^c + w_A^b &<= (k_U+k_F)ell_e + t ell_e = (t+k_U+k_F) ell_e, \
  q_d &<= t + k_U + k_F, #tag[as $ell_e>0$] \
  q_d-t &<= k_U+k_F = x. #<eq:kU-lambda-qmt>
$

This proves the first inequality of the lemma.
The processes in $A union B$ each receive at most $k_U+k_F$ distinct $endorsem(v,id)$ messages from correct processes, so we have $w_A^c + w_B^c <= (k_NF+k_F+k_NB)(k_U+k_F)$.
Combined with the inequalities~@eq:sup-on-wCc on $w_C^c$ and @eq:sup-all-witness on $w_A^c+w_B^c+w_C^c$ that remain valid in this case, we now have:
$
  & (k_NF+k_F+k_NB)(k_U+k_F) + (q_f-1)(c-k_NF-k_NB-k_F) >= (k_U+k_F)(c-d), \
  
  & (k_NF+k_F+k_NB)(k_U+k_F-q_f+1) >= (k_U+k_F)(c-d) - c(q_f-1). #<eq:kappaLambda-geq>
$

Let us determine the sign of $(k_U+k_F-q_f+1)$.
We derive from @eq:kU-lambda-qmt:

$
  k_U+k_F-q_f+1 &>= q_d-t-q_f+1 \
  &>= 1 > 0. #tag[as $q_d-q_f >= t$ by @assum:base]
$

As $(k_U+k_F-q_f+1)$ is positive and we have $k_U >= k_NF$ by definition, we can transform @eq:kappaLambda-geq into:
$
  (k_U+k_F+k_NB)(k_U+k_F-q_f+1) &>= (k_U+k_F)(c-\tm) - c(q_f-1), \
  (x+k_NB)(x-q_f+1) &>= x(c-d) - c(q_f-1), #tag[as $x=k_U+k_F$] \
  x^2 - x(c-d+q_f-1-k_NB) &>= -(c-k_NB)(q_f-1). #qedhere
$
]

#lemma(number: [@lem:enough-if-one[]])[
If $k_NB=0$, and at least one correct process $k2l$-delivers $(v,id)$, then $k_U+k_F >= q_d$.
]

#proof[
By @lem:polynom-if-one we have:
$
  x^2& - x(c-d+q_f-1-k_NB) >= -(c-k_NB)(q_f-1). #<eq:polynom-if-one-start>
$

As @eq:polynom-if-one-start holds for all, values of $c in [n-t,n]$, we can in particular consider $c=n-t$.
Moreover, as by hypothesis, $k_NB=0$, we have. 
$
  x^2 & - x(n-t-d+ q_f - 1) + (q_f -1) (n-t) >= 0, \
  
  x^2 & - alpha x + (q_f - 1) (n-t) >= 0. & #tag[by definition of $alpha$] #<eq:ineq-polynomial-no-kNB>
$

Let us first observe that the discriminant of the second-degree polynomial in @eq:ineq-polynomial-no-kNB is nonnegative, #ie $alpha^2-4(q_f-1)(n-t) >= 0$ by @assum:disc.
This allows us to compute the two real-valued roots as follows:
$
  r_0 &= alpha/2 - sqrt(alpha^2 - 4 (q_f-1)(n-t))/2 #[~~~~~~and~~~~~~]
  r_1 = alpha/2 + sqrt(alpha^2 - 4 (q_f-1)(n-t))/2.
$

Thus @eq:ineq-polynomial-no-kNB is satisfied if and only if $x <= r_0 or x >= r_1$.

- Let us prove $r_0 <= q_d-1-\tb$.
  We need to show that: 
  $
    alpha/2 - sqrt(alpha^2 - 4 (q_f-1)(n-t))/2 & <= q_d -1 -t \
    
    alpha/2-(q_d-1)+t &<= sqrt(alpha^2-4(q_f-1)(n-t))/2 \
    
    sqrt(alpha^2-4(q_f-1)(n-t))/2 &>= alpha/2-(q_d-1)+t \
    
    sqrt(alpha^2-4(q_f-1)(n-t)) &>= alpha-2(q_d-1)+2t.
  $
  
  The inequality is trivially satisfied if $alpha-2(q_d-1)+2t < 0$.
  For all other cases, we need to verify that:
  $
    alpha^2 - 4 (q_f-1)(n -t) & >= (alpha - 2(q_d -1) + 2t)^2, \
    
    alpha^2 - 4 (q_f-1)(n-t) & >= alpha^2 + 4(q_d -1)^2 + 4t^2 -4 alpha(q_d -1) +4 alpha t- 8 t(q_d-1), \
    
    - 4 (q_f-1)(n-t) & >= 4(q_d -1)^2 + 4t^2 -4 alpha(q_d -1) +4 alpha t- 8 t(q_d-1), \
    
    - (q_f-1)(n-t) & >= (q_d-1)^2 + t^2 - alpha(q_d -1) + alpha t -2t(q_d-1), \
    
    - (q_f-1)(n-t) & >= (q_d-1-t)^2 - alpha(q_d -1 -t),
  $
  and thus $alpha(q_d-1-t)-(q_f-1)(n-t)-(q_d-1-t)^2 >= 0$, which is true by @assum:r0.

- Let us prove $r_1 > q_d-1$.
  We want to show that: 
  $
    alpha/2 + sqrt(alpha^2 - 4(q_f-1)(n-t))/2 & > q_d -1.
  $
  
  Let us rewrite the inequality as follows:
  $
    alpha + sqrt(alpha^2 - 4 (q_f-1)(n-t)) &> 2(q_d -1) \
    
    sqrt(alpha^2 - 4 (q_f-1)(n-t)) &> 2(q_d-1) -  alpha.
  $
  
  The inequality is trivially satisfied if $2(q_d-1) -alpha < 0$. 
  For all other cases, we can take the squares as follows:
  $
    alpha^2 - 4(q_f-1)(n-t) & > (2(q_d-1)- alpha)^2, \
    
    alpha^{2} - 4 (q_f-1)(n-t) & > 4(q_d-1)^2 + alpha^2 -4 alpha(q_d -1), \
    
    - 4 (q_f-1)(n-t) &> 4(q_d-1)^2 -4 alpha(q_d -1), \
    
    4 alpha(q_d -1) - 4 (q_f -1)(n-t) - 4(q_d-1)^2 & > 0, \
    
    alpha(q_d -1) - (q_f-1)(n-t) - (q_d-1)^2 &> 0,
  $
  which is true by @assum:r1.

We now know that $r_0 <= q_d-1-t$ and that $r_1 > q_d-1$.
In addition, as $x <= r_0 or x >= r_1$, we have $x <= q_d-t-1 or x > q_d-1$.
But @lem:polynom-if-one states that $x >= q_d-t$, which is incompatible with $x <= q_d-t-1$.
So we are left with $x > q_d-1$, which implies, as $q_d$ and $x$ are integers that $x >= q_d$, thus proving the lemma for $c=n-t$. 

Let us now consider the set $E_0$ of all executions in which $t$ processes are Byzantine, and therefore $c=n-t$, and a set $E_c$ of executions in which there are fewer Byzantine processes, and thus $c > n-t$ correct processes. 
We show that $E_c subset.eq E_0$ in that a Byzantine process can always simulate the behavior of a correct process.
In particular, if the simulated correct process is not subject to the message adversary, the simulating Byzantine process simply operates like a correct process.
If, on the other hand, the simulated correct process misses some messages as a result of the message adversary, the Byzantine process can also simulate missing such messages.
As a result, the executions that can happen when $c > n-t$ can also happen when $c=n-t$.
Thus, our result proven for $c=n-t$ can be extended to all possible values of $c$.
]

#lemma(number: [@lem:ell-if-enough[]])[
If $k_NB = 0$ and $k_U+k_F >= q_d$, then at least $lval$ correct processes $k2l$-deliver some value with identity $id$ (not necessarily $v$).
]

#proof[
As $k_NB=0$ and $k_U+k_F>= q_d$, we can rewrite the inequality of @lem:l-fact-min into:
$
  ell_e times (k_U+k_F-q_d+1) >= (k_U+k_F)(c-d-q_d+q_f) - c(q_f-1).
$

From $k_U+k_F >= q_d$ we derive $k_U+k_F-q_d+1>0$, and we transform the above inequality into:
$
  ell_e &>= ((k_U+k_F)(c-d-q_d+q_f) - c(q_f-1))/(k_U+k_F-q_d+1).
$

Let us now focus on the case in which $c=n-t$, we obtain:
$
  ell_e &>= ((k_U+k_F)(n-t-d-q_d+q_f) - (n-t)(q_f-1))/(k_U+k_F-q_d+1).
$

The right side of the inequality is of the form:
$
  ell_e &>= (phi x - beta)/(x-gamma) = phi + (phi gamma - beta)/(x-gamma) #<eq:case1-ell-ge>
$
with:
$
  x &= k_U+k_F, \
  
  gamma &= q_d-1, \
  
  alpha &= n-t-d+q_f-1, \
  
  phi &= n-t-d-q_d+q_f, \
  
  beta &= c(q_f-1).
$
Since, by hypothesis, $x = k_U+k_F >= q_d$, we have:
$
  x-gamma = k_U+k_F-q_d+1 > 0. #<eq:xmgamma-gz>
$
We also have:
$
  phi gamma - beta &= (alpha - gamma) gamma - c(q_f-1) = alpha gamma - gamma^2 - c(q_f-1), \
  
  &= alpha(q_d-1)-(q_d - 1)^2 - (n-t)(q_f -1) > 0, #tag[by @assum:r1] \
  
  phi gamma - beta &> 0. #<eq:phigammambeta-gz>
$

Injecting @eq:xmgamma-gz and @eq:phigammambeta-gz into @eq:case1-ell-ge, we conclude that $phi + (phi gamma - beta)/(x-gamma)$ is a _decreasing hyperbole_ defined over $x in ]gamma,oo]$ with _asymptotic value_ $phi$ when $x -> oo$.
As $x$ is a number of correct processes, $x<= c$.
The decreasing nature of the right-hand side of @eq:case1-ell-ge leads us to:
$ ell_e >= phi + (phi gamma - beta)/(c-gamma)
= (phi c - beta)/(c-gamma) >= (c(c-d-q_d+q_f) - c(q_f-1))/(c-q_d+1)
>= c times (c-d-q_d+1)/(c-q_d+1) = c(1-d/(c-q_d+1))$.

Since $ell_e$ is a positive integer, we conclude that at least $ell_sans("min")=lval$ correct processes receive at least $q_d$ message $endorsem(v,id)$ at @line:sf-k2l:cond-dlv.
As each of these processes either $k2l$-delivers $(v,id)$ when this first happens, or has already $k2l$-delivered another value $v' != v$ with identity $id$, we conclude that at least $ell_sans("min")$ correct processes $k2l$-deliver some value (whether it be $v$ or $v' != v$) with identity $id$ when $c=n-t$.
The reasoning for extending this result to any value of $c in [n-t,n]$ is identical to the one at the end of the proof of @lem:enough-if-one just above.
]

#lemma([$k2l$-Weak-Global-delivery], number: [@lem:sf-k2l-weak-global-delivery[]])[
If $single = ffalse$, and a correct process $k2l$-delivers a value $v$ with identity $id$, then at least $ell = lval$ correct processes $k2l$-deliver a value $v'$ with identity $id$ (each possibly different from $v$).
]

#proof[
Let us assume $single = ffalse$, and one correct process $k2l$-delivers $(v,id)$.
By @lem:single-if-kNB, $k_NB = 0$.
The prerequisites for @lem:enough-if-one are verified, and therefore $k_U+k_F >= q_d$.
This provides the prerequisites for @lem:ell-if-enough, from which we conclude that at least $ell = lval$ correct processes $k2l$-deliver a value $v'$ with identity $id$, which concludes the proof of the lemma.
]

#lemma([$k2l$-Strong-Global-delivery], number: [@lem:sf-k2l-strong-global-delivery[]])[
If $single = ttrue$, and a correct process $k2l$-delivers a value $v$ with identity $id$, and no correct process $k2l$-casts a value $v' != v$  with identity $id$, then at least $ell = lval$ correct processes $k2l$-deliver $v$ with identity $id$.
]

#proof[
Let us assume that _(i)_ $single = ttrue$, _(ii)_ no correct process $k2l$-casts $(v',id)$ with $v' != v$, and _(iii)_ one correct process $k2l$-delivers $(v,id)$.
@lem:k2lcast-if-fwd holds and implies that $k_NB = 0$.
From there, as above, @lem:enough-if-one[Lemmas] and~@lem:ell-if-enough[] hold, and at least $ell=lval$ correct processes $k2l$-deliver a value for identity $id$.
  
By hypothesis, no correct process broadcasts $endorsem(v',id)$ at @line:sf-k2l:bcast with $v' != v$.
Similarly, because of @lem:k2lcast-if-fwd, no correct process broadcasts $endorsem(v',id)$ at @line:sf-k2l:fwd with $v' != v$.
As a result, a correct process can receive at most receive $t$ messages $endorsem(v',id)$ at @line:sf-k2l:cond-dlv (all from Byzantine processes).
As $q_d>t$ (by @assum:base), the condition of @line:sf-k2l:cond-dlv never becomes true for $v' != v$, and as result no correct process delivers a value $v' != v$ with identity $id$.
All processes that $k2l$-deliver a value with identity $id$, therefore, $k2l$-deliver $v$, which concludes the lemma.
]
