#import "../setup.typ": *

= A MBRB Implementation with \ Near-Optimal Communication <sec:coded-mbrb>

#v(2em)

// #epigraph(
//   [He who can properly define and divide is to be considered a god.],
//   [Plato]
// )

#epigraph(
  [Information is the resolution of uncertainty.],
  [Claude Shannon]
)

#v(2em)

As discussed in detail in @sec:reliable-bcast, reliable broadcast plays a crucial role in key applications, including consensus algorithms, replication, event notification, and distributed file systems.
These systems sometimes require broadcasting large messages or files (#eg permissioned blockchains), and thus, reducing the communication overhead to a minimum is an important aspect of achieving scalability.
In that vein, this chapter aims at providing a _communication efficient_ solution for the task of reliable broadcast in the presence of process and link faults (#ie MBRB, see @sec:model-and-mbrb).

In particular, the MBRB algorithm presented in this chapter communicates $O(|v|+n secp)$ bits per process (or $O(n|v| + n^2 secp)$ bits overall), where $|v|$ represents the length of the disseminated value and $secp = Omega(log n)$ is a security parameter.
This communication complexity is optimal up to the parameter $secp$.
#footnote[
  As stated in @sec:sota-comm-efficien-brb, for deterministic algorithms~@DXR21 @NRSVX20, the lower bound for the communication cost of BRB is of $Omega(|v|+n)$ bits sent per correct process, as every correct process must receive the entire value~$v$, and as the reliable broadcast of a single bit necessitates at least $Omega(n^2)$ messages~@DR85.
]
This significantly improves upon the original MBRB solution (see @sec:sig-mbrb), which incurs communication of $O(n|v|+n^2 secp)$ bits per process.
The MBRB solution of this chapter sends at most $4n^2$ messages overall, which is also asymptotically optimal.
Reduced communication is achieved by employing coding techniques that replace the need for all processes to (re-)broadcast the entire value~$v$.
Instead, processes forward authenticated fragments of the encoding of $v$ using an erasure-correcting code.
Under the cryptographic assumptions of threshold signatures and vector commitments, and assuming $n > 3t+2d$, this algorithm allows at least $lmbrb = n - t - (1 + epsilon)d$ (for any arbitrarily small $epsilon> 0$) correct processes to reconstruct $v$, despite missing fragments caused by the malicious processes and the message adversary.
// Hence, we rely on the same assumption as in @sec:sig-mbrb.

// #let mbrbassum = link(<assum:c-mbrb>)[MBRB-Assumption]
// #mbrb-assumption(numbering: none)[$n > 3t+2d$.] <assum:c-mbrb>

// Overall, $O(n|v| + n^2 secp)$ bits are communicated by correct processes.
// As previously stated, this bound is tight (up to the size~$secp$ of the cryptographic structures used) for deterministic algorithms~@DXR21 @NRSVX20, as every correct process must receive the entire value~$v$, and as the reliable broadcast of a single bit necessitates at least $Omega(n^2)$ messages~@DR85.
// #FT[The header of this chapter works very well I think. Just this last paragraph feels a bit redundant: do you need it? You could drop it and reinject the references in the remaining text.]

@tab:chap6-notations summarizes the acronyms and notations of this chapter.

#figure(placement: auto,
  table(
    columns: 2, row-gutter: (0pt, 0pt, 3pt, 0pt), align: horizon,
    [*Acronyms*], [*Meanings*],
    [MA], [Message adversary],
    [MBRB], [MA-tolerant Byzantine reliable broadcast],
    [*Notations*], [*Meanings*],
    $n$, [number of processes in the system],
    $t$, [upper bound on the number of Byzantine processes],
    $d$, [power of the message adversary],
    $c$, [effective number of correct processes in a run ($n-t <= c <= n$)],
    $secp$, [security parameter of the cryptographic primitives],
    $p_i$, [process of the system with identity $i$],
    // [$v$, $|v|$], [applicative value, size of the applicative value (in bits)],
    $star$, [unspecified value],
    $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
    // $rtc$, [time complexity of MBRB],
    $omc$, [message complexity of MBRB],
    $bcc$, [communication complexity of MBRB \ (number of bits sent during the execution overall)],
    $p_s$, [the designated sending process (with identity $s$)],
    $k$, [reconstruction threshold of the erasure code ($k$ out of $n$)],
    $tilde(v)_i$, [$i$#super[th] fragment of value $v$],
    $Sigma$, [threshold signature (TS)],
    $tau$, [threshold of the TS scheme (set to $tau = floor((n+t)/2)+1$ in our algorithm)],
    $sigma_i$, [signature share of the TS scheme by process $p_i$],
    [$sig_i$, $sigs$], [the pair $(sigma_i, i)$, set of $(sigma_i, i)$ pairs],
		$C$, [vector commitment (VC)],
		$pi_i$, [proof of inclusion of fragment $tilde(v)_i$ in a VC]
  ),
  caption: [Acronyms and notations used in @sec:coded-mbrb]
) <tab:chap6-notations>

#paragraph[Roadmap]
@sec:c-mbrb-intuition presents an initial overview of the MBRB solution of this chapter, and @sec:c-mbrb-prelim introduces preliminary notions useful for understanding the algorithm.
@sec:c-mbrb-impl showcases @alg:coded-mbrb-helpers[Algorithms] @alg:coded-mbrb[and], a coding-based MBRB implementation.
For concision, the proof of the Global-delivery property of Coded-MBRB is only sketched in @sec:c-mbrb-correct-intuition, while the full correctness proof of the algorithm can be found in @sec:coded-mbrb-correctness-proof.
The communication analysis of Coded-MBRB is then given in @sec:c-mbrb-comm.
@sec:c-mbrb-discussion discusses supplementary aspects of Coded-MBRB.
Namely, @sec:select-k explains how the reconstruction threshold of the erasure coding scheme can be instantiated, @sec:c-mbrb-multi addresses the problem of upgrading the algorithm for it to become multi-sender and multi-shot, and @sec:bracha-with-MA explains why alternative approaches for achieving near-optimal communication MBRB based on classic error-free BRB (such as Bracha's @B87) would likely not sit well with a message-adversary-prone setting.
Finally, @sec:c-mbrb-conclu concludes the chapter.

// #FT[What follows feels quite detailed for a chapter's header (and certainly longer than in other chapters). Can you make it a first section of the chapter ("Problem analysis and statement" or "Overview and intuition?")? Or merge it with what follows?]

// #paragraph[Contributions and techniques]

== Overview and intuition <sec:c-mbrb-intuition>

This chapter presents an MBRB algorithm able to tolerate a hybrid adversary combining $t$ Byzantine processes and a Message Adversary of power $d$, while providing optimal Byzantine resilience and near-optimal communication and power~$lmbrb$.

Its communication complexity ($O(|v|+n^2 secp)$ bits sent per correct process) holds assuming a sufficiently long value~$v$. 
Further, $n-t-d$ is a natural upper bound on the delivery power~$lmbrb$ of any MBRB algorithm.
This bound arises from the power of the message adversary to isolate a subset of correct processes of size~$d$, and omit all messages sent to this subset. 
Our solution obtains a delivery power~$lmbrb$ that is as close to the limit as desired, at the cost of increasing communication (through the hidden constants in the asymptotic $O(dot)$ term, which depends on~$epsilon$).
Finally, $n>3t+2d$ is a necessary condition to implement MBRB under asynchrony~(see @sec:nec-cond-mbrb), thus making the solution of this chapter optimal in terms of Byzantine resilience.

The starting point of this chapter's MBRB algorithm is the original MBRB algorithm~(@sec:sig-mbrb), that we call Original MBRB in the following for convenience.
This algorithm achieves all the desired MBRB properties (@sec:mbrb), albeit with a large communication cost of at least $n^2|v|$ bits overall.
This communication cost stems from the re-emission strategy used by Original MBRB.
In Original MBRB, the sender first disseminates the value $v$ to all processes.
To counter a possibly faulty sender, each process that receives $v$ signs it and forwards it to the entire network, along with its own signature and any other signature observed so far for that value.
This re-broadcasting step leads to $n^2|v|$ bits of communication.
In total, correct processes communicate $O(n^2|v|+n^3 secp)$ bits in Original MBRB (see @lem:sb-mbrb-comm-cost, #pageref(<lem:sb-mbrb-comm-cost>)).

In order to reduce the communication costs, we apply a coding technique inspired by an approach by Cachin and Tessaro~@CT05, later applied more specifically to the BRB problem by Alhaddad #etal~@ADDRVXZ22.
Instead of communicating the value~$v$ directly, the sender first encodes the value using an error-correction code and "splits" the resulting codeword between the processes, so that each process receives one fragment of size $O(|v|\/n)$ bits.
Now, each process needs to broadcast only its fragment of the value rather than the entire value.
This reduced per-process communication effectively reduces the overall communication for disseminating the value itself to $n|v|$ bits.

Some of the fragments might not arrive at their destination due to the action of the message adversary and the Byzantine processes.
Error-correction codes have the property that the value $v$ can be reconstructed from any sufficiently large subset of the fragments.
But Byzantine processes can do even worse, namely, they can propagate an incorrect fragment.
Correct processes cannot distinguish correct fragments from incorrect ones (at least, not until enough fragments are collected, and the value is reconstructed).
Without this knowledge, correct processes might assist the Byzantine processes in propagating incorrect fragments, possibly harming the correctness and/or performance of the algorithm.
To prevent this, the sender could sign each fragment that it sends.
A process that receives a fragment could then verify that the fragment is correctly signed by the sender, and could ignore it otherwise.
The drawback of this solution is that only the sender can generate signatures for fragments.

In the MBRB algorithm of this chapter, which we call Coded MBRB in the sequel for simplicity, we rely on correct processes that have already reconstructed the correct value to disseminate its fragments to the processes that have not received any (say, due to the message adversary).
In principle, when a process reconstructs the correct
value, it can generate the codeword and obtain all the fragments, even if it did not receive some of them beforehand.
However, the process cannot generate the sender's signature for the fragments it generated by itself.
Because of this, the process cannot relay these fragments to the other processes, potentially leading to a reduced delivery power~$lmbrb$.

We avert this issue by exploiting vector commitments~@CF13.
This cryptographic primitive generates a unique short digest~$C$ for any input vector of elements~$V$.
Additionally, it generates succinct proofs of inclusion for each element in~$V$.
In our system, the fragments of the (coded) value~$v$ form the vector~$V$, and the inclusion proofs replace the need to sign each fragment separately.
In more detail, every fragment of the codeword communicated by some process is accompanied by two pieces of information: the commitment $C$ for the vector $V$ containing all fragments of~$v$, and a proof of inclusion showing that the specific fragment indeed belongs to~$V$ (see @sec:crypto-prim for a formal definition of these properties).
The sender signs only the commitment~$C$. 
This means that Byzantine processes cannot generate an incorrect fragment and a proof that will pass the verification, since they cannot forge the sender's signature on~$C$.
Yet, given value~$v$, generating a proof of inclusion for any specific fragment can be done by any process.
The vector commitment on value $v$ creates the same commitment~$C$ and the same proofs of inclusion generated by the sender.
These could then be propagated to any other process along with the sender's signature on~$C$.

To complete the description of the Coded MBRB algorithm, we mention that, similar to Original MBRB, the algorithm tries to form a quorum of signatures on some specific vector commitment~$C$.
In parallel, processes collect fragments they verify as part of the value whose vector commitment is~$C$. 
Once a process collects enough signatures (for some~$C$) and at the same time obtains enough value fragments that are proven to belong to the same~$C$, the process can reconstruct~$v$ and deliver (accept) it.
At this point, the process also disseminates the quorum of signatures (compacted into a threshold signature, see @sec:crypto-prim) along with (some of) the fragments. 
This allows other correct processes to reconstruct the value and verify that a quorum has been reached.
In fact, the dissemination of fragments, including fragments that this process did not have before reconstructing the value, is a crucial step in amplifying the number of processes that  deliver~$v$ to our stated level of $lmbrb = n-t-(1+epsilon)d$.
See the full description of Coded MBRB in @sec:coded-mbrb-desc.

Although the Coded MBRB algorithm builds quorums on commitments, it departs substantially from the BRB algorithm proposed by Das, Xiang, and Ren~@DXR21, which avoids signatures and relies on hashes only.
Their solution provides an overall communication complexity in $O(n|v|+n^2 secp)$ that is optimal up to the $secp$ parameter.
Following the sender's initial dissemination of value $v$, their proposal runs Bracha's algorithm on the hash of the broadcast value to ensure agreement.
Unfortunately, when used with a message adversary, Bracha's algorithm loses the optimal Byzantine resilience $n>3t+2d$ that the Original MBRB and Coded MBRB algorithms provide, which is why the solution presented in this chapter avoids it.
(See @sec:bracha-with-MA for a more detailed discussion of why this is so.)

// Our work contributes to the advancement of the state of the art in the field of coded reliable broadcast by offering improved fault-tolerance guarantees that are stronger than the aforementioned solutions.
// Other solutions rely on error-correcting codes or erasure codes.

== Preliminaries <sec:c-mbrb-prelim>

As the other algorithms presented in @sec:sig-mbrb[Chapters] and @sec:k2l-cast[], the MBRB algorithm described in this chapter builds upon the underlying system model defined in @sec:model.
In contrast to the previously presented algorithms, the MBRB algorithm of this chapter heavily relies on the $comm(m_1,...,m_n)$ operation, which sends (potentially different) messages $m_j$ to every process $p_j$ ($j in [1..n]$).
Like for the $broadcast$ operation, the message adversary can suppress up to $d$ messages sent by the $comm$ operation.
The rest of this section describes additional features of the model that are specific to this chapter.

#paragraph[General notations and conventions]
For a positive integer~$n$, let $[n]$ denote the set ${1,2,dots,n}$.
A sequence of elements $(x_1,dots,x_n)$ is shorthanded as $(x_i)_(i in [n])$.
All logarithms are base 2.

// #paragraph[The $comm(dot)$ operation and the Message Adversary] 
// Any ordered pair of processes $p_i,p_j$ has access to a communication channel $italic("channel")_(i,j)$.
// Each process can send messages to all processes (possibly by sending a different message to each process).
// Instead of always communicating by broadcasting the same message to the network, a process $p_i$ may sometimes want to send different messages to different processes.
// To do that, $p_i$ can invoke the transmission macro $comm(m_1,dots,m_n)$, that sends message $m_j$ to~$p_j$ for every $j in [n]$.
// The message~$m_j$ can also be empty, in which case nothing will be sent to~$p_j$.
// However, in our algorithms, all messages sent in a single $comm$ call will have the same length.
// As we can see, the $broadcast$ operation (described in @sec:model) is a special case of $comm$, where the process sends the same message $m$ to all processes: $broadcast(m)=comm(m,m,dots,m)$.

// Faulty processes may deviate arbitrarily from the correct implementation of $comm(dot)$.
// For instance, they may unicast messages to only a subset of processes.
// While communication channels are not prone to message corruption, duplication, or creation of fake messages that were never sent by processes; the _message adversary_~@SW89 @SW07 @R16-2 has a limited ability to remove messages communicated through loss.

// This entity can remove implementation messages from the communication channels used by correct processes when they invoke~$comm$. 
// More precisely, during each call of $comm(m_1,dots,m_n)$, the adversary has the discretion to choose up to $d$ messages from the set~${m_i}$ 
// and eliminate them from the corresponding communication channels where they were queued.
// We assume that the adversary has full knowledge of the contents of all messages~${m_i}$, and thus it makes a worst-case decision as to which messages to eliminate.

=== Error correction codes (ECC) <sec:ecc>
A central tool used in our algorithm is an error-correction code (ECC)~@R06.
Intuitively speaking, an ECC takes a message as input and adds redundancy to create a codeword from which the original message can be recovered even when parts of the codeword are corrupted. 
In this work, we focus on _erasures_, a corruption that replaces a symbol of the codeword with a special erasure mark~$bot$.
#ta[
We further denote by $k$ the reconstruction threshold of the ECC scheme we use: at least $k$ out of the $n$ fragments are sufficient to reconstruct the initial value (where $n$ is the total number of fragments).
#footnote[
  Following the dedicated literature, we use the letter $k$ to denote the ECC reconstruction threshold, however it should not be confused with the parameter $k$ of the $k2l$-cast abstraction presented in @sec:k2l-cast.
]
]

Let $FF$ denote a finite field whose size we set later, and let $bot$ be a special symbol ($bot in.not FF$). 
Given two strings of the same length, $x,y in FF^n$, their _Hamming distance_ is the number of indices where they differ, $Delta(x,y) = |{i in [n] | x_i != y_i}|$.
Given a subset $I subset.eq [n]$, we denote by $x_I in FF^(|I|)$ the string $x$ restricted to the indices in~$I$.

To avoid confusion with global parameters, we denote the ECC-specific parameters by using a bar (#eg $macron(x)$).
An _error-correction code_ is a function $ECC: FF^macron(k) -> FF^macron(n)$, with _rate_ $macron(r)=macron(k)/macron(n)$, and _distance_ $macron(d) = min_(x,y in FF^macron(k), x!=y) Delta( ECC(x), ECC(y))$.
// _Linear_ codes are such that their image is a linear subspace of~$FF^n$ of dimension~$k$.
The Singleton bound determines that $macron(d) <= macron(n)-macron(k)+1$, and when the equality holds, the code is said to be maximum distance separable (MDS).
A prominent example of MDS codes is Reed-Solomon (RS) codes~@RS60, which exist for any $macron(k),macron(n)$, and $|FF| >= macron(n)$.
Such codes can be efficiently encoded and decoded~@R06.

#fact("Erasure Correction Capability")[
  Any error-correction code of distance $macron(d)$ can recover up to $macron(d)-1$ erasures.
  That is, for any $y in (FF union {bot})^macron(n)$, let $E = { i | y_i = bot}$ the set of erased indices.
  Then, if $|E| < macron(d)$, there is at most a single $x in FF^macron(k)$ such that $y_([macron(n)] \\ E) = ECC(x)_([macron(n)] \\ E)$.  
] <fct:ecc-capability>

For convenience, we introduce the additional functions $eccsplit(v) -> (tilde(v)_1,...,tilde(v)_n)$ and $eccreconstruct(tilde(v)_1,...,tilde(v)_n) -> v$.
The $eccsplit$ function takes a value $v$, obtains its codeword using the $ECC(v)$ function, and splits it into $n$ fragments $(tilde(v)_1,...,tilde(v)_n)$ of the same size.
Conversely, the $eccreconstruct$ function takes $n$ value fragments $(tilde(v)_1,...,tilde(v)_n)$ (where at most $n-k$ may be equal to the $bot$ sentinel value), and applies the inverse function of $ECC(dot)$ to obtain the original value $v$, even in spite of the presence of at most $n-k$ erasures.

=== Cryptographic primitives <sec:crypto-prim>

Our algorithm relies on cryptographic assumptions.
We assume that the Byzantine processes are computationally bounded with respect to the security parameter, denoted by~$secp$.
That is, all cryptographic algorithms are polynomially bounded in the input~$1^secp$.
Recall from @sec:model-crypto-schemes (#pageref(<sec:model-crypto-schemes>)) that we assume $secp = Omega(log n)$.
We further assume the availability of Public Key Infrastructure (PKI), which is the setting that assumes each process is assigned a pair of public/private keys, generated according to some common key-generation algorithm.
Further, at the start of the computation, each process holds its own private key and the public key of all other parties.
This setting implies private and authenticated channels.
In particular, each process has public and private keys to support the following cryptographic primitives.

#paragraph[Threshold signatures] <sec:ts>
In a _$(tau,n)$ threshold signature_ scheme~@S00, at least $tau$ out of all $n$ processes (the threshold) produce individual _signatures shares_ $sigma$ for the same value $v$, which are then aggregated into a fixed-size _threshold signature_ $Sigma$.
Verifying $Sigma$ does not require the public keys of the signers; one just needs to use a single system-wide public key, the same for all threshold signatures produced by the scheme.
This system public key, known to everyone, is generated during the setup phase of the system, and is also distributed through the PKI.

Formally, we define a $(tau,n)$ threshold signature scheme as a tuple of (possibly randomized) algorithms $(tssignshare,tsverifyshare,tscombine,tsverify)$.
The signing algorithm executed by process~$p_i$ (denoted, $tssignshare_i$) takes a value~$v$ (and implicitly a private key) and produces a signature $sigma = tssignshare_i (v)$.
The share verification algorithm takes a value $v$, a signature share $sigma_i$, and the identity $i$ of its signer $p_i$ (and implicitly $p_i$'s public key), and outputs a single bit, $b=tsverifyshare(v,sigma_i,i) in {ttrue,ffalse}$, which indicates whether the signature share is valid or not.
The combination algorithm takes a set $sigs$ of $tau$ valid signature shares produced by $tau$ out of $n$ processes and the associated value $v$ (and implicitly the system public key) and outputs a threshold signature $Sigma = tscombine(sigs)$.
The threshold signature verification algorithm takes a value $v$ and a threshold signature $Sigma$ (and implicitly the system public key) and outputs a single bit $b=tsverify(v,Sigma) in {ttrue,ffalse}$, indicating if the threshold signature is valid or not.

We require the conventional robustness and unforgeability properties for threshold signatures. 
// Naturally, a $(tau,n)$ threshold signature for a value $v$ is valid if and only if it aggregates $tau$ valid distinct signature shares for $v$.
This scheme is parameterized by the security parameter~$secp$, and the size of signature shares and threshold signatures, $|sigma|=|Sigma|=O(secp)$ bits, is independent of the size of the signed value, $v$.
In our algorithm, we take $tau=floor((n+t)/2)+1$ (#ie the integer right above $(n+t)/2$).

#paragraph[Vector commitments (VC)] <sec:vc>
A _vector commitment_ (VC) is a short digest $C$ for a vector of elements $V$, upon which a user can then generate a _proof of inclusion_ $pi$ (sometimes called _partial opening_) of some element in $V$ without disclosing the other elements of $V$ to the verifier: the verifier only needs $C$, $pi$, the element, and its index in the vector to verify its inclusion in $V$.
A Merkle tree~@M89 is a notable example of vector commitment, although with several sub-optimal properties.
For example, for a hash size of $secp$, a Merkle proof of inclusion is of $O(secp log |V|)$ bits, which is significantly larger than modern schemes such as Catalano-Fiore vector commitments~@CF13, which produce proofs of inclusion with an optimal size of $O(secp)$ bits.
In our construction, we use these optimal VC schemes (such as Catalano-Fiore's), which provide commitments and proofs in $O(secp)$ bits.
The VC scheme provides two operations, parameterized by the security parameter~$secp$: $vccommit(dot)$ and $vcverify(dot)$, that work as follows.
For any vector of strings $V=(x_1,dots,x_n) = (x_i)_(i in [n])$, the function $vccommit(V) -> (C,pi_1,dots,pi_n)$ returns $C$, the commitment, and every $pi_i$, the proof of inclusion for $x_i$.
The following hold.

- *Proof of inclusion (Correctness).*
  Let $(C,(pi_i)_(i in [n])) = vccommit((x_1,dots,x_n))$.
  Then for any $i in [n]$, it holds that $vcverify(C,pi_i,x_i,i)=ttrue$.

- *Collision-resistance (Binding).*
  For any $j in [n]$ and any randomized algorithm $A$ taking $(x_i)_(i in [n])$ and $(C, (pi_i)_(i in [n])) = vccommit(x_1,dots,x_n)$ as input, $Pr(A "outputs" (x_j',pi'_j,j) and vcverify(C,pi'_j,x'_j,j)=ttrue) < 2^(-Omega(secp))$.
  Namely, it is difficult to generate $x'_j != x_j$ and a valid proof~$pi'_j$ for the same commitment~$C$.

We omit the traditional Hiding property of VC schemes (a commitment does not leak information on the vector~@AAFGRRT24) as it is unneeded in our algorithm.
We also implicitly assume that the $vccommit$ operation is deterministic: it always returns the same commitment $C$ given the same input vector $V$, no matter the calling process $p_i$.
This is the case for Catalano-Fiore's scheme~@CF13, which does not use random salt (a.k.a _blinding factor_).

== The Coded MBRB algorithm <sec:c-mbrb-impl>

The proposed solution, named Coded MBRB (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]), allows a distinguished sender~$p_s$ (known to everyone) to disseminate one specific value~$v$.
In @sec:c-mbrb-multi, we discuss how to extend this algorithm so that it implements a general MBRB algorithm, allowing any process to be the sender, as well as allowing multiple instances of the MBRB, either with the same or different senders, to run concurrently.
In the algorithm, we instantiate the threshold signature scheme with the threshold value set to $tau=floor((n+t)/2)+1$ (see @sec:crypto-prim).

@alg:coded-mbrb-helpers describes the $mbrbbroadcast(v)$ operation as well as helper functions used in Coded MBRB, and @alg:coded-mbrb describes the phases of Coded MBRB.
The $mbrbbroadcast(v)$ operation takes value~$v$ and disseminates it reliably to a minimum bound of correct processes, denoted $lmbrb$.
That is, after executing @alg:coded-mbrb, and assuming a correct sender, at least $lmbrb$ correct processes will have invoked the $mbrbdeliver(v)$ callback, while no correct process will have invoked $mbrbdeliver(v' != v)$.

The Coded MBRB algorithm (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]) relies on the following assumption (the "c" prefix stands for "coded").

#c-mbrb-assumption(numbering: none)[$n>3t+2d$ and $k<= n-t-2d$.] <assum:c-mbrb>

As in the Original MBRB algorithm (@alg:sb-mbrb, #pageref(<alg:sb-mbrb>)), Coded MBRB assumes the necessary and sufficient condition $n>3t+2d$ for implementing MBRB (@thm:mbrb-opti).
Furthermore, while we have some flexibility in selecting the reconstruction threshold $k$ of the erasure-correcting code (as discussed in @sec:select-k), which affects the parameters of the ECC and thus the communication complexity, Coded MBRB requires that $k$ will not be "too large," #ie $k <= n-t-2d$.

=== Algorithm description <sec:coded-mbrb-desc>

The operation $mbrbbroadcast(v)$ allows the sender $p_s$ to start disseminating value $v$ (@line:c-mbrb:mbrb).
The sender (@line:c-mbrb:snd-compute-frag-vc) starts by invoking $computeFragVC(v)$ (@alg:coded-mbrb-helpers).
This function encodes the value~$v$ using an error-correction code, divides it into $n$ fragments and constructs a vector commitment with an inclusion proof for each fragment.
The function returns several essential values: the commitment $C$, and the fragment details~$(tilde(v)_j, pi_j, j)$, which contain the fragment data itself~$tilde(v)_j$ (the $j$-th part of the $eccsplit(v)$; see below for detail), a proof of inclusion~$pi_j$ for that part, and the respective index $j$ of each fragment.
For ease of reference, let $Commitment(v)$ represent the commitment $C$ obtained from $computeFragVC(v)$.
This commitment serves as a compact representation of the entire value $v$.

The sender process $p_s$ is responsible for signing the computed commitment~$C$ and generating a signature share denoted $sig_s$ (@line:c-mbrb:snd-sign). 
Notably, this signature share includes $p_s$'s identifier.
The sender then initiates $v$'s propagation by employing the $comm$ operation (@line:c-mbrb:snd-comm), which sends to each process $p_j$ an individual message $m_j$. 
The message~$m_j$ is of type $sendm$ and includes several components: the commitment $C$, the $j$-th fragment details $(tilde(v)_j, pi_j, j)$, and the signature share $sig_s$ (@line:c-mbrb:snd-sign) for~$C$.

The rest of the algorithm progresses in two phases, which we describe in turn.
The first phase is responsible for value dissemination, which forwards value fragments received from the sender.
The other role of this phase is reaching a quorum of processes that vouch for the same value.
A process vouches for a single value by signing its commitment.
Processes collect and save signature shares until it is evident that sufficiently many processes agree on the same value.
The subsequent phase focuses on disseminating the quorum of signature shares so that it is observed by at least~$lmbrb$ correct processes, and on successfully terminating while ensuring the delivery of the reconstructed value.

#include "alg/coded-mbrb.typ"

#paragraph[Validating message integrity]
The validity of the signatures and inclusion proofs are checked each time a new message is received (at @line:c-mbrb:rcv-send[lines], @line:c-mbrb:rcv-forward[], @line:c-mbrb:rcv-bundle[or]) using the function $isValid$ (@alg:coded-mbrb-helpers). 
All message types ($sendm$, $forwardm$, and $bundlem$) carry a vector commitment ($C$ or $C'$) and up to two value fragments with their inclusion proofs.
Moreover, the $sendm$ and $forwardm$ types contain up to two signature shares for the provided commitment, and the $bundlem$ type contains a threshold signature for the provided commitment. 
The validation hinges on the following three key criteria.

+ Every enclosed signature share or threshold signature must be valid and correspond to the accompanying commitment.
+ For $sendm$ or $forwardm$ messages, the signature share from the designated sending process $p_s$ must be present.
+ All value fragments must contain valid inclusion proofs for the provided commitment.

Note that $pi_i$, the proof of inclusion of~$tilde(v)_i$, does not need to be signed by $p_s$, as the commitment already is.

#paragraph[Phase I: Message dissemination]
This phase facilitates the widespread distribution of the value fragments $tilde(v)_j$.
Recall that the sender has sent to each process a different (encoded) fragment of the value~$v$, however, no process currently holds enough information to retrieve the value~$v$.
The phase also sets the ground for forming a quorum on the value~$v$.

When a process receives a $sendm$ message from the sender, it begins by validating the fragment's authenticity (@line:c-mbrb:rcv-send-isvalid).
Process $p_i$ then determines whether it had previously broadcast a $forwardm$ message at @line:c-mbrb:rcv-send-bcast or signed a commitment $C''$ from $p_s$ distinct from the currently received $C'$, in which case the incoming message is discarded (@line:c-mbrb:rcv-send-cond-other-vc).
Otherwise, $p_i$ generates its own signature share $sig_i$ for the commitment $C'$ (@line:c-mbrb:rcv-send-sign).
Subsequently, $p_i$ proceeds to save its signature share and the received information (@line:c-mbrb:rcv-send-save), encompassing the fragment $tilde(v)_i$ and the associated signature share $sig_s$, linked to the specific commitment $C'$.
We clarify that $p_i$ never saves multiple copies of the same information, #ie all save operations are to be read as adding an item to a set.
Process $p_i$ then disseminates all the relevant information, by broadcasting the message $forwardm(C', (tilde(v)_i, pi_i, i), {sig_s, sig_i})$ (@line:c-mbrb:rcv-send-bcast).
The broadcast of a $forwardm$ message is instrumental in disseminating information for several reasons.
First, up to $d$ processes might not receive the sender's $sendm$ message.
Second, this is the process's way to disseminate its own fragment and signature share for that specific~$C'$.  

Upon the arrival of a $forwardm(C', fragtuple_j, sigs_j)$ message from $p_j$ (@line:c-mbrb:rcv-forward), the recipient $p_i$ validates the incoming message using the $isValid$ function (@alg:coded-mbrb-helpers), discarding invalid messages (@line:c-mbrb:rcv-forward-isvalid). 
As for $sendm$ messages, $p_i$ checks if it already signed a commitment $C''$ from $p_s$, in which case it discards the message (@line:c-mbrb:rcv-forward-cond-other-vc).
Subsequently, $p_i$ saves the set of signature shares $sigs_j$ linked to the specific commitment $C'$ (@line:c-mbrb:rcv-forward-save-sigs) and fragment contained in this message, if any (@line:c-mbrb:rcv-forward-save-frag).
Also, $p_i$ assesses whether a $forwardm$ message has been previously dispatched (@line:c-mbrb:rcv-forward-cond-no-msg).
If it has already done so, there is no reason to re-send it, and the processing ends here.
Otherwise, similar to above, $p_i$ generates and saves its own signature share $sig_i$ for the commitment $C'$, and broadcasts the message $forwardm(C', bot, {sig_s, sig_i})$ (@line:c-mbrb:rcv-forward-sign[lines]-@line:c-mbrb:rcv-forward-bcast[]).
Note that, in this case, $p_i$ is unaware of his own fragment (#ie it has not received a $sendm$ message, or otherwise it would have already sent a $forwardm$ message at @line:c-mbrb:rcv-send-bcast); therefore it sends the sentinel value~$bot$ instead.

// %Note that a correct process $p_i$ might send up to two $forwardm$ messages for the same hash $h'$, at \cref{line:v3.1:forward:after:send,line:v3.1:forward:after:forward}. 
// %The $forwardm$ message of \cref{line:v3.1:forward:after:send} contains $p_i$'s fragment $\tilde m_i$, whereas the $forwardm$ message of \cref{line:v3.1:forward:after:forward} does not ($\bot$ is included instead). 
// %This approach increases the accumulation of signatures for a specific message hash $h'$, even from correct processes that might not have received (and potentially would not receive) their corresponding fragment. 
// %Furthermore, this design guarantees that the set of correct processes receiving a $forwardm$ message is encompassed by the set of processes sending $forwardm$ messages, enabling reasoning analogous to that employed in the proof of the \AFRT MBRB protocol. \ran{here is too early to discuss this, I'm removing it}

#paragraph[Phase II: Reaching quorum and termination]
This phase relies on the $getThreshSig$ function described in @alg:coded-mbrb-helpers, which, given a commitment $C$, either returns a threshold signature for $C$ (received beforehand or aggregating $tau=floor((n+t)/2)+1$ signature shares saved for $C$) if it exists, or $bot$ otherwise.
This phase focuses on ensuring that, once a Byzantine quorum (represented by the threshold signature returned by $getThreshSig$) and enough value fragments for reconstructing the original value $v$ are gathered, at least~$lmbrb$ correct processes deliver~$v$ and terminate.
Process~$p_i$ enters Phase~II only when there is a commitment $C'$ for which $getThreshSig$ returns a valid threshold signature, and $p_i$ saves at least $k$~value fragments.
As long as no value from~$p_s$ was delivered (@line:c-mbrb:quorum), $p_i$~reconstructs value~$v_i$ (@line:c-mbrb:quorum-reconstruct) using the saved value fragments, and use this value as an input to $computeFragVC$ (@line:c-mbrb:quorum-comp-frag-vc), which outputs its commitment $C=Commitment(m_i)$ along with coded value fragments and proofs of inclusion, $(tilde(v)'_j, pi'_j, j)$.
Process $p_i$ then ensures that the computed commitment $C$ matches the saved commitment $C'$ (@line:c-mbrb:quorum-cond-diff-vc). 
If this condition holds true, then $v_i=v$ is the value sent by the sender, and in particular, $p_i$ now holds _all_ the possible fragments for~$v$ along with their valid proof of inclusion, including fragments it has never received before!
Process~$p_i$ then retrieves the threshold signature $Sigma_C$ of $C$ using the $getThreshSig$ function (@line:c-mbrb:quorum-get-tsig), and disseminates it along with the value fragments to the rest of the network. 
In particular, to each~$p_j$ in the network, $p_i$ sends a $bundlem$ message (@line:c-mbrb:quorum-comm) that includes the commitment $C$, fragment details $(tilde(v)'_i, pi'_i, i)$ and $(tilde(v)'_j, pi'_j, j)$, and the associated threshold signature~$Sigma_C$.
After these transmissions, $p_i$ can mbrb-deliver the reconstructed value $v_i$ (@line:c-mbrb:quorum-dlv).

The parameter $k$ used at @line:c-mbrb:quorum is the number of (valid) fragments sufficient to reconstruct value~$v$ by the error-correction code~$ECC$. 
This parameter should be practically selected by the desired $lmbrb$ given in @thm:coded-mbrb-correctness.
// That is, one needs to set $epsilon > 0$ for $lmbrb = n-t-(1+epsilon)d$ and then choose $k <= 1 + epsilon/(1+epsilon) (n-t-d)$.
#ta[That is, for a given $epsilon > 0$, we can achieve $lmbrb = n-t-(1+epsilon)d$ by picking $k$ such that $k <= 1 + epsilon/(1+epsilon) (n-t-d)$.
The choice of $epsilon$ affects the rate of the code and, thus, the exact communication complexity of
the algorithm: a lower $epsilon$ means worse communication complexity.]
(See details in @sec:select-k.)

Upon the arrival of a $bundlem(C', (tilde(v)'_j, pi'_j, j), fragtuple'_i, Sigma)$ message from $p_j$ (@line:c-mbrb:rcv-bundle), the recipient~$p_i$ validates the received message using the $isValid$ function (with the $isThreshSig$ parameter set to $ttrue$ to indicate that we verify a threshold signature) and discards invalid messages (@line:c-mbrb:rcv-bundle-isvalid).
Process $p_i$ proceeds to save the arriving value fragment $tilde(v)'_j$ and threshold signature $Sigma$ for the specific commitment $C'$ (@line:c-mbrb:rcv-bundle-save-other). 
In the case that no $bundlem$ message was sent by $p_i$ and the received $fragtuple'_i$ is nonempty (so $p_i$ learns its fragment, which it saves at @line:c-mbrb:rcv-bundle-save-own, unless already known), $p_i$ broadcasts a $bundlem(C', (tilde(v)'_i, pi'_i, i), bot, Sigma)$ message (@line:c-mbrb:rcv-bundle-bcast).

The use of the $bot$ sentinel value appears also in $bundlem$ messages (@line:c-mbrb:quorum-comm[lines] @line:c-mbrb:rcv-bundle-bcast[and]). 
A $bundlem$ message might contain up to two fragments: the sender's fragment ($tilde(v)'_i$ in the pseudo-code), which is always included, and the receiver's fragment ($tilde(v)'_j$), which is included only when the sender was able to reconstruct the value $v$ (at @line:c-mbrb:quorum-reconstruct). 
The sender's fragments are collected by the receivers and allow reconstruction of the value once enough $bundlem$ messages are received. 
The receiver's fragment allows the receiver to send $bundlem$ messages (with its fragment), facilitating the dissemination of both threshold signatures and fragments.

=== The error-correction code in use <sec:ecc-instantiation>
The function $computeFragVC$ (@alg:coded-mbrb-helpers) uses an error-correction code at @line:c-mbrb:comp-split to encode value~$v$, before it is split into $n$~fragments that will be disseminated by the processes.
The code uses a fixed parameter $k$, that can be set later.
Our algorithm requires that the ECC will be able to decode value~$v$ from any subset of~$k$ fragments out of the $n$ fragments generated.
That is, we need an ECC that can deal with erasures, where the erased symbols are those contained in the $n-k$ missing fragments.
To that end, we use a Reed-Solomon code $ECC: FF^macron(k) -> FF^macron(n)$ with $macron(k) > |v| \/ log |FF|$.
Each fragment contains $macron(n)/n$ symbols of the codeword, and to be able to recover from $(n-k) times macron(n)/n$ erased symbols by @fct:ecc-capability, we can set the code's distance to be $macron(d) > (n-k) times macron(n)/n$.
Since a Reed-Solomon code is MDS (see @sec:ecc), $macron(d) <= macron(n)-macron(k)+1$, and we can set $macron(n) > n/k(macron(k)-1)$. 
The code will have a constant rate, #ie $|ECC(v)| = O(|v|)$, as long as $v$ is sufficiently long, #ie $|v| = Omega(n log |FF|)$,  which implies that $macron(k) = Omega(n)$, and as long as $k = Omega(n)$.
Recall also that $|FF| >= macron(n)$ is in a Reed-Solomon code.
// From this point on, we assume that the code has a constant rate and that the above constraints hold.

=== Intuition of Coded MBRB's Global-delivery property <sec:c-mbrb-correct-intuition>
The following main theorem states that the Coded MBRB algorithm (composed of @alg:coded-mbrb-helpers and @alg:coded-mbrb) is correct.

#theorem("MBRB-Correctness")[
If #c-mbrb-assum, _@alg:coded-mbrb-helpers[Algorithms]_ _@alg:coded-mbrb[_and_]_ implement MBRB with the guarantee $lmbrb = c-(1+epsilon)d$, where $epsilon > 0$.
] <thm:coded-mbrb-correctness>

Let us remind that Coded-MBRB relies on #c-mbrb-assum, which states that $n>3t+2d$ (necessary and sufficient condition for MBRB, see @thm:mbrb-opti, #pageref(<thm:mbrb-opti>)) and $k <= n-t-2d$ (the ECC reconstruction threshold is not too high).
Let us also recall that @alg:coded-mbrb-helpers[Algorithms] @alg:coded-mbrb[and] describe are _single sender_ and _single shot_ broadcast algorithm, therefore the proof of correctness of Coded MBRB is done on a _single sender_ and _single shot_ version of the MBRB specification given in @sec:mbrb, #pageref(<sec:mbrb>): we only consider a single sender, $p_s$, that mbrb-broadcasts only one value.
As explained in @sec:c-mbrb-multi, the Coded MBRB algorithm (and its proofs) can easily be generalized to the multi-sender/multi-shot case by employing sender identities and sequence numbers.

For concision, the full derivations of the correctness proof of Coded MBRB are given in @sec:coded-mbrb-correctness-proof.
In the following, we sketch the proof of MBRB-Global-delivery property of @thm:coded-mbrb-correctness (assuming the other properties hold).
The detailed proof of this property can be found in #pageref(<lem:c-mbrb-global-delivery>).

#lemma([MBRB-Global-delivery])[
If a correct process $p_i$ mbrb-delivers a value~$v$, then at least $lmbrb = c-d(1/(1-(k-1)/(c-d)))$ correct processes mbrb-deliver~$v$.
]

#proof-sketch[
Let us denote by $C_v$ the vector commitment that $computeFragVC(v)$ returns.
The proof counts the $bundlem$ messages disseminated by correct processes.
If a correct process disseminates a $bundlem$ message both at @line:c-mbrb:quorum-comm[lines] @line:c-mbrb:rcv-bundle-bcast[and], we only consider the one from @line:c-mbrb:quorum-comm.

Let $Bsnd$ be the set of correct processes that disseminate at least one $bundlem$ message during the execution.
Similarly, let $Brcv$ be the set of correct processes that receive at least one valid $bundlem$ message from a correct process during the execution. 
Let $Bkrcv$ be the set of correct processes that receive $bundlem$ messages from at least $k$ distinct correct processes.
The following holds.

#observation[
$c >= |Brcv| >= c-d$ and $c >= |Bsnd| >= c-d$.
] <obs:sketch-Brcv-Bsnd-quorums>

#proof-of(<obs:sketch-Brcv-Bsnd-quorums>)[
Since $Bsnd$ and $Brcv$ contain only correct processes, trivially $c >= |Bsnd|$ and $c >= |Brcv|$.
Since $p_i$ mbrb-delivers $v$ at @line:c-mbrb:quorum-dlv, it disseminated $bundlem$ messages of the form $bundlem(C_v, (tilde(v)'_i, pi'_i, i), (tilde(v)'_j, pi'_j, j), Sigma_v)$ (@line:c-mbrb:quorum-comm).
The $bundlem$ messages sent by~$p_i$ eventually reach at least $c-d$ correct processes.
The detailed proof (in @sec:coded-mbrb-correctness-proof) shows that these $bundlem$ messages are valid. 
Hence, $Brcv >= c-d > 0$ proves the lemma's first part. 

The processes in $Brcv$ execute @line:c-mbrb:rcv-bundle[lines]-@line:c-mbrb:rcv-bundle-isvalid[], and reach @line:c-mbrb:rcv-bundle-cond-no-bundle. 
Because $p_i$ has included a non-$bot$ second fragment in all its $bundlem$ message, any of the $c-d$ processes of $Brcv$ that receive one of $p_i$'s $bundlem$ messages and has not already sent a $bundlem$ message passes the condition at @line:c-mbrb:rcv-bundle-cond-no-bundle.
Each such process then disseminates a (valid) $bundlem$ message at @line:c-mbrb:rcv-bundle-bcast.
This yields $|Bsnd| >= c-d$.
]

#include "fig/c-mbrb-msg-dist.typ"

#observation[
$|Bkrcv| times |Bsnd| + (k-1)(|Brcv|-|Bkrcv|) >= |Bsnd|(c-d)$.
] <obs:sketch-bundle-eq>

#proof-of(<obs:sketch-bundle-eq>)[
Let us denote by $nbundle$ the overall number of valid $bundlem$ messages received by correct processes from distinct correct senders.
More specifically, in the case when a correct process disseminates $bundlem$ messages both at @line:c-mbrb:quorum-comm[lines] @line:c-mbrb:rcv-bundle-bcast[and], we only consider the _last_ $bundlem$ message, #ie the one of @line:c-mbrb:quorum-comm.
We know that each $p in Bsnd$ sends a $bundlem$ message, which by @lem:msgs-sent-valid is valid.
As the message adversary may drop up to~$d$ out of the $n$ messages of this $comm$ instance, we are guaranteed that at least $c-d$ correct processes receive $p$'s $bundlem$ message.
This immediately implies that
$ nbundle >= |Bsnd|(c-d). #<eq:sketch-nbundle-ge> $

The processes in $Bkrcv$ may receive up to $|Bsnd|$ $bundlem$ messages (@fig:c-mbrb-msg-dist) from distinct correct senders (one from each sender in $Bsnd$), for a maximum of $|Bkrcv| times |Bsnd|$ $bundlem$ messages.
The remaining process of $Brcv \\ Bkrcv$ may each receive up to $k-1$ valid $bundlem$ messages from distinct correct senders, by definition of $Bkrcv$.
As $Bkrcv subset.eq Brcv$ by definition, $|Brcv \\ Bkrcv| = |Brcv|-|Bkrcv|$, and the processes of $Brcv \\ Bkrcv$ account for up to $(k-1)(|Brcv|-|Bkrcv|)$ $bundlem$ messages overall.
The $bundlem$ messages counted by $nbundle$ are received either by correct processes in $Bkrcv$ or in $Bkrcv \\ Brcv$.
This implies $|Bkrcv| times |Bsnd| + (k-1)(|Brcv|-|Bkrcv|) >= nbundle$.
Combining the latter and $nbundle >= |Bsnd|(c-d)$ yields the desired inequality.
]

#observation[
$|Bkrcv| >= c-d(1/(1-(k-1)/(c-d))).$
] <obs:sketch-Bkrcv-ge>

#proof-of(<obs:sketch-Bkrcv-ge>)[
By @obs:sketch-bundle-eq, $|Brcv| <= c$, and $k >= 1$,
$ |Bkrcv| times (|Bsnd|-k+1) >= |Bsnd|(c-d) - |Brcv|(k-1) >= |Bsnd|(c-d) - c(k-1). $
By @obs:sketch-Brcv-Bsnd-quorums and #c-mbrb-assum, $|Bsnd| >= c-d >= c-2d >= k$. 
Thus, $|Bsnd|-k+1 > 0$ and the previous equation can be written to
$ |Bkrcv| >= (|Bsnd|(c-d)-c(k-1))/(|Bsnd|-k+1). #<eq:sketch-Bkrcv-ge> $

Equation @eq:sketch-Bkrcv-ge's right-hand side monotonically increases in~$|Bsnd|$ when $|Bsnd| > k-1$, as its derivative, $(d(k+1))/((|Bsnd|-k+1)^2)$, is positive.
By @obs:sketch-Brcv-Bsnd-quorums, $|Bsnd| in [c-d, c] subset.eq [k, c]$. 
The minimum of the right-hand side of @eq:sketch-Bkrcv-ge is therefore obtained for $Bsnd = c-d$, yielding
$ |Bkrcv| >= ((c-d)^2-c(k-1))/((c-d)-k+1)) = c-d(1/(1-(k-1)/(c-d))), $
which concludes the proof of the observation.
]

#observation[
All processes in $Bkrcv$ mbrb-deliver~$v$.
] <obs:sketch-Bkrcv-dlv>

#proof-of(<obs:sketch-Bkrcv-dlv>)[
Let $p_u in Bkrcv$, #ie $p_u$ receives $k$ valid $bundlem$ messages from $k$ distinct correct processes. 
Denote $bundlem(C_x, (tilde(v)_x, pi_x, x), star, Sigma_x)$ these $k$ messages with $x in [k]$.
The detailed proof in @sec:coded-mbrb-correctness-proof (#pageref(<lem:c-mbrb-global-delivery>)) shows that for all $x in [k]$, $C_x = C_v$. 
In addition, $p_u$ saves each received threshold signature $Sigma_x$, which is valid for $C_v$.

Because the messages are valid, so are the proofs of inclusion $pi_x$, and as we have assumed that vector commitments are collision-resistant, $C_x=C_v$ implies that the received fragments $tilde(v)_x$ all belong to the set of fragments computed by $p_s$ (@line:c-mbrb:snd-compute-frag-vc) for $v$.
As the $bundlem$ messages were received from $k$ distinct correct processes, $p_u$ receives at least $k$ distinct valid fragments for $v$ during its execution.
If $p_u$ has not mbrb-delivered any value yet, the condition at @line:c-mbrb:quorum eventually becomes true for $C_v$, and $p_u$ reconstructs $v$ (@line:c-mbrb:quorum-reconstruct), since it has at least $k$ (correct) fragments, which are sufficient for the correct recovery of~$v$.
Then, $p_u$ mbrb-delivers $v$ (@line:c-mbrb:quorum-dlv).
If $p_u$ has already mbrb-delivered some value~$v'$, MBRB-No-duplicity implies $v'=v$, since $p_i$ is known to have mbrb-delivered~$v$. 
Therefore, $p_u$ mbrb-delivers~$v$ in all cases.
]

Finally, the lemma is implied by @obs:sketch-Bkrcv-ge[Observations] @obs:sketch-Bkrcv-dlv[and], and the fact that all processes in $Bkrcv$ are correct.
]

=== Communication analysis of Coded MBRB <sec:c-mbrb-comm>

In this section, we analyze the communication of Coded MBRB (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]) and prove @thm:coded-mbrb-performance.
Let us recall from @sec:mbrb that the variables $omc$ and $bcc$ respectively denote the overall numbers of messages and bits communicated by correct processes during the execution of an MBRB algorithm (in this case, Coded MBRB) when the sender $p_s$ is correct.

#theorem([MBRB-Performance])[
// This rule is a workaround to force the bullets to appear at the center of the first line of the list items.
// ref: https://github.com/typst/typst/issues/1204
#show list.item: it => context [
  #let marker = list.marker.at(0)
  #let height = measure[#it.body].height
  #box(height: height)[#marker #it.body] \
]
If _ #c-mbrb-assum _ is satisfied and the sender $p_s$ is correct, _@alg:coded-mbrb-helpers[Algorithms] @alg:coded-mbrb[_and_]_ provide the following MBRB guarantees:
  
- $omc = 4n^2$ messages sent overall,

- $bcc = O(n|v|+n^2 secp)$ bits sent overall.
] <thm:coded-mbrb-performance>

#proof[
Let us count the messages communicated by counting $comm$ and $broadcast$ invocations.
The sender $p_s$ sends $sendm$ messages at @line:c-mbrb:snd-comm.
In Phase~I, each correct process that has received a $sendm$ message broadcasts a $forwardm$ message once (@line:c-mbrb:rcv-send-cond-other-vc[lines] @line:c-mbrb:rcv-send-bcast[and]). 
However, if it receives a $forwardm$ before the $sendm$ arrives, it performs one additional $forwardm$ broadcast (@line:c-mbrb:rcv-forward-bcast). 
This yields at most $2$ $comm$ and $broadcast$ invocations per correct process until the end of Phase~I.
We can safely assume that a correct sender always sends a single $forwardm$ (#ie it immediately and internally receives the $sendm$ message sent to self).
Thus, $p_s$ is also limited to at most $2$ invocations up to this point.
In Phase~II, each correct process that mbrb-delivers a value at @line:c-mbrb:quorum-dlv transmits $bundlem$ messages at @line:c-mbrb:quorum-comm.
This can only happen once due to the condition at @line:c-mbrb:quorum.
Additionally, it may transmit $bundlem$ messages also at @line:c-mbrb:rcv-bundle-bcast, upon the reception of a $bundlem$.
However, this second $bundlem$ transmission can happen at most once, due to the if-statement at @line:c-mbrb:rcv-bundle-cond-no-bundle.
This leads to at most $2$ additional $comm$ and $broadcast$ invocations per correct process.
Thus, as the number of correct processes is bounded by~$n$, the two phases incur in total at most $4n$ invocations of $comm$ and $broadcast$ overall. 
Since each invocation communicates exactly $n$ messages, the total message cost for correct processes when executing one instance of Coded MBRB (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]) is upper bounded by~$4n^2$.
Note that the above analysis holds for correct processes also in the presence of Byzantine participants, including when $p_s$ is dishonest.

We now bound the number of bits communicated by correct processes throughout a single instance of Coded MBRB (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]).
Let $v$ be a specific value of size $|v|$. 
For every codeword $tilde(v)$ produced from $v$, we have $|tilde(v)| = O(|v|)$ since we use a code with a constant rate (@sec:ecc).
Thus, any specific value fragment $tilde(v)_i$ has length $|tilde(v)_i| = O(|v|\/n)$.
Recall that the sizes of a signature share digest $sigma$, a threshold signature $Sigma$, a commitment $C$, and an inclusion proof $pi$ all have $O(secp)$~bits (@sec:crypto-prim).
In a signature share (pair) $sig=(sigma,i)$, the identifier $i$ of the signing process is included, which takes additional $O(log n)$~bits. 
However, since $secp=Omega(log n)$, the inclusion of this field does not affect asymptotic communication costs.

We now trace all the $comm$ and $broadcast$ instances in @alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[] and analyze the number of bits communicated in each.
The $sendm$ $comm$ (@line:c-mbrb:snd-comm) communicates $n$ messages, where each message includes a fragment of $v$ ($O(|v|\/n)$ bits) with its proof of inclusion ($O(secp)$ bits), a commitment ($O(secp)$ bits), and a signature share ($O(secp)$ bits).
Thus, this operation allows the sender to communicate at most $O(|v|+n secp)$ bits. 
Each $forwardm$ broadcast at @line:c-mbrb:rcv-send-bcast[lines] @line:c-mbrb:rcv-forward-bcast[and] sends $n$ copies of a message containing a commitment ($O(secp)$ bits), at most one value fragment with its proof of inclusion ($O(|v|\/n+secp)$ bits), and two signature shares ($O(secp)$ bits).
Hence, each one of @line:c-mbrb:rcv-send-bcast[lines] @line:c-mbrb:rcv-forward-bcast[and] communicates a total of $O(|v|+secp n)$ bits.
The $bundlem$ communication (@line:c-mbrb:quorum-comm[lines] @line:c-mbrb:rcv-bundle-bcast[or]) sends $n$ messages, where each contains a commitment ($O(secp)$ bits), at most two value fragments with their proof of inclusion ($O(|v|\/n+secp)$ bits), and one threshold signature ($O(secp)$ bits).
Hence, each line communicates at most $O(|v|+n secp)$ bits.
As analyzed above, the sending process ($p_s$, when correct) performs at most one $comm$ of $sendm$ messages, while each correct process performs at most two $broadcast$ of $forwardm$ messages, and at most two $comm$/$broadcast$ of $bundlem$ messages. 
Thus, each process communicates at most $O(|v|+n secp)$ bits.
Overall, the total bit communication by correct processes during the execution of @alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[] is $O(n|v|+n^2 secp)$.
As mentioned above, the analysis holds in the presence of Byzantine processes, even if $p_s$ is dishonest.
]

== Discussion <sec:c-mbrb-discussion>

This section addresses subsidiary aspects of our Coded MBRB solution, namely how to choose the reconstruction threshold $k$ of the underlying erasure-correcting code (@sec:select-k), how to make our solution multi-sender and multi-shot (@sec:c-mbrb-multi), and whether using Bracha's BRB on hashes of the disseminated value could help to obtain the same communication cost under a message adversary (@sec:bracha-with-MA).

=== Selection of $k$ <sec:select-k>
In the previous analysis, we set $k$ to be a parameter that controls the number of fragments that allow decoding the ECC.
To obtain the communication depicted in @thm:coded-mbrb-performance, we assumed $k=Omega(n)$.
Furthermore, this parameter affects the delivery power of the MBRB algorithm, as seen in @lem:c-mbrb-global-delivery, namely $lmbrb = c-d(1/(1-(k-1)/(c-d)))$.

Let us assume that we wish to design an MBRB algorithm with a specified delivery power of $lmbrb = c-(1+epsilon)d$, for some $epsilon>0$.
Plugging in @lem:c-mbrb-global-delivery, we need the delivery power~$lmbrb$ provided by @alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[] to surpass $c-(1+epsilon)d$, thus
$ c-(1+epsilon)d <= c-d(1/(1-(k-1)/(c-d))) $
leading to $k <= epsilon/(1+epsilon)(c-d)+1$.
That is, choosing any integer $k <= epsilon/(1+epsilon)(n-t-d)+1$ satisfies the above.
Recall that the blowup of the ECC is given by $macron(n)\/macron(k) approx n/k$ (@sec:ecc-instantiation), which implies that for any value~$v$, we have $|ECC(v)| approx n/k|v| = (1+epsilon)/epsilon times n/(n-t-d)|v|$.

Together with #c-mbrb-assum, we conclude that the constraints on~$k$ that support delivery power of $lmbrb >= n-t-(1+epsilon)d$, are
$ k <= min(n-t-2d, epsilon/(1+epsilon)(n-t-d)+1). $

=== Supporting multiple instances and multiple senders <sec:c-mbrb-multi>
The above analysis fits the single-shot broadcast algorithm with a fixed sender.
As mentioned above, a multi-shot multi-sender algorithm can be achieved by communicating the sender's identity and a sequence number along with any information communicated or processed during this algorithm.
This added information uniquely identifies any piece of information with the respective instance.
Additionally, signature shares, threshold signatures, commitments, and inclusion proofs should be performed on the value~$v$ augmented with the sender's identity and the sequence number.
This will prevent Byzantine processes from using valid signature shares/threshold signatures from one instance in a different instance. 
As a result, an additive factor of $O(log n)$ bits has to be added to each communicated message, which yields additive communication of $O(n^2 log n)$ and has no effect on the asymptotic communication, as we explained in the proof of @thm:coded-mbrb-performance.
Other changes, such as augmenting the value $v$ with the sender's identity and sequence number do not affect the length of signature shares, threshold signatures, commitments, and inclusion proofs.

=== Using Bracha's BRB on hash values under a message adversary
<sec:bracha-with-MA>

Das, Xiang, and Ren~@DXR21 have proposed a communication optimal (up to the parameter $secp$) BRB algorithm that does not use signatures and relies on Bracha instead to reliably broadcast a hash value of the initial sender's message.
One might legitimately ask whether this approach could not be easily adapted to withstand a message adversary, possibly resulting in an MBRB algorithm exhibiting optimal communication complexity (up to the size of hashes $secp$), optimal Byzantine resilience ($n>3t+2d$), and optimal delivery power $n-t-d$ (or at least some close-to-optimal delivery power $lmbrb$, up to some factor $epsilon$), while avoiding signatures altogether.

#let lbrb = $ell_italic("BRB")$

Unfortunately, under a message adversary, Bracha's BRB leads to a sub-optimal Byzantine resilience, and degraded delivery power $lmbrb$.
Indeed, as shown in the previous chapter (@sec:k2l-cast), Bracha can be used to implement an MBRB algorithm, but with a sub-optimal resilience bound ($n > 3t + 2d + 2 sqrt(t d)$) and a reduced delivery power $lbrb = ceil(n-t-((n-t)/(n-3t-d))d)$.
Disappointingly, these less-than-optimal properties would in turn be passed on to any MBRB algorithm using Bracha's BRB along the lines of Das, Xiang, and Ren's solution.
#footnote[
  Taking into account the initial dissemination of value $v$ by the sender, which is also impacted by the message adversary, such an algorithm could in fact at most reach a delivery power of $max(0, (n-t-d)+lbrb-(n-t)) = max(0, lbrb-d) = max(0, ceil(n-t-((n-t)/(n-3t-d)+1)d))$.
]
By contrast, the algorithm we propose is optimal in terms of communication cost (up to $secp$) and Byzantine resilience, and close to optimal in terms of delivery power (up to some parameter $epsilon$ that can be chosen arbitrarily small).

To hint at why Bracha's BRB leads to degraded resilience and delivery power when confronted with a message adversary (MA), consider the classical $echom$ phase of Bracha's BRB~@B87.
At least one correct process must receive strictly more than $(n+t)/2$ $echom$ messages to ensure the first $readym$ message by a correct process can be emitted.
To ensure Local-delivery, the threshold $(n+t)/2$ must remain lower than the worst number of $echom$ messages a correct process can expect to receive when the sender is correct.
Without an MA this constraint leads to $(n+t)/2 < n-t$, which is verified by assuming $n>3t$.
With an MA, the analysis is more complex.
Applying a similar argument to that of the proof of MBRB-Global-delivery of Coded MBRB (see @sec:c-mbrb-correct-intuition), one can show that in the worst case the adversary can ensure that no correct process receives more than $(n-t-d)^2/(n-t)$ $echom$ messages.
Ensuring that at least one correct process reaches the Byzantine quorum threshold $(n+t)/2$ therefore requires that we have:

$ (n+t)/2 < (n-t-d)^2/(n-t). $

This leads to a quadratic inequality involving $n$, $t$ and $d$, which results in the following constraint on $n$:

$ n > 2t + 2d + sqrt((d+t)^2+d^2) >= 3t + 3d. $

In @sec:k2l-cast, we improve on this resilience bound by systematically optimizing the various retransmission and phase thresholds used by Bracha's BRB algorithm, but the resulting solution still falls short of the optimal lower bound $n > 3t + 2d$, which the solution presented in this chapter provides. 

== Conclusion <sec:c-mbrb-conclu>

This chapter introduced a Coded MBRB algorithm that significantly improves the communication cost of the original MBRB solution presented in @sec:sig-mbrb. //(see ). 
Namely, it achieves optimal communication (up to the size of the cryptographic structures~$secp$) while maintaining a high delivery power, #ie it ensures that messages are delivered by at least $lmbrb = n-t-(1+epsilon)d$ correct processes, where $epsilon > 0$ is a tunable parameter #ta[that can be made arbitrarily close to $0$, albeit with a marginal increase in communication costs].
// #FT[that can be made arbitrarily small/close to zero (you say so later, so I would just move up the comment)].
The proposed solution is deterministic up to its use of cryptography (threshold signatures and vector commitments).
Each correct process sends no more than $4n$ messages and communicates at most $O(|v|+n secp)$ bits, where~$|v|$ represents the length of the input value and $secp$ is a security parameter. 
We note that the algorithm's communication efficiency holds for sufficiently long messages and approaches the natural upper bound on delivery power $n-t-d$, which accounts for the message adversary's (MA) ability to isolate a subset of correct processes.
// The proposed approach achieves a delivery power $lmbrb$ that can be made arbitrarily close to this limit, albeit with a marginal increase in communication costs, which depends on the chosen  $epsilon$.
// This work represents a significant advancement in Byzantine Reliable Broadcast,
// #FT[This feels a bit too self-congratulating. Let the reader judge. E.g. "This work offers a practical solution for robust communication in asynchronous message-passing systems with malicious processes and message adversaries, while delivering a communication complexity that is comparable with that of the most recent existing MA-free BRB algorithms [XXXsomerefsXXX]."] 
#ta[This work offers a practical solution for robust communication in asynchronous message-passing systems with malicious processes and message adversaries, while delivering a communication complexity that is comparable with that of the most recent existing MA-free BRB algorithms @ADDRVXZ22 @DXR21.]
One intriguing question is whether it is possible to devise an (M)BRB algorithm that does not exhibit the $secp$ parameter in its communication complexity or the $epsilon$ parameter in its delivery power $lmbrb$, for instance by leveraging randomization~@ACDNPRS23 or error-freedom~@ADDRVXZ22 (#ie avoiding cryptography).