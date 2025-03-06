#import "../setup.typ": *

= Background <sec:background>

#v(2em)

#epigraph(
  [If I have seen further, it is by standing on the shoulders of Giants.],
  [_Isaac Newton_, letter to Robert Hooke, 1675]
)

#v(2em)

// In the following, we first define the basic system model assumed by all the solutions presented in this chapter (@sec:sota-model), and we then develop the state-of-the-art of this dissertation's two main study topics: _Byzantine reliable broadcast_ (@sec:sota-brb) and _hybrid fault models_ (@sec:sota-hybrid).

This chapter provides the foundational knowledge and state-of-the-art context necessary to understand the research landscape in which this thesis is situated.
We begin by defining the standard system model (@sec:sota-model) underpinning the existing solutions discussed in this chapter.
This model sets the stage for our exploration on two key areas: _Byzantine reliable broadcast_~(_BRB_) and _hybrid fault models_.
In @sec:sota-brb, we delve into the state-of-the-art in _Byzantine reliable broadcast_, a fundamental primitive in distributed systems that ensures reliable cooperation in the presence of Byzantine faults.
We examine both asynchronous and synchronous implementations, highlighting key algorithms and recent advancements in efficiency and fault tolerance.
@sec:sota-hybrid explores _hybrid fault models_, which combine traditional Byzantine process failures with dynamic link failures.
// This section provides crucial context for our work on extending BRB to more complex failure scenarios.
By the end of this chapter, readers will have a comprehensive understanding of the current state of research in fault-tolerant distributed systems, setting the stage for the novel contributions presented in subsequent chapters.

@tab:chap2-notations summarizes the acronyms and notations used in this chapter.

#figure(placement: auto,
  table(
    columns: 2, row-gutter: (0pt, 0pt, 3pt, 0pt),
    [*Acronyms*], [*Meanings*],
    [BRB], [Byzantine-tolerant reliable broadcast],
    [MA], [Message adversary],
    // [MBRB], [Message adversary- and Byzantine-tolerant reliable broadcast],
    [*Notations*], [*Meanings*],
    $n$, [number of processes in the system],
    $t$, [upper bound on the number of Byzantine processes],
    // $d$, [power of the message adversary],
    $c$, [effective number of correct processes in a run ($n-t <= c <= n$)],
    $secp$, [security parameter of the cryptographic primitives],
    $p_i$, [process of the system with identity $i$],
    // [$v$, $|v|$], [BRB value, size of the BRB value (in bits)],
    $star$, [unspecified value],
    // $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
    // $rtc$, [time complexity of MBRB],
    // $omc$, [message complexity of MBRB]
  ),
  caption: [Acronyms and notations used in @sec:background]
) <tab:chap2-notations>

== The standard system model <sec:sota-model>
// #FT[This section contains very few references. You could inject at least a few to link up what you present to the existing body of knowledge: e.g. mentioning one of Michel's books]
The formal design and analysis of distributed algorithms requires a precise model of computation.
Many models exist that cover the capacities of interacting agents (_Do they have an identity? Do they know each other? Is their setup static or dynamic?_), the type of interactions (#eg shared memory or message passing, see @sec:intro-dist-def), the fault model (crash faults, Byzantine faults, see @sec:intro-faults), or temporal assumptions (synchrony vs. asynchrony, see @sec:intro-sync-async)~@CGR11 @L96 @R13 @R18.
In what follows, we describe one such system model that became a _de facto_ standard in many distributed computing works.
This is the common model assumed by all state-of-the-art solutions presented in @sec:sota-brb and @sec:sota-hybrid.

// In this section, we consider the common features on the system models of the solutions presented in this state-of-the-art.#FT[Scaffolding text. Can you think of some header text that would ease the reader into the rest of the section? Some context or background, e.f. "The formal design and analysis of distributed algorithms requires a precise model of computation. Many models exist, that cover the capacities of interacting agents (do they have an identity? do they know each other? is their setup static or dynamic?), the type of interactions (e.g. shared memory or message passing), the fault model (crash faults, Byzantine faults), temporal assumptions (synchrony vs. asynchrony). In what follows, we ..."]

=== Process model
The different solutions presented in this chapter assume a static message-passing distributed system comprising $n$ processes, denoted $p_1$, ..., $p_n$.
Each process $p_i$ has an identity, and all the identities are different and known by all processes.
To simplify, we assume that $i$ is the identity of $p_i$.

Regarding failures, up to $t<n$ processes can be Byzantine, where a Byzantine process is a process whose behavior does not follow the code specified by its algorithm~@LSP82 @PSL80.
Byzantine processes can collude to fool the non-Byzantine processes (also called correct processes).
Let us also notice that, in this model, the premature stop (crash) of a process is a Byzantine failure.

Moreover, given an execution of the algorithm, $c$ denotes the number of processes that effectively behave correctly in that execution.
We always have $n-t <= c <= n$.
While this number remains unknown to correct processes, it is used in the following to analyze and characterize (more precisely than using its lower bound $n-t$) the guarantees provided by the proposed algorithm.

=== Communication model <sec:sota-comm-model>

The processes communicate through a fully connected point-to-point communication network.
This network is assumed to be reliable in the sense that it neither corrupts, loses, nor creates messages.
This chapter discusses both asynchronous and synchronous algorithms, so no synchrony assumption on the network is made at this stage.

Let $msgm$ be a message type and $v$ the associated value. 
A process can invoke the unreliable operation $broadcast$ $msgm(v)$, which is a shorthand for "*for all* $i in {1, dots, n}$ *do* $send$ $msgm(v)$ *to* $p_i$ *end for*."
It is assumed that all the correct processes invoke $broadcast$ to send messages. 
As we can see, the operation $broadcast$ $msgm(v)$ is unreliable.
For example, if the invoking process crashes during its invocation, some correct processes might receive the implementation message $msgm(v)$ while others do not.
// #FT[Unpack the implications of these: In particular, some correct processes might receive $msgm(v)$ while others do not.]
Moreover, a Byzantine process can, by its very nature, send messages without using the macro-operation $broadcast$.

From a terminology point of view, at the implementation/network level, we say that messages are _broadcast_ and _received_.
Let us remind that we distinguish _messages_ (which relate to the implementation level) from _values_ (which refer to the applicative payloads).

=== Cryptographic schemes <sec:model-crypto-schemes>
Some of the solutions presented in this manuscript use cryptographic schemes, such as secure hash functions, asymmetric signatures, or erasure codes.

#paragraph[Computationally-bounded cryptographic adversary]
Except for very specific _theoretically unbreakable_ cryptographic schemes (#eg one-time pads
#footnote[
  One-time pads however introduce costly assumptions to function, making them seldom used in practice.
]), cryptography notoriously relies on probabilistic assumptions, such as the intractability of reversing one-way functions (#eg the prime factorization or discrete log problems). 
To this end, it is typically assumed that the adversary is computationally bounded (what is sometimes formalized as a _probabilistic polynomial-time_ (_PPT_) adversary in the literature @KL14).
This adversary tries to compromise the private information of honest participants (#eg secret keys, messages, #etc) based on the information publicly transiting on the network (#eg public keys, signatures, #etc).

#paragraph[Security parameter $bold(secp)$]
Following the cryptography literature, a cryptographic scheme's security level is characterized by an abstract _security parameter_, which we denote $secp$: the higher this parameter, the more secure the scheme is @KL14.

However, for each cryptographic scheme, a trade-off exists between its security level (represented by $secp$) and its storage and computational costs.
A cryptographic scheme outputs cryptographic structures (such as hashes or signatures) and has associated storage costs (the size of the structures) and computational costs (the time taken to generate or verify the structures).
But to increase the scheme's resistance to attacks, we typically increase the size of its structures, which also increases its storage and computational cost.

// #FT[The link between this paragraph and the precedent needs to be revised. The role/meaning of $secp$ is unclear. Here you say it represents the security level of the scheme, while you've just said that it characterizes the storage and computational cost. Both are linked of course, but I think the confusion arises because we are told that $secp$ is two things before being told that these two things are essentially the same.]
For example, if we want a higher security level for a hash function (#ie better resistance against collision and preimage attacks), then the hashes must be longer, incurring higher storage and computational overhead.
In fact, $secp$ is proportional to the scheme's number of security bits (the effective number of bits one has to brute-force to break it).
It is typically assumed that the communication and computational costs of cryptographic schemes is in $O(secp)$ (#eg a hash has $O(secp)$ bits).

Moreover, it is commonly assumed that, in a system of $n$ processes, we have $secp = Omega(log n)$.
Indeed, as public keys (or hashes of public keys, which have $O(secp)$ bits) are typically used to identify the system's processes, the keyspace must be at least as large as the minimum number of bits needed to identify each process (#ie $log n$).
This constraint also follows from the assumption that an adversary controlling a constant fraction of a system of size $n$ cannot bruteforce the cryptographic schemes too quickly, or more formally, that her computing power is subexponential in the security parameter $secp$.

== Byzantine reliable broadcast (BRB) <sec:sota-brb>

The system model presented in @sec:sota-model was initially proposed in the eighties and has since motivated a large body of work regarding its inherent computability limits, as well as the fundamental primitives it can support.
One such primitive is reliable broadcast, whose goal and importance have been highlighted in @sec:reliable-bcast.
Due to its fundamental nature, Byzantine reliable broadcast (BRB) has been addressed by many authors, as we will see in the following.
But first, let us formally define the BRB abstraction.
// #FT[It would be nice to link up what follows with that you've just presented. E.g. "The system model presented in Section 1.1. was initially proposed in eighties and has since then motivated a large body of work regarding its inherent computability limits, and the fundamental primitives it can support. One such primitive is reliable broadcast, which .... In a Byzantine fault model, the problem of ... "]
// #FT[Providing some high-level context on BRB before diving into the technical details is also a good idea: it tells the reader why what follows is important, and why she should pay attention, e.g. that it was first introduced forty years ago, and is still an active research area, among others due to its importance when implementing some permissioned blockchain algorithms (e.g. HotStuff or HoneyBadger).]

#paragraph[BRB operations]
The BRB communication abstraction comprises two matching operations, denoted $brbbroadcast()$ and $brbdeliver()$.//#FT[Formally $brbdeliver$ is more a callback than an operation.]
It considers that each value $v$ disseminated using BRB has a unique identity $(sn,i)$ (sequence number, sender identity).
Furthermore, it assumes (as a precondition) that any two invocations of the $brbbroadcast()$ by a correct process provide different sequence numbers.
Sequence numbers are one of the most natural ways to design "multi-shot" reliable broadcast algorithms, that is, algorithms where the $brbbroadcast()$ operation can be invoked multiple times with different values.

When, at the application level, a process $p_i$ invokes $brbbroadcast(v,sn)$, where $v$ is the value and $sn$ the associated sequence number, we say $p_i$ "brb-broadcasts~$(v,sn)$."
Similarly, when $p_i$ invokes $brbdeliver(v,sn,j)$, where $p_j$ is the sender process, we say $p_i$ "brb-delivers $(v,sn,j)$."
The $brbdeliver()$ operation is, in fact, a callback issued by the abstraction to notify the client that a value has been delivered.
To summarize, we say that the values are _brb-broadcast_ and _brb-delivered_ (while, as said in @sec:sota-comm-model, the messages of the underlying algorithm are _broadcast_ and _received_).

#paragraph[BRB properties]
The BRB abstraction is defined by the following safety and liveness properties @B87 @R18.

- *Safety.*
  - *BRB-Validity (no spurious message).*
    If a correct process $p_i$ brb-delivers a value $v$ from a correct process $p_j$ with sequence number $sn$, then $p_j$ brb-broadcast $v$ with sequence number $sn$.
    
  - *BRB-No-duplication.*
    A correct process $p_i$ brb-delivers at most one value $v$ from a process $p_j$ with sequence number $sn$.
  
  - *BRB-No-duplicity.*
    No two correct processes brb-deliver different values from a process $p_i$ with the same sequence number $sn$.

- *Liveness.*
  - *BRB-Local-delivery.*
    If a correct process $p_i$ brb-broadcasts a value $v$ with sequence number $sn$, then at least one correct process $p_j$ eventually brb-delivers $v$ from $p_i$ with $sn$.
    
  - *BRB-Global-delivery.*
    If a correct process $p_i$ brb-delivers a value $v$ from a process $p_j$ with sequence number $sn$, then all $c$ correct processes brb-deliver $m$ from $p_j$ with sequence number $sn$.

Given two correct processes $p_i$ and $p_j$, a value $v$ and a sequence number $sn$, BRB guarantees that _"$p_i$ brb-delivers $v$ from $p_j$ with $sn$ if and only if $p_j$ has brb-broadcast $v$ with $sn$"_ (the _"if and only"_ translates to a double implication that entails both BRB-Validity and BRB-Local-delivery).
Furthermore, given a correct process $p_i$, a (correct or Byzantine) process $p_j$, a value $v$ and a sequence number $sn$, BRB also ensures that _"if $p_i$ brb-delivers $v$ from $p_j$ with $sn$, then, all correct processes brb-deliver only $v$ for the value identity $(sn,j)$"_ (this captures BRB-No-duplicity and BRB-Global-delivery, and the _"only"_ guarantees BRB-No-duplication).
    
=== Asynchronous signature-free BRB

// #FT[Some more context would be welcome: e.g. you could explain that the power of signatures when implementing distributed algorithms was recognized very early, e.g. by Lamport who introduced oral and written messages. Using signatures imposes, however, additional assumptions (the existence of a PKI, a limit on the computer power of individual processes). Researchers have therefore repeatedly striven to propose signature-free implementations of BRB.]

The power of digital signatures for implementing distributed algorithms was recognized very early.
For example, Lamport, Shostak, and Pease showed in 1982~@LSP82 how _signed_ messages can drastically improve fault tolerance over _oral_ (#ie unsigned) messages#footnote[
  In particular, Lamport, Shostak, and Pease showed that, in a synchronous context, it is possible to implement BRB under any arbitrary number of Byzantine processes using signatures; but without them, it is only possible to tolerate less than one-third of Byzantine processes @LSP82.
], just a few years after the public description of RSA @RSA78, the first secure public-key cryptosystem for encryption and digital signatures.
However, using signatures imposes additional assumptions, #eg the existence of a public-key infrastructure (PKI) or a limit on the computing power of the adversary~(see @sec:model-crypto-schemes).
Since the introduction of the Byzantine reliable broadcast (BRB) problem, researchers have therefore repeatedly striven to propose solutions that do not rely on digital signatures.
Hence, this section presents two of the most prominent signature-free BRB algorithms: Bracha's BRB @B87, and Imbs-Raynal's BRB @IR16.

In the following algorithms and throughout this manuscript, the $star$ symbol is used as a wildcard (any value can be matched).

#paragraph[Bracha's BRB (1987)]
One of the most famous and earliest asynchronous BRB algorithms, described in @alg:bracha-brb, is due to Bracha @B87.
For a value disseminated by a correct sender, this algorithm gives rise to three sequential communication steps and up to $(n-1)(2n+1)$ messages sent by correct processes.
This algorithm requires $n>3t$, which is optimal in terms of fault tolerance.
The versatility  of Bracha's algorithm has been analyzed in~@HKL20 @R21.

Like many other distributed agreement algorithms, Bracha's BRB leverages the concept of _quorums_ @MR98, which refers to a subset of processes that (at the implementation level) "vote" for the same value.
This definition takes quorums in their ordinary sense: in a deliberative assembly, a quorum is the minimum number of members that must vote the same way for an irrevocable decision to be taken.

#include "alg/bracha-brb.typ"

As detailed in @alg:bracha-brb, Bracha's BRB works in three communication phases, each associated with a particular message type: $initm$, $echom$, and $readym$.
The initial BRB sender uses the $initm$ type to broadcast her value to everyone in the network at @line:b-brb:snd-bcast.
Next, all (correct) receivers of the $initm$ message broadcast an $echom$ message at @line:b-brb:rcv-init-bcast containing the first value $v$ they received for the associated _identity_ $(sn,i)$.

When some correct process observes a quorum of $echom$ messages for the first time, it sends a $readym$ message backing the same value at @line:b-brb:quorum-echo-bcast-ready.
Finally, when a correct receives _enough_ $readym$ messages for the same value, it brb-delivers this value at @line:b-brb:quorum-ready-dlv.
By construction, it is impossible to observe two different quorums of strictly more than $(n+t)/2$ $echom$ messages backing two different values $v != v'$.

Informally, the $echom$ phase guarantees BRB-No-duplicity (at most one value can be brb-delivered), while the $readym$ phase guarantees BRB-Global-delivery (if some process brb-delivers, everyone brb-delivers).

#paragraph[Imbs-Raynal's BRB (2016)]
Addressing efficiency issues, Imbs and Raynal proposed another signature-free BRB algorithm @IR16, described in @alg:imbs-raynal-brb.
This algorithm implements the reliable broadcast of a value by a correct process with only two communication steps (which is optimal) and up to $n^2-1$ messages sent by correct processes.
The price for this gain in efficiency is a weaker $t$-resilience than Bracha's BRB, namely $n>5t$.
Hence, this algorithm and Bracha's algorithms differ in their trade-off between $t$-resilience and message/time efficiency.

#include "alg/imbs-raynal-brb.typ"

As detailed in @alg:imbs-raynal-brb, Imbs-Raynal's BRB works in only two communication phases, each associated with a particular message type: $initm$ and $witnessm$.
Like in Bracha's BRB, the initial sender in Imbs-Raynal's BRB broadcasts her value to everyone in a $initm$ message at @line:ir-brb:snd-bcast.
Then, every correct receiver broadcasts a $witnessm$ message backing the first received value from the sender @line:ir-brb:rcv-init-bcast.
A first threshold of $n-2t$ received $witnessm$ messages for the same value corresponds to the situation where a correct process can broadcast a new $witnessm$ message for this value at @line:ir-brb:quorum1-witness-fwd, if it has not already done so previously.
A second threshold of $n-t$ received $witnessm$ messages for the same value corresponds to a brb-delivery of this value at @line:ir-brb:quorum2-witness-dlv.

Intuitively, the $witnessm$ message of Imbs-Raynal's algorithm fulfills the functions of both the $echom$ and $readym$ messages in Bracha's algorithm.
Indeed, the first threshold is large enough to guarantee BRB-No-duplicity (there cannot be two different quorums of $n-2t$ messages if $n>5t$), while the _forwarding_ mechanism and the second threshold ensure BRB-Global-delivery.
// #FT[The intuitive explanations of Bracha and Imbs Raynal work very well I think. :-)]

=== Asynchronous communication-efficient BRB <sec:sota-comm-efficien-brb>

Besides improving the resilience and round complexity (#ie latency) of BRB, reducing its communication cost (#ie the number of bits sent in the network overall) is also an important research direction.
Here are a few recent results.
Similarly to Bracha's algorithm, all these algorithms assume an underlying fully connected asynchronous reliable network.

An efficient algorithm for BRB with long inputs of $b$ bits using lower costs than $b$ single-bit instances is presented in~@NRSVX20.
This algorithm, which assumes $t < n/3$, achieves the best possible communication complexity of $Theta(n b)$ input sizes.
This article also presents an authenticated extension of this solution.

Scalable BRB is addressed in @GKMPS19.
This work aims to avoid paying the $O(n^2)$ message complexity price by using a non-trivial message-gossiping approach.
This strategy makes it possible to design a sophisticated BRB algorithm satisfying probability-dependent properties.

To minimize the dissemination costs associated with message transmission across the network, some solutions rely on digital signatures and coding techniques~@ADDRVXZ22 @CP02 @CT05 @DRZ18 @MXCSS16 @YPAKT22.
Instead of communicating a value~$v$ of $|v|$ bits directly, the sender first encodes the value using an error-correction code and "splits" the resulting codeword between the processes, so that each process receives one fragment of size $O(|v|\/n)$ bits.
Any process that has received a _sufficient_ number of fragments can reconstruct the entire value, thus ensuring the ability to reconstruct data in the event of process failures or adversarial compromises.
Using this technique, each process needs to broadcast only its fragment of the value rather than the entire value.
This reduced per-process communication effectively reduces the overall communication for disseminating the value itself to $n|v|$ bits.

#ta[
Another problem close to BRB is _Verifiable Information Dispersal_ (or _VID_)~@CT05.
VID implementations aim to ensure the consistency of the received information across the network, while reducing the required bandwidth usage, typically by using error-correcting codes.
]
In this setting, significant contributions have been made by Cachin and Tessaro~@CT05 as well as Cachin and Poritz in SINTRA~@CP02, followed by its successors such as Honey Badger~@MXCSS16, BEAT~@DRZ18, or DispersedLedger~@YPAKT22.
// #FT[Can you say in one or two sentences what connects these works together? I'm not sure Cachin and Tessaro explicitly mention blockchains for instance.]

From a theoretical perspective, a lower bound on the overall communication complexity of BRB is $Omega(n|v|+n^2)$ bits, because every correct process must receive the entire value $v$, and because the reliable broadcast of a single bit necessitates at least $Omega(n^2)$ messages, as implied by the Dolev-Reischuk lower bound @DR85.
In this context, Alhaddad #etal~@ADDRVXZ22 proposed several _balanced_ BRB algorithms relying on erasure coding (_balanced_ means that the communication cost is the same for the sender and the rest of the processes).
//  without signatures and $O(n|v|+n^2 secp)$ with signatures (informally, each process can only broadcast a constant amount of value fragments and signatures to everyone)
Notably, Alhaddad #etal proposed two _near-optimal_ balanced BRB algorithms: one signature-free in $O(n|v|+n^2 log n)$ bits overall and one signature-based in $O(n|v|+n secp+n^2 log n)$ bits overall, where $secp$ denotes the security parameter (see @sec:model-crypto-schemes).

=== Synchronous BRB <sec:sota-sync-brb>

The Synchronous Byzantine Reliable Broadcast problem was first introduced in~@PSL80 by Lamport, Shostak, and Pease, who proposed in~@LSP82 a deterministic solution based on signature chains, which tolerates any arbitrary number $t<n$ of Byzantine processes present in the system.
This solution requires $t+1$ rounds both in good cases (where the sender is correct) and bad cases (where the sender is Byzantine).
Dolev and Strong showed this worst-case round complexity of $t+1$ rounds to be optimal for deterministic algorithms~@DS83.

In recent years, substantial progress has been made in circumventing the bound of $t+1$ rounds for deterministic BRB algorithms, by exploiting _randomization_ or only considering the good case where the BRB sender is correct @ANRX21 @FN09 @WXSD20.
In the deterministic case, it has also been recently shown that a good-case latency (#ie latency when the sender is correct) for synchronous BRB lower than $t+1$ rounds can be achieved using a deterministic algorithm subject to an arbitrary number of Byzantine faults @AFRT24 (in particular, this algorithm has a good-case latency of $max(2,t+3-c)$ synchronous rounds).
// #FT[explain to the reader what good-case latency means. A quick fix would be to do so in brackets "(where 'good case' refers to the situation in which ...)"]

// === Other recent works related to asynchronous BRB
    
// BRB in dynamic systems is addressed in @GKKPST20 (_dynamic_ means that a process can enter and leave the system at any time).
// In their article, the authors present an efficient BRB algorithm for such a context.
// This algorithm assumes that the system has at least two times more correct processes than Byzantine ones at any time.

// @ANRX21

=== Summary

In this section, we have explored the state-of-the-art in Byzantine reliable broadcast, from foundational algorithms like Bracha's to recent advancements in communication efficiency and synchronous implementations.
These algorithms provide the basis for reliable communication in Byzantine-prone systems, but they are limited to static failure models where Byzantine behavior is confined to a fixed set of processes.
As we will see in the next section and throughout this thesis, extending these concepts to more dynamic failure scenarios is crucial for addressing the challenges of modern distributed systems.
// #FT[The lead into the next section works very well here I think :-)]

== Hybrid fault models <sec:sota-hybrid>

While Byzantine reliable broadcast provides robust communication in the presence of Byzantine process failures, real-world distributed systems often face more complex failure scenarios.
This brings us to our next topic: _hybrid fault models_.
These models extend our understanding of system failures beyond just Byzantine processes, incorporating dynamic link failures to more accurately represent the challenges faced in real-world distributed systems.

Byzantine process failures cover many adversarial behaviors but remain bound to a specific set of processes.
Santoro and Widmayer proposed an alternative fault model for synchronous networks @SW89 @SW07, which considers _mobile_ (or dynamic) _link failures_ between correct processes.
In this model, failures are no longer bound to particular processes.
Instead, a _message adversary_ (MA) may corrupt or delete some of the $n(n-1)$ possible transmissions during one synchronous round, where $n$ is the number of processes in the system.
This notion of MA was implicitly introduced in @SW89 (under the name _transient faults_ and _ubiquitous faults_) and then used (sometimes implicitly) in many works (#eg @AG13 @CS09 @RS13 @SW07 @TZKZ20). 
A short tutorial on message adversaries is presented in @R16-2.
The works of~@BDP97 @D98 @SW07 focus on the case of reliable broadcast in the presence of such link failures.
#ta[Another remarkable work @AG15 utilizes an MA to arrive at a very elementary proof of the Herlihy-Shavit characterization of wait-free solvability.]

Generalizing further, mobile link failures and Byzantine processes may be combined to produce a _hybrid fault model_, in which some failures are pinned to specific processes while others affect links dynamically @BSW11 @GLR98 @PT86 @SCY98.
Biely, Schmid, and Weiss @BSW11 have, in particular, proposed an extensive hybrid fault model for synchronous systems that includes both a range of process failures (including Byzantine behaviors) along with mobile link failures between correct processes.
As in Santoro and Widmayer's model, link failures are mobile in that they might impact different processes in different (synchronous) rounds.
The model is constrained by limiting the number of link failures a process might experience during a synchronous round both as a sender (_send_ link failures) and as a recipient (_receive_ link failures).

This model was extended by Schmid and Fetzer @SF03
#footnote[
  Although Schmid and Fetzer's work @SF03 predates the publication of Biely, Schmid, and Weiss @BSW11, it cites an earlier version of @BSW11 available as a technical report.
]
to _asynchronous round-based algorithms_.
Schmid and Fetzer present, in particular, a Simulated Authenticated Broadcast algorithm (a weak form of Byzantine broadcast allowing duplicity by Byzantine senders) and a Randomized Consensus algorithm that work provided both send and receive link failures remain limited to specific patterns, ensuring in particular that no correct
#footnote[
  The model uses a finer notion of _obedient_ process, which is ignored here for simplicity.
]
process ever gets entirely disconnected from other correct processes.

Another approach to address Byzantine processes coupled with faulty links is to consider the edge connectivity of incomplete communication networks.
In this setting, Pelc proved that robust communication is feasible over graphs whose edge-connectivity is more than~$2f$, assuming the number of Byzantine _links_ is bounded by~$f$ @P92, which is also implied by the work of Dolev~@D82.
Intuitively, if at least half of the communication channels of each process can be severed, then an adversary can partition the network.
Censor-Hillel, Cohen, Gelles, and Sela~@CCGS23 showed that any computation can be performed when all links suffer arbitrary substitution faults (but no crashes), provided the network is $2$-edge connected.
// #FT[the referent of 'their' is ambiguous: "but the overall amount of corruption is restricted"]
When all links suffer corruption, but the overall amount if corruption restricted, any computation can be reliably performed using the solution by Hoza and Schulman~@HS16, for synchronous networks where the topology is known, or the solution by Censor-Hillel, Gelles, and Haeupler~@CGH19, for asynchronous networks with unknown topology.
// #FT[the formulation suggests the authors can do the computation. Rephrase? E.g. "using the solution proposed by ..."]
Bonomi, Decouchant, Farina, Rahli, and Tixeuil also considered the case of BRB in a synchronous multi-hop (#ie partially connected) communication network @BDFRT21.
However, as it is classically assumed in distributed graph algorithms, the previous works either assume synchronous communication or static network topology, thus precluding the study of dynamic and mobile link faults under asynchrony.

=== Summary

This section provided an overview the evolution of fault models in distributed systems, from traditional Byzantine faults to more complex hybrid models that incorporate dynamic link failures.
These hybrid fault models represent a significant advancement in our ability to design and analyze robust distributed systems.
By accounting for both process and link failures, they enable the development of algorithms and protocols that can maintain reliability and consistency in more diverse and challenging environments.

== Conclusion

This chapter has provided an overview of the foundational concepts and state-of-the-art research underpinning this thesis.
We introduced the standard system model for distributed computing and explored Byzantine Reliable Broadcast (BRB), a crucial primitive for ensuring reliable cooperation in Byzantine-prone systems.
Our examination of both asynchronous and synchronous BRB implementations highlighted the ongoing challenges in balancing fault tolerance, efficiency, and scalability.
We also discussed the evolution of fault models, from traditional Byzantine faults to hybrid models that incorporate dynamic link failures.
These hybrid models represent a significant step towards more realistic representations of failure scenarios in distributed systems.
However, throughout this exploration, several key challenges emerged:
// - The need for BRB algorithms that can operate in more dynamic network conditions; #TA[This seems very close to the second item]
#FT[Since what follows announces the rest of your thesis, I'll redact each point using one or more sentences, and explicitly explain why the sota is not satisfying. E.g., "Although existing hybrid models cover many behaviors, they are often limited to synchronous systems or to algorithms that explicitly follow a round-based structure. There is therefore a need for ... that can be applied generally to any distributed message-pasisng algorithm in asynchronous systems."]
- The need for simple hybrid fault models accounting for both Byzantine processes and unreliable network links, that can apply to any asynchronous message-passing algorithm (independently of its use of rounds or not);
// - Extending BRB to hybrid fault models accounting for both Byzantine processes and unreliable network links;
- Designing BRB algorithms that can operate in more dynamic network conditions;
- Balancing resilience, communication efficiency, and latency in BRB implementations.

These challenges set the stage for the novel contributions presented in this thesis.
In the following chapters, we will introduce our new hybrid fault model and the Message-Adversary-tolerant Byzantine Reliable Broadcast (MBRB) abstraction, addressing many of the identified challenges and advancing our understanding of fault-tolerant distributed systems.
