#import "../setup.typ": *

= A Theoretical Framework \ for Hybrid Fault Tolerance <sec:model-and-mbrb>
// MBRB: Message-Adversary-Tolerant Byzantine Reliable Broadcast
// A Theoretical Framework for Hybrid Fault Tolerance
// A New Fault Model and Distributed Problem: MBRB #TA[Not fan of this title]

#v(2em)

// #epigraph(
//   [Do not quench your inspiration and your imagination; do not become the slave of your model.],
//   [Vincent Van Gogh]
// )

#epigraph(
  [The single biggest problem in communication is the illusion that it has taken place.],
  [George Bernard Shaw]
)

#v(2em)

The increasing complexity and scale of modern distributed systems have exposed limitations in traditional fault models, particularly when dealing with hybrid failures that affect both processes and network communications.
This chapter introduces a novel computing model that addresses these challenges by combining Byzantine process failures with a message adversary in an asynchronous setting.

We begin by presenting the details of this new hybrid fault model (@sec:model), which will serve as the foundation for all subsequent algorithms and analyses in this thesis.
This model assumes an asynchronous distributed system of $n$ processes, out of which at most $t$ may be Byzantine, and where a message adversary (MA) may remove up to $d$ copies of a message broadcast by a correct process.
This represents a particularly challenging environment, as the MA may target different correct processes every time the network is used, or focus indefinitely on the same (correct) victims.
Further, the Byzantine processes may collude with the MA for maximal impact.

Building on this model, we introduce the _Message-Adversary-tolerant Byzantine Reliable Broadcast_ (_MBRB_) abstraction (@sec:mbrb), a powerful primitive that extends traditional reliable broadcast to environments prone to both Byzantine and network failures.
Finally, we establish fundamental bounds on the implementability of MBRB in asynchronous systems (@sec:nec-cond-mbrb), providing crucial insights into the limits and possibilities of fault-tolerant communication in challenging distributed environments.

By developing this comprehensive theoretical framework, we aim not only to advance our understanding of fault-tolerant distributed systems, but also to pave the way for more resilient algorithms capable of operating in increasingly complex and unpredictable network conditions.

@tab:chap3-notations summarizes the acronyms and notations used in this chapter.

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
    $p_i$, [process of the system with identity $i$],
    $lmbrb$, [minimal number of correct processes that mbrb-deliver a value],
    $rtc$, [time complexity of MBRB],
    $omc$, [message complexity of MBRB],
    $bcc$, [communication complexity of MBRB \ (number of bits sent during the execution overall)]
  ),
  caption: [Acronyms and notations used in @sec:model-and-mbrb]
) <tab:chap3-notations>

== A common computing model <sec:model>

In this section, we introduce a new hybrid system model capturing Byzantine and link faults, that will be the common theoretical framework for the rest of this thesis.
This model explicitly considers the disconnection of correct processes and applies to any message-passing algorithm, whether it uses rounds or not.
#footnote[
  In Schmid and Fetzer's model @SF03, rounds are essential to defining _receive_ link failures.
]
(In particular, no algorithm presented in this thesis uses explicit rounds.)

Our motivation for this novel hybrid fault model originated from our research on the reconciliation of local process states in distributed Byzantine-tolerant money transfer systems (a.k.a. cryptocurrencies), in which processes become temporarily disconnected.
As in the model of Schmid and Fetzer @SF03 (see @sec:sota-hybrid), our model combines two types of adversary in an asynchronous network: some processes may be _Byzantine_, but in addition, a _message adversary_ may also remove network messages between correct processes.
#footnote[
  Schmid and Fetzer's model also encompasses arbitrary link failures, which may corrupt messages.
]
However, contrary to Schmid and Fetzer's approach, we do not limit the number of receive link failures.
As a consequence, our model allows correct processes to become disconnected for arbitrarily long periods of time.
This design also allows us to eschew the notion of rounds entirely in the definition of our fault model.

#paragraph[Process model]
The following process model largely follows that of the standard system model, presented in @sec:sota-model.
The system comprises $n>1$ asynchronous sequential processes denoted $p_1$, ..., $p_n$.
Out of these $n$ processes, up to $t$ can be Byzantine @LSP82 @PSL80.
For a more fine-grained analysis, we also consider $c$, the effective number of correct processes in the system for one run of the system, such that $n-t <= c <= n$.
The number $c$ is unknown to participants.

#paragraph[Communication model ($comm$ and $broadcast$ operations)]
As in the standard model (@sec:sota-model), processes communicate through a fully connected asynchronous point-to-point communication network.
Although this network is assumed to be reliable---in the sense that it neither corrupts, duplicates, nor creates messages---it may nevertheless lose messages due to the actions of a message adversary (defined below).

Correct processes communicate by using the transmission macro $comm(m_1,dots,m_n)$, that sends message $m_j$ to~$p_j$ for every $j in [1..n]$.
The message~$m_j$ can also be empty, in which case nothing will be sent to~$p_j$.
Therefore, let us note that the $comm(dot)$ primitive can simulate any kind of multicast communication between processes of the system (whether it be unicast or broadcast, for different messages or for the same message).
For simplicity, processes also have access to a $broadcast$ operation, which is a shorthand for $broadcast m=comm(m,m,dots,m)$, and which simply sends the same message $m$ to all processes.
Byzantine processes may deviate arbitrarily from the correct implementation of $comm(dot)$.
For instance, they may unicast messages to only a subset of processes.

// This entity can remove messages from the communication channels used by correct nodes when they invoke~$comm$. 
// More precisely, during each call of $comm(m_1,dots,m_n)$, the adversary has the discretion to choose up to $d$ messages from the set~${m_i}$ and eliminate them from the corresponding communication channels where they were queued.
// We assume that the adversary has full knowledge of the contents of all messages~${m_i}$, and thus it makes a worst-case decision as to which messages to eliminate.

// Correct processes communicate by sending messages $msgm(v)$ through a #broadcast $msgm(v)$ instruction, which is a macro-command for "*for all* $i in {1,dots,n}$ *do* $send$ $msgm(v)$ *to* $p_j$ *end for*".

#paragraph[Message adversary]
Let $d$ be an integer such that $0 <= d < c$.
An adversary controls, to some extent, the communication network and eliminates messages sent by processes.
More precisely, when a correct process invokes $comm(m_1,dots,m_n)$, the message adversary has the discretion to choose up to $d$ messages of the set ${m_1,...,m_n}$ and eliminate them from the corresponding communication channels where they were queued.
#footnote[
  #ta[
  Let us note that, for uniformity, our definition allows the message adversary to suppress a message sent by a process to itself.
  In practice, messages sent to oneself are not subject to network interference, but interestingly, this assumption does not impact the analyses presented in this thesis.
  ]
]
// $broadcast$ $msgm(v)$, the message adversary can arbitrarily suppress up to $d$ copies of message $msgm(v)$ intended to correct processes
// #footnote[
//   Note that this message adversary is not limited to algorithms that use the $broadcast$ macro-operation.
//   The same adversary can be equivalently defined for an operation $sans("multicast")$ that sends a message to a dynamically defined subset of processes (be it multiple recipients or only one in the case of unicast), by stipulating that the MA can still suppress up to $d$ copies of this message.
//   In this case, the most robust way for correct processes to disseminate a message is to send it to all processes, #ie to fall back on a $broadcast$ operation.
// ].
This means that, despite the sender being correct, up to $d$ correct processes may miss their intended message $m_j$.
#footnote[
  A close but different notion was introduced by Dolev in @D82 (and explored in subsequent works, such as~@BDFRT21), which considers static $kappa$-connected networks.
  If the adversary selects statically for each correct sender $d$ correct processes that do not receive this sender's messages, the proposed model includes Dolev's model with $kappa=n-d$.
]
#ta[We call $d$ the _power_ of the message adversary.]
Let us remark that, given that the $broadcast$ $m$ macro-operation is defined using the $comm(dot)$ primitive, it is also subject to the action of the MA: when a correct process invokes $broadcast$ $m$, the MA can arbitrarily suppress up to $d$ copies of message $m$.

For example, consider a set $D$ of correct processes, where $1 <= |D| <= d$, such that during some period of time, the MA suppresses all the messages sent to them.
It follows that, during this period of time, this set of processes appears as being (unknowingly) input-disconnected from the other correct processes.
Depending on the strategy of the MA, the set $D$ may vary with time, and it is never known by the correct processes.
Let us notice that $d=0$ corresponds to the weakest possible message adversary: it boils down to a classical static system where some processes are Byzantine, but no message is lost (the network is fully reliable).

We remark that this type of message adversary is stronger and, therefore, covers the more specific case of _silent churn_, in which processes may decide to disconnect from the network.
While disconnected, such a process silently pauses its algorithm (a legal behavior in our asynchronous model) and is implicitly moved (by the adversary) to the $D$ adversary-defined set.
Upon returning, the node resumes its execution and is removed from $D$ by the adversary.
#footnote[
  So, the notion of a message adversary implicitly includes the notion of message omission failures.
]

Informally, in a silent churn environment, a correct process may miss messages sent by other processes while disconnected from the network.
The adjective "silent" in _silent churn_ expresses that processes do not send notifications on the network whenever they leave or join the system.
There is no explicit "attendance list" of connected processes, and processes are given no information on their peers' status (connected/disconnected).
In this regard, the silent churn model diverges from the classical approach when designing dynamic distributed systems, in which processes send messages on the network notifying their connection or disconnection @GKKPST20.
The silent churn model is a good representation of real-life large-scale peer-to-peer systems, where peers can leave the network silently (#ie without warning other peers).
#footnote[
  For more insights on this topic, see @KLO10, which presents an in-depth study of distributed computation in dynamic networks.
]

Let us also observe that silent churn allows us to model input-disconnections due to process mobility.
When a process moves from one location to another, the sender's broadcasting range may not be large enough to ensure the moving process remains input-connected.
An even more prosaic example is when a user simply turns off her device or disables its Internet connection, preventing it from receiving or sending any further messages.
In this context, the MA removes all the incoming messages from the corresponding process until the device reconnects.

Let us mention that the loss of messages caused by a message adversary may be addressed using a reliable unicast protocol.
These protocols were originally introduced to provide reliable channels on top of an unreliable network subject to message losses. 
The principle is simple: the sender keeps sending idempotent messages through an unreliable channel until it receives an acknowledgment from the receiver.
This principle notoriously lies at the core of the Transmission Control Protocol (TCP), although with important practical adaptations (TCP uses timeouts to close a malfunctioning or otherwise idle connection, typically after a few minutes).

But because there is no way to detect that a process has crashed or disconnected in an asynchronous environment, an ideal reliable unicast protocol (#ie one that keeps on re-transmitting until success) needs to treat disconnected processes the same way as slow processes or as if there were packet losses in the network: the sender will thus potentially send infinitely many messages to a disconnected receiver.
To overcome this issue, some solutions leverage causal dependencies to avoid resending old messages: if the sender receives an acknowledgment for a given message, it can stop resending the messages that causally precede this message and that have not been acknowledged yet (#eg @DKSS22).
However, this approach still assumes that, eventually, every communication channel lets some messages pass.
However, our fault model does not guarantee this property, as the MA can permanently sever up to $d$ channels per correct process.

== MA-tolerant Byzantine reliable broadcast (MBRB) <sec:mbrb>

Having established our new hybrid fault model, which captures both Byzantine process failures and the actions of a message adversary, we now look into the challenge of reliable communication in such an environment.
The following section introduces the _Message-Adversary-tolerant Byzantine Reliable Broadcast_ (_MBRB_) abstraction, a powerful primitive designed to operate within the constraints of our hybrid fault model.
MBRB extends traditional reliable broadcast concepts to account for the additional complexities introduced by the message adversary, providing a robust foundation for building fault-tolerant distributed applications.
// Building on the previous hybrid system model, we address in this section the problem of fault-tolerant reliable broadcast in asynchronous $n$-process message-passing systems, in which up to $t$ processes are Byzantine, and a message adversary that may prevent up to $d$ non-Byzantine processes from delivering a network message broadcast by a non-Byzantine process.
// In particular, we introduce a new broadcast abstraction called _Message Adversary-Tolerant Byzantine Reliable Broadcast_ (MBRB for short).
Several researchers have indeed pointed out the fundamental role that broadcast abstractions play in Byzantine money transfer systems (for instance, see @AFRT20 @CK21 @CGKKMPPSTX20 @DKSS22 @GKKPST20 @GKMPS19).
This crucial role naturally leads to considering how Byzantine reliable broadcast can be expanded to more volatile and dynamic settings, thus motivating our proposal to combine traditional Byzantine faults with a message adversary.



// enriched with message signatures

#paragraph[MBRB operations]
The MBRB communication abstraction comprises two matching operations, denoted $mbrbbroadcast$ and $mbrbdeliver$.
It considers that each value is associated with an identity $(sn,i)$ (sequence number, sender identity) and assumes that any two values mbrb-broadcast by the same correct process have different sequence numbers.

When, at the application level, a process $p_i$ invokes $mbrbbroadcast(v,sn)$, where $v$ is the value and $sn$ the associated sequence number, we say $p_i$ "mbrb-broadcasts $(v,sn)$".
Similarly, when $p_i$ invokes $mbrbdeliver(v,sn,j)$, where $p_j$ is the sender process, we say $p_i$ "mbr-delivers $(v,sn,j)$".
We say that the values are _mbrb-broadcast_ and _mbrb-delivered_.

#paragraph[MBRB properties]
Because of the message adversary, we cannot always guarantee that a value mbrb-delivered by a correct process is eventually mbrb-delivered by all correct processes.
Hence, in the MBRB specification, we introduce a variable $lmbrb$ which indicates the strength of the primitive's global delivery guarantee: if one correct process mbrb-delivers a value, then $lmbrb$ correct processes eventually mbrb-deliver this value.
#footnote[
  If there is no message adversary (#ie $d = 0$), we should have $lmbrb = c >= n-t$.
]
#ta[We call the variable $lmbrb$ the _delivery power_ of MBRB.]
The MBRB abstraction is defined by the following properties.
- *Safety.*
  - *MBRB-Validity (no spurious message).*
    If a correct process $p_i$ mbrb-delivers a value $v$ from 
    a correct process $p_j$ with sequence number $sn$, then $p_j$ mbrb-broadcast $v$ with sequence number $sn$.
    
  - *MBRB-No-duplication.*
    A correct process $p_i$ mbrb-delivers at most one value 
    $v$ from a process $p_j$ with sequence number $sn$.
  
  - *MBRB-No-duplicity.*
    No two different correct processes mbrb-deliver different 
    values from a process $p_i$ with the same sequence number $sn$.

- *Liveness.*
  - *MBRB-Local-delivery.*
    If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then at least one correct process $p_j$ eventually mbrb-delivers $v$ from $p_i$ with $sn$.
    
  - *MBRB-Global-delivery.*
    If a correct process $p_i$ mbrb-delivers a value $v$ from a process $p_j$ with sequence number $sn$, then at least $lmbrb$ correct processes mbrb-deliver $v$ from
    $p_j$ with sequence number $sn$.

It is implicitly assumed that a correct process does not use the same sequence number twice.
Let us observe that since, at the implementation level, the message adversary can always suppress all the messages sent to a fixed set $D$ of $d$ processes.
It entails that the best-guaranteed value for the delivery power $lmbrb$ (#ie the minimum number of correct processes that mbrb-deliver the value) is $c-d$.
// Furthermore, notice that the constraint $n>2d$ prevents the message adversary from partitioning the system.

#paragraph[Performance metrics]
In addition to the correctness specification, we define three metrics that capture the performance of an MBRB algorithm: the time complexity $rtc$ (in number of communication rounds), the message complexity $omc$, and the (bit-)communication complexity $bcc$ of the algorithm.
These are defined as follows.
- *MBRB-Time-cost.*
  If a correct process $p_i$ mbrb-broadcasts a value $v$ with sequence number $sn$, then $lmbrb$ correct processes mbrb-deliver $v$ from $p_i$ with sequence number $sn$ in at most $rtc$ communication rounds.
  
  As in similar analyses @CR93, a _communication round_ is defined by assuming that the asynchronous algorithm executes in a synchronous model.
  In this model, all processes execute in lock-step synchronous rounds.
  Each synchronous round comprises a computation step followed by a communication step.
  In a computation step, invoked operations (#eg $mbrbbroadcast$) are executed; pending messages (if any) are processed (*when* ... *do* statements); and sent messages are buffered (but not delivered).
  In the subsequent communication step, all buffered messages not suppressed by the message adversary get delivered to their destination.
  These messages are then processed in the computation step of the following synchronous round.
  
- *MBRB-Message-cost.*
  The mbrb-broadcast of a value $v$ by a correct process $p_i$
  entails the sending of at most $omc$ messages by correct processes overall.

- *MBRB-Communication-cost.*
  The mbrb-broadcast of a value $v$ by a correct process $p_i$ entails the sending of at most $bcc$ bits by correct processes overall.

#paragraph[Byzantine Reliable Broadcast (BRB)]
If $lmbrb=c$ (obtained when $d=0$), the previous specification boils down to Bracha's seminal specification @B87, which defines the Byzantine reliable broadcast (BRB) communication abstraction.
Hence, the BRB abstraction is a special case of MBRB.

== A necessary and sufficient condition for MBRB <sec:nec-cond-mbrb>

// #TA[I don't know if I should name this section "A *necessary and sufficient* condition" to make it stronger if I hadn't yet introduced the signature-based MBRB algorithm proving the upper bound (and the tightness).]

With the MBRB abstraction defined, a natural question arises: under what conditions can this primitive be implemented in an asynchronous system subject to our hybrid fault model?
The following section addresses this question by presenting a fundamental theorem on the necessary and sufficient conditions for implementing MBRB (@thm:mbrb-opti), namely: in an asynchronous $n$-process system with at most $t$ Byzantine processes and a message adversary of power $d$, MBRB can be implemented if and only if $n>3t+2d$.
This result not only establishes the boundaries of what is achievable within our model but also provides crucial guidance for the design of optimal MBRB algorithms, which we will explore in subsequent chapters.

#theorem("MBRB-Tightness")[
Considering an asynchronous $n$-process
system in which up to $t$ processes can be Byzantine and where a $d$-message adversary can suppress messages, the condition $n>3t+2d$ is necessary and sufficient for implementing _MBRB_.
] <thm:mbrb-opti>

// #proof[
// @thm:mbrb-necessity has shown that the condition
// $n > 3t+2d$ is necessary, while @alg:sb-mbrb has shown that this condition is sufficient (@theo:sb-mbrb-correctness).
// ]

Intuitively, $n>3t$ comes from the traditional condition for implementing Byzantine fault tolerant consistent broadcast (a weak form of reliable broadcast) in an asynchronous system~@R18, while $n>2d$ imposes that the message adversary cannot partition the network.
Informally, $n>3t+2d$ is simply the conjunction of these two well-known bounds.
This theorem follows from two sub-results, one proving that the $n>3t+2d$ condition is necessary, and the other proving that it is sufficient.

The proof that $n>3t+2d$ is sufficient for implementing MBRB is given by @thm:sb-mbrb-correctness (#pageref(<thm:sb-mbrb-correctness>)) and @thm:coded-mbrb-correctness (#pageref(<thm:coded-mbrb-correctness>)), which respectively show that @alg:sb-mbrb (Original MBRB) and @alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[] (Coded MBRB) implement the MBRB abstraction under this resilience bound.
Consequentially, it also entails that these two MBRB implementations are optimal with respect to their Byzantine- and Message-Adversary resilience.

The proof that $n>3t+2d$ is a necessary condition for implementing MBRB is given by @lem:mbrb-necessity, which states that no _event-driven_ algorithm can implement MBRB in an asynchronous $n$-process system with at most $t$ Byzantine processes and a message adversary of power $d$ if $n <= 3t+2d$.
In this context, _event-driven_ means that the algorithm sends messages only after receiving messages or input from the upper-layer client (@def:evt-driven).
This _event-driven_ characteristic can seem restrictive at first, as it forbids processes from updating their state and sending messages when no message arrives, but we can convince ourselves that this does not decrease the power of the model, since a process cannot gain any knowledge in an asynchronous system until a message arrives @V04.

#definition("Event-driven algorithm")[
  An algorithm implementing a broadcast communication abstraction is _event-driven_ if, as far as the correct processes are concerned, #ta[the sending of a message can only be triggered by] (i) the invocation of the broadcast operation that is provided to the application by the broadcast communication abstraction, or (ii) the reception of a network message (sent by a correct or a Byzantine process).
] <def:evt-driven>

We proceed to show the following impossibility condition for implementing MBRB.
// #ta[Let us remark that, in the following analysis, we implicitly require that the _delivery power_ $lmbrb$ of the MBRB abstraction (#ie the minimum number of correct processes that mbrb-deliver the value) is at least 2, since otherwise, the problem can be trivially solved.]

#lemma("MBRB-Necessary-condition")[
When $n <= 3t+2d$, there is no event-driven (signature-free or signature-based) algorithm implementing the _MBRB_ communication abstraction on top of an $n$-process asynchronous system in which up to $t$ processes may be Byzantine and where a message adversary may suppress up to $d$ copies of each message broadcast by a
correct process.
#footnote[
  Without loss of generality, we consider that processes communicate through the unreliable $broadcast$ operation defined in @sec:model.
  However, let us remark that the following rationale also holds if the underlying communication medium is the generalized $comm$ operation (@sec:model), that can disseminate different messages to different recipients.
]
] <lem:mbrb-necessity>

#proof[
Without loss of generality, the proof considers the case
$n = 3t+2d$.
Let us partition the $n$ processes into five sets $Q_1, Q_2, Q_3$, $D_1$, and $D_2$, such that $|D_1|= |D_2|= d$ and $|Q_1|=|Q_2|=|Q_3|=t$.
#footnote[
  For the case $n < 3t+2d$, the partition is such that $max(|Q_1|,|D_2|) <= d$ and $max(|Q_1|,|Q_2|,|Q_3|) <= t$.
]
So, when considering the sets $Q_1$, $Q_2$, and $Q_3$, there are executions in which all the processes of either $Q_1$ or $Q_2$ or $Q_3$ can be Byzantine, while the processes of the two other sets are not.

#TA[Why did we call the sets $Q$? Also, doesn't the proof implicitly assume that $lmbrb>=2$?]

The proof is by contradiction.
So, assuming that there is an event-driven algorithm $A$ that builds the MBRB abstraction for $n = 3t+2d$, let us consider an execution $E$ of $A$ in which the processes of $Q_1$, $Q_2$, $D_1$, and $D_2$ are not Byzantine while all the processes of $Q_3$ are Byzantine.

#include "fig/mbrb-nec-cond.typ"

Let us observe that the message adversary can isolate up to $d$ processes by preventing them from receiving any message. 
Without loss of generality, let us assume that the adversary #ta[controls the network asynchrony to] isolate a set of $t$ correct processes that does not contain the message sender.
As $A$ is event-driven, these $t$ isolated processes do not send messages during the execution $E$ of $A$.
As a result, no correct process can expect messages from more than $n-t-d$ different processes without risking being blocked forever.
Thanks to the assumption $n=3t+2d$, this translates as "no correct process can expect messages from more than $2t+d$ different processes without risking being blocked forever."

In the execution $E$, the (Byzantine) processes of $Q_3$ simulate the mbrb-broadcast of a value such that this value appears as being mbrb-broadcast by one of them and is mbrb-delivered as the value $v$ to the processes of $Q_1$ (hence the processes of $Q_3$ appear, to the processes of $Q_1$, as if they were correct) and as some other value $v' != v$ to the processes of $Q_2$ (hence, similarly to the previous case, the processes of $Q_3$ appear to the processes of $Q_2$ as if they were correct).
Let us call $v$-messages (resp., $v'$-messages) the messages generated by the event-driven algorithm $A$ that entails the mbrb-delivery of $v$ (resp., $v'$).
Moreover, the execution $E$ is such that we have the following.

- Concerning the $v$-messages: the message adversary suppresses all the $v$-messages sent to the processes of $D_2$, and asynchrony delays the reception of all the $v$-messages sent to $Q_2$ until some time $tau$ defined below.
  #footnote[
    Equivalently, we could also say that asynchrony delays the reception of all the $v$-messages sent to $D_2 union Q_2$ until time $tau$.
    The important point is here that, due to the assumed existence of Algorithm $A$, the processes of $Q_1$ and $D_1$ mbrb-deliver $v$ with $v$-messages from at most $2t+d$ different processes.
  ]
  So, as $|Q_1 union D_1 union Q_3| = n-t-d = 2t+d$, Algorithm A will cause the processes of $Q_1$ and $D_1$ to mbrb-deliver $v$.
  #footnote[
    Let us notice that this is independent of whether the processes in $Q_3$ are Byzantine or not.
  ]
    
- Concerning the $v'$-messages: the message adversary suppresses all the $v'$-messages sent to the processes of $D_1$, and the asynchrony delays the reception of all the $v'$-messages sent to $Q_1$ until time $tau$.
  As previously, as $|Q_2 union D_2 union Q_3| = n-t-d = 2t+d$, Algorithm $A$ will cause the processes of $Q_2$ and $D_2$ to mbrb-deliver $v'$.

- Finally, the time $tau$ occurs after the mbrb-delivery of $v$ by the processes of $D_1$ and $Q_1$, and after the mbrb-delivery of $v'$ by the processes of $D_2$ and $Q_2$.

It follows that different non-Byzantine processes mbrb-deliver different values for the same mbrb-broadcast (or a fraudulent simulation of it) issued by a Byzantine process (with possibly the help of other Byzantine processes).
This contradicts the MBRB-No-Duplicity property, which
concludes the proof of the theorem.
]

== Conclusion

This chapter introduced a comprehensive computing model for addressing hybrid (#ie process- and network-related) failures in distributed systems, that will serve as the theoretical framework for the algorithms and analyses presented in the remainder of this thesis.
This model defines an asynchronous message-passing network of $n$ processes, out of which at most $t$ may be Byzantine, and where a message adversary (MA) may remove $d$ copies of a message disseminated by a correct process.
#ta[Our model goes beyond earlier approaches, by considering hybrid faults under asynchrony while remaining oblivious to the algorithm's underlying structure (in particular, if it uses rounds or not), thus offering greater flexibility and realism.]
// By explicitly considering malicious behaviours and network unreliability, our model offers greater flexibility and realism than previous approaches.
// #FT[Maybe rephrase this sentence: here you want to explain why this contribution is valuable. Just saying that is combines process and link failures falls a bit flat, as earlier models have already done this. You can reuse the same formulation as at the end of chapter 2 to drive the message home: "Contrary to earlier proposals of hybrid fault models, ... " (mention asynchrony and the fact it applies to any algorithm), alternatively "This new hybrid fault model goes beyond earlier proposals as it XXX"]
// As the system failures may target both processes and the network, we call this a _hybrid fault_ model.

Building on this new system model, the chapter then presented a novel hybrid-fault-tolerant reliable broadcast abstraction, called _Message-adversary-tolerant Byzantine reliable broadcast_, or _MBRB_ (@sec:mbrb).
MBRB extends the traditional notion of Byzantine Reliable Broadcast (BRB) to account for the additional complexities introduced by the message adversary.

Finally, the chapter proved an optimality theorem regarding asynchronous MBRB, namely that it can be implemented if and only if we have $n>3t+2d$.
The proof of this condition offers valuable insights into the interplay between Byzantine processes and the message adversary, highlighting the challenges of achieving agreement in such complex environments.
#ta[
This also demonstrates that, compared to BRB, MBRB can tolerate additional link failures, sometimes at no extra cost in Byzantine resiliency.
For example, in a system of $n=6$ processes, a BRB algorithm can tolerate a maximum of $t=1$ Byzantine failure, but an MBRB algorithm can additionally tolerate a message adversary of power $d=1$.
]

In the following chapters, we will leverage this theoretical foundation to present concrete implementations of MBRB, exploring both signature-based (@sec:sig-mbrb) and signature-free (@sec:k2l-cast) approaches, as well as techniques for optimizing communication efficiency (@sec:coded-mbrb).
As our hybrid computing model is particularly aggressive regarding its weak synchrony assumptions and complex failures, these MBRB algorithms are designed to function in very challenging conditions.
// #FT[Very good. You could mention explicitly mention the chapters in which each topic will be discussed.]