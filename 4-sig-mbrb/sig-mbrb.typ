#import "../setup.typ": *

= A Simple Signature-Based \ MBRB Implementation <sec:sig-mbrb>

#v(2em)

#epigraph(
  [Some single mind must be master, else there will be no agreement in anything.],
  [Abraham Lincoln]
)

#v(2em)

This chapter presents an algorithm that implements the MBRB communication abstraction (presented in the previous chapter) in an asynchronous setting under the constraint $n > 3t+2d > 0$.
This algorithm uses digital signatures, and is optimal both in terms of Byzantine resilience and delivery power.
// #FT[Maybe summarize in one sentence what is key about this algorithm: it uses signatures and is optimal both in terms of Byzantine resilience and delivery power. You can then introduce the next sentence as a nice-to have additional property ("Furthermore, when consideirng")]

Furthermore, when considering $d=0$ (#ie no message adversary), this algorithm provides both an optimal $t$-resilience (as in Bracha's BRB~@B87, @alg:bracha-brb) and an optimal latency (as in Imbs-Raynal's BRB~@IR16, @alg:imbs-raynal-brb): it only assumes $n > 3t$, and guarantees mbrb-delivery of a value in only two communication rounds, which is optimal.
#footnote[
  Signature-based BRB in only two rounds is a known result~@ANRX21, however, to the best of our knowledge, no existing BRB algorithm tolerates message adversaries as well as ours.
]
Signatures can help save one round compared to classical signature-free BRB algorithms that assume $n > 3t$.
@alg:sb-mbrb fulfills the MBRB-Global-delivery property with a maximal delivery power#footnote[
  Recall from @sec:mbrb that this is the best possible delivery power for MBRB.
] of $lmbrb = c-d$ under the following assumption ("sb" stands for "signature-based").

#sb-mbrb-assumption(numbering: none)[$n > 3t+2d$.] <assum:sb-mbrb>

@tab:chap4-notations summarizes the acronyms and notations of this chapter.

#figure(placement: top,
  table(
    columns: 2, row-gutter: (0pt, 0pt, 3pt, 0pt), align: horizon,
    [*Acronyms*], [*Meanings*],
    [MA], [Message adversary],
    [MBRB], [MA-tolerant Byzantine reliable broadcast],
    [*Notations*], [*Meanings*],
    $n$, [number of processes in the system],
    $t$, [upper bound on the number of Byzantine processes],
    // $d$, [power of the message adversary],
    $c$, [effective number of correct processes in a run ($n-t <= c <= n$)],
    $secp$, [security parameter of the cryptographic primitives],
    $p_i$, [process of the system with identity $i$],
    // [$v$, $|v|$], [value, size of the value (in bits)],
    $star$, [unspecified value],
    $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
    $rtc$, [time complexity of MBRB],
    $omc$, [message complexity of MBRB],
    $bcc$, [communication complexity of MBRB \ (number of bits sent during the execution overall)]
  ),
  caption: [Acronyms and notations used in @sec:sig-mbrb]
) <tab:chap4-notations>

#paragraph[Roadmap]
@sec:sig-mbrb-prelim presents preliminary notions for this chapter.
@sec:sig-mbrb-impl presents @alg:sb-mbrb, a simple signature-based MBRB implementation, whose correctness proof and performance analysis are given in @sec:sig-mbrb-correct and @sec:sig-mbrb-perf, respectively.
Finally, @sec:sig-mbrb-conclu concludes the chapter.

== Preliminaries <sec:sig-mbrb-prelim>

#paragraph[Message types]
The algorithm uses only one message type, #bundlem, that carries the signatures backing a given value $v$, along with $v$'s content, sequence number, and emitter.
#bundlem messages propagate through the network using controlled flooding.

#paragraph[Local data structures]
Each (correct) process saves locally the valid signatures (#ie the signed fixed-size digests of some data) that it has received from other processes using #bundlem messages.
Each signature "endorses" a certain triplet $(v,sn,j)$.
When certain conditions are met (described below), a process further broadcasts in a #bundlem message all signatures it knows for a given triplet $(v,sn,j)$.
A correct process $p_i$ saves at most one signature for a $(v,sn,j)$ triplet per signing process $p_k$.

#paragraph[Time measurement]
For the proofs related to MBRB-Time-cost (@lem:amt-dlv-2-rnd[Lemmas] @lem:sb-mbrb-time-cost[to]), we assume that the duration of local computations is negligible compared to that of message transfer delays, and consider them to take zero time units.
As the system is asynchronous, time is measured under the traditional assumption that all messages have the same transfer delay @CR93.

#paragraph[Digital signatures]
We assume the availability of an asymmetric cryptosystem to sign data (in practice, messages) and verify its authenticity.
We assume that signatures are secure and, therefore, that the computing power of the adversary is bounded.
Every process in the network has a public/private key pair.
We suppose that the public keys are known to everyone and that the private keys are kept secret by their owner.
Everyone also knows the mapping between any process' identity $i$ and its public key.
Additionally, we suppose that each process can produce at most one signature per message.

The signatures are used to cope with the net effect of the Byzantine processes, and the fact that messages broadcast (sent) by correct processes can be eliminated by the message adversary.
A noteworthy advantage of signatures is that, despite the unauthenticated nature of the point-to-point communication channels, signatures allow correct processes to verify the authenticity of messages that have not been directly received from their initial sender but rather relayed through intermediary processes.
Signatures provide us with a _network-wide_ non-repudiation mechanism: if a Byzantine process issues two conflicting messages to two different subsets of correct processes, then the correct processes can detect the malicious behavior by disclosing to each other the Byzantine signed messages.
#footnote[
  The fact that the algorithm uses signed messages does not mean that MBRB requires signatures to be implemented, see @sec:k2l-cast.
]

#paragraph[Size of values and signatures]
To analyse the communication cost of @alg:sb-mbrb (@lem:sb-mbrb-comm-cost), we must characterize the size (in bits) of the structures used in the algorithm, in particular values and digital sigantures.
We denote by $|v|$ the size of a value $v$ disseminated through the MBRB abstraction.
We further assume that the size of signatures is linear in the security parameter $secp$ of the cryptographic primitives (see @sec:model-crypto-schemes), #ie each signature has $O(secp)$ bits.
Lastly, as traditionally assumed, we assume that $secp = Omega(log n)$.

== Algorithm <sec:sig-mbrb-impl>

At a high level, @alg:sb-mbrb works by producing, forwarding, and accumulating _witnesses_ of an initial #mbrbbroadcast operation until a large enough quorum is observed by at least one correct process, which propagates this quorum of signatures in one final unreliable #broadcast operation.

Witnesses take the form of signatures for a given triplet $(v,sn,i)$, where $v$ is the value, $sn$ its associated sequence number, and $i$ the identity of the sender $p_i$ (which also produces a signature for $(v,sn,i)$).
Signatures serve to ascertain the provenance and authenticity of these propagated #bundlem messages, thus providing a key ingredient to tolerate the limited reliability of the underlying network.
They also authenticate the invoker of the #mbrbbroadcast operation.
Finally, in the last phase of the algorithm, they allow the propagation of a cryptographic proof that a quorum has been reached, thereby ensuring that enough correct processes eventually mbrb-deliver the value that was mbrb-broadcast.

#include "alg/sb-mbrb.typ"

In more detail, when a (correct) process $p_i$ invokes $mbrbbroadcast(v,sn)$, it builds and signs the triplet $(v,sn,i)$ to guarantee its non-repudiation, and saves locally the resulting signature (@line:sb-mbrb:snd-save-own-sig).
Next, $p_i$ broadcasts the #bundlem message containing the signature it just produced (@line:sb-mbrb:snd-bcast).

When a correct process $p_i$ receives a $bundlem(v,sn,j,sigs)$ message, it first checks that no value has already been mbrb-delivered for the given sequence number $sn$ and sender $p_j$ (@line:sb-mbrb:rcv-cond-alrdy-dlv), and if the sender $p_j$ signed the value (@line:sb-mbrb:rcv-cond-no-snd).
If this condition is satisfied, $p_i$ saves all the new (#ie unsaved) valid signatures inside the $sigs$ set (@line:sb-mbrb:rcv-save-sigs).
Next, $p_i$ creates and saves its own signature for $(v,sn,j)$ and then broadcasts it in a #bundlem message, if it has not already done so previously (@line:sb-mbrb:rcv-cond-fwd[lines]-@line:sb-mbrb:rcv-fwd[]).
Finally, if $p_i$ has saved a quorum of strictly more than $(n+t)/2$ signatures for the same triplet $(v,sn,j)$, it broadcasts a #bundlem message containing all these signatures and mbrb-delivers the triplet (@line:sb-mbrb:rcv-cond-dlv[lines]-@line:sb-mbrb:rcv-dlv[]).
#footnote[
  The pseudo-code presented in @alg:sb-mbrb favors readability and is therefore not fully optimized.
  For instance, in some cases, a process might unreliably broadcast exactly the same content at @line:sb-mbrb:rcv-fwd[lines] and~@line:sb-mbrb:rcv-bcast-quorum[].
  This could be avoided by using an appropriate flag or tracking and preventing the repeated broadcast of identical #bundlem messages.
]

The reader can notice that the system parameters $n$ and $t$ appear in the algorithm, whereas the system parameter $d$ does not.
Naturally, they all explicitly appear in the proof.

== Correctness proof of @alg:sb-mbrb <sec:sig-mbrb-correct>
This section proves the correctness properties of MBRB.

#theorem("MBRB-Correctness")[
If _ #sb-mbrb-assum _ is satisfied, then _ @alg:sb-mbrb _ implements MBRB with the guarantee $lmbrb = c-d$.
] <thm:sb-mbrb-correctness>

The proof follows from the next five lemmas.

#lemma([MBRB-Validity])[
If a correct process $p_i$ mbrb-delivers $v$ from a correct process $p_j$ with sequence number $sn$, then $p_j$ has previously mbrb-broadcast $v$ with sequence number $sn$.
] <lem:sb-mbrb-validity>

#proof[
If a correct process $p_i$ mbrb-delivers $(v,sn,j)$ (where $p_j$ is correct) at @line:sb-mbrb:rcv-dlv, then it has passed the condition at @line:sb-mbrb:rcv-cond-no-snd, which means that it must have witnessed a valid signature for $(v,sn,j)$ by $p_j$.
Since signatures are secure, the only way to create this signature is for $p_j$ to execute
the instruction at @line:sb-mbrb:snd-save-own-sig, during the $mbrbbroadcast(v,sn)$ invocation.
]

#lemma([MBRB-No-duplication])[
A correct process $p_i$ mbrb-delivers at most one value from a process $p_j$ with a given sequence number $sn$.
] <lem:sb-mbrb-no-duplication>

#proof[
This property derives trivially from the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv.
]

#lemma([MBRB-No-duplicity])[
No two different correct processes mbrb-deliver different values from a process $p_i$ with the same sequence number~$sn$.
] <lem:sb-mbrb-no-duplicity>

#proof[
Let us consider two correct processes $p_a$ and $p_b$ which respectively mbrb-deliver $(v,sn,i)$ and $(v',sn,i)$.
Due to the condition at @line:sb-mbrb:rcv-cond-dlv, $p_a$ and $p_b$ must have saved (and thus received) two sets $Q_a$ and $Q_b$ containing strictly more than $(n+t)/2$ signatures for $(v,sn,i)$ and $(v',sn,i)$, respectively.
We thus have $|Q_a| > (n+t)/2$ and $|Q_b| > (n+t)/2$.

As, for any two sets $A$ and $B$, we have $|A inter B| = |A|+|B|-|A union B| >= |A|+|B|-n > 2 (n+t)/2-n = t$, $A$ and $B$ have at least one correct process $p_k$ in common, which must have signed both $(v,sn,i)$ and $(v',sn,i)$.
But before signing $(v,sn,i)$ at @line:sb-mbrb:snd-save-own-sig or at @line:sb-mbrb:rcv-save-own-sig, $p_k$ checks that it did not sign a different value from the same sender and with the same sequence number, whether it be implicitly during a $mbrbbroadcast(v,sn)$ invocation or at @line:sb-mbrb:rcv-cond-fwd.
Thereby, $v$ is necessarily equal to $v'$.
]

#lemma([MBRB-Local-delivery])[
If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then at least one correct process $p_j$ mbrb-delivers $v$ from $p_i$ with sequence number $sn$.
] <lem:sb-mbrb-local-delivery>

#proof[
If a correct process $p_i$ mbrb-broadcasts $(v,sn)$, then it broadcasts its own signature $sig_i$ for $(v,sn,i)$ in a $bundlem(v,sn,i,{sig_i})$ message at @line:sb-mbrb:snd-bcast.
As $p_i$ is correct, it does not sign another triplet $(v',sn,i)$ where $v' != v$, therefore it is impossible for a correct process to mbrb-deliver $(v',sn,i)$ at @line:sb-mbrb:rcv-dlv, because it cannot pass the condition at @line:sb-mbrb:rcv-cond-no-snd.

Let $K$ be the set of correct processes that receive a message $bundlem(v,sn,i,{sig_i,...})$ at least once.
Note that because $p_i$ executes @line:sb-mbrb:snd-bcast, by definition of the message adversary, $K$ contains at least $c-d$ processes.
The assumption $n>3t+2d$ further yields that $c-d>2t+d>= 0$, and therefore $K != diameter$.
The first one of such $bundlem$ messages that a process of $K$ receives can be the one $p_i$ initially broadcast at @line:sb-mbrb:snd-bcast, but it can also be a $bundlem$ message broadcast by a correct process at @line:sb-mbrb:rcv-fwd or at @line:sb-mbrb:rcv-bcast-quorum, or it can even be a $bundlem$ message sent by a Byzantine process.
In any case, the first time the processes of $K$ receive such a $bundlem$ message, they pass the conditions at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[], and they also pass the condition at @line:sb-mbrb:rcv-cond-fwd, except for $p_i$ if it belongs to $K$.
Consequently, each process $p_k$ of $K$ necessarily broadcasts its own signature $sig_k$ for $(v,sn,i)$ in a $bundlem(v,sn,i,{sig_k,sig_i,...})$ message.

By construction of the algorithm, the set $K$ of correct processes that ever receive a $bundlem(v,sn,i,{sig_i,...})$ message is therefore included into the set $K'$ of correct processes $p_k$ that ever broadcast a $bundlem(v,sn,i,{sig_k,sig_i,...})$, $K subset.eq K'$.
This inclusion in turn implies
$
  |K| <= |K'|. #<eq:K-smaller-than-Kp>
$
By the definition of the message adversary, a message $bundlem(v,sn,i,{sig_k,sig_i,...})$ broadcast by a correct process $p_k in K'$ is eventually received by at least $c-d$ correct processes.
Because $K$ is the set of processes that ever receives $sig_i$ in a $bundlem$ message, these $c-d$ correct processes belong to $K$ by construction.
Hence, the minimum number of signatures for $(v,sn,i)$ made by processes of $K'$ that are also received by processes of $K$ globally is $|K'|(c-d)$.
Using $K != diameter$ and therefore $|K| > 0$, it follows that a given process of $K$ individually receives on average the distinct signatures of at least $|K'|(c-d)/(|K|)$ processes of $K'$.

Using @eq:K-smaller-than-Kp yields $|K'|(c-d)/(|K|) >= c-d$.
From #sb-mbrb-assum, we have
$n > 3t+2d <==> 2n > n+3t+2d <==> 2n-2t-2d > n+t <==> c-d >= n-t-d > (n+t)/2$ (as $n-t <= c$).
As a result, by the pigeonhole principle, at least one process $p_j$ of $K$ (ergo one correct process) receives a set $S$ (in possibly multiple $bundlem$ messages) of strictly more than $(n+t)/2$ valid distinct signatures for $(v,sn,i)$.
When $p_j$ receives the last signature of $S$, there are two cases:

- Case if $p_j$ does not pass the conditions at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[].
    
  As processes of $K$ are correct, then when they broadcast a $bundlem(v,sn,i,sigs)$ message, they necessarily include $sig_i$ in $sigs$, which implies that $sig_i$ is necessarily in $S$.
  Therefore, if $p_j$ does not pass the condition at @line:sb-mbrb:rcv-cond-alrdy-dlv, it is because $p_j$ already mbrb-delivered some $(star,sn,i)$.
  Recall that, as $p_i$ is correct, it is impossible for $p_j$ to mbrb-deliver anything different from $(v,sn,i)$.
  Therefore, $p_j$ has already mbrb-delivered $(v,sn,i)$.
    
- Case if $p_j$ passes the conditions at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[].
  
  Process $p_j$ then saves all signatures of $S$ at @line:sb-mbrb:rcv-save-sigs, and after it passes the condition at @line:sb-mbrb:rcv-cond-dlv (as
  $|S| > (n+t)/2$) and finally mbrb-delivers
  $(v,sn,i)$ at @line:sb-mbrb:rcv-dlv. #qedhere
]

#lemma([MBRB-Global-delivery])[
If a correct process $p_i$ mbrb-delivers a value $v$ from $p_j$ with sequence number $sn$, then at least $lmbrb = c-d$ correct processes mbrb-deliver $v$ from $p_j$ with sequence number $sn$.
] <lem:sb-mbrb-global-delivery>

#proof[
If a correct process $p_i$ mbrb-delivers $(v,sn,j)$ at @line:sb-mbrb:rcv-dlv, it must have saved a set $sigs$ of strictly more than $(n+t)/2$ valid distinct signatures because of the condition at @line:sb-mbrb:rcv-cond-dlv.
Let us remark that $sigs$ necessarily contains the signature for $(v,sn,j)$ by $p_j$ because of the condition at @line:sb-mbrb:rcv-cond-no-snd.
Additionally, $p_i$ must also have broadcast  $bundlem(v,sn,i,sigs)$ at @line:sb-mbrb:rcv-bcast-quorum, that, by definition of the message adversary, is received by a set $K$ of at least $c-d$ correct processes.
For each process $p_k$ of $K$, we have the following.

- If $p_k$ does not pass the conditions at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[], it is necessarily because it has already mbrb-delivered some $(star,sn,j)$ at @line:sb-mbrb:rcv-dlv.
  But because of MBRB-No-duplicity, $p_k$ has necessarily mbrb-delivered $(v,sn,j)$.
    
- If $p_k$ passes the conditions at @line:sb-mbrb:rcv-cond-alrdy-dlv[lines] and~@line:sb-mbrb:rcv-cond-no-snd[], then it saves all signatures of $sigs$ at @line:sb-mbrb:rcv-save-sigs and then passes the condition at @line:sb-mbrb:rcv-cond-dlv and finally mbrb-delivers $(v,sn,j)$ at @line:sb-mbrb:rcv-dlv.

Therefore, all processes of $K$ (which, as a reminder, are at least $c-d=lmbrb$) necessarily mbrb-deliver $(v,sn,j)$ at @line:sb-mbrb:rcv-dlv.
]

#paragraph[Remark]
Neither of @lem:sb-mbrb-validity[Lemmas], @lem:sb-mbrb-no-duplication[], @lem:sb-mbrb-no-duplicity[] or~@lem:sb-mbrb-global-delivery[] use the assumption $n>3t+2d$ (#sb-mbrb-assum).
As a result, if @alg:sb-mbrb is used in a situation when the message adversary can partition the system ($n <= 2d$), the safety properties of the algorithm (MBRB-Validity, MBRB-No-duplication, and MBRB-No-duplicity) and the MBRB-Global-delivery property continue to hold.
In case of partition, however, the MBRB-Local-delivery property might get violated, as a value mbrb-broadcast by a correct process might fail to gather a quorum of signatures at @line:sb-mbrb:rcv-cond-dlv to trigger mbrb-delivery at @line:sb-mbrb:rcv-dlv.

== Theoretical performance analysis of @alg:sb-mbrb <sec:sig-mbrb-perf>

#include "new-perf-analysis.typ"
// #include "old-perf-analysis.typ"

// // == Experimental latency analysis (?)

== Conclusion <sec:sig-mbrb-conclu>

This chapter has presented an asynchronous  algorithm implementing the Message-Adversary-tolerant Byzantine reliable broadcast (MBRB) abstraction, #ta[introduced in @sec:model-and-mbrb to capture the problem of reliable broadcast in the context of the hybrid failures].
// #FT[Remind the reader how where the MBRB abstraction comes from, "as introduced in Chapter XXX to capture the problem of reliable broadcast in the context of the hybrid fault model that underpins this thesis' work"]
More precisely, this algorithm works in spite of Byzantine failures and message losses caused by an adversary.
To do so, this MBRB algorithm exploits cryptographic signatures, and assumes $n > 3t+2d$ (where $n$ is the number of processes, $t$ is the maximum number of Byzantine processes, and $d$ is an upper bound on the power of the message adversary), that we have shown to be a necessary and sufficient condition in @sec:nec-cond-mbrb (hence, the bound is tight).
Moreover, when there is no message adversary, this algorithm is optimal both in terms of Byzantine resilience and the number of communication rounds.
// These properties are also satisfied in other circumstances, including a message adversary whose power $d$ is restricted to some well-defined threshold.