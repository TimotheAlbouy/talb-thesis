#import "../setup.typ": *

= Introduction <sec:intro>

#v(2em)

#epigraph(
  [Je n'ai fait cette lettre plus longue que parce que je n'ai pas eu le loisir de la faire plus courte.],
  [Blaise Pascal, _Les Provinciales, lettre 16_, 1656]
)

#v(2em)

Distributed computing is the science of cooperation: it arises as soon as multiple participants work together to achieve a common goal despite having only partial knowledge of their environment~@R23-1.
As such, distributed computing appears in everyday life, and formalizes considerations that have existed since the dawn of civilization, #eg ensuring the secrecy and authenticity of communication, or coping with the slowness and unreliability of information propagation.
With the rise of micro-computers and the launch of the Internet in the 1980s, servers and optic fiber have progressively supplanted army generals and royal emissaries, but it is interesting to note that things have not intrinsically changed since ancient times, only sped up!

From messaging apps and online payments to e-voting and cloud computing, geographically distributed _computer_ systems pervade our modern interconnected world.
However, with the increasing prevalence of cyber threats and the lingering risk of software bugs and hardware malfunctions, the imperative for robustness and availability guarantees in distributed systems is clear.
Hence, this dissertation will explore theoretical tools and techniques for making modern distributed systems more resilient against all these sources of unpredictability.

== Distributed computing: definition and comparison <sec:intro-dist-def>
A distributed _computer_ system comprises multiple _processes_
#footnote[
  Many different terms are commonly used to refer to the participants of a distributed system (agents, nodes, peers, sensors, #etc).
  For consistency, we will stick to _processes_ in this manuscript.
]
that execute an algorithm and coordinate their activities by exchanging information.
The literature distinguishes two primary kinds of communication mediums: _message passing_ and _shared memory_.
These two models differ fundamentally in how they enable communication among the processes.

- In message-passing systems, processes communicate by explicitly sending and receiving messages through a network, that could be implemented by protocols such as TCP/IP.
  // #DF[you were talking about theoretical models and now you're talking about TCP/IP which is an implementation. I would use a transition saying."This models networks..." or something similar. Also, try to keep the same structure for this bullet and the next.]
  // Perhaps one of the most important and famous distributed problems in this model is _consensus_, #ie reaching an agreement between all processes on one of the values proposed by them.
  Perhaps the most important and famous distributed computing problem is _consensus_, which was historically introduced in the message-passing model: all processes must reach an agreement on one of the values they proposed @L96.
  // #FT[Beware that consensus is defined independently from the underlying comm paradigm. In fact, the consensus numbers hierarchy is only defined in the shared memory model.]
  Message-passing systems are also studied from the standpoint of networking or cryptography, under the term _multi-party computation_ (_MPC_).

- In shared-memory systems, processes can directly read from and write to a common memory space, as if they were accessing their local memory.
  One of the oldest and most important problems relating to this model is _mutual exclusion_ (or _mutex_) @D65, #ie making sure that no two different processes can concomitantly access a shared resource, whether physical (#eg an office printer) or logical (#eg the critical section of a program).
  In operating systems research, the case of shared memory is also studied under the angles of _scheduling_ or _cache coherence_.

// #FT[Remark on what precedes: The link to problems is nice, as it makes things concrete, but the danger is that it suggests that problems are linked to/specified w.r.t. a given interaction model, which is not the case typically (abstraction are typically specified independently of the interaction model). One approach could be to tone down the link, and add a remark that the link is historical but not conceptual.]
Although multiple works show the many similarities that exist between these two communication models (it is sometimes believed that consensus and mutual exclusion are two faces of the same coin @R23-2
#footnote[
  Let us note that consensus and mutex were historically linked to specific interaction models (message passing and shared memory, respectively), but their formal definitions are, in fact, oblivious to the underlying communication paradigm.
]), the present manuscript will mainly focus on message-passing distributed systems.
In the sequel, we underline the differences between distributed computing and other models of computation.
// and then present the notions of specification, algorithm, and proof in (distributed) algorithmics.

// It is worth mentioning that the question _"What is the most important distributed problem?"_ may yield different answers depending on the researcher.
// In the folklore, the distributed computing community is divided between the _Reds_ and the _Blues_ @F10: the former are mostly interested in consensus and mutual exclusion (they focus on the _time_ aspect of distributed systems), while the latter are mostly interested in distributed algorithms applied to graph problems, such as the maximal independent set (MIS) and graph coloring (they focus on the _space_ aspect of distributed systems) @L96.#DF[this paragraph appears a bit out of place here. Why are you talking about graph problems at all?]
// #TA[Some graph-oriented researchers may not like the claim "the most important distributed problem is consensus" or that I do not mention their area of research when presenting DC]

// constitute the backbone of our globalized world
// This model was _de facto_ standard

// #FT[I would tell the reader where the rest of the section is going here,e.g. "In the following, we first ..."]

#paragraph[Sequential, parallel and distributed computing]
// #FT[The following discussion is important, but I would try to link it better to what precedes.
Because distributed computing typically involves independent sequential processes executing concurrently, it is closely related to both sequential and parallel computing, yet should not be confused with either of these two major fields.
// Before continuing, it is important to underline the distinctions between _distributed_ computing on one side and _sequential_ and _parallel_ computing on the other.

_Sequential computing_ refers to the traditional model of computation, where a single processing unit (such as a CPU core) executes instructions one after the other in a sequence, following the order defined by the program.
Sequential computing has been the dominant model for decades, mainly thanks to the "free lunch" allowed by Moore's law @M98, which predicted a rapid increase in available computing power through transistor miniaturization, and enabled faster programs without optimization.

However, at the beginning of the century, the increasing difficulty of maintaining the growth of microprocessors' clock speeds led manufacturers to progressively switch to multicore chips~@CRR23 @P06.
Harnessing this new trend, _parallel computing_ rose to prominence as a way to execute programs efficiently, by distributing the workload on several computing units.
// cores of a multiprocessor#FT[Beware: multicore (a processor with multiple core on the same silicium dice)≠ multiprocessor (a computer with multiple processing units, each on its own dice)].
// #FT['increasingly appeared', 'became increasingly important', 'grew to prominence': 'appeared' alone suggests that parallel computing did not exist before, which is not true]
As a simplified example, in a parallel program, the input data can be divided into distinct chunks, that can then be independently processed by multiple workers (see @fig:parallel).
// #FT[This is what is called 'Embarrassingly parallel', but many parallel program do not fall into this description, see e.g. Amdahl's Law etc. I would tone down your claim: e.g. 'In the ideal case', 'Typically']
Parallel programs involve important synchronization issues (#eg threads, locks, or barriers), making them notoriously harder to write than sequential programs.
However, with respect to computability power, parallel computing is an equivalent of sequential computing primarily interested in efficiency.
// non-trivial extension
// #FT[Again toning down, extension can be see as disparaging, and many colleagues might feel shorted.]
Indeed, given enough time, every problem that can be solved in parallel can also be solved sequentially.

#include "fig/parallel.typ"

_Distributed computing_ studies issues similar to parallel (and sequential) computing, but from a different angle.
Unlike parallel computing, where the environment is typically under the programmer's control (no failures), in distributed computing, the (physically) distributed nature of the system is imposed on the system designer @R23-1.
// #FT[Again toning down and hedging your claims is better: 'typically', 'generally', in most cases. People working on theoretical distributed computing often also work on synchronization primitives which are directly relevant to parallel computing. Rather than say that dist. comp. provide a perspective that is orthogonal, or attack similar issues from a different angle, ...] 
The challenge in distributed systems lies in mastering the uncertainties created by this environment: concurrency (#ie the actions of other processes in the system), information speed (#eg message delays, memory latency, #etc), or failures (process- or network-related).
Interestingly, one can observe that these uncertainties all stem from the impossibility of instantaneous communication.

#paragraph[Computability power and impossible problems]
Sequential and distributed computing also differ fundamentally in terms of _computability power_, #ie the classes of problems that are solvable in these two models.
#footnote[
  Computability power is not to be confused with _computing power_, which refers to how fast some machine can make calculations, and which is typically measured in _floating-point operations per second_ (or _FLOPS_).
]

Indeed, our current understanding of the computability limits of sequential machines#footnote[
  We consider the sequential machines of the Chomsky-Schützenberger hierarchy of automata~@CS63 @C56 @C59: Finite state automata $subset$ Pushdown automata $subset$  Turing machines.
  Even though this hierarchy was initially presented as a classification of formal grammars, it also applies to sequential computation in the context of symbol manipulation.
] are determined by the Church-Turing thesis, which conjectures that everything that can be mechanically computed can be done so by a Turing machine.
However, in 1936, A.M. Turing famously demonstrated in his paper _"On computable numbers, with an application to the Entscheidungsproblem"_ that some problems cannot be solved by Turing machines~@T37.
#footnote[
  Although Alonzo Church wrote a similar proof of undecidability a few months before~@C36-1 @C36-2, Alan Turing's is the most well-known today due to the elegance and simplicity of his Turing machine model (compared to Church's $lambda$-calculus).
]
This impossibility result
#footnote[
  Turing's proof follows from the unsolvability of some decision problems, one of which is the famous _halting problem_.
] lies at the foundation of modern informatics and is sometimes regarded as the "birth certificate" of the discipline~@S99.
// This impossibility result, widely known today as the _halting problem_, lies at the foundation of modern informatics (some consider it as the "birth certificate" of the discipline).

Similar fundamental impossibility results also exist in the realm of distributed computing @AE14, such as the CAP @GL02 or FLP @FLP85 theorems (see @sec:consensus), but as stated by Herlihy, Rajsbaum, and Raynal @HRR13, _"these limits to computability reflect the difficulty of making decisions in the face of ambiguity, and have little to do with the inherent computational power of individual participants."_
Indeed, even if all processes of the distributed system were stronger than a Turing machine (which is inconceivable according to the Church-Turing thesis), these problems would remain unsolvable.

// As Zvi Lotker put it, _sequential and distributed computing are to informatics what psychology and sociology are to the humanities_.

== Algorithmics: a few basic notions

Before proceeding further into this dissertation, it is essential to explain a few notions relating to (distributed) algorithmics, namely the concepts of _specification_, _algorithm_ and _proof_, and the distinction between _application_ and _implementation_.  

#paragraph[Specification, algorithm, and proof]
As we show next, answering questions about the computability of distributed problems requires systematic reasoning centered on specifications, algorithms, and proofs.

// #FT[Ideally, you would like to link this next part with what you've just discussed. Maybe something along the line: "Answering questions about the computability or optimal complexity of distributed problems requires a form of systematic reasoning that revolves around specification, algorithms and proofs. More specifically, ..."]

All theoretical problems considered in algorithmics (such as graph coloring or array sorting) are formally defined using _specifications_ (or _abstractions_), #ie structured descriptions of the problem's properties on its inputs and outputs.
Formal specifications are central to _declarative programming_, one of the two main programming paradigms, which focuses on describing the problem to solve, #ie _what_ we want (a.k.a. the black box approach), rather than giving precise instructions on _how_ to solve it (a.k.a. the white box approach).
These specifications are often given as a list of _preconditions_ (#ie requirements on the problem's input) and _postconditions_ (#ie guarantees on the problem's outputs).
Let us consider the example of an operation "$sans("sort_array")(italic("unsorted_array")) -> italic("sorted_array")$" that takes a (potentially) unsorted number array as input and outputs the associated sorted array.
The precondition (requirement) is that $italic("unsorted_array")$ is a well-formed array of numbers (which can be verified at the type level), while the postcondition (guarantee) is that $italic("sorted_array")$ is indeed a sorted number array, #ie every number in the array is greater or equal to each of its predecessors.

Specifications are then implemented using _algorithms_, which are sequences of instructions describing the steps to _solve_ (or _implement_) the problem.
An algorithm can be seen as an instance of _imperative programming_, the other main programming paradigm, which focuses on describing _how_ the program should operate to solve the problem, by providing its exact instructions and control flow.
For array sorting, these instructions may involve reading a number in the array or swapping two numbers, for instance.
Multiple algorithms can implement a given specification: for example, merge sort and bubble sort are two popular algorithms that implement the previous $sans("sort_array")()$ specification, although the former is more efficient than the latter in terms of execution time.
Using complexity theory, different implementations of the same problem may be formally compared in terms of performance or cost: _time complexity_ characterizes the algorithm's execution duration (typically, its asymptotic number of executed instructions), while _space complexity_ characterizes its storage usage (#ie the asymptotic number of bits it needs to store). 

Finally, a _proof_ uses formal reasoning to show that a given algorithm implements a given specification, in which case the algorithm is said to be _correct_.
Correctness is an essential feature of dependable or critical systems.
As stated by Maurice Herlihy: "_Correctness may be theoretical, but incorrectness has a practical impact._"
// #FT[Some ref?]

The same pipeline also applies to distributed algorithmics: distributed problems are first specified, then implementations are proposed, and finally, the implementations are proven correct.
// #FT["algorithms": many researchers work on distributed computing systems, where the onus is on constructing and characterizing actual systems (with proofs less important)]
In contrast to sequential algorithms, distributed algorithms are executed simultaneously by all system processes, and use additional instructions for inter-process communication, such as $send()$/$receive()$ for exchanging messages or $read()$/$write()$ on a shared memory.
Moreover, specifications in distributed computing (and more generally in system design) tend to distinguish two kinds of guarantees: _safety_ properties (#ie "nothing bad ever happens") and _liveness_ properties (#ie "something good eventually happens").
For instance, in an automated train system, safety ensures that train wrecks cannot happen (derailment, collision, ...), while liveness guarantees that the train eventually reaches its destination on time.
Although safety is always a priority, liveness is particularly important, as it precludes trivial implementations (#eg a train that does not move has no accident) and captures the "dynamic" aspect of informatics that mathematics lacks.

#paragraph[Implementation and application, messages and values]
When considering an abstraction (#ie formal specification), one must distinguish between the _implementation_ and the _applicative_ levels.
As outlined previously, the implementation refers to the lower-level algorithm that satisfies the abstraction.
In contrast, the application refers to the upper-level client of the abstraction, which could be the system's end user, or another algorithm that leverages the abstraction to construct more complex behaviors. 
In this context, the specification acts as the interface between the implementation and the application.
The interplay between implementation and application is instrumental in building modular complex systems.

From a terminology point of view, we also distinguish two complementary notions: _messages_ and _values_.
In a message-passing distributed system, the word _message_ refers to a message sent by an algorithm on the network level to implement an abstraction.
Messages are _sent_ and _received_.
On the other hand, the word _value_ refers to a payload that a client (application) seeks to disseminate via an abstraction.
In message-passing algorithms, values are typically contained in messages, but these two notions should not be conflated.
In short, messages relate to the implementation, while values relate to the application.

The terms denoting the dissemination and acceptance of some values at the application level depend on the abstraction.
For instance, in consensus, we say that values are _proposed_ and _accepted_ (see @sec:consensus), while in reliable broadcast, we say that they are _rb-broadcast_ and _rb-delivered_ (see @sec:reliable-bcast).

== Models of distributed computing

// == Taming the zoo of fault tolerance
// #paragraph[On theory and practice]

Having established these fundamental concepts of algorithmics, we can now explore how they are applied in the modeling of distributed systems.
Like many other scientific disciplines (pure vs. applied math, theoretical vs. experimental physics, #etc), research in distributed computing spans a spectrum going from theory to practice.
As researchers, we are always someone's theoretician and someone else's practitioner.
One of the theoreticians' goals is to design formal models, #ie simplifications of reality that are easy to reason about.
Practitioners can then use these theoretical frameworks to build trusted solutions, applications, and systems.
This section presents the _de facto_ standard models of distributed computing regarding communication (a)synchrony and fault tolerance.

=== Communication: synchrony, asynchrony, and partial synchrony <sec:intro-sync-async>

// In this section, we present the main communication models of distributed computing.
// Although these models have analogs in the shared memory world, recall that this dissertation is mainly interested in message-passing systems.#FT[Scaffolding text: the section title makes clear already you are going to discuss these topics. Drop?]
In message-passing distributed computing, it is assumed that an adversary can control (to some extent) the delay of messages transiting in the network, thus introducing some unpredictability.
Hence, the subsequent communication models define the limits of the adversary's power to delay messages.

In the _synchronous_ model, all messages have a maximum delay $Delta$ known by all processes.
Thus, the adversary cannot delay a message for more than $Delta$ time units.
The synchronous model can also be represented by round-based communication: all processes go at the same pace and exchange messages during communication rounds of duration $Delta$, and all messages sent during a round are received in the same round.

By contrast, in the _asynchronous_ model, messages can have any arbitrary (but finite) delay.
// #FT['by contrast' seems to work better here]
Hence, there is no upper bound $Delta$ on the maximum delay, but the adversary must eventually let messages be received.
#footnote[
  As the duration of local computations by processes is often negligible compared to message delays, one typically considers that the former is "absorbed" in the latter.
]
// #DF[I think the typical definition also mentions processing delays but I am not a 100% sure it matters.]

The _partially synchronous_ model was first introduced by Dwork and Lynch in @DLS88 as a middle ground between the two previous models.
// in #FT["by X and Y" (Dwork and Lynch?). More generally, good to avoid using ref call-outs as grammatical element (although it's often unavoidable)]
It originates from the observation that existing large-scale distributed systems (such as the Internet) are not completely synchronous or asynchronous.
// #DF['or' not applies to or so if you do not nor, it does not work. If you want to use nor, you need to use neither instead of not]
Indeed, these systems are usually synchronous (network latencies are stable), but they can sometimes experience phases of asynchrony (where latency spikes can appear) due to congestion or denial-of-service attacks, for instance.
Partially synchronous algorithms are typically designed to be always _safe_ (even when synchrony assumptions are temporarily violated), but they may stop progressing during asynchronous periods.
However, their termination is guaranteed as soon as the network becomes synchronous again.
Two models have been proposed to represent partial synchrony: in the first one, there is a _global synchronization time_ (or _GST_ for short), unknown to processes, before which the system is asynchronous and after which it is synchronous; and in the second one, there is a maximum delay of messages $Delta$, but that is not known by processes @CHT96.

This manuscript focuses on the asynchronous model.
This model is weaker than its (partially) synchronous counterparts: as no assumption is made on network delays, fewer problems are solvable under asynchrony (see @sec:consensus).
However, asynchronous algorithms have the advantage of being more robust: they keep their guarantees no matter the message delays and tolerate (partially) synchronous environments, whereas (partially) synchronous algorithms may break under asynchrony.
Additionally, asynchronous algorithms do not need to wait for the end of communication rounds to advance; they progress as soon as their conditions on received messages are satisfied, making them more reactive and, therefore, faster in practice than (partially) synchronous algorithms.
// #FT["in practice"? (since the notion of continuous time is not always clearly defined in these models)]

=== Faults: processes and network <sec:intro-faults>

A distributed system can be subject to faults that impact its processes or its communication medium (#ie network in our case).
Faults usually correspond to involuntary defects in the software or hardware, but they can also be caused by a malicious adversary trying to jeopardize the system (in the case of a cyberattack).
As we shall see next, these two types of failures are irreducible to one another, in the sense that one cannot simulate network faults using process faults, and _vice versa_.
// #FT[reciprocally?]

#paragraph[Process faults]
Models for process faults can be classified in the following hierarchy, sorted by increasing expressive power: Crash faults $subset$ Omission faults $subset$ Byzantine faults.
The non-faulty processes of the system that obediently follow the algorithm are called _correct_ processes.

_Crash faults_ (also called fail-stop) are the least expressive model of the hierarchy, in the sense that they only represent the specific case where a process that previously followed the algorithm suddenly becomes silent (#ie stops communicating) after a specific instant (the crash).

_Omissions_ are meant to generalize crashes.
As with crashes, a process $p$ subject to omissions follows the algorithm.
But, unbeknownst to $p$, an adversary may block some (or all) of the messages that $p$ sends (in the case of send omissions) or that are intended to $p$ (in the case of receive omissions).
We can observe that omissions can trivially emulate the crash of a process if the adversary removes all its incoming and outgoing messages.
However, compared to crashes, omissions can also represent other (more favorable) settings where only a subset of these messages are deleted.

Finally, _Byzantine faults_ are the most expressive model for process faults, as they can consider every possible behavior from faulty processes @LSP82 @PSL80.
Indeed, a Byzantine process may arbitrarily deviate from the algorithm and collude with other Byzantine processes to fool correct processes.
As the most general model for process failures, Byzantine fault tolerance (BFT) is often regarded as the golden standard for building robust distributed systems.

// #FT[Maybe introduce the following discussion by noting that although the BFT model is one of the most aggressive, classically there are things that Byzantine processes cannot do, such as creating identities or preventing two correct processes from communicating.]
Although the BFT model is one of the most aggressive, some attack vectors cannot be represented only by Byzantine processes.
For example, for several decades, theoretical research in distributed computing revolved mainly around _static_ (or _permissioned_/_closed_) systems, where the set of participating processes never changes, and new identities cannot be created or acquired.
But in the early 2000s, the advent of large-scale peer-to-peer services (#eg Napster, BitTorrent @C02 @MM02, Tor @DMS04, #etc) brought interest to _dynamic_ (or _permissionless_/_open_) systems, where processes can join and leave the network (or simply disconnect/reconnect), a phenomenon known as _churn_.
In particular, open systems must cope with Sybil attacks, in which an adversary tries to compromise the network by flooding it with fake identities~@D02.
Sybil resistance constitutes an even harder challenge for distributed systems designers, as the adversary thresholds often assumed in closed settings (typically, less than one-third of processes are Byzantine) cannot continue to hold in open settings.
// Although Sybil resistance constitutes an even harder challenge for distributed systems designers, it still belongs to the realm of BFT, as Sybil identities are Byzantine processes.

// #TA[I don't know if I should make this last paragraph a sub-section on its own addressing the models for staticity/dynamicity]

// #paragraph[Byzantium is not the world's end!]
// #paragraph[A fault model to rule them all]

#paragraph[Network faults]
In addition to process faults, a practical distributed system may also experience failures related to its communication medium.
Indeed, messages transiting on the network can be subject to deletions (omissions), corruptions, or spurious creations due to interference or lossy channels, for instance.

This family of network failures has been formalized by the _Message Adversary_ (_MA_) model, first introduced by Santoro and Widmayer in @SW89.
Unlike Byzantine or omission faults, which are _static_, #ie they are pinned to specific processes, an MA removes this constraint and introduces _mobile_ faults, which may target different communication links during the execution.
In particular, these link failures may happen between two correct processes, a scenario ignored in the standard Byzantine model (unless one assumes all processes to be potentially Byzantine, which considerably limits what can be achieved in practice).
Hence, the MA model can cover significant phenomena, such as correct processes' disconnections, dynamicity, and churn.

// Initially, the MA model only considered synchronous settings (where some amount of network faults may happen at each synchronous round), but as discussed in the rest of this thesis, it can naturally be extended to asynchronous settings.

// I was privileged to witness Nicola Santoro and Michael Widmayer's Dijkstra award citation at PODC 2024 in Nantes.

#paragraph[Hybrid fault models]
As we have just seen, process and network failures are orthogonal fault models, in the sense that they cannot emulate each other.
For example, a message adversary suppressing messages cannot simulate a Byzantine process; conversely, a Byzantine process cannot delete messages exchanged between two correct processes.
// fault models whose most powerful paradigms are Byzantine faults and Message Adversaries (MA), respectively.

Remarkably, the seminal papers that introduced these two models both received the Dijkstra Prize, the most prestigious award in distributed computing //, which rewards seminal papers over a decade old
#footnote[
  In distributed computing, the Dijkstra Prize is only surpassed in prestige by a few awards covering all subdisciplines in informatics, the most notorious being the Turing Prize (considered the "Nobel of informatics").
]: Pease, Shostak, and Lamport's 1980 paper _"Reaching agreement in the presence of faults"_~@PSL80, which introduced Byzantine failures, received the 2005 citation, and Santoro and Widmayer's 1989 paper _"Time is not a healer"_~@SW89, which introduced message adversaries, received the 2024 citation.

Combining the two types of faults into one fault model allows for considering significant scenarios these paradigms could not cover individually: the whole is greater than the sum of the parts.
For instance, hybrid failures can represent systems prone to both malicious processes and recoverable message omissions for correct processes (#eg due to transient disconnections or process mobility).

To illustrate hybrid faults, consider a distributed storage system.
Process faults can occur when a server crashes or is compromised by an attacker (becoming Byzantine).
Simultaneously, network faults can occur due to network congestion or denial-of-service attacks, resulting in message losses between still-operational servers.
This combination of process and network faults yields complex hybrid fault scenarios that this thesis aims to address.

// To illustrate hybrid faults, one can consider the following example: during a phone call between two participants, there can be problems related to the cellular network (#eg interference) hampering communication, but one of the participants can also tell lies to the other partipant.
// The former issues fall into the _network faults_ category, while the latter fall into the _process faults_ category.
// These hybrid fault models were seldom studied in the literature, and constitute the study topic of this thesis.

== The multiple flavors of agreement

Having established the fundamental models and concepts of distributed computing, we can turn our attention to the central challenges that distributed systems must address.
// we can now explore how these principles are applied to solve one of the field's central challenges: achieving agreement among distributed processes.
In distributed computing, all problems involve the cooperation of multiple participants towards a common goal.
Whether for building a system for leader election, a naming service, or a collaborative editing tool, distributed algorithms typically seek to achieve some form of _agreement_.
However, as we shall see, the agreement problem can manifest itself in many different forms.
The following section will focus on two key variants of this problem: _consensus_ and _reliable broadcast_.

=== Consensus: A fundamental problem... <sec:consensus>

Consensus is a fundamental abstraction of distributed computing with a simple premise: all participants of a distributed system must propose a value, and all participants must eventually agree on the same value among the ones that have been proposed @L96 (see @fig:consensus).

The industrial applications of consensus are manyfold: cloud computing, distributed databases, satellite navigation systems, clock synchronization, blockchain systems, #etc
In particular, consensus is critical in the context of _state-machine replication_ (_SMR_), that is, making a system of multiple processes that can individually fail appear to external observers (clients) as one single entity that is never subject to failures.
The importance of consensus is further exemplified by the fact that it is a _universal problem_~@H91: roughly speaking, consensus can be used to solve any other distributed problem (specified as a concurrent object with a sequential specification)~@HS08.
// #FT["concurrent" or "sequential". I thought the universalism of consensus holds for objects with a sequential specification only.]

#include "fig/consensus.typ"

#paragraph[...with a fundamental impossibility]
It has been famously proven in @FLP85 that asynchronous consensus cannot be solved even with one process crash.
This impossibility result, colloquially known as the _FLP theorem_ (for the initials of its authors: Fischer, Lynch, Patterson), is fundamental: it assumes a very general communication medium (asynchrony) while considering a very weak fault model (only one crash).

Intuitively, this impossibility arises from the fact that a process of the system (Bob) may think that some other process (Alice) sent a message on the network that influenced the decisions of others.
However, Bob cannot distinguish between the case where Alice's message to Bob is delayed due to asynchrony and the case where Alice crashed (see @fig:consensus-alice-bob).
Indeed, in asynchrony, it is impossible to detect crashes.
#footnote[
  Let us notice that a crashed process can be detected under synchrony by simply sending a message to it and waiting for a response for 2 times the maximum delay.
]

// #FT[in the crash fault model (in the Byzantine model, a Byzantine node may remain silent to some nodes, and not to others)]

#include "fig/consensus-alice-bob.typ"

The implications of this impossibility are profound: even if we consider a very large network of billions of computers, a single crash can prevent consensus.
The FLP theorem can be seen as the formalization of Lamport's famous quote, which humorously describes the nature of distributed computing: _"A distributed [computer] system is one in which the failure of a computer you didn't even know existed can render your own computer unusable"_~@L87.

Other impossibility proofs of _asynchronous resilient consensus_ were later presented.
The initial FLP proof was circumscribed to the message-passing model, but Loui and Abu-Amara later showed that this impossibility also holds in shared memory @LA87.
Some other proofs are based on combinatorial topology (such as in the asynchronous computability theorem by Herlihy and Shavit~@HS99), and others follow an axiomatic approach @AFGGNW24-1 @T91: the notion of asynchronous resilient consensus is defined as a system of axioms which is then proven inconsistent, #ie it contains a contradiction.
Constructive proofs follow another interesting approach @GL23 @V04: they explicitly describe how a non-terminating execution of consensus can be constructed.

#paragraph[Circumventing the impossibility]
Multiple solutions circumvent the FLP impossibility by enriching the underlying model with additional assumptions or relaxing the consensus guarantees.
Some of these solutions require adding partial synchrony assumptions @CL99 @L98, while others rely on randomization @B83 @MMR14.
A detailed review of some of the most notable solutions to avoid FLP is presented in @sec:circumvent-flp.
// Roughly speaking, all of these solutions negate at least one of the following four properties: resilience

#paragraph[The other penalty of consensus: performance]
Distributed systems relying on consensus typically suffer substantial performance overheads due to strong synchronization costs between the processes.
// #FT[Because of the definite article 'the' you need to qualify 'synchronization cost', e.g. 'the synchronization cost typically incurred by consensus algorithms' ("typically" helps edging the claim, which is quite broad)]
For example, most decentralized cryptocurrencies (#eg Bitcoin @N08) use consensus
#footnote[
  In blockchains, consensus is typically implemented with probabilistic safety guarantees (#ie safety properties might be temporarily violated in unfavorable cases, which is sometimes referred to as _Nakamato consensus_), contrary to the traditional approach for implementing consensus in closed (or permissioned) systems which provides probabilistic liveness but ensures deterministic safety.
] to implement a blockchain, a replicated append-only database storing all system transactions in a chain of blocks.
// #FT[Maybe add a footnote that Blockchian consensus in permissionless systems usually only provides probabilistic safety guarantees, i.e. safety properties might be (temporarily) violated in unfavorable cases, contrary to consensus algorithms designed for closes (or permissioned) systems.]
Blocks containing new transactions are regularly added to the chain, thus forming a _total order_ of transactions: all participants process all transactions sequentially and in the same order (block by block).
In practice, achieving total order in a decentralized and open system (such as a cryptocurrency) is particularly costly.
For example, Bitcoin's throughput is capped at a dozen transactions per second _worldwide_ @CMVM18, while mainstream (centralized) payment processing networks, such as Visa or Mastercard, can handle several thousand transactions per second.
This technical difficulty has been captured in the _Blockchain Trilemma_~@KJGGSF18, which conjectures that there is a necessary trade-off between three critical aspects of blockchain technology: _Security_ (resilient against attack), _Decentralization_ (open, no central authority), and _Scalability_ (high throughput, low latency and operational costs).

However, contrary to common belief, total order and strong agreement (such as consensus) are unnecessary in many applications, particularly money-transfer/cryptocurrency systems.
Indeed, to tackle the performance issue of consensus/blockchain-based cryptocurrencies, weaker abstractions can be exploited, such as _reliable broadcast_ @AFRT20 @BDS20 @CGKKMPPSTX20 @GKMPS22. 

// money transfer systems, such as blockchain-based cryptocurrencies like Bitcoin @N08 use a variant of consensus (and more precisely, a variant called Nakamoto consensus), which imposes a _total order_ on the system's transactions: all transactions are seen and processed sequentially and in the same order by all participants.

=== Reliable broadcast (RB) <sec:reliable-bcast>

Introduced in the mid-eighties, _reliable broadcast_ (_RB_) is another fundamental communication abstraction that lies at the center of many fault-tolerant distributed systems.
Formally defined in the synchronous setting by Lamport, Shostak, and Pease in 1982 (under the name _Byzantine generals problem_) @LSP82, and then in the asynchronous setting by Bracha and Toueg in 1985~@BT85 @B87, RB allows each process to broadcast values with well-defined properties in the presence of process failures.
// #footnote[
//   The term _delivery_ refers here to the application layer where a process receives and processes the content of an application message (see @sec:model).
// ]
In turn, these properties make it possible to design provably correct distributed software for upper-layer applications, such as distributed file systems, event notification, or replication.
Notably, reliable broadcast plays a crucial role in money and asset transfer systems, as discussed below.

#include "fig/bcast.typ"

Like other members of the broadcast family, reliable broadcast involves a leader (the sender) who disseminates some value to the entire network (see @fig:rbcast).
Informally, reliable broadcast guarantees that the correct processes _deliver_ (#ie accept) the same set of values, which includes at least all the values they broadcast.
#footnote[
  Additionally, unlike other primitives such as CRDT @FGRT24 @OUMI06 @SPBZ11 or gossip @EGHKK03 @KMG03, reliable broadcast guarantees that at most one value is delivered from each sender per broadcast instance.
]
// #TA[I am not sure about this definition, it can also be satisfied by CRDTs]#FT[Yes, indeed. The key additional property is that at most one message is at most delivered from each sender per broadcast instance, which CRDTs or gossip do not provide.]
This set may also contain values broadcast by faulty processes.
The fundamental property of reliable broadcasting is that no two correct processes deliver different sets of values @CGR11 @R18, despite the potential failure of the sender or other processes in the system (hence _reliable_).
#ta[In other words, RB ensures an _all-or-nothing_ delivery: either all correct processes eventually deliver the same value, or no one does.]
// However, compared to , where the value is sent only once by the sender to all recipients, RB is said to be _reliable_ because it can function despite process failures, even on the sender.
// #footnote[
//   However, reliable broadcast is typically implemented using unreliable broadcast primitives, as we shall see in this thesis.
// ]
The multi-sender generalization of reliable broadcast allows all processes to be senders, but each broadcast instance by some process runs "in isolation" (it does not have side effects with broadcasts from other processes).
In RB, values are _rb-broadcast_ and _rb-delivered_.

// Depending on the abstraction, values are said to be  _mbrb-broadcast_ and _mbrb-delivered_ (for the MBRB abstraction, see @sec:mbrb), or _$kl$-cast_ and _$kl$-delivered_ (for the $kl$-cast abstraction, see @sec:k2lcast).

#paragraph[Byzantine reliable broadcast (BRB)]
Designing a reliable broadcast algorithm that tolerates any number of crashes is quite simple: the sender sends her value to everyone, and every receiver forwards this value to everyone (in case the sender crashed in the middle of the execution).
However, by contrast, implementing reliable broadcast in the presence of Byzantine failures is far from trivial, because Byzantine processes may, for instance, dissemble and send or forward contradicting values to different recipients.
Such an algorithm is called _Byzantine reliable broadcast_ (_BRB_), and we say that a process _brb-broadcasts_ and _brb-delivers_ values.
The most famous BRB algorithm is due to Bracha @B87 (1987), and assumes that the system comprises at least two times more correct processes than Byzantine ones (which is optimal in terms of Byzantine fault tolerance~@R18).
// it typically requires the use of _quorums_, #ie critical masses of messages voting for the same value to ensure that this value is legitimate

#paragraph[Comparison with consensus]
As we can observe, Byzantine reliable broadcast (BRB) is a _one-to-many_ primitive (one sender brb-broadcasts, everyone brb-delivers), while consensus is a _many-to-many_ primitive (everyone proposes, everyone decides).
As explained previously, BRB can be naturally generalized to a multi-sender setting.
However, unlike in consensus, two values brb-broadcast by two distinct processes are not in competition with each other: each BRB instance runs "in isolation," whereas in consensus, the decision of some value prevents the decision of values proposed by other processes.
This sole difference allows BRB to be implemented in asynchronous and fault-prone environments @B87.
In contrast, consensus cannot be achieved in the same setting due to the FLP impossibility (see @sec:consensus).

On the flip side, BRB is weaker than consensus: all problems solved by BRB can also be solved by consensus, but the reverse is not true.
For instance, consensus can solve the leader election problem, but BRB cannot.
However, BRB still has many interesting and useful applications, such as _money transfer_.

#paragraph[Example of application: money transfer] <sec:app-money-transfer>
As hinted at at the end of @sec:consensus, consensus or, equivalently, total order of transactions are unnecessary when constructing decentralized electronic payment systems.
Intuitively, we can understand this fact by observing that real-world bookkeeping never attempted to record all the world's transactions, let alone order them: two unrelated transactions do not need to be ordered relative to each other.
The fact that consensus is not necessary to implement money transfer was stated one of the first times in~@G16, and then proven in~@GKMPS22.
More formally, the only condition required to prevent double-spending in a payment system is for the processes to agree on the order in which transactions are issued from each individual account: if some account issues two conflicting transactions spending the same funds, the rest of the network, and especially the corresponding creditors, have to settle on which transaction (if any) is correct.
This relaxed, per-account transfer ordering can be obtained by communication primitives weaker than consensus, such as BRB.
#footnote[
  This is only the case for money transfer systems where each account is owned by a single process.
  In systems where accounts can have multiple owners, consensus can be required between the processes owning a given account.
]

Following the seminal result of @GKMPS22, multiple concomitant papers have presented money transfer systems based on BRB @AFRT20 @BDS20 @CGKKMPPSTX20.
The first paper @AFRT20 is more theoretical: it presents the first concurrent specification of money transfer, an algorithm, and its correctness proof.
Surprisingly, it also shows that money transfer is a weaker problem than implementing read/write registers.
The other two papers introduced _Astro_ @CGKKMPPSTX20 and _FastPay_ @BDS20, two practical implementations of money transfer, along with performance benchmarks.
These two broadcast-based systems claim Visa-level scalability regarding transaction throughput and latency.
Astro was later extended to open environments into the Pastro (permissionless Astro) system~@KPPT23, and FastPay was also extended to provide confidential and untraceable transfers into the Zef system~@BSKD23.

This line of work demonstrates that BRB-based systems can provide correctness, resilience, scalability, and privacy guarantees on par with (and sometimes greater than) their consensus-based counterparts.

// === Eventual agreement

// CRDT, Claudia Ignat

// === Hierarchy of agreements

// The variants of the agreement problem we reviewed in this section can be classified in the following hierarchy: Consensus $>$ Reliable Broadcast $>$ Eventual Agreement.
// In this hierarchy, a stronger agreement can be used to implement a weaker one, but the reverse is not necessarily true.
// Indeed, compared to Eventual Agreement, 
// #TA[Not really true I think, CRDT could be used to implement send/receive then implement RB]

== Thesis

Having introduced the different facets of the agreement problem, we are now able to formulate the central thesis of this work, which focuses on the efficient resolution of reliable broadcast in environments subject to hybrid failures.
In this manuscript, we will therefore rely on the following assumption:

// This dissertation will concentrate on asynchronous distributed systems with hybrid fault models, involving process and network failures.
// Hence, it will build upon the following assumption.

- *Assumption* \ _Hybrid fault models that combine Byzantine faults with a network-level message adversary, can accurately represent real-world conditions of large-scale asynchronous distributed systems._

// #FT[Maybe qualify which hybrid models you are referring to, as this is otherwise very generic, e.g "that combine Byzantine process faults with a network-level message adversary"]

In this setting, the present dissertation mainly focuses on the case of reliable broadcast.
Indeed, while significant progress has been made in understanding and implementing reliable broadcast in various contexts, there remain open questions and opportunities for improvement, particularly in systems subject to hybrid failures.
This work aims to address these gaps and advance the state of the art in reliable broadcast implementations.
Therefore, this dissertation will defend the following thesis.

- *Thesis* \ _Interesting problems, such as reliable broadcast, can be efficiently implemented in asynchronous environments prone to hybrid process-and-network failures._

#paragraph[Contributions]
To support this thesis, the dissertation presents the following contributions.

+ _A new distributed system model capturing hybrid failures._
  This model allows for a more faithful representation of complex failures in real systems, paving the way for more robust algorithms.
  Specifically, in a system of $n$ processes, this model combines at most $t$ Byzantine process failures with a message adversary that can delete $d$ messages sent by any process during a communication step on the network.
  The message adversary is defined independently of any synchrony assumption or any specific structure of the algorithm.
  As a result, this fault model naturally applies to any algorithm executing on an asynchronous message-passing system.
  // Specifically, this model describes an asynchronous message-passing system of $n$ processes, among which at most $t$ can be Byzantine.
  // Additionally, a message adversary has the power to delete at most $d$ messages sent by any process during a communication step on the network.

+ _A new formal definition of reliable broadcast (MBRB)._
  Using the previous hybrid model, this thesis defines a new abstraction called _Message-Adversary Byzantine Reliable Broadcast (MBRB)_, that generalizes simple Byzantine reliable broadcast (BRB) and allows addressing broader failure scenarios, particularly those involving mobile faults that can cause message losses.
  Specifically, MBRB explicitly imposes a lower bound (noted $lmbrb$ and called "_delivery power_") on the number of correct processes that must deliver individual broadcast values.
  This is because, unlike with BRB, it is no longer possible to guarantee that all processes deliver the broadcast value in the presence of a message adversary, as the latter can completely isolate at most $d$ correct processes from the network.

+ _An optimality theorem for MBRB._
  We demonstrate that, within the theoretical framework we have defined, MBRB can be implemented if and only if the condition $n>3t+2d$ is respected.
  Intuitively, this bound combines the condition $n>3t$, necessary and sufficient to solve agreement problems in asynchronous contexts subject to Byzantine failures, with the condition $n>2d$, which prevents the presence of network partitioning.
  This theoretical result establishes fundamental limits and guides the design of optimal algorithms.

+ _A simple and optimal implementation of MBRB._
  Building on the previous insights, we propose a novel algorithm based on digital signatures, that simply demonstrates the practical feasibility of MBRB, with maximum resilience and delivery power.
  Indeed, this algorithm only assumes the optimal resilience bound $n>3t+2d$, and its delivery power is $lmbrb=c-d$, where $c$ is the actual number of correct processes in the system ($n-t <= c <= n$).

+ _The $k2l$-cast abstraction._
  Although the previous algorithm provides an implementation of MBRB with optimal resilience and delivery power, it requires signatures, which in practice are only guaranteed to hold with a given probability.
  In order to explore how MBRB can be implemented without such an assumption, we introduce a novel many-to-many abstraction termed $k2l$-cast, which ensures that if a critical mass of $k$ correct processes broadcast the same value, then at least $ell$ correct processes will eventually deliver the value.
  Thus, $k2l$-cast captures a quorum construction mechanism omnipresent in the design of distributed algorithms.
  Particularly, we demonstrate that $k2l$-cast facilitates the construction of signature-free MBRB algorithms by transforming classic signature-free BRB algorithms, such as Bracha's or Imbs-Raynal's, making them not only tolerant to hybrid failures but also faster in execution.
  This allows us to broaden the applicability of our work to systems without cryptography.

+ _An implementation of MBRB using erasure coding._
  In a final contribution, we revisit the signature-based implementation of MBRB from a communication complexity perspective.
  Although our first signature-based MBRB algorithm provides optimal fault resilience and delivery power, it exhibits a high communication cost.
  By contrast, our new enhanced algorithm, called Coded MBRB, achieves near-optimal communication complexity using erasure coding techniques, threshold signatures, and vector commitments.
  Indeed, Coded MBRB has a communication cost of $O(|v|+n secp)$ bits sent per correct process, where $|v|$ is the size of the broadcast value, and $secp$ is the security parameter of the cryptographic primitives.
  This makes Coded MBRB optimal up to $secp$, given that the lower communication bound is $Omega(|v|+n)$ bits sent per correct process.
  In summary, Coded MBRB is a more efficient algorithm for deployments on large-scale systems where bandwidth is a precious resource, such as blockchain systems or replicated databases.

== Organization

The rest of this manuscript is organized as follows.

- @sec:background presents the state of the art, positioning our work in the current scientific landscape.
// presents the state of the art on hybrid failure models and the reliable broadcast problem.

- @sec:model-and-mbrb defines our hybrid system model and the MBRB problem, laying the theoretical foundations for our contributions.
// defines a new hybrid system model, which will be the foundation of all algorithms and results presented in this thesis.
// This section also defines the MBRB problem and proves a tightness theorem on the resilience bound of MBRB in asynchronous systems.

- @sec:sig-mbrb presents our simple implementation of MBRB, demonstrating its practical feasibility.
// introduces a simple signature-based MBRB implementation that provides optimal hybrid fault resilience.

- @sec:k2l-cast showcases $k2l$-cast, expanding the scope of our results to signature-free systems.
// showcases the $k2l$-cast abstraction, a new object useful for enhancing quorum engineering in distributed systems, particularly for building signature-free MBRB implementations.

- @sec:coded-mbrb optimizes our approach, making MBRB more communication-efficient for large-scale deployments.
// presents a coding-based MBRB implementation that provides the near-optimal communication complexity for this family of algorithms.

- Finally, @sec:conclusion synthesizes our findings and opens perspectives for future research.
// discusses the contributions of this work and potential future research directions.

- For the sake of presentation, some developments appear in @sec:circumvent-flp[Appendices]-@sec:coded-mbrb-correctness-proof[], such as additional details on the consensus problem and correctness proofs.


