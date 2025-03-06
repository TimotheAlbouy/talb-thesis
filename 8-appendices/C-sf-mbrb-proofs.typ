#import "../setup.typ": *

= Proof of the Signature-Free \ MBRB Implementations

#let lval = $ceil(c(1-d/(c-q_d+1)))$

The proofs of correctness that follow use integer arithmetic.
Given a real number $x$ and an integer $i$, let us recall that $x-1 < floor(x) <= x <= ceil(x) < x+1$, $floor(x+i) = floor(x)+i$, $ceil(x+i) = ceil(x)+i$, $floor(-x) = -ceil(x)$, $(i > x) <==> (i >= floor(x)+1)$, $(i < x) <==> (i <= ceil(x)-1)$.

//  of Bracha's MBRB (@alg:bracha-mbrb) and Imbs-Raynal's MBRB (@alg:imbs-raynal-mbrb) given in this section

== Proof of Bracha's reconstructed MBRB (@alg:bracha-mbrb) <sec:bracha-mbrb-proof>

#let Bbound = $3t + 2d + 2 sqrt(t d)$
#let Bl = $ceil(c (1-d/(c-2t-d)))$

=== Instantiating the parameters of the $k2l$-cast objects

In @alg:bracha-mbrb (#pageref(<alg:bracha-mbrb>)), we instantiate the $k2l$-cast objects $obj_E$ and $obj_R$ using the signature-free implementation presented in @sec:sf-k2lcast.
Let us mention that, given that $obj_E.single = obj_R.single = ttrue$, then we use the strong variant of the global-delivery property of $k2l$-cast ($k2l$-Strong-Global-delivery) for both objects $obj_E$ and $obj_R$.
Moreover, according to the definitions of $k'$, $k$, $ell$ and $nodpty$ and their values stated in @th:sf-k2l-correctness, we have:

- $obj_E.k' = obj_E.q_f-n+c = t+1-n+c >= t+1-t = 1$,
    
- $obj_E.k &= floor((c(obj_E.q_f-1))/(c-d-obj_E.q_d+obj_E.q_f)) + 1
  = floor((c(t+1-1))/(c-d-floor((n+t)/2)-1+t+1)) + 1 \
  &= floor((c t)/(c-d-floor((n-t)/2))) + 1,$
  
- $obj_E.ell &=
  ceil(c (1-d/(c-obj_E.q_d+1)))
  = ceil(c (1 - d/(c-floor(n+t)/2)-1+1)) \
  &= ceil(c (1 - d/(c-floor((n+t)/2)))),$
  
- $obj_E.nodpty &= ((obj_E.q_f > (n+t)/2) or (obj_E.single and obj_E.q_d > (n+t)/2)) \
  &= ((t+1 > (n+t)/2) or (ttrue and floor((n+t)/2) + 1 > (n+t)/2))
  = (ffalse or (ttrue and ttrue)) \
  &= ttrue,$
  
- $obj_R.k' = obj_R.q_f-n+c = t+1-n+c >= t+1-t = 1$,
  
- $obj_R.k
  &= floor((c(obj_R.q_f-1))/(c-d-obj_R.q_d+obj_R.q_f)) + 1
  = floor((c(t+1-1))/(c-d-2t-d-1+t+1)) + 1 \
  &= floor((c t)/(c-2d-t)) + 1,$
  
- $obj_R.ell
  &= ceil(c(1-d/(c-obj_R.q_d+1)))
  = ceil(c(1-d/(c-2t-d-1+1))) \
  &= ceil(c(1-d/(c-2t-d))),$
  
- $obj_R.nodpty
  &= ((obj_R.q_f > (n+t)/2) or (obj_R.single and obj_R.q_d > (n+t)/2)) \
  &= ((t+1 > (n+t)/2) or (ttrue and 2t+d+1 > (n+t)/2))
  in {ttrue,ffalse}.$

We recall that parameter $nodpty$ controls the conditional no-duplicity property.
The value for $obj_E.nodpty$ is $ttrue$, but that of value for $obj_R.nodpty$ may be either $ttrue$ or $ffalse$ depending on the values of $n$, $t$, and $d$.
This is fine because, in Bracha's reconstructed algorithm (@alg:bracha-mbrb), it is the first round ($obj_E$) that ensures no-duplicity.
Once this has happened, the second round ($obj_R$) does not need to provide no-duplicity but only needs to guarantee the termination properties of local and global delivery.
This observation allows $obj_R$ to operate with lower values of $q_d$ and $q_f$.

#let Bformula = $2t+d+sqrt(t^2+6t d+d^2)$

Finally, we observe that for @alg:bracha-mbrb, @assum:base[sf-$k2l$-Assumptions] through~@assum:r0[] are all satisfied by #b87assum $n > Bbound$.
In the following, we prove that $Bbound >= Bformula >= 3t+2d$.

#observation[
For $d,t in NN_0$ non-negative integers, we have: 
$
  Bbound >= Bformula >= 3t+2d.
$
] <obs:boundBracha>

#proof[
Let us start by proving the first inequality. 
$
  t^2 + 6 t d + d^2 + 4 sqrt(t d)(t+d) &>= t^2 + 6 t d + d^2, \
  
  t^2 + d^2 + 4 t d + 4 t sqrt(t d) + 4 d sqrt(t d) + 2 t d &>= t^2 + 6 t d + d^2, \
  
  (t + d + 2 sqrt(t d))^2 &>= t^2 + 6 t d + d^2, \
  
  t + d +2 sqrt(t d) &>= sqrt(t^2 + 6 t d + d^2), \
  
  3t + 2d +2 sqrt(t d) &>= 2t+d + sqrt(t^2 + 6 t d + d^2).
$

Let us then prove the second inequality:
$
  t^2 + 6 t d + d^2 &>= t^2 + 2 t d + d^2 = (t+d)^2, \
  
  sqrt(t^2 + 6 t d + d^2) &>= t+d, \
  
  2 t + d + sqrt(t^2 + 6 t d + d^2) &>= 3t+2d. #qedhere
$
]

=== Proof of satisfaction of the assumptions of @alg:sf-k2lcast
In the following, we prove that all the assumptions of the signature-free $k2l$-cast implementation presented in @alg:sf-k2lcast (#pageref(<alg:sf-k2lcast>)) are well respected for the two $k2l$-cast instances used in @alg:bracha-mbrb ($obj_E$ and $obj_R$).

#lemma[
_@alg:sf-k2lcast'_s sf-$k2l$-Assumptions are well respected for $obj_E$.
] <lem:proof-objE>

#proof[
Let us recall that $q_f = t+1$ and $q_d= floor((n+t)/2)+1$ for $obj_E$.

- _Proof of satisfaction of _@assum:base ($c-d >= obj_E.q_d >= obj_E.q_f+t >= 2t+1$):

  By #b87assum and @obs:boundBracha, we have the following:
  $
    c-d &>= n-t-d = (2n-2t-2d)/2, #tag[by definition of $c$] \
    
    &> (n+3t+2d-2t-2d)/2 = (n+t)/2, #tag[as $n > 3t+2d$] \
    
    &>= floor((n+t)/2)+1. #<eq:b-echo-asmp-1-1>
  $
  We also have:
  $
    floor((n+t)/2)+1 &>= floor((3t+2d+1+t)/2)+1, #tag[as $n > 3t+2d$] \
    
    &>= floor(2t+d+1/2)+1 = 2t+d+1 >= 2t+1. #<eq:b-echo-asmp-1-2> \
  $
  By combining (@eq:b-echo-asmp-1-1) and (@eq:b-echo-asmp-1-2), we get:
  $
    & c-d >= floor((n+t)/2)+1 >= 2t+1 >= 2t+1, \
    
    & c-d >= obj_E.q_d >= obj_E.q_f+t >= 2t+1. #tag[@assum:base]
  $

- _Proof of satisfaction of_ @assum:disc ($alpha^2-4(obj_E.q_f-1)(n-t) >= 0$):

  Let us recall that, for object $obj_E$, we have $q_f=t+1$ and $q_d=floor((n+t)/2)+1$.
  We therefore have $alpha = n+q_f-t-d-1 = n-d$.
  Let us now consider the quantity:
  $
    Delta &= alpha^2 - 4 (q_f-1)(n-t) = (n-d)^2 - 4t (n-t) \
    &= 4t^2 + d^2 + n^2 + n (-4t - 2d).
  $
  The inequality is satisfied if $n > 2 sqrt(t d) + 2t+d$, which is clearly the case as $n > Bbound$.
  This proves @assum:disc. 


- _Proof of satisfaction of_ @assum:r1 ($alpha(obj_E.q_d-1)-(obj_E.q_f-1)(n-t)-(obj_E.q_d-1)^2 > 0$):

  Let us consider the quantity on the left-hand side of @assum:r1 and substitute $q_f=t+1$, $q_d=floor((n+t)/2) + 1$:
  $
    & alpha (q_d-1) - (q_f-1) (n-t) - (q_d-1)^2, \
    
    =& (n + q_f - t - d - 1) (q_d - 1) - (q_f-1) (n-t) - (q_d - 1)^2, \
    
    =& (n - d) (floor((n+t)/2)) - t(n-t) - (floor((n+t)/2))^2. #<eq:brEr1-beforeCases>
  $
  
  We now observe that $(floor((n+t)/2)) = ((n+t-epsilon)/2)$ with $epsilon=0$ if $n+t=2k$ is even, and $epsilon=1$ if $n+t=2k+1$ is odd.
  We thus rewrite @eq:brEr1-beforeCases as follows:
  $
    & (n - d) ((n+t-epsilon)/2) - t (n-t) - ((n+t-epsilon)/2)^2, \
    
    =& (n+t-epsilon)/2 times (2n-2d-n-t+epsilon)/2 - t (n-t), \
    
    =& ((n+t-epsilon) (n-2d-t+epsilon) - 4t (n-t))/4, \
    
    =& (n^2 - t^2 - 2 t d + 2 t epsilon - 2n d + 2 d epsilon - epsilon^2 - 4 n t + 4t^2)/4, \
    
    =& (n^2 + 3t^2 - 2 t d - 2 n(d +2t) + epsilon (2t+2d-epsilon))/4.
  $
  
  As we want to show that the above quantity is positive, the result will not change if we multiply it by 4:
  $
    &n^2 +3 t^2 - 2 t d - 2 n(d+2t) + epsilon(2t+2d-epsilon)>0. #<eq:assum-r1brEbeforeN>
  $
  
  We now solve the inequality to obtain: 
  $
    n &> 2 t + d + sqrt(t^2 + 6 t d + d^2 - epsilon(2 t + 2 d - epsilon)).
  $
  
  We observe that, for $t+d >= 1$, the quantity $- epsilon(2t + 2d - epsilon)$ is strictly negative if $epsilon=1$, therefore if $epsilon=1 or t+d >= 1$:
  $
    n &> Bbound, \
    
    &>= t + d + sqrt(t^2 + 6 t d + d^2), #tag[by @obs:boundBracha] \
    
    &>= 2t + d + sqrt(t^2 + 6 t d + d^2 - epsilon(2 t + 2 d - epsilon)).
  $
  
  This leaves out the case $(t=d=0) and (n=2k+1 "is odd")$, for which we can show that @eq:assum-r1brEbeforeN is positive or null for $n >= 1$:
  $
    #[@eq:assum-r1brEbeforeN]:& n^2 +3t^2 - 2 t d - 2 n(d+2t) + epsilon(2t+2d-epsilon), \
    
    &= n^2-1 >= 0 "for" n >= 1.
  $
  This completes the proof of @assum:r1.


- _Proof of satisfaction of_ @assum:r0 ($alpha(obj_E.q_d-1-t)-(obj_E.q_f-1)(n-t)-(obj_E.q_d-1-t)^2 >= 0$):

  Let us consider the quantity on the left-hand side of @assum:r0 and substitute 
  $q_f=t+1$, $q_d=floor((n+t)/2)+1$:
  $
    & alpha(q_d - 1 - t) - (q_f - 1) (n - t) - (q_d - 1 - t)^2, \
    
    &= (n + q_f - t - d - 1) (q_d -1 - t) - (q_f -1) (n - t) - (q_d - 1 - t)^2, \
    
    &= (n - d) (floor((n+t)/2) - t) - t (n - t) -(floor((n+t)/2) - t)^2. #<eq:brEr0-beforeCases>
  $

  Like before, we observe that $floor((n+t)/2) = (n+t-epsilon)/2$ with $epsilon=0$ if $n+t=2k$ is even, and $epsilon=1$ if $n+t=2k+1$ is odd.
  We thus rewrite @eq:brEr0-beforeCases as follows:
  $
    & (n-d) ((n+t-epsilon)/2 - t) - t (n - t) - ((n+t-epsilon)/2 - t)^2, \
    
    &= (n-d) times (n-t-epsilon)/2 - t (n - t) - ((n-t-epsilon)/2)^2, \
    
    &= (n-t-epsilon)/2 times (2n - 2d - n + t+ epsilon)/2 - t (n - t), \
    
    &= ((n-t-epsilon) (n - 2d + t + epsilon) - 4 n t + 4t^2)/4, \
    
    &= (-t^2 + 2 t d - 2 t epsilon + 2 d epsilon - 2 d n - epsilon^2 + n^2)/4.
  $
  
  As we want to show that the above quantity is non-negative, the result will not change if we multiply it by 4:
  $
    & - t^2 + 2 t d - 2 t epsilon + 2 d epsilon - epsilon^2 - 2 d n + n^2.
  $
  
  We then solve the inequality to obtain: $n >= max(t+epsilon, -t+2d-epsilon)$, which is clearly satisfied as $n>=Bbound+1$.
  This proves all previous inequality and thus @assum:r0. \
]

#lemma[
_@alg:sf-k2lcast'_s sf-$k2l$-Assumptions are well respected for $obj_R$.
]

#proof[
Let us recall that $q_f = t+1$ and $q_d = 2t+d+1$ for $obj_R$.
Let us observe that we have then $q_d-q_f-t-d=0$.

- _Proof of satisfaction of_ @assum:base ($c-d >= obj_R.q_d >= obj_R.q_f+t >= 2t+1$):

  From @obs:boundBracha, we have:
  $
    & c-d >= n-t-d >= 3t+2d+1-t-d >= 2t+d+1, #tag[as $n > 3t+2d$] \
    
    & c-d >= 2t+d+1 >= 2t+1 >= 2t+1, \
    
    & c-d >= obj_R.q_d >= obj_R.q_f+t >= 2t+1. #tag[@assum:base]
  $

- _Proof of satisfaction of_ @assum:disc ($alpha^2-4(obj_R.q_f-1)(n-t) >= 0$):
  
  Let us recall that, for object $obj_R$, we have $q_f=t+1$ and $q_d=2t+d+1$.
  As @assum:disc depends on $q_d$ but not on $q_f$, and since $obj_E.q_f = obj_R.q_f$, we refer the reader to the proof we gave in @lem:proof-objE for $obj_E$. 
  
- _Proof of satisfaction of_ @assum:r1 ($alpha(obj_R.q_d-1) - (obj_R.q_f-1)(n-t)-(obj_R.q_d-1)^2 > 0$):
  
  Let us consider the quantity on the left-hand side of @assum:r1: 
  $
    & alpha (q_d - 1) - (q_f-1) (n-t) - (q_d - 1)^2 \
    
    =& (n + q_f - t - d - 1) (q_d - 1) - (q_f - 1) (n - t) - (q_d - 1)^2 \
    
    =& (n - d) (2t + d) - t (n - t) - (2t + d)^2 \
    
    =& 2 n t + n d - 2 t d - d^2 - n t + t^2 - 4 t^2 - d^2 - 4 t d
    
    = n(t + d) - 6 t d - 2d^2 - 3t^2 \
    
    =& n(t + d) - (6 t d + 2d^2 +3t^2). #<eq:assum-r1brR-beforebound>
  $
  
  Then, we observe that we can lower bound the quantity on the left side of @eq:assum-r1brR-beforebound by substituting #b87assum, #ie $n > Bbound >= Bformula$.
  For convenience, in the following, we write $rho = t^2 + 6 t d + d^2$, thus $n > 2t + d + sqrt(rho)$.
  We get:
  $
    n(t+d)-(3t^2 + 6 t d + 2d^2)
    
    &> (2t + d + sqrt(rho)) (t + d) -(3t^2 + 6 t d + 2d^2) \
    
    &= sqrt(rho)(t+d) - d^2 - t^2 - 3 t d.
  $
  
  We now want to show that the above quantity is positive or null, #ie 
  $
    & sqrt(rho)(t+d) - d^2 - t^2 - 3 t d >= 0. #<eq:assum-r1brR-afterbound2>
  $
  We now rewrite @eq:assum-r1brR-afterbound2 as follows:
  $
    sqrt(rho)(t+d) &>= d^2 + t^2 + 2 t d + t d, \
    
    sqrt(rho)(t+d) &>= (d + t)^2 + t d, \
    
    (t^2 + 6 t d + d^2) (t + d)^2 &>= ((d + t)^2 + t d)^2, #tag[as $(d + t)^2 + t d >= 0$] \
    
    ((t + d)^2 + 4 t d) (t + d)^2 &>= ((d + t)^2 + t d)^2, \
    
    (t + d)^4 + 4 t d (t + d)^2 &>= (d + t)^4 + (t d)^2 + 2 t d (t + d)^2, \
    
    2 t d (t + d)^2 &>= (t d)^2, \
    
    2 t d (t^2 + d^2 + 2 t d) &>= (t d)^2, \
    
    2 t d (t^2 + d^2) + 4(t d)^2 &>= (t d)^2, \
    
    2 t d (t^2 + d^2) + 3(t d)^2 &>= 0.
  $
  
  This proves @eq:assum-r1brR-afterbound2, all previous inequalities, and ultimately @assum:r1.
  
- _Proof of satisfaction of_ @assum:r0 ($alpha(obj_R.q_d-1-t) - (obj_R.q_f-1) (n-t) - (obj_R.q_d-1-t)^2 >= 0$):
  
  Let us consider the quantity on the left-hand side of @assum:r0:
  $
    & alpha(q_d - 1 - t) - (q_f -1) (n - t) - (q_d -1 - t)^2 #<eq:assum-r0brR-goal> \
    
    =& (n + q_f - t - d - 1) (q_d - 1 - t) - (q_f -1) (n - t) - (q_d - 1 - t)^2 \
    
    =& (n - d) (t + d) - t(n - t) - (t + d)^2
    
    = (t + d)(n - 2 d - t) - t(n - t) \
    
    =& n t + n d - 2 t d - 2 d^2 - t^2 - t d - n t + t^2
    
    = n d - 3 t d - 2 d^2 \
    
    =& d (n - 3 t - 2 d). #<eq:assum-r0brR-beforebound> 
  $ #TA[TO CHECK]
  
  Like before, we observe that we can lower bound the quantity on the left side of @eq:assum-r0brR-beforebound by substituting #b87assum, #ie $n>Bbound >= 3t+2d$, so we have:
  $
    d (n - 3t - 2d)
    > d (3t+2d-2d-3t) = 0. #<eq:assum-r0brR-final>
  $
  which recursively proves that @eq:assum-r0brR-goal is positive or zero, and thus @assum:r0. #qedhere
]

=== MBRB proof of @alg:bracha-mbrb
We prove in the sequel the following theorem.

#theorem([MBRB-Correctness])[
If _ #b87assum _ is verified, then _ @alg:bracha-mbrb _ implements MBRB with the guarantee $lmbrb = ceil(c (1-d/(c-2t-d)))$.
] <th:b-mbrb-correctness>

The proof follows from the next lemmas.

#lemma[
$c-d >= obj_E.k$.
] <lem:echo-sufficient>

#proof[
We want to show that:
$
  c-d &>= floor((c t)/(c-d-floor((n-t)/2)))+1 = obj_E.k. #<eq:proofEk-start>
$

As the left-hand side is also an integer, we can rewrite @eq:proofEk-start as follows:
$
  c-d &> (c t)/(c-d-floor(n-t)/2), \
  
  (c-d)(c-d-floor((n-t)/2)) &> c t. #tag[as $(c-d-floor((n-t)/2)>0$]
$

We now observe that $(floor((n+t)/2)) = ((n+t-epsilon)/2)$ with $epsilon=0$ if $n+t=2k$ is even, and $epsilon=1$ if $n+t=2k+1$ is odd, which leads us to:
$
  (c - d)(c-d- (n-t-epsilon)/2) &> c t, \
  
  (c - d)(2c - 2d - n + t + epsilon) &> 2 c t, \
  
  (c - d)(2c - 2d- n + t + epsilon) - 2 c t &> 0.
$

Like for the proofs of @lem:enough-if-one and @lem:ell-if-enough, we leverage the fact that the executions that can happen when $c > n-t$ can also occur when $c = n-t$.
We thus rewrite our inequality for $c=n-t$:
$
  (n-t-d) (n-t-2d+epsilon) - 2(n-t)t &> 0, \
  
  (n-t)(n-t-2d+epsilon-2t) - d(n-t-2d+epsilon) &> 0, \
  
  (n-t)^2 + (n-t)(-2d+epsilon-2t) - d(n-t-2d+epsilon) &> 0, \
  
  n^2 + t^2 - 2 n t - 2 n d + n epsilon - 2 n t + 2 t d - t epsilon + 2 t^2 - n d + t d + 2 t^2 - epsilon d &> 0, \
  
  n^2 + 3t^2 - 4 n t - 3 n d + n epsilon + 3 t d - t epsilon + 2d^2 - epsilon d &> 0, \
  
  n^2 - n (4t + 3d - epsilon) + 3t^2 + 3 t d + 2d^2 - epsilon (t+d) &> 0.
$

We now solve the second-degree inequality with respect to $n$.
It is easy to see that the discriminant is non-negative for non-negative values of $t$ and $d$.
So we obtain: 
$
  & n > 2 t + (3d)/2 - epsilon/2 + sqrt(4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2)/2, \
  
  & -4t - 3d + epsilon + 2n - sqrt(4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2) > 0,
$
which is implied by the following as $n >= 3t + 2d + 2 sqrt(t d) + 1$:
$
  & 4 sqrt(t d) + 2t + d + 2 + epsilon - sqrt(4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2) > 0, \
  
  & 4 sqrt(t d) + 2 t + d + 2 + epsilon > sqrt(4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2).
$

Taking the squares as both the argument of the square root and the left-hand side are non-negative leads to:
$
  (4 sqrt(t d) + 2t + d + epsilon + 2)^2 > 4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2,& \
  
  16 t^(3/2) sqrt(d) + 8 sqrt(t) d^(3/2) + 8 sqrt(t) sqrt(d) epsilon + 16 sqrt(t) sqrt(d) + 4t^2 + 20 t d + 4 t epsilon + 8t + d^2 + 2 d epsilon
  
  + 4d + epsilon^2 + 4 epsilon + 4&
  
  \ > 4t^2 + 12 t d - 4 t epsilon + d^2 - 2 d epsilon + epsilon^2, &
$
which simplifies to:
$
  16t^(3/2) sqrt(d) + 8 sqrt(t) d^(3/2) + 8 sqrt(t) sqrt(d) epsilon + 16 sqrt(t) sqrt(d) + 8 t d + 8 t epsilon + 8t + 4 d epsilon
  + 4d + 4 epsilon + 4 > 0. #<eq:proofek-final>
$

We can then easily  observe that the left-hand side of @eq:proofek-final is strictly positive, thereby proving all previous inequalities and thus the lemma. 
]

#lemma[
$obj_E.ell >= obj_R.k$.
] <lem:ready-sufficient>

#proof[
We need to prove: 
$
  obj_E.ell &= ceil(c (1-d/(c-floor((n+t)/2)))) >= floor((c t)/(c-2d-t))+1 = obj_R.k. #<eq:proofel-start>
$

For two real numbers $x$ and $m$, we observe that $x >= floor(m)+1$ if and only if $x > m$, and that $m >= floor(m)$.
Therefore @eq:proofel-start is implied by the following:
$
  c (1 - d/(c - (n + t - epsilon)/2)) &>= (c t)/(c - t - 2d), \
  
  c - (2 d c)/(2 c - t - n + epsilon) &> (c t)/(c - t - 2d).
$
As both denominators are positive, we can solve: 
$
  & -t (-t + 2c + epsilon - n) - 2d (-t - 2d + c) + (-t - 2d + c) (-t + 2c + epsilon - n) > 0, \
  
  & -t (-t + 2c + epsilon - n) + (-t - 2d + c) (-t -2d + 2c + epsilon - n) > 0, \
  
  & -t (-2t + c + epsilon) + (-t - 2d + c) (-2t - 2d + c + epsilon) > 0, #tag[as $c>= n - t$] \
  
  & -t (-2t + c + epsilon) + (-t - 2d + c) (-2t - 2d + c + epsilon) > 0, \ 
  
  & -t (-t + 2c - n) + epsilon (- 3t - 2d + c) + (-t - 2d + c)^2 > 0, \
  
  & t^2 - 2 t c + d n + epsilon (-3t - 2d + c) + (-t - 2d + c)^2 > 0, \
  
  & t^2 - 2 t c + t (2 sqrt(t) sqrt(d) + 3t + 2d + 1) + epsilon (-3t - 2d + c) + (-t - 2d + c)^2 > 0, \
  & #h(20em) #tag[as $n >= 3t + 2d +2 sqrt(t d)$] \
  
  & 2t^(3/2) sqrt(d) + 4t^2 + 2 t d - 2 t c + t + epsilon (-3t - 2d + c) + (-t - 2d + c)^2 > 0, \
  
  & 2t^(3/2) sqrt(d) + 5t^2 + 6 t d - 4 t c + t + 4 d^2 - 4 d c + c^2 + epsilon (-3t - 2d + c) > 0.
$ #TA[FIXME]

We now consider the two possible values of $epsilon$:

- $epsilon = 0$:
  $
    & 2t^(3/2) sqrt(d) + 5t^2 + 6 t d - 4 t c + t + 4 d^2 - 4 d c + c^2 > 0. #<eq:proofel-tosolve>
  $

  We solve the inequality with respect to $c$ to obtain (when the discriminant is positive): 
  $
    c &> 2t + 2d + sqrt(-2t^(3/2) sqrt(d) - t^2 + 2 t d - t),
  $
  which we prove by observing that $c >= n-t >= 2t + 2d + 2 sqrt(t d)+1$ and that: 
  $
    & 2t + 2d + 2 sqrt(t d) + 1 > 2t + 2d + sqrt(-2t^(3/2) sqrt(d) - t^2 + 2 t d - t),
  $
  as all terms except $2 t d$ inside the square root are negative.
  When the discriminant is negative (#eg for $d=0$),  inequality @eq:proofel-tosolve is satisfied for all values of $c$.

- $epsilon = 1$:

  In this case, we obtain:
  $
    & 2t^(3/2) sqrt(d) + 5t^2 + 6 t d - 4 t c - 2 t + 4 d^2 - 4 d c - 2 d + c^2 + c > 0,
  $
  which is implied by a negative discriminant or by:
  $
    & c > 2t + 2d + sqrt(- 2t^(3/2) sqrt(d) - t^2 + 2 t d + 1/4) - 1/2.
  $

  Like before, we simply observe that:
  $
    2 sqrt(t d) &>= sqrt(2 t d) + 1/2 - 1/2, \
    
    2 sqrt(t d) &>= sqrt(2 t d + 1/4) - 1/2, \
    
    2 sqrt(t d) &>= sqrt(-2t^(3/2) sqrt(d) - t^2 + 2 t d + 1/4) - 1/2,
  $
  thereby proving the second case and the lemma. #qedhere
]

#lemma([MBRB-Validity])[
If a correct process $p_i$ mbrb-delivers a value $v$ from a correct process $p_j$ with sequence number~$sn$, then $p_j$ mbrb-broadcast $v$ with sequence number~$sn$.
] <lem:b-mbrb-validity>

#proof[
If $p_i$ mbrb-delivers $(v,sn,j)$ at @line:b-mbrb:mbrb, then it $k2l$-delivered $(readym(v),(sn,j))$ using $obj_R$.
From $k2l$-Validity, and as $obj_R.k' = 1$, we can assert that at least one correct process $p_x$ $k2l$-cast $(readym(v),(sn,j))$ at @line:b-mbrb:ready, after having $k2l$-delivered $(echom(v),(sn,j))$ using $obj_E$.
Again, from $k2l$-Validity, we can assert that at least $obj_E.k' = 1$ correct process $p_y$ $k2l$-cast $(echom(v),(sn,j))$ at @line:b-mbrb:echo, after having received an $initm(v,sn)$ message from $p_j$.
And as $p_j$ is correct and the network channels are authenticated, then $p_j$ has broadcast $initm(v,sn)$ at @line:b-mbrb:mbrb, during a $mbrbbroadcast(v,sn)$ invocation.
]

#lemma([MBRB-No-duplication])[
A correct process $p_i$ mbrb-delivers at most one value from a process $p_j$ with sequence number~$sn$.
] <lem:b-mbrb-no-duplication>

#proof[
By $k2l$-No-duplication, we know that a correct process $p_i$ can $k2l$-deliver at most one $readym(star)$ with identity $(sn,j)$.
Therefore, $p_i$ can mbrb-deliver only one value from $p_j$ with sequence number~$sn$. 
]

#lemma([MBRB-No-duplicity])[
No two different correct processes mbrb-deliver different values from a process $p_i$ with the same sequence number~$sn$.
] <lem:b-mbrb-no-duplicity>

#proof[
We proceed by contradiction. Let us consider two correct processes $p_w$ and $p_x$ that respectively mbrb-deliver~$(v,sn,i)$ and $(v',sn,i)$ at @line:b-mbrb:dlv, such that $v != v'$.
It follows that $p_w$ and $p_x$ respectively $k2l$-delivered $(readym(v),(sn,i))$ and $(readym(v'),(sn,i))$ using $obj_R$.

From $k2l$-Validity, and as $obj_R.k' >= 1$, we can assert that two correct processes $p_y$ and $p_z$ respectively $k2l$-cast $(readym(v),(sn,i))$ and $(readym(v'),(sn,i))$ at @line:b-mbrb:ready, after having respectively $k2l$-delivered $(echom(v),(sn,i))$ and $(echom(v'),(sn,i))$ using $obj_E$.
But as $obj_E.nodpty = ttrue$, then, by $k2l$-No-duplicity, we know that $v = v'$.
There is a contradiction.
]

#lemma([MBRB-Local-delivery])[
If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number~$sn$, then at least one correct process $p_j$ eventually mbrb-delivers $v$ from $p_i$ with sequence number~$sn$.
] <lem:b-mbrb-local-delivery>

#proof[
If $p_i$ mbrb-broadcasts $(v,sn)$ at @line:b-mbrb:mbrb, then it invokes broadcasts $initm(v,sn)$.
By the definition of the MA, the message $initm(v,sn)$ is then received by at least $c-d$ correct processes at @line:b-mbrb:echo, which then $k2l$-cast $(echom(v),sn,i)$.
As $p_i$ is correct and broadcasts only one message $initm(star,sn)$, then no correct process $k2l$-casts any different $(echom(star),sn,i)$.
Moreover, thanks to @lem:echo-sufficient, we know that:
$
  c-d >= obj_E.k = floor((c t)/(c-d -floor((n-t)/2))) + 1.
$

Hence, from $k2l$-Local-delivery and $k2l$-Strong-Global-delivery, at least $obj_E.ell = ceil(c (1-d/(c-floor((n+t)/2))))$ correct processes eventually $k2l$-deliver $(echom(v),(sn,i))$ using $obj_E$ and then $k2l$-cast $(readym(v),(sn,i))$ using $obj_R$ at @line:b-mbrb:ready.
By $k2l$-Validity, and as $obj_R.k' >= 1$, then no correct process can $k2l$-cast a different $(readym(star),(sn,i))$, because otherwise it would mean that at least one correct process would have $k2l$-cast a different $(echom(star),(sn,i))$, which is impossible (see before).
Moreover, thanks to @lem:ready-sufficient, we know that:
$
  ceil(c (1-d/(c-floor((n+t)/2)))) = obj_E.ell >= obj_R.k = floor((c t)/(c-2d-t)) + 1.
$

Therefore, $k2l$-Local-delivery applies and we know that at least one correct processes eventually $k2l$-delivers~$(readym(v),(sn,i))$ using $obj_R$ and then mbrb-delivers~$(v,sn,i)$ at @line:b-mbrb:dlv.
]

#lemma([MBRB-Global-delivery])[
If a correct process $p_i$ mbrb-delivers a value $v$ from a process $p_j$ with sequence number~$sn$, then at least $lmbrb = ceil(c (1-d/(c-2t-d)))$ correct processes mbrb-deliver $v$ from $p_j$ with sequence number~$sn$.
] <lem:b-mbrb-global-delivery>

#proof[
If $p_i$ mbrb-delivers $(v,sn,j)$ at @line:b-mbrb:dlv, then it has $k2l$-delivered $(readym(v),(sn,j))$ using $obj_R$.
From $k2l$-Validity, we know that at least $obj_R.k' >= 1$ correct process $k2l$-cast $(readym(v),(sn,j))$ using $obj_R$ at @line:b-mbrb:ready and thus $k2l$-delivered $(echom(v),(sn,j))$ using $obj_E$.
From $k2l$-No-duplicity, and as $obj_E.nodpty = ttrue$, we can state that no correct process $k2l$-delivers any $(echom(v'),(sn,j))$ where $v' != v$ using $obj_E$, so no correct process $k2l$-casts any $(readym(v'),(sn,j))$ where $v' != v$ using $obj_R$ at @line:b-mbrb:ready.
It means that $k2l$-Strong-Global-delivery applies, and we can assert that at least $obj_R.ell = ceil(c (1-d/(c-2t-d))) = lmbrb$ correct processes eventually $k2l$-deliver~$(readym(v),(sn,j))$ using $obj_R$ and thus mbrb-deliver $(v,sn,j)$ at @line:b-mbrb:dlv.
]

== Proof of Imbs-Raynal's reconstructed MBRB (@alg:imbs-raynal-mbrb) <sec:imbs-raynal-mbrb-proof>

#let IRbound = $5t + 12d + (2 t d)/(t+2d)$
#let IRl = $ceil(c (1 - d/(c-floor((n+3t)/2)-3d)))$
#let IRqd = $floor((n+3t)/2)+3d+1$
#let IRqf = $floor((n+t)/2)+1$
#let IRk = $floor((c floor((n+t)/2))/(c-t-4d)) + 1$
#let IRl = $ceil(c (1- d/(c-floor(n+3t)/2 -3d)))$

=== Instantiating the parameters of the $k2l$-cast object
In @alg:imbs-raynal-mbrb (#pageref(<alg:imbs-raynal-mbrb>)), we instantiate the $k2l$-cast object $obj_W$ using the signature-free implementation presented in @sec:sf-k2lcast with parameters $q_d=IRqd$, $q_f=IRqf$, and $single=ffalse$.
Based on @th:sf-k2l-correctness (#pageref(<th:sf-k2l-correctness>)), these parameters lead to the following values for $k'$, $k$, $ell$ and $nodpty$.

- $obj_W.k' &= obj_W.q_f-n+c = IRqf -n+c \
  &>= IRqf - n + n - t = floor((n-t)/2)+1,$
  
- $obj_W.k &= floor((c(obj_W.q_f-1))/(c-d-obj_W.q_d + obj_W.q_f)) + 1
  = floor((c(IRqf -1))/(c-d-(IRqd) + IRqf))+1 \
  &= IRk,$
  
- $obj_W.ell &= ceil(c (1-d/(c-obj_W.q_d+1)))
  = ceil(c (1-d/(c- (IRqd) +1))) \
  &= IRl,$
  
- $obj_W.nodpty &= ((obj_W.q_f > (n+t)/2) or (obj_W.single and obj_W.q_d > (n+t)/2))
  = (ttrue or (ffalse and ttrue)) \
  &= ttrue.$

Finally, we observe that for @alg:imbs-raynal-mbrb, @assum:base[sf-$k2l$-Assumptions] through~@assum:r0[] are all satisfied by #ir16assum ($n > IRbound$).

=== Proof of satisfaction of the assumptions of @alg:sf-k2lcast
This section proves that all the assumptions of the signature-free $k2l$-cast implementation presented in @alg:sf-k2lcast (#pageref(<alg:sf-k2lcast>)) are well respected for the $k2l$-cast instance used in @alg:imbs-raynal-mbrb ($obj_W$).

#lemma[
_@alg:sf-k2lcast'_s sf-$k2l$-Assumptions are well respected for $obj_W$.
]

#proof[
Let us recall that $q_f = IRqf$ and $q_d = IRqd$ for object $obj_W$.

- _Proof of satisfaction of_ @assum:base ($c-d >= obj_W.q_d >= obj_W.q_f+t >= 2t+1$):

  From #ir16assum ($n > IRbound$), we get that $n > 5t+8d$, which yields:
  $
    c-d &>= n-t-d = (2n-2t-2d)/2, #tag[by definition of $c$] \
    
    c-d &> (n+5t+8d-2t-2d)/2 = (n+3t)/2, #tag[as $n > 5t+8d$] \
    
    c-d &>= floor((n+3t+6d)/2)+1 = floor((n+3t)/2)+3d+1. #<eq:satisf-objw-1-1>
  $
  We also have:
  $
    floor((n+3t)/2)+1 &> floor((5t+8d+3t)/2)+1 = 4t+4d+1, #tag[as $n > 5t+8d$] \
    
    &>= 2t+1. #<eq:satisf-objw-1-2>
  $
  By combining @eq:satisf-objw-1-1 and @eq:satisf-objw-1-2, we obtain:
  $
    c-d &>= floor((n+3t)/2)+3d+1 >= floor((n+3t)/2)+1 >= 2t+1, \
    
    c-d &>= obj_W.q_d >= obj_W.q_f+t >= 2t+1.
  $

- _Proof of satisfaction of_ @assum:disc ($alpha^2-4(obj_W.q_f-1)(n-t) >= 0$):

  Let us recall that for object $obj_W$, we have $q_f=IRqf$ and $q_d=IRqd$.
  We therefore have $alpha = floor((3n-t)/2) - d$.
  Let us now consider the following quantity:
  $
    Delta &= alpha^2 - 4 (q_f - 1)(n - t), \
    
    &= (floor((3n-t)/2) - d)^2 - 4 floor((n+t)/2) (n-t). #<eq:irD-beforecases>
  $
  
  We now observe that $(floor(m)/2)) = ((m - epsilon)/2)$ with $epsilon=0$ if $m=2k$ is even, and $epsilon=1$ if $m=2k+1$ is odd.
  We thus rewrite @eq:irD-beforecases as follows:
  $
    Delta =& ((3n-t-epsilon)/2 - d)^2 - 4 (n+t-epsilon)/2  (n-t) \
    
    =& ((3n-t-epsilon-2d)/2)^2 - 4 (n+t-epsilon)/2  (n-t) \
    
    =& (t^2 + 4 t d + 2 t epsilon - 6 t n + 4 d^2 + 4 d epsilon - 12 d n + epsilon^2 - 6 epsilon n + 9 n^2)/4
    
    + (8t^2 -8 t epsilon + 8 epsilon n - 8 n^2)/4 \
    
    =& (9t^2 + 4 t d - 6 t epsilon - 6 t n + 4 d^2 + 4 d epsilon - 12 d n + epsilon^2 + 2 epsilon n + n^2)/4 \
    
    =& (9 t^2 - 6 t n + n^2 + 4 t d - 12 d n + 4 d^2 + 4 d epsilon - 6 t epsilon + epsilon^2 + 2 epsilon n)/4 \
    
    =& ((n-3t)^2 + 4 d (t - 3 n + d) + epsilon (4 d - 6 t + epsilon + 2 n))/4.
  $
  
  We now multiply by $4$ and solve the inequality: 
  $
    & n^2 - 6n (t + 2d) + 9t^2 + 4 t d + 4 d^2 + epsilon (-6t + 4d + epsilon + 2 n) >= 0, \
    
    & n >= 3t + 4 sqrt(d) sqrt(2t + 2d - epsilon) + 6d - epsilon. #<eq:intermediate>
  $
  
  By #ir16assum we have $n > IRbound$.
  To prove @eq:intermediate, we therefore show that  $IRbound >= 3t + 4 sqrt(d) sqrt(2t + 2d) + 6d$:
  $
    & IRbound >= 3t + 4 sqrt(d) sqrt(2t + 2d) + 6d, \
    
    & 2t + 6d + (2 t d)/(t + 2d) >= 4 sqrt(d) sqrt(2t + 2d), \
    
    & (2t + 6d + (2 t d)/(t + 2d))^2 >= 16 d (2t + 2d), \
    
    & - 16d (t + 2d) (2t + 2d) + (2 t d + 2 t (t + 2 d) + 6 d (t + 2d))^2 >= 0, \
    
    & 4t^4 + 48t^3 d + 192t^2 d^2 - 32t^2 d + 288 t d^3 - 96 t d^2 + 144 d^4 - 64d^3 >= 0. #<eq:proof-ir-disc-final>
  $
  
  We observe that @eq:proof-ir-disc-final holds as $144d^4 >= 64d^3$, $288 t d^3 >= 96 t d^2$, and $192 t^2 d^2 >= 32t^2 d$, therefore proving @assum:disc.


- _Proof of satisfaction of_ @assum:r1 ($alpha(obj_W.q_d-1)-(obj_W.q_f-1)(n-t)-(obj_W.q_d-1)^2 > 0$):

  Let us consider the quantity on the left-hand side of @assum:r1 and substitute $q_f=IRqf$, $q_d= IRqd$, and $alpha=floor((3n-t)/2) - d$:
  $
    & alpha (q_d - 1) - (q_f-1) (n-t) - (q_d - 1)^2 \
    
    =& (floor((3n-t)/2) - d) (floor((n+3t)/2) + 3d) - (floor((n+t)/2)) (n-t)
    
    -(floor((n+3t)/2) +3d)^2.
  $
  
  We now observe that $floor(m/2) = ((m-epsilon)/2)$ with $epsilon=0$ if $m=2k$ is even, and $epsilon=1$ if $m=2k+1$ is odd, and rewrite the expression accordingly:
  $
    & (3n-t-2d-epsilon)/2 times (n+3t+6d-epsilon)/2 - ((n+t-epsilon)(n-t))/2
    
    -((n+3t+6d-epsilon)/2)^2 \
    
    =& ((n+3t+6d-epsilon)(3n-t-2d-epsilon-n-3t-6d+epsilon))/4 - ((n+t-epsilon)(n-t))/2 \
    
    =& ((n+3t+6d-epsilon)(2n-4t-8d))/4 - ((n+t-epsilon)(n-t))/2 \
    
    =& (-12t^2 - 48 t d + 4 t epsilon + 2 t n - 48 d^2 + 8 d epsilon + 4 d n - 2 epsilon n + 2 n^2 + 2t^2 - 2 t epsilon + 2 epsilon n - 2 n^2)/4 \
    
    =& (-10t^2 - 48 t d + 2 t epsilon + 2 t n - 48 d^2 + 8 d epsilon + 4 d n)/4.
  $
  
  As the coefficients of $n$ are all positive, we can lower-bound the quantity using $n>IRbound$:
  $
    & (-10t^2 - 48 t d - 48d^2 + 2n (t + 2d) + 2 epsilon (t + 8d))/4 \
    
    =& (-10t^2 - 48 t d - 48d^2 +  2 (5t + 12d + (2 t d)/(t+2d)) (t + 2d) + 2 epsilon (t + 8 d))/4 \
    
    =& (-10t^2 - 48 t d - 48 d^2 + 10 t^2 + 44 t d + 48 d^2 + 4 t d + 2 epsilon(t + 8d))/4 \
    
    =& (epsilon(t + 8d))/2 >= 0
  $
  which proves all previous inequalities and thus @assum:r1.

- _Proof of satisfaction of_ @assum:r0 ($alpha(obj_W.q_d-1-t) - (obj_W.q_f-1) (n-t) -(obj_W.q_d-1-t)^2 >= 0$):

  Let us consider the quantity on the left-hand side of @assum:r0 and substitute $q_f=IRqf$, $q_d= IRqd$, and $alpha=floor((3n-t)/2)-d$:
  $
    & alpha(q_d -1 - t) - (q_f - 1)(n-t) - (q_d - 1 - t)^2 \
    
    =& (floor((3n-t)/2) -d) (floor((n+3t)/2) + 3d - t) - (floor((n+t)/2)) (n-t)
    
    -(floor((n+3t)/2) + 3d - t)^2.
  $

  We now observe that $(floor(m/2)) = ((m-epsilon)/2)$ with $epsilon=0$ if $m=2k$ is even, and $epsilon=1$ if $m=2k+1$ is odd, and rewrite the expression accordingly:
  $
    & ((3n-t-epsilon)/2 - d) ((n+3t-epsilon)/2 + 3d - t) - ((n+t-epsilon)/2) (n-t) 
    
    -((n+3t-epsilon)/2 +3d - t)^2 \
    
    =& ((3n-t-2d-epsilon)/2) ((n+t+6d-epsilon)/2) - ((n+t-epsilon)/2) (n-t)
    
     -((n+t+6d-epsilon)/2)^2 \
    
    =& ((n+t+6d-epsilon) (3n-t-2d-epsilon-n-t-6d+epsilon))/4 - (((n+t-epsilon)(n-t))/2) \
    
    =& ((n+t+6d-epsilon)(2n-2t-8d))/4 - (((n+t-epsilon)(n-t))/2) \
    
    =& ((n+t+6d-epsilon)(n-t-4d)-(n+t-epsilon)(n-t))/2 \
    
    =& (-10 t d - 24d^2 + 4 d epsilon + 2 d n)/2.
  $
  
  As the coefficients of $n$ are all positive, we can get a lower bound using $n>IRbound>5t+12d$ to obtain:
  $
    & (-10 t d - 24d^2 + 4 d epsilon + 2 d (5 t + 12d))/2 \
    
    =& (- 10 t d - 24d^2 + 4 d epsilon + 10 t d +24 d^2)/2 \
    
    =& 2 d epsilon >= 0
  $
  which proves @assum:r0. #qedhere
]

=== MBRB proof of @alg:imbs-raynal-mbrb
We prove in the sequel the following theorem.

#theorem([MBRB-Correctness])[
If _ #ir16assum _ is verified, then _ @alg:imbs-raynal-brb _ implements MBRB with the guarantee $lmbrb = IRl$.
] <th:ir-mbrb-correctness>

The proof follows from the next lemmas.

#lemma[
$c-d >= obj_W.k$.
] <lem:witness-sufficient>

#proof[
This proof is presented in reverse order: we start with the result we want to prove and finish with a proposition we know to be true.
In this manner, given two consecutive propositions, we only need the latter to imply the former and not necessarily the converse.
We want to show that:
$
  c-d &>= IRk = obj_W.k, \
  
  c-d &> (c floor((n+t)/2))/(c-t-4d), #tag[as $x >= floor(y)+1 <==> x>y$] \
  
  c-d &> (c (n+t)/2)/(c-t-4d), \
  
  c-d &> (c(n+t))/(2 (c-t-4d)), \
  
  c-d &> (c(n+t))/(2c-2t-8d), \
  
  (c-d) (2c-2t-8d) &> c(n+t), #tag[as $2c-2t-8d > 0$ by #ir16assum] \
  
  (c-d) (2c-2t-8d) &> c(c-2t) >= c(n+t), #tag[as $n <= c+t$] \
  
  (c-d)(2c-2t-8d)-c(c-2t) &> 0, \
  
  c^2 + 2 t d - 4 t c + 8d^2 - 10 d c &> 0, \
  
  2 t d + 8d^2 + c^2 + c (-4t -10d) &> 0.
$

The left-hand side of the above inequality is a second-degree polynomial, whose roots we can solve:
$
  [2t + 5d - sqrt(4t^2 + 18 t d + 17d^2), 2 t + 5 d + sqrt(4 t^2 + 18 t d + 17d^2)].
$

We now need to show that:
$
  c > 2t + 5d + sqrt(4t^2 + 18 t d + 17d^2).
$
By #ir16assum, we know that:
$
  n >= 5t + 12d + (2 t d)/(t + 2d) + 1,
$
and thus that:
$
  n &>= 5t + 12d + 1, \
  
  c &>= 4t + 12d + 1.
$
So we want to show that:
$
  4t + 12d + 1 &> 2t + 5d + sqrt(4t^2 + 18 t d + 17d^2), \
  
  2t + 7d + 1 &> sqrt(4t^2 + 18 t d + 17 d^2).
$
It is easy to see that the right-hand side of the above inequality is non-negative, so we get:
$
  (2t + 7d + 1)^2 &> 4t^2 + 18 t d + 17 d^2, \
  
  4t^2 + 28 t d + 4t + 49d^2 + 14d + 1 &> 4t^2 + 18 t d + 17d^2, \
  
  10 t d + 4t + 32d^2 + 14d + 1 &> 0.
$
This concludes the proof.
]

#lemma([MBRB-Validity])[
If a correct process $p_i$ mbrb-delivers a value $v$ from a correct process $p_j$ with sequence number $sn$, then $p_j$ mbrb-broadcast $v$ with sequence number $sn$.
] <lemma:ir-mbrb-validity>

#proof[
If $p_i$ mbrb-delivers $(v,sn,j)$ at @line:ir-mbrb:mbrb, then it $k2l$-delivered $(witnessm(v),(sn,j))$ using $obj_W$.
From $k2l$-Validity, and as $obj_W.k' >= 1$, we can assert that at least one correct process $p_i'$ $k2l$-cast $(witnessm(v),(sn,j))$ at @line:ir-mbrb:witness, after having received an $initm(v,sn)$ message from $p_j$.
And as $p_j$ is correct and the network channels are authenticated, then $p_j$ has broadcast $initm(v,sn)$ at @line:ir-mbrb:mbrb, during a $mbrbbroadcast(v,sn)$ invocation.
]

#lemma([MBRB-No-duplication])[
A correct process $p_i$ mbrb-delivers at most one value from a process $p_j$ with sequence number $sn$.
] <lem:ir-mbrb-no-duplication>

#proof[
By $k2l$-No-duplication, we know that a correct process $p_i$ can $k2l$-deliver at most one $witnessm(star)$ with identity $(sn,j)$. Therefore, $p_i$ can mbrb-deliver only one value from $p_j$ with sequence number $sn$. 
]

#lemma([MBRB-No-duplicity])[
No two distinct correct processes mbrb-deliver different values from a process $p_i$ with the same sequence number $sn$.
] <lem:ir-mbrb-no-duplicity>

#proof[
As $obj_W.nodpty = ttrue$, then, by $k2l$-No-duplicity, we know that no two correct processes can $k2l$-deliver two different values with the same identity using $obj_W$ at @line:ir-mbrb:dlv.
Hence, no two correct processes mbrb-deliver different values for a given sequence number sn and sender $p_i$.
]

#lemma([MBRB-Local-delivery])[
If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then at least one correct process $p_j$ eventually mbrb-delivers $v$ from $p_i$ with sequence number~$sn$.
] <lem:ir-mbrb-local-delivery>

#proof[
If $p_i$ mbrb-broadcasts $(v,sn)$ at @line:ir-mbrb:mbrb, then it broadcasts $initm(v,sn)$.
By the definition of the MA, the message $initm(v,sn)$ is then received by at least $c-d$ correct processes at @line:ir-mbrb:witness, which then $k2l$-cast $(witnessm(v),(sn,i))$.
But thanks to @lem:witness-sufficient, we know that:
$ c-d >= obj_W.k = IRk. $

As $p_i$ is correct and broadcasts only one message $initm(star,sn)$, then no correct process $k2l$-casts any different $(witnessm(star),(sn,i))$, $k2l$-Local-delivery applies and at least one correct processes eventually $k2l$-delivers $(witnessm(v),(sn,i))$ using $obj_W$ and thus mbrb-delivers $(v,sn,i)$ at @line:ir-mbrb:dlv.
]

#lemma([MBRB-Global-delivery])[
If a correct process $p_i$ mbrb-delivers a value $v$ from a process $p_j$ with sequence number $sn$, then at least $lmbrb = IRl$ correct processes mbrb-deliver $m$ from $p_j$ with sequence number~$sn$.
] <lem:ir-mbrb-global-delivery>

#proof[
If $p_i$ mbrb-delivers $(v,sn,j)$ at @line:ir-mbrb:dlv, then it has $k2l$-delivered $(witnessm(v),(sn,j))$ using $obj_W$.
As $obj_W.nodpty = ttrue$, we can assert from $k2l$-Weak-Global-delivery and $k2l$-No-duplicity that at least $obj_W.ell = lval$ correct processes eventually $k2l$-deliver $(witnessm(v),(sn,j))$ using $obj_W$ and thus mbrb-deliver $(v,sn,j)$ at @line:ir-mbrb:dlv.
By substituting the values of $q_f$ and $q_d$, we obtain $obj_W.ell = IRl = lmbrb$, thus proving the lemma. \
]