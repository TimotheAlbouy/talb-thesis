#import "../setup.typ": *

= $k2l$-cast: A Modular Abstraction for Signature-Free MBRB <sec:k2l-cast>

#v(2em)

#epigraph(
  [C'est dans les vieux pots qu'on fait \les meilleures confitures.],
  [Proverbe français]
)
// #epigraph(
//   [The best broths are cooked in the oldest pans.],
//   [French proverb]
// )

#v(2em)

The previous chapter (@sec:sig-mbrb) demonstrated how the problem of designing an MA-tolerant BRB (MBRB) could be solved by leveraging digital signatures within a monolithic algorithm.
However, the use of cryptographic signatures introduces important assumptions about the adversary's computing power (#eg the intractability of forging bogus signatures), which weakens the algorithm's deterministic properties.
This is why the study of cryptography-free (also called _error-free_) distributed algorithms remains an essential area of research.
In this context, this chapter shows that the MBRB problem can also be solved in an error-free context using a modular strategy.
In particular, we present the following results in this chapter.
// #FT[Perfect transition from one chapter to the next: reminds the reader what you've just presented, and tells him why this opens more questions that you're going to discuss now.]

- We first introduce a new modular abstraction, $k2l$-cast, which appears to be a foundational building block for implementing BRB abstractions (with or without the presence of an MA).
  This communication abstraction systematically dissociates the predicate used to forward (network) messages from the predicate that triggers the delivery of a value, and lies at the heart of the work presented in the chapter.
  // #FT[You had "paper" instead of "chapter". Do a general search for "paper", "article", "work", to check whether they can stay or should be replaced.]
  When proving the $k2l$-cast communication abstraction, the chapter presents an in-depth analysis of the power of an adversary that controls at most $t$ Byzantine processes and an MA of power $d$. 
    
- Using the $k2l$-cast abstraction, we then deconstruct two signature-free BRB algorithms (Bracha's @B87 and Imbs and Raynal's @IR16 algorithms) and reconstruct new versions that tolerate _both_ Byzantine processes and an MA.
  Interestingly, when considering Byzantine failures only, these deconstructed versions use smaller quorum sizes and are thus more efficient than their initial counterparts.

To limit our working assumptions as much as possible, we further assume that the adversary's computability power is unbounded (except for the cryptography-based algorithm presented in @sec:sb-k2lcast), which precludes the use of signatures.
(However, we assume that each point-to-point communication channel is authenticated.)
@tab:chap5-notations summarizes the acronyms and notations of this chapter.

#figure(placement: auto,
  table(
    columns: 2, row-gutter: (0pt, 0pt, 0pt, 3pt, 0pt),
    [*Acronyms*], [*Meanings*],
    [MA], [Message adversary],
    [BRB], [Byzantine reliable broadcast],
    [MBRB], [MA-tolerant Byzantine reliable broadcast],
    // [MBRB], [Message adversary- and Byzantine-tolerant reliable broadcast],
    [*Notations*], [*Meanings*],
    $n$, [number of processes in the system],
    $t$, [upper bound on the number of Byzantine processes],
    $d$, [power of the message adversary],
    $c$, [effective number of correct processes in a run ($n-t <= c <= n$)],
    // $secp$, [security parameter of the cryptographic primitives],
    // [$v$, $|v|$], [BRB value, size of the BRB value (in bits)],
    $p_i$, [process of the system with identity $i$],
    $star$, [unspecified value],
    $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
    // $rtc$, [time complexity of MBRB],
    // $omc$, [message complexity of MBRB]
    $k$, [minimal nb of correct processes that $k2l$-cast a value],
    $ell$, [minimal nb of correct processes that $k2l$-deliver a value],
    $k'$, [minimal nb of correct $k2l$-casts if there is a correct $k2l$-delivery],
    $nodpty$, [$ttrue$ if no-duplicity is guaranteed, $ffalse$ otherwise],
    $q_d$, [size of the $k2l$-delivery quorum],
    $q_f$, [size of the forwarding quorum],
    $single$, [$ttrue$ iff only a single value can be endorsed, $ffalse$ otherwise]
  ),
  caption: [Acronyms and notations used in @sec:k2l-cast]
) <tab:chap5-notations>


== The $k2l$-cast abstraction: Definition

Signature-free BRB algorithms~@ART19 @B87 @IR16 often rely on successive waves of internal messages (#eg the $echom$ or $readym$ messages of Bracha's algorithm~@B87) to provide safety and liveness.
Each wave is characterized by a threshold-based predicate that triggers the algorithm's next phase when fulfilled (#eg enough $echom$ messages for the same value $v$).
In this section, we introduce a new modular abstraction, called $k2l$-cast, that encapsulates a wave/thresholding mechanism that is both Byzantine- and MA-tolerant.

#paragraph[Specification]
$k2l$-cast (for $k$-to-$ell$-cast) is a many-to-many communication abstraction #footnote[
  An example of this family is the binary reliable broadcast introduced in~@MMR14, which is defined by specific delivery properties---not including MA-tolerance---allowing binary consensus to be solved efficiently with the help of a common coin.
].
Intuitively, it relates the number $k$ of correct processes that disseminate a value $v$ (we say that these processes _$k2l$-cast_ $v$) with the number $ell$ of correct processes that deliver $v$ (we say that they _$k2l$-deliver_ $v$).
Both $k$ and $ell$ are subject to thresholding constraints: enough correct processes must $k2l$-cast a value for it to be $k2l$-delivered at least once; and as soon as one (correct) $k2l$-delivery occurs, some minimal number of correct processes are guaranteed to $k2l$-deliver as well.

More formally, $k2l$-cast is a multi-shot abstraction, #ie each value $v$ that is $k2l$-cast or $k2l$-delivered is associated with an identity $id$.
(Typically, such an identity is a pair consisting of a process identity and a sequence number.)
It provides two operations, $k2lcast$ and $k2ldeliver$, whose behavior is defined by the values of four parameters: three integers $k'$, $k$, $ell$, and a Boolean $nodpty$.
This behavior is captured by the following six properties:

- *Safety.*
  - *$bold(k2l)$-Validity.* 
    If a correct process $p_i$ $k2l$-delivers a value $v$ with identity $id$, then at least $k'$ correct processes $k2l$-cast $v$ with
    identity $id$.
    
  - *$bold(k2l)$-Non-duplication.*
    A correct process $k2l$-delivers at most one value $v$ with identity~$id$.
    
  - *$bold(k2l)$-Non-duplicity.*
    If the Boolean $nodpty$ is $ttrue$, then no two different correct processes $k2l$-deliver different values with the same identity~$id$.

- *Liveness.
  *#footnote[
     The liveness properties comprise a _local_ delivery property that provides a necessary condition for the $k2l$-delivery of a value by at least _one_ correct process, and two _global_ delivery properties that consider the collective behavior of correct processes.
  ]
  
  - *$bold(k2l)$-Local-delivery.*
    If at least $k$ correct processes $k2l$-cast a value $v$ with identity $id$ and no correct process $k2l$-casts a value $v' != v$ with identity~$id$, then at least one correct process $k2l$-delivers the value $v$ with identity~$id$.

  - *$bold(k2l)$-Weak-Global-delivery.* 
    If a correct process $k2l$-delivers a value $v$ with identity $id$, then at least $ell$ correct processes $k2l$-deliver a value $v'$ with identity $id$ (each of them possibly different from $v$).
    
  - *$bold(k2l)$-Strong-Global-delivery.*
    If a correct process $k2l$-delivers a value $v$ with identity $id$, and no correct process $k2l$-casts a value $v' != v$ with identity $id$, then at least $ell$ correct processes $k2l$-deliver the value $v$ with identity $id$. 

This specification is _parameterized_ in the sense that each tuple $(k',k,ell,nodpty)$ defines a specific communication abstraction with different guarantees.
This versatility explains why the $k2l$-cast abstraction can be used to produce highly compact reconstructions of existing BRB algorithms, rendering them MA-tolerant in the process (using four and three lines of pseudo-code respectively, see @sec:mbrb-b86-ir16).
Despite this versatility, however, we will see in @sec:sf-k2lcast that $k2l$-cast can be implemented using a single (parameterized) algorithm, underscoring the fundamental commonalities of MA-tolerant BRB algorithms.

Intuitively, the parameters $k'$, $k$, and $ell$ hobble the disruption power of the adversary controlling the Byzantine processes/MA by setting limits on the number of correct processes that are either required or guaranteed to be involved in one communication "wave" (corresponding to one identity $id$).
The parameter $k'$ sets the minimal number of correct processes that must $k2l$-cast for any $k2l$-delivery to occur: it thus limits the ability of the Byzantine/MA adversary to trigger spurious $k2l$-deliveries.
// Let us note that, when $k'=0$, this specification does not prevent correct processes from $k2l$-delivering a value $k2l$-cast only by Byzantine processes.
The role of $k$ is symmetrical.
It guarantees that some $k2l$-delivery will necessarily occur if $k$ correct processes $k2l$-cast some message.
It thus prevents the adversary from silencing correct processes as soon as some critical mass of them participates.
Finally, $ell$ captures a "quite-a-few-or-nothing" guarantee that mirrors the traditional "all-or-nothing" delivery  guarantee of traditional BRB.
As soon as one correct $k2l$-delivery occurs (for some identity $id$), then $ell$ correct processes must also $k2l$-deliver (with the same identity).

The fourth parameter, $nodpty$, is a flag that, when $ttrue$, enforces agreement between $k2l$-deliveries.
When $delta=ttrue$, the $k2l$-No-duplicity property implies that all the values $v'$ involved in the $k2l$-Weak-Global-delivery property are equal to $v$.

== Signature-free $k2l$-cast <sec:sf-k2lcast>

// In this section, we implement and prove the 
Among the many possible ways of implementing $k2l$-cast, this section presents a quorum-based
#footnote[
  In this chapter, a quorum is a set of processes that (at the implementation level) broadcast the same message.
  // This typically occurs when processes forward values encapsulated in #endorsem messages (these #endorsem $witnessm$ messages are called _witnesses_ of the corresponding value).
  This definition takes quorums in their ordinary sense.
  In a deliberative assembly, a quorum is the minimum number of members that must vote the same way for an irrevocable decision to be taken.
  Let us notice that this definition does not require quorum intersection.
  However, if quorums have a size greater than $(n+t)/2$, the intersection of any two quorums contains, despite Byzantine processes, at least one correct process~@B87 @R18.
]
signature-free implementation
#footnote[
  Another $k2l$-cast implementation, which uses digital signatures and allows to reach optimal values for $k$ and $ell$, is presented in @sec:sb-k2lcast.
] of the abstraction.
To overcome the disruption caused by Byzantine processes and message losses from the MA, our algorithm uses the broadcast primitive (cf. our communication model in @sec:model) to accumulate and forward $endorsem$ messages before deciding whether to deliver.
Forwarding and delivery are triggered by _two thresholds_ (a pattern also found, for instance, in Bracha's BRB algorithm~@B87):

- a first threshold, $q_d$, triggers the delivery of a value $v$ when enough $endorsem$ messages supporting $v$ have been received;

- a second threshold, $q_f$, which is lower than $q_d$, controls how $endorsem$ messages are forwarded during the algorithm's execution.

Forwarding, which is controlled by $q_f$, amplifies how correct processes react to $endorsem$ messages, and is instrumental to ensure the algorithm's liveness.
As soon as some critical "mass" of agreeing $endorsem$ messages accumulates within the system, forwarding triggers a chain reaction which guarantees that a minimum number of correct processes eventually $k2l$-deliver the corresponding value.

#stack(
  dir: ltr,
  include "alg/sf-k2lcast.typ",
  box(include "fig/sf-k2l-construct.typ", width: 13em)
)

More concretely, our algorithm provides an object ($SigFreeK2LCast$, @alg:sf-k2lcast), instantiated using the function $SigFreeK2LCast(q_d,q_f,single)$, using three input parameters:

- $q_d$: the number of matching $endorsem$ messages that must be received from distinct processes in order to $k2l$-deliver a value;
    
- $q_f$: the number of matching $endorsem$ messages that must be received from distinct processes for the local $p_i$ to endorse the corresponding value (if it has not yet);
    
- $single$: a Boolean that controls whether a given correct process can endorse different values for the same identity $id$ ($single=ffalse$), or not ($single=ttrue$).

The algorithm provides the operations $k2lcast$ and $k2ldeliver$.
Given a value $v$ with identity $id$, the operation $k2lcast(v,id)$ broadcasts $endorsem(v,id)$ provided $p_i$ has not yet endorsed any different value for the same identity $id$ (@line:sf-k2l:cond-bcast[lines]-@line:sf-k2l:bcast[]). 
When $p_i$ receives a message $endorsem(v,id)$, its executes two steps.
If the forwarding quorum $q_f$ has been reached, $p_i$ first retransmits $endorsem(v,id)$ (Forwarding step, @line:sf-k2l:begin-fwd[lines]-@line:sf-k2l:fwd[]).
Then, if the $k2l$-delivery quorum $q_d$ is attained, $p_i$ $k2l$-delivers $v$ (Delivery step, @line:sf-k2l:begin-dlv[lines]-@line:sf-k2l:dlv[]).

For brevity, we define $alpha = n + q_f - t - d - 1$.
Given an execution defined by the system parameters $n$, $t$, $d$, and $c$, @alg:sf-k2lcast requires the following assumptions to hold for the input parameters $q_f$ and $q_d$ of a $k2l$-cast instance (a global picture linking all parameters is presented in @fig:sf-k2l-construct).
The prefix "sf" stands for "signature-free."

#sf-k2l-assumption[
  $c-d >= q_d >= q_f+t >= 2t+1$.
] <assum:base>

#sf-k2l-assumption[
  $alpha^2 - 4 (q_f - 1)(n - t) >= 0$.
] <assum:disc>
    
#sf-k2l-assumption[
  $alpha (q_d - 1) - (q_f-1) (n - t) - (q_d - 1)^2 > 0$.
] <assum:r1>

#sf-k2l-assumption[
  $alpha(q_d - 1 - t) - (q_f - 1)(n - t)  - (q_d - 1 - t)^2 >= 0$.
] <assum:r0>

In particular, the safety of @alg:sf-k2lcast relies solely on @assum:base, while its liveness relies on all four of them.
@assum:disc[sf-$k2l$-Assumptions] @assum:r0[through] constrain the solutions of a second-degree inequality resulting from the combined action of the MA, the Byzantine processes, and the message-forwarding behavior of @alg:sf-k2lcast.
We show in @sec:bracha-mbrb[Sections] and~@sec:imbs-raynal-mbrb[] that, in practical cases, these assumptions can be satisfied by a bound of the form $n > lambda t + xi d + f(t,d)$, where $lambda, xi in NN$ and $f(t,0)=f(0,d)=0$.
Together, the assumptions allow @alg:sf-k2lcast to provide a $k2l$-cast abstraction (with values of the parameters $k'$, $k$, $ell$, and $nodpty$ defining a specific $k2l$-cast instance) as stated by the following theorem.

#let lval = $ceil(c(1-d/(c-q_d+1)))$

#theorem([@alg:sf-k2lcast correctness])[
If _@assum:base[sf-$k2l$-Assumptions]_ _@assum:r0[_to_]_ are satisfied, _@alg:sf-k2lcast _ implements $k2l$-cast with the following guarantees:

- _$k2l$-Validity_ with $k' = q_f-n+c$,

- _$k2l$-Non-duplication_,

- _$k2l$-Non-duplicity_ with $
  nodpty = (q_f > (n+t)/2) or (single and q_d > (n+t)/2)$,
  
- _$k2l$-Local-delivery_ with $k = floor((c(q_f-1))/(c-d-q_d+q_f)) + 1$, #v(.5em)
  
- #pad(y: -50%)[
    $display(mat(delim: "{",
      &#text[if $single = ffalse$,]&, &#text[$k2l$-Weak-Global-delivery]& ;
      &#text[if $single = ttrue$,]&, &#text[$k2l$-Strong-Global-delivery]& ;
    ))$
    with $ell = lval$.
  ]
] <th:sf-k2l-correctness>

=== Proof intuition of @alg:sf-k2lcast 

The proofs of the $k2l$-cast safety properties stated in @th:sf-k2l-correctness ($k2l$-Validity, $k2l$-No-duplication, and $k2l$-No-duplicity) are fairly straightforward.
For the sake of the presentation, these proofs (@lem:n-bcast-if-kldv[Lemmas] @lem:sf-kl-conditional-no-duplicity[to]) appear in @sec:sf-k2lcast-safety.

Compared to safety, the proofs of the $k2l$-cast liveness properties stated in @th:sf-k2l-correctness ($k2l$-Local-delivery, $k2l$-Weak-Global-delivery, $k2l$-Strong-Global-Delivery) are more involved, and are informally sketched below (@lem:l-fact-min[Lemmas]-@lem:sf-k2l-strong-global-delivery[]).
Their full development can be found in @sec:sf-k2lcast-liveness.

When seeking to violate the liveness properties of $k2l$-cast, the attacker can use the MA to control in part how many $endorsem$ messages are received by each correct process, thus interfering with the quorum mechanisms defined by $q_d$ and $q_f$.
To analyze the joint effect of this interference with Byzantine faults, our proofs consider seven well-chosen subsets of correct processes ($A$, $B$, $C$, $U$, $F$, $NF$, and $NB$, depicted in @fig:sf-k2l-proc-sets).

These subsets are defined for an execution of @alg:sf-k2lcast in which $k_I$ correct processes $k2l$-cast $(v,id)$ (the $I$ in $k_I$ stands for "Initial"), and $ell_e$ correct processes receive at least $q_d$ messages $endorsem(v,id)$.
The first three subsets, $A$, $B$, and $C$, partition correct processes based on the number of $endorsem(v,id)$ messages they receive. 

- $A$ contains the $ell_e$ correct processes that receive at least $q_d$ $endorsem(v,id)$ messages (be it from correct or from Byzantine processes), and thus $k2l$-deliver some message.
  #footnote[
    Because of the condition at @line:sf-k2l:cond-dlv, these processes do not necessarily $k2l$-deliver $(v,id)$, but all do $k2l$-deliver a value for identity $id$.
  ]
    
- $B$ contains the correct processes that receive at least $q_f$ but less than $q_d$ $endorsem(v,id)$ messages and thus do not $k2l$-deliver $(v,id)$.
    
- $C$ contains the remaining correct processes that receive less than $q_f$ $endorsem(v,id)$ messages.
  They neither forward nor deliver any message for identity $id$ (since $q_f <= q_d$).

In our proofs, we count the number of messages $endorsem(v,id)$ broadcast by correct processes that are received by the processes of $A$ (resp. $B$ and $C$).
We note these quantities $w_A^c$, $w_B^c$, and $w_C^c$, and use them to bootstrap our proofs using bounds on messages (see below).

The last four subsets intersect with $A$, $B$, and $C$, and distinguish correct processes based on the broadcast operations they perform. 
- $U$ consists of the correct processes that broadcast $endorsem(v,id)$ at @line:sf-k2l:bcast.
    
- $F$ denotes the correct processes of $A union B$ that broadcast $endorsem(v,id)$ at @line:sf-k2l:fwd (#ie they perform a forwarding).
    
- $NF$ denotes the correct processes of $A union B$ that broadcast $endorsem(v,id)$ at @line:sf-k2l:bcast.
    
- $NB$ denotes the correct processes of $A union B$ that never broadcast $endorsem(v,id)$, be it at @line:sf-k2l:bcast or at @line:sf-k2l:fwd.
  These processes have received at least $q_f$ messages $endorsem(v,id)$, but do not forward $endorsem(v,id)$, because they have already broadcast $endorsem(v',id)$ at @line:sf-k2l:bcast or at @line:sf-k2l:fwd for a value $v' != v$.

#paragraph[Proof strategy]
We note $k_U=|U|$, $k_F=|F|$, $k_NF=|NF|$, $k_NB=|NB|$.
Observe that $k_U <= k_I$ and $k_NF <= k_U$, since all (correct) processes in $U$ and $NF$ invoke $k2lcast$.
Also, $(k_U+k_F)$ represents the total number of correct processes that broadcast a message $endorsem(v,id)$.
@fig:sf-k2l-msg-dist illustrates how these quantities constrain the distribution of $endorsem$ messages across $A$, $B$ and $C$.
Our core proof strategy lies in bounding the areas shown in @fig:sf-k2l-msg-dist.
(For instance, observe that $w_A^c <= |A| times (k_U+k_F)$, since each of the $ell_e$ correct processes in $A$ can receive at most one $endorsem$ message from each of the $(k_U+k_F)$ correct processes that send them.)
This reasoning on bounds yields a polynomial involving $ell_e=|A|$, $k_I$, and $k_U$, whose roots can then be constrained to yield the liveness guarantees required by the $k2l$-cast specification.

#subpar.grid(
  figure(
    include "fig/sf-k2l-proc-sets.typ",
    caption: [Subsets of correct processes based on the number of received $endorsem$ messages ($A$, $B$, and $C$) and their broadcast actions ($U$, $F$, $NF$, and $NB$)]
  ), <fig:sf-k2l-proc-sets>,
  figure(
    include "fig/sf-k2l-msg-dist.typ",
    caption: [Distribution of $endorsem$ messages among correct processes of $A$, $B$, and $C$, sorted by decreasing number of $endorsem$ messages received]
  ), <fig:sf-k2l-msg-dist>,
  columns: (1fr, 1fr),
  caption: [Subsets of correct processes and distribution of $endorsem$ messages among them],
  placement: auto,
  label: <fig:sf-k2l-procs-msg-dist>,
  supplement: [Figure]
)

#paragraph[Observation]
In the same way we have bounded $w_A^c$, we can also bound $w_B^c$ by observing that there are $(k_NF+k_NF+k_F-ell_e)$ processes in $B$ and that each can receive at most $q_d-1$ $endorsem$ messages.
Similarly, we can bound $w_C^c$ by observing that the $(c-k_NF-k_NB-k_F)$ processes of $C$ can receive at most $q_f-1$ $endorsem$ messages.
Thus, we have:
$
  w_A^c &<= (k_U+k_F)ell_e, #<eq:sup-on-wAc> \
  w_B^c &<= (q_d-1)(k_NF+k_NB+k_F-ell_e), #<eq:sup-on-wBc> \
  w_C^c &<= (q_f-1)(c-k_NF-k_NB-k_F). #<eq:sup-on-wCc>
$

Moreover, the MA cannot suppress more than $d$ copies of each individual $endorsem$ message broadcast to the $c$ correct processes.
Thus, the total number of $endorsem$ messages received by correct processes $(w_A^c+w_B^c+w_C^c)$ is such that:
$
  w_A^c+w_B^c+w_C^c >= (k_U+k_F)(c-d). #<eq:sup-all-witness>
$

#lemma[
$ell_e times (k_U+k_F-q_d+1) >= (k_U+k_F)(c-d-q_d+q_f) - c(q_f-1) - k_NB (q_d-q_f)$.
] <lem:l-fact-min>

#proof-sketch[
We get this result by combining @eq:sup-on-wAc, @eq:sup-on-wBc, @eq:sup-on-wCc and @eq:sup-all-witness, and using @assum:base with the fact that $k_NF <= k_U$.
(Full derivations in @sec:sf-k2lcast-liveness.)
]

#lemma[
If no correct process $k2l$-casts $(v',id)$ with $v' != v$, then no correct process forwards _$endorsem(v',id)$_ at @line:sf-k2l:begin-fwd (and then $k_NB = 0$).
#proof-in-apx(<sec:sf-k2lcast-liveness>)
] <lem:k2lcast-if-fwd>

#lemma([$k2l$-Local-delivery])[
If at least $k=floor((c(q_f-1))/(c-d-q_d+q_f))+1$ correct processes $k2l$-cast a value $v$ with identity $id$ and no correct process $k2l$-casts any value $v'$ with identity $id$ such that $v != v'$, then at least one correct process $p_i$ $k2l$-delivers $v$ with identity $id$.
] <lem:sf-k2l-local-delivery>

#proof-sketch[
From the hypotheses, @lem:k2lcast-if-fwd helps us determine that $k_NF=0$.
Then, the property is proved by contraposition, by assuming that no correct process $k2l$-delivers $(m,id)$, which leads us to $ell_e=0$.
Using prior information and @assum:base, we can rewrite the inequality of @lem:l-fact-min to get the threshold of $k2l$-casts above which there is at least one $k2l$-delivery. 
(Full derivations in @sec:sf-k2lcast-liveness.)
]

#lemma[
$(single = ffalse) ==> (k_NB = 0)$.
#proof-in-apx(<sec:sf-k2lcast-liveness>)
] <lem:single-if-kNB>

#lemma[
If at least one correct process $k2l$-delivers $(v,id)$ and $x=k_U+k_F$ (the number of correct processes that broadcast _$endorsem(v,id)$_ at @line:sf-k2l:bcast or~@line:sf-k2l:fwd[]), then $x >= q_d-t$ and $x^2 - x(c-d+q_f-1-k_NB) >= -(c-k_NB)(q_f-1)$.
] <lem:polynom-if-one>

#proof-sketch[
We prove this lemma by counting the total number of messages (sent by Byzantine or correct processes) that are received by the processes of $A$, and by using @eq:sup-on-wAc, @eq:sup-on-wCc @eq:sup-all-witness, and @assum:base.
(Full derivations in @sec:sf-k2lcast-liveness.)
]

#lemma[
If $k_NB=0$, and at least one correct process $k2l$-delivers $(v,id)$, then $k_U+k_F >= q_d$.
] <lem:enough-if-one>

#proof-sketch[
Given that $k_NB=0$, we can rewrite the inequality of @lem:polynom-if-one, which gives us a second-degree polynomial (where $x=k_U+k_F$ is the unknown variable).
We compute its roots and show that  the smaller one contradicts @lem:polynom-if-one, and that the larger one is greater than or equal to $q_d$.
The fact that $x$ must be greater than or equal to the larger root to satisfy @lem:polynom-if-one proves the lemma.
(Full derivations in @sec:sf-k2lcast-liveness.)
]

#lemma[
If $k_NB = 0$ and $k_U+k_F >= q_d$, then at least $lval$ correct processes $k2l$-deliver some value with identity $id$ (not necessarily $v$).
] <lem:ell-if-enough>

#proof-sketch[
From the hypotheses, we can rewrite the inequality of @lem:l-fact-min to get a lower bound on $ell_e$.
Using @assum:r1, we can determine that this lower bound is decreasing with the number of broadcasts by correct processes ($x=k_u+k_f$).
Hence, this lower bound is minimum when $x$ is maximum, that is, when $x=c$.
This gives us the minimum number of correct processes that $k2l$-deliver under the given hypotheses.
(Full derivations in @sec:sf-k2lcast-liveness.) \
]

#lemma([$k2l$-Weak-Global-delivery])[
If $single = ffalse$, and a correct process $k2l$-delivers a value $v$ with identity $id$, then at least $ell = lval$ correct processes $k2l$-deliver a value $v'$ with identity $id$ (each possibly different from $v$).
] <lem:sf-k2l-weak-global-delivery>

#proof-sketch[
As $single = ffalse$ and one correct process $k2l$-delivers $(m,id)$, @lem:single-if-kNB[Lemmas] and~@lem:enough-if-one[] apply, and we have $k_NF = 0$ and $k_U+k_F >= q_d$.
This provides the prerequisites for @lem:ell-if-enough, which concludes the proof.
(Full derivations in @sec:sf-k2lcast-liveness.)
]

#lemma([$k2l$-Strong-Global-delivery])[
If $single = ttrue$, and a correct process $k2l$-delivers a value $v$ with identity $id$, and no correct process $k2l$-casts a value $v' != v$  with identity $id$, then at least $ell = lval$ correct processes $k2l$-deliver $v$ with identity $id$.
] <lem:sf-k2l-strong-global-delivery>

#proof-sketch[
As $single = ttrue$, @lem:k2lcast-if-fwd holds and implies that $k_NB = 0$.
As above, @lem:enough-if-one and @lem:ell-if-enough hold, yielding the lemma.
(Full derivations in @sec:sf-k2lcast-liveness.)
]

== $k2l$-cast in action: From classical BRB to MBRB algorithms <sec:mbrb-b86-ir16>

This section uses $k2l$-cast to reconstruct two signature-free BRB algorithms initially introduced in a pure Byzantine context (#ie without any MA): Bracha's BRB @B87 (@alg:bracha-brb) and Imbs-Raynal's BRB @IR16 (@alg:imbs-raynal-brb).
These reconstructions produce Byzantine-MA-tolerant versions of the initial algorithms that implement the MBRB specification of @sec:mbrb.
Moreover, when $d = 0$, our two reconstructed BRB algorithms are strictly more efficient than the original algorithms that gave rise to them: they terminate earlier.

More precisely, the original and reconstructed versions of Bracha's BRB are identical in terms of communication cost, time complexity, and $t$-resilience (when $d=0$).
The same comparison applies to the original and reconstructed versions of Imbs and Raynal's BRB.
However, both reconstructed BRB algorithms use smaller quorums than their original versions, requiring fewer messages to progress.
This means a lower latency in a real-world network, as practical networks typically exhibit a long-tail distribution of latencies (a phenomenon well-studied by system and networking researchers~@CSJRLWZCC21 @DB13 @DZ19 @YPAKT22).

To help readers who are familiar with the initial algorithms, we use the same message types ($initm$, $echom$, $readym$, $witnessm$) as in the original publications. 
Recall that the MBRB problem can be solved if and only if $n > 3t+2d$ (@thm:mbrb-opti, #pageref(<thm:mbrb-opti>)).

=== Bracha's BRB algorithm (1987) reconstructed <sec:bracha-mbrb>

#let Bbound = $3t + 2d + 2 sqrt(t d)$
#let Bl = $ceil(c (1-d/(c-2t-d)))$

#paragraph[Reconstructed version]
Bracha's BRB algorithm comprises three phases.
When a process invokes $brbbroadcast(v,sn)$, it disseminates the value $v$ in an $initm$ message (first phase).
The reception of this message by a correct process triggers its participation in a second phase implemented by the exchange of messages tagged $echom$.
Finally, when a process has received $echom$ messages from "enough" processes, it enters the third phase, in which $readym$ messages are exchanged, at the end of which it brb-delivers the value $v$.
@alg:bracha-mbrb is a reconstructed version of the Bracha's BRB, which assumes $n > Bbound$.

#include "alg/bracha-mbrb.typ"

The algorithm requires two instances of $k2l$-cast, denoted $obj_E$ and $obj_R$, associated with the $echom$ messages and the $readym$ messages, respectively.
For both these objects, the Boolean $single$ is set to $ttrue$.
For the quorums, we have the following:

- $obj_E$: $q_f = t+1$ and $q_d= floor((n+t)/2)+1$,

- $obj_R$: $q_f = t+1$ and $q_d = 2t+d+1$.

The integer~$sn$ is the sequence number of the value $v$ mbrb-broadcast by $p_i$.
The identity of $v$ is consequently the pair $angle.l sn,i angle.r$.

@alg:bracha-mbrb provides $lmbrb = Bl$ under the following assumption (B87 stands for Bracha 1987).

#b87-assumption(numbering: none)[
  $n > Bbound$.
] <assum:b87>

The proof of correctness of @alg:bracha-mbrb can be found in @sec:bracha-mbrb-proof.

#paragraph[Comparison (@tab:comparison-B87)]
When $d=0$, both Bracha's algorithm and its reconstruction use the same quorum size for the $readym$ phase.
However, the quorums of the $echom$ phase are different (@tab:comparison-B87).
As the algorithm requires $n>3t$, we define $Delta = n-3t$ as the slack between the lower bound on $n$ and the actual value of $n$.
When considering the forwarding threshold $q_f$, we have $floor((n+t)/2)+1 = 2t+floor(Delta/2)+1 > t+1$.
As a result, the reconstruction of Bracha's algorithm always uses a lower forwarding threshold for $echom$ messages than the original.
It, therefore, forwards messages more rapidly and reaches the delivery quorum faster. 

#figure(
  table(
    align: horizon + center, columns: 3, inset: .8em,
    // LINE 1
    [*Threshold*], [*Original version* ($echom$ phase)], [*$bold(k2l)$-cast-based version* ($obj_E$)],
    // LINE 2
    [*Forwarding $bold(q_f)$*], $display(floor((n+t)/2)+1)$, $t+1$,
    // LINE 3
    [*Delivery* $bold(q_d)$], $display(floor((n+t)/2)+1)$, $display(floor((n+t)/2)+1)$
  ),
  caption: [Bracha's original version vs. $k2l$-cast-based reconstruction when $d = 0$]
) <tab:comparison-B87>

=== Imbs-Raynal's BRB algorithm (2016) reconstructed <sec:imbs-raynal-mbrb>

#let IRbound = $5t + 12d + (2 t d)/(t+2d)$
#let IRl = $ceil(c (1 - d/(c-floor((n+3t)/2)-3d)))$
#let IRqd = $floor((n+3t)/2)+3d+1$
#let IRqf = $floor((n+t)/2)+1$
#let IRk = $floor((c floor((n+t)/2))/(c-t-4d)) + 1$
#let IRl = $ceil(c (1- d/(c-floor(n+3t)/2 -3d)))$

#paragraph[Reconstructed version]
Recall that Imbs and Raynal's BRB is another BRB implementation, which achieves an optimal good-case latency (only two communication steps) at the cost of a non-optimal $t$-resilience.
Its reconstructed version requires $n > IRbound$.

#include "alg/imbs-raynal-mbrb.typ"

The algorithm requires a single $k2l$-cast object, denoted $obj_W$, associated with the $witnessm$ message, and which is instantiated with $q_f = floor((n+t)/2)+1$ and $q_d = floor((n+3t)/2)+3d+1$, and the Boolean $single=ffalse$.
Similarly to Bracha's reconstructed BRB, an identity of value in this algorithm is a pair $angle.l sn,i angle.r$ containing a sequence number $sn$ and a process identity $i$.

@alg:imbs-raynal-mbrb provides $lmbrb = IRl$ under the following assumption (IR16 stands for Imbs-Raynal 2016).

#ir16-assumption(numbering: none)[
  $n > IRbound$ (where $t+d>0$).
] <assum:ir16>

The proof of correctness of @alg:imbs-raynal-mbrb can be found in @sec:imbs-raynal-mbrb-proof.

#paragraph[Comparison (@tab:comparison-IR16)]
@tab:comparison-IR16 compares Imbs and Raynal's original algorithm against its $k2l$-cast reconstruction for $d=0$.
Recall that this algorithm saves one communication step with respect to Bracha's at the cost of a weaker $t$-tolerance, #ie it requires $n > 5t$.
As for Bracha, let us define the slack between $n$ and its minimum as $Delta = n-5t$, we have $Delta >= 1$.
- Let us first consider the size of the forwarding quorum (first line of the table). 
  We have $n-2t = 3t+Delta$ and $floor((n+t)/2)+1 = 3t+floor(Delta/2)+1$.
  When $Delta>2$, we always have $Delta > floor(Delta/2)+1$, it follows that the forwarding predicate of the reconstructed version is equal or weaker than the one of the original version.

- The same occurs for the size of the delivery quorum (second line of the table).
  We have $n-t= 4t+Delta$ and $floor((n+3t)/2)+1 = 4t+floor(Delta/2)+1$.
  So both reconstructed quorums are lower than those of the original version when $Delta>2$, making the reconstructed algorithm quicker as soon as $n >= 5t+3$.
  The two versions behave identically for $5t+3 >= n >= 5t+2$ (where $Delta in {1,2}$).

#figure(
  table(
    align: horizon + center, columns: 3, inset: (top: .8em, bottom: .8em),
    // LINE 1
    [*Threshold*], [*Original version* ($witnessm$ phase)], [*$bold(k2l)$-cast-based version* ($obj_W$)],
    // LINE 2
    [*Forwarding $bold(q_f)$*], $n-2t$, $display(floor((n+t)/2)+1)$,
    // LINE 3
    [*Delivery* $bold(q_d)$], $n-t$, $display(floor((n+3t)/2)+1)$
  ),
  caption: [Imbs-Raynal's original version vs. $k2l$-cast-based reconstruction when $d = 0$]
) <tab:comparison-IR16>

=== Numerical evaluation of the MBRB algorithms <sec:numer-eval-mbrb>

@fig:Bracha-IR-full-heatmap provides a numerical evaluation of the delivery guarantees of both $k2l$-cast-based MBRB algorithms (@alg:bracha-mbrb[Algorithms] and~@alg:imbs-raynal-mbrb[]) in the presence of Byzantine processes and an MA.
Results were obtained for $n=100$ and $c=n-t$, and show the values of $lmbrb$ for different values of $t$ and $d$.
For instance, @fig:Bracha-full-heatmap shows that with $6$ Byzantine processes and an MA suppressing up to $9$ broadcast messages, @alg:bracha-mbrb ensures the MBRB-Global-delivery property with $lmbrb=83$.
The figures illustrate that the reconstructed Bracha algorithm performs in a broader range of parameter values, mirroring the bounds on $n$, $t$, and $d$ captured by #b87assum and IR-Assumption.
Nonetheless, both algorithms exhibit values of $lmbrb$ that can support real-world applications in the presence of an MA.

#subpar.grid(
  figure(
    image("plots/klcast-kmin-OBJ_R-BRACHA-l-heatmap.svg"),
    caption: [Reconstructed Bracha MBRB (@alg:bracha-mbrb)]
  ), <fig:Bracha-full-heatmap>,
  figure(
    image("plots/klcast-kmin-IMBS-RAYNAL-l-heatmap.svg"),
    caption: [Reconstructed Imbs-Raynal MBRB (@alg:imbs-raynal-mbrb)]
  ), <fig:IR-full-heatmap>,
  columns: (1fr, 1fr),
  caption: [Values of $lmbrb$ for the reconstructed BRB algorithms when varying $t$ and $d$ ($n=100$ and $c=n-t$) within the ranges that satisfy #b87assum and #ir16assum],
  placement: top,
  label: <fig:Bracha-IR-full-heatmap>,
  supplement: [Figure]
)

#paragraph[Additional results]
The following presents additional numerical results that complement those of @fig:Bracha-IR-full-heatmap, and provides concrete lower-bound values for parameters $k$ and $ell$ of the $k2l$-cast objects used in the reconstructed Bracha MBRB algorithm (@alg:bracha-mbrb).
Again, results were obtained by considering a network with $n=100$ processes and varying
values of $t$ and $d$.

#subpar.grid(
  figure(
    image("plots/klcast-kmin-OBJ_E-BRACHA-k-heatmap.svg"),
    caption: [Minimum required $k$]
  ), <fig:BrachaEk-heatmap>,
  figure(
    image("plots/klcast-kmin-OBJ_E-BRACHA-l-heatmap.svg"),
    caption: [Minimum provided $ell$]
  ), <fig:BrachaEl-heatmap>,
  columns: (1fr, 1fr),
  caption: [Required values of $k$ and provided values of $ell$ for $obj_E$ in the reconstructed Bracha BRB algorithm with varying values of $t$ and $d$ within the ranges that satisfy #b87assum],
  placement: top,
  label: <fig:BrachaE-heatmap>,
  supplement: [Figure]
)

#subpar.grid(
  figure(
    image("plots/klcast-kmin-OBJ_R-BRACHA-k-heatmap.svg"),
    caption: [Minimum required $k$]
  ), <fig:BrachaRk-heatmap>,
  figure(
    image("plots/klcast-kmin-OBJ_R-BRACHA-l-heatmap.svg"),
    caption: [Minimum provided $ell$]
  ), <fig:BrachaRl-heatmap>,
  columns: (1fr, 1fr),
  caption: [Required values of $k$ and provided values of $ell$ for $obj_R$ in the reconstructed Bracha BRB algorithm with varying values of $t$ and $d$ within the ranges that satisfy #b87assum],
  placement: top,
  label: <fig:BrachaR-heatmap>,
  supplement: [Figure]
)

#figure(
  image("plots/klcast-kmin-IMBS-RAYNAL-k-heatmap.svg", width: 45%),
  caption: [Required values of $k$ for $obj_W$ in the reconstructed Imbs-Raynal BRB algorithm with varying values of $t$ and $d$ within the ranges that satisfy #ir16assum],
  placement: top,
) <fig:IR-k-heatmap>

@fig:BrachaE-heatmap and @fig:BrachaR-heatmap present the values of $k$ and $ell$ for the $obj_E$ and $obj_R$ of @alg:bracha-mbrb.
The numbers in each cell show the value of $k$ (@fig:BrachaEk-heatmap[Figures] and~@fig:BrachaRk-heatmap[]), resp. $ell$ (@fig:BrachaEl-heatmap[Figures] and~@fig:BrachaRl-heatmap[]) that is required, resp. guaranteed, by the corresponding $k2l$-cast object.
The two plots show the two roles of the two $k2l$-cast objects.
The first, $obj_E$, needs to provide agreement among the possibly different messages sent by Byzantine processes (@fig:BrachaE-heatmap).
As a result, it can operate in a more limited region of the parameter space.
On the other hand, $obj_R$ would, in principle, be able to support larger values of $t$ and $d$, but it needs to operate in conjunction with $obj_E$~(@fig:BrachaR-heatmap).

@fig:IR-full-heatmap already displays the values of $ell$ provided by $obj_W$ in the Imbs-Raynal algorithm.
@fig:IR-k-heatmap complements it by showing the required values of $k$ for $obj_W$.
The extra constraint introduced by chaining the two objects suggests that a single $k2l$-cast algorithm could achieve better performance.
But this is not the case if we examine the performance of the reconstructed Imbs-Raynal algorithm depicted in @fig:IR-full-heatmap.
The reason lies in the need for higher quorum values in $obj_W$ due to $single=ffalse$. 
In the future, we plan to investigate if variants of this algorithm can achieve tighter bounds and explore the limits of signature-free $k2l$-cast-based broadcast in the presence of an MA and Byzantine processes.

== Signature-based $k2l$-cast <sec:sb-k2lcast>

This section presents an implementation of $k2l$-cast based on digital signatures.
The underlying model is the same as that of @sec:sf-k2lcast (#pageref(<sec:sf-k2lcast>)), except that the computing power of the attacker is now bounded, which allows us to leverage asymmetric cryptography.

=== Algorithm
The signature-based algorithm is described in @alg:sb-k2lcast.
It uses an asymmetric cryptosystem to sign messages and verify their authenticity.
Every process has a public/private key pair.
Public keys are known to everyone, but private keys are only known to their owner.
(Byzantine processes may exchange their private keys.)
Each process also knows the mapping between process indexes and associated public keys, and each process can produce a unique, valid signature for a given message, and check if a signature is valid.

#include "alg/sb-k2lcast.typ"

It is a simple algorithm that ensures that a value must be $k2l$-cast by at least $k$ correct processes to be $k2l$-delivered by at least $ell$ correct processes.
For the sake of simplicity, we say that a correct process $p_i$ "broadcasts a set of signatures" if it broadcasts a $bundlem(v,id,sigs_i)$ message in which $sigs_i$ contains the signatures at hand.
A correct process $p_i$ broadcasts a value $v$ with identity $id$ at @line:sb-k2l:k2l-bcast or @line:sb-k2l:rcv-bcast.

- If this occurs at @line:sb-k2l:k2l-bcast, $p_i$ includes in the message it broadcasts all the signatures it has already received  for $(v,id)$ plus its own signature.

- If this occurs at @line:sb-k2l:rcv-bcast, $p_i$  has just received a message containing a set of signatures $sigs$ for the pair $(v,id)$.
  The process $p_i$ then aggregates in $sigs$ the valid signatures it just received with the ones it did know about beforehand (@line:sb-k2l:rcv-agg-sigs).

This algorithm relies on the following assumptions (the prefix "sb" stands for signature-based).

#sb-k2l-assumption[
  $c > 2d$.
] <assum:no-partition>

#sb-k2l-assumption[
  $c-d >= q_d >= t+1$.
] <assum:dlv-tshld>

Thanks to digital signatures, processes can relay the messages of other processes in @alg:sb-k2lcast.
The algorithm, however, does not use forwarding in the same way @alg:sf-k2lcast did: there is no equivalent of $q_f$ here, that is, the only way to "endorse" a value (which, in this case, is equivalent to signing this value) is to invoke the $k2lcast$ operation.
Furthermore, only one value can be endorsed by a correct process for a given identity (which is the equivalent of $single = ttrue$ in the signature-free version).

Although this implementation of $k2l$-cast provides better guarantees than @alg:sf-k2lcast, using it to reconstruct signature-free BRB algorithms would be counter-productive.
This is because signatures allow for MA-tolerant BRB algorithms that are more efficient in terms of round and message complexity than those that can be constructed using $k2l$-cast~(see @sec:sig-mbrb).

However, a signature-based $k2l$-cast does make sense in contexts in which many-to-many communication patterns are required~@ART19, and, we believe, opens the path to novel ways to handle local state resynchronization resilient to Byzantine failures and message adversaries.
For instance, we are using the previous algorithm in our own work to design churn-tolerant money transfer systems tolerating Byzantine failures and temporary disconnections.
#TA[Keep this mention?]

=== Proof
In this section, we prove the following theorem.

#theorem([$k2l$-Correctness])[
If _ @assum:no-partition _ and _ @assum:dlv-tshld _ are verified, _ @alg:sb-k2lcast _ implements $k2l$-cast with the following guarantees:
(i) $k' = q_d-n+c$, (ii) $k = q_d$, (iii) $ell = c-d$, and (iv) $nodpty = q_d > (n+t)/2$.
] <th:sb-kl-correctness>

The proof follows from the subsequent lemmas (@lem:n-sign-if-kldv[Lemmas] @lem:sb-kl-strong-global-delivery[to]).
Let us first remind that, given two sets $A$ and $B$, we have $|A inter B| = |A|+|B|-|A union B|$.
Moreover, the number of correct processes $c$ is superior or equal to $n-t$. 
Additionally, if $A$ and $B$ are both sets containing a majority of correct processes, we have $|A union B| <= c$, which implies that $|A inter B| >= |A|+|B|-c$.

#paragraph[Safety proof]
The proofs of the safety properties are given in the following.

#lemma[
If a correct process $p_i$ $k2l$-delivers $(v,id)$, then at least $q_d-n+c$ correct processes have signed $(v,id)$ at @line:sb-k2l:k2l-sign.
] <lem:n-sign-if-kldv>

#proof[
If $p_i$ $k2l$-delivers $(v,id)$ at @line:sb-k2l:dlv, then it sent $q_d$ valid signatures for $(v,id)$ (because of the predicate at @line:sb-k2l:rcv-cond).
The effective number of Byzantine processes in the system is $n-c$, such that $0 <= n-c <= t$.
Therefore, $p_i$ must have sent at least $q_d-n+c$ (which, due to @assum:dlv-tshld, is strictly positive because $q_d > t >= n-c$) valid distinct signatures for $(v,id)$ that correct processes made at @line:sb-k2l:k2l-sign, during a $k2lcast(v,id)$ invocation. #qedhere
]

#lemma([$k2l$-Validity])[
If a correct process $p_i$ $k2l$-delivers a value $v$ with identity $id$, then at least $k' = q_d-n+c$ correct processes $k2l$-cast $v$ with identity $id$.
] <lem:sb-kl-validity>

#proof[
The condition at @line:sb-k2l:k2l-cond implies that the correct processes that $k2l$-cast $(v,id)$ constitute a superset of those that signed $(v,id)$ at @line:sb-k2l:k2l-sign.
Thus, by @lem:n-sign-if-kldv, their number is at least $k'=q_d-n+c$. 
]

#lemma([$k2l$-No-duplication])[
A correct process $k2l$-delivers at most one value $v$ with identity~$id$.
] <lem:sb-kl-no-duplication>

#proof[
This property derives trivially from the predicate at @line:sb-k2l:chk-cond. 
]

#lemma([$k2l$-No-duplicity])[
If the Boolean 
$nodpty = q_d > (n+t)/2$ is $ttrue$, then no two different correct processes $k2l$-deliver different values with the same identity~$id$.
] <lem:sb-kl-conditional-no-duplicity>

#proof[
Let $p_i$ and $p_j$ be two correct processes that respectively $k2l$-deliver $(v,id)$ and $(v',id)$.
We want to prove that, if the predicate $(q_d > (n+t)/2)$ is satisfied, then $v=v'$.
    
Thanks to the predicate at @line:sb-k2l:chk-cond, we can assert that $p_i$ and $p_j$ must have respectively sent at least $q_d$ valid signatures for $(v,id)$ and $(v',id)$, made by two sets of processes, that we respectively denote $A$ and $B$, such that $|A| >= q_d > (n+t)/2$ and $|B| >= q_d > (n+t)/2$.
We have $|A inter B| > 2(n+t)/2-n = t$.
Hence, at least one correct process $p_x$ has signed both $(v,id)$ and $(v',id)$.
But because of the predicate at @line:sb-k2l:k2l-cond, $p_x$ signed at most one couple $(star,id)$ during a $k2lcast(v,id)$ invocation at @line:sb-k2l:k2l-sign.
We conclude that $v$ is necessarily equal to $v'$.
]

#paragraph[Liveness proof]
The proofs of the liveness properties are given in the following.

#lemma[
All signatures made by correct processes at @line:sb-k2l:k2l-sign are eventually received by at least $c-d$ correct processes at @line:sb-k2l:rcv.
] <lem:rcv-all-sigs>

#proof[
Let ${s_1,s_2,...}$ be the set of all signatures for $(v,id)$ made by correct processes at @line:sb-k2l:k2l-sign.
We first show by induction that, for all $z$, at least $c-d$ correct processes receive all signatures ${s_1,s_2,...,s_z}$ at @line:sb-k2l:rcv.

Base case $z = 0$.
As no correct process signed $(v,id)$, the proposition is trivially satisfied.

Induction.
We suppose that the proposition is verified at $z$: signatures $s_1,s_2,...,s_z$ are received by a set of at least $c-d$ correct processes that we denote $A$.
We now show that the proposition is verified at $z+1$: at least $c-d$ correct processes eventually receive all signatures $s_1,s_2,...,s_(z+1)$.

The correct process that makes the signature $s_(z+1)$ broadcasts a $bundlem(v,id,sigs)$ message (at @line:sb-k2l:k2l-bcast) where $sigs$ contains $s_(z+1)$.
From the definition of the MA, $bundlem(v,id,sigs)$ is eventually received by a set of at least $c-d$ correct processes that we denote $B$.
We have $|A inter B| = 2(c-d)-c = c-2d > 2d-2t = 0$ (from @assum:no-partition).
Hence, at least one correct process $p_j$ eventually receives all signatures $s_1,s_2,...,s_(z+1)$, and thereafter broadcasts $bundlem(v,id,sigs')$ where ${s_1,s_2,...,s_(z+1)} subset.eq sigs'$.
Again, from the definition of the MA, $bundlem(v,id,sigs')$ is eventually received by a set of at least $c-d$ correct processes at @line:sb-k2l:rcv.
]

#lemma[
If no correct process $k2l$-casts $(v,id)$ at @line:sb-k2l:k2l, then no correct process $k2l$-delivers $(v,id)$ at @line:sb-k2l:dlv.  
] <lem:no-dlv-if-no-klc>

#proof[
Looking for a contradiction, let us suppose that a correct process $p_i$ $k2l$-delivers $(v,id)$ while no correct process $k2l$-cast $(v,id)$.
Because of the condition at @line:sb-k2l:chk-cond, $p_i$ must have broadcast at least $q_d$ valid signatures for $(v,id)$, out of which at most $t$ are made by Byzantine processes.
As $q_d > t$ (@assum:dlv-tshld), we know that $q_d-t > 0$.
Hence, at least one correct process must have $k2l$-cast $(m,id)$.
Contradiction.
]

#lemma([$k2l$-Local-delivery])[
If at least $k = q_d$ correct processes $k2l$-cast a value $v$ with identity $id$ and no correct process $k2l$-casts a value $v' != v$ with identity~$id$, then at least one correct process $p_i$ $k2l$-delivers the value $v$ with identity~$id$.  
] <lem:sb-kl-local-delivery>

#proof[
As no correct process $k2l$-casts a value $v' != v$ with identity~$id$, then @lem:no-dlv-if-no-klc holds, and no correct process can $k2l$-deliver $(v',id)$ where $v' != v$.
Moreover, no correct process can sign $(v',id)$ where $v' != v$ at @line:sb-k2l:k2l-sign, and thus all $k = q_d$ correct processes that invoke $k2lcast(v,id)$ at @line:sb-k2l:k2l also pass the condition at @line:sb-k2l:k2l-cond, and then sign $(v,id)$ at @line:sb-k2l:k2l-sign.
From @lem:rcv-all-sigs, we can assert that all $q_d$ signatures are received at @line:sb-k2l:rcv by a set of at least $c-d$ correct processes, that we denote $A$.
Let us consider $p_j$, one of the processes of $A$.
There are two cases:

- If $p_j$ passes the condition at @line:sb-k2l:rcv-cond, then it sends all $q_d$ signatures at @line:sb-k2l:rcv-bcast, then invokes $checkdelivery()$ at @line:sb-k2l:rcv-chk, passes the condition at @line:sb-k2l:chk-cond (if it was not already done before) and $k2l$-delivers $(v,id)$ at @line:sb-k2l:dlv;

- If $p_j$ does not pass the condition at @line:sb-k2l:rcv-cond, then it means that it has already sent all $q_d$ signatures before, whether it be at @line:sb-k2l:k2l-bcast or at @line:sb-k2l:rcv-bcast, but after that, it necessarily invoked $checkdelivery()$ (at @line:sb-k2l:k2l-chk or at @line:sb-k2l:rcv-chk, respectively), passed the condition at @line:sb-k2l:chk-cond (if it was not already done before) and $k2l$-delivered $(v,id)$ at @line:sb-k2l:dlv. #qedhere
]

#lemma([$k2l$-Weak-Global-delivery])[
If a correct process $k2l$-delivers a value $v$ with identity $id$, then at least $ell = c-d$ correct processes $k2l$-deliver a value $v'$ with identity $id$ (each of them possibly different from $m$).  
] <lem:sb-kl-weak-global-delivery>

#proof[
If $p_i$ $k2l$-delivers $(v,id)$ at @line:sb-k2l:dlv, then it has necessarily broadcast the $bundlem(v,id,sigs)$ message containing the $q_d$ valid signatures before, whether it be at @line:sb-k2l:k2l-bcast or at @line:sb-k2l:rcv-bcast.
From the definition of the MA, a set of at least $c-d$ correct processes, that we denote $A$, eventually receives this $bundlem(v,id,sigs)$ message at @line:sb-k2l:rcv. 
If some processes of $A$ do not pass the condition at @line:sb-k2l:rcv-cond upon receiving this $bundlem(v,id,sigs)$ message, it means that they already broadcast all signatures of $sigs$.
Thus, in every scenario, all processes of $A$ eventually broadcast all signatures of $sigs$ at @line:sb-k2l:k2l-bcast or at @line:sb-k2l:rcv-bcast.
After that, all processes of $A$ necessarily invoke the $checkdelivery()$ operation at @line:sb-k2l:k2l-chk or at @line:sb-k2l:rcv-chk, respectively, and then evaluate the condition at @line:sb-k2l:chk-cond.
Hence, all correct processes of $A$, which are at least $c-d = ell$, $k2l$-deliver some value for identity $id$ at @line:sb-k2l:dlv, whether it be $v$ or any other value.
#qedhere
]

#lemma([$k2l$-Strong-Global-delivery])[
If a correct process $k2l$-delivers a value $v$ with identity $id$, and no correct process $k2l$-casts a value $v' != v$ with identity $id$, then at least $ell = c-d$ correct processes $k2l$-deliver $v$ with identity $id$.  
] <lem:sb-kl-strong-global-delivery>

#proof[
If a correct process $k2l$-delivers $(v,id)$ at @line:sb-k2l:dlv, then by @lem:sb-kl-weak-global-delivery, we can assert that at least $ell = c-d$ correct process eventually $k2l$-deliver some value (not necessarily $v$) with identity $id$.
Moreover, as no correct process $k2l$-casts $(v',id)$ with $v' != v$, then @lem:no-dlv-if-no-klc holds, and we conclude that all $ell$ correct processes $k2l$-deliver $(v,id)$.
]

== Conclusion <sec:k2lcast-conclusion>

This chapter discussed the implementation of message-adversary-tolerant Byzantine reliable broadcast (MBRB) in asynchronous systems in a cryptography-free (or error-free) context.
To this end, it introduced a novel many-to-many communication primitive, called $k2l$-cast, which enables better quorum engineering, and enhances existing signature-free reliable broadcast algorithms (#eg Bracha @B87 and Imbs-Raynal @IR16) to make them not only resilient against a wider range of adversarial behaviours (namely Byzantine faults and a message adversary) but also more efficient (they terminate quicker).
This approach can be applied to the design of a wide range of quorum-based distributed algorithms other than reliable broadcast.
For instance, we conjecture that $k2l$-cast could benefit self-stabilizing and self-healing distributed systems~@ADDP19, where a critical mass of messages from other processes is needed to re-synchronize the local state of a given process.