#import "../setup.typ": *

= Conclusion <sec:conclusion>

#v(2em)

#epigraph(
  [Those are my principles, and if you don't like them... well, I have others!],
  [Groucho Marx]
)

#v(2em)

// Distributed systems designers aim to build trusted architectures despite the many sources of uncertainty posed by the environment's distributed nature.
// These uncertainties can, for instance, stem from the concurrency and contention among the system's participants, the communication delays, or the system failures.
// In particular, we distinguish two kinds of failures in the system: process faults (#eg crashes or Byzantines), which relate to the system participants, and network faults (#eg message adversaries), which relate to the underlying message-passing communication network.

// This thesis explored how to design reliable building blocks that can tolerate such adversarial settings, and that can then be used to construct more complex distributed applications.
// In particular, this thesis studied the problem of implementing Reliable Broadcast in such adversarial settings.
// Reliable Broadcast is a fundamental distributed problem motivated by many industrial applications.

This thesis has explored the realm of fault-tolerant distributed systems, focusing on the implementation of reliable broadcast in asynchronous environments prone to hybrid failures.
This work has been motivated by the increasing prevalence of large-scale distributed systems and the need for robust communication primitives that can withstand both process and network failures.
The main contributions of this dissertation span theoretical modeling, algorithm design, and performance optimization in the context of _Message-Adversary-tolerant Byzantine Reliable Broadcast_ (_MBRB_).
In the following, we review the contributions of this thesis and their implications in the field of fault-tolerant distributed systems (@sec:contribs-summary), and we then deliberate upon the novel research issues raised by our findings (@sec:future-work).

== Summary of contributions <sec:contribs-summary>

#paragraph[A new computing model and distributed problem: MBRB]
Our first contribution laid the groundwork for the entire thesis by introducing a novel computing model for designing distributed systems.
This model defines an asynchronous message-passing network of $n$ processes, where up to $t$ processes may exhibit Byzantine behavior, and a message adversary (MA) can remove up to $d$ copies of a message disseminated by a correct process.
Moreover, the parameter $c$ denotes the effective number of correct (#ie non-faulty) processes in the system.
By allowing Byzantine processes to collude with the MA, we created a hybrid fault model that captures a wider range of failure scenarios than traditional models.

Building on this model, we introduced the MBRB abstraction, which generalizes the standard definition of Byzantine Reliable Broadcast (BRB) to accommodate hybrid failures.
Particularly, MBRB accounts for the fact that, in the presence of an MA, it is impossible to guarantee that all correct processes of the system deliver every broadcast value.
To consider this array of adversarial behaviors, MBRB introduces a new parameter $lmbrb$, denoting the minimum number of correct processes that deliver the value broadcast during each MBRB execution.
One can observe that the best possible value for $lmbrb$ is $c-d$, as the MA can always completely input-disconnect at most $d$ correct processes in the system.
We can also remark that, when $lmbrb=c$ (which can only be achieved when $d=0$, #ie when there is no MA), MBRB boils down to the traditional definition of BRB.

A key theoretical result of our work is the optimality theorem for asynchronous MBRB, which states that implementation is possible if and only if $n > 3t + 2d$.
This condition establishes clear boundaries for what is achievable in terms of fault tolerance in this family of distributed systems, and serves as a guideline for designing robust distributed algorithms.
Besides laying essential theoretical foundations, this result also provides a practical benchmark against which future solutions can be measured.

#paragraph[A simple signature-based MBRB implementation]
Our second contribution presented a concrete implementation of MBRB using cryptographic signatures.
This algorithm achieves optimal Byzantine resilience and number of communication rounds when there is no message adversary.
// , and maintains these properties under certain thresholds of adversarial power
// #FT[Maybe revise in light of our discussion for 2-round delivery].
The algorithm's reliance on the condition $n > 3t + 2d$ aligns with our theoretical optimality theorem, demonstrating a tight connection between theory and practice.
Furthermore, to show the algorithm's practicality, we have comprehensively studied its time, message, and communication costs.
This supports the idea that our solution can efficiently operate under the challenging conditions of real-world networks.

#paragraph[$bold(k2l)$-cast: a modular approach to construct signature-free MBRB algorithms]
The third contribution of this thesis addressed the challenge of implementing MBRB in a cryptography-free context.
We introduced a novel communication primitive called $k2l$-cast, which enables more efficient quorum engineering.
// This abstraction not only enhances existing signature-free reliable broadcast algorithms (such as Bracha's @B87 and Imbs-Raynal's @IR16) to withstand a broader range of adversarial behaviors but also improves their efficiency.
This abstraction makes it possible to reconstruct existing signature-free reliable broadcast algorithms (such as Bracha's @B87 and Imbs-Raynal's @IR16), to make them tolerant against Byzantine failures and message losses, therefore yielding working MBRB implementations that do not rely on digital signatures.
Interestingly, when there is no message adversary, the reconstructed MBRB algorithms are also more efficient than the original counterparts, as they use smaller quorums and thus need fewer messages to progress.
However, the trade-off for these signature-free MBRB implementations is that they are sub-optimal in terms of delivery power and resilience against Byzantine faults and message adversaries.

// #FT[Maybe mention you've presented a signature-free implementation of k2l cast used it to reconstruct Bracha and IB's BRB algorithm, yielding working MBRB implementations that do not rely on signatures. These implementations are not however optimal either in delivery power or Byzantine resilience.]

Our work on $k2l$-cast opens up new possibilities for designing hybrid-fault-tolerant systems without relying on cryptographic primitives.
This is particularly valuable in scenarios where computational resources are limited or where the use of cryptography is undesirable due to regulatory or performance constraints.
Moreover, the potential applications of $k2l$-cast extend beyond reliable broadcast only, with possible benefits for self-stabilizing and self-healing distributed systems.

#paragraph[A coding-based MBRB implementation with near-optimal communication]
Our final contribution focused on optimizing the communication cost of MBRB.
We introduced the Coded MBRB algorithm that achieves near-optimal communication complexity while preserving an optimal resilience of $n>3t+2d$.
More specifically, when the sender is correct, Coded MBRB features a communication cost of $O(|v|+n secp)$ bits sent per correct process, where $|v|$ is the size of the broadcast value, and $secp$ is the security parameter of the underlying cryptographic primitives.
This significantly improves upon the original signature-based MBRB algorithm (presented previously) which possesses a communication complexity of $O(n|v|+n^2secp)$ bits sent per correct process.
Importantly, Coded MBRB nearly reaches the theoretical lower bound of $Omega(|v|+n)$ bits communication by each correct process, as our solution exhibits only one additional factor $secp$ in its asymptote.
In addition, Coded MBRB maintains a high delivery power of $lmbrb=c-(1+epsilon)d$, where $epsilon$ is a tunable parameter that can be made arbitrarily close to 0.

Coded MBRB offers these high-performance guarantees by leveraging several tools and concepts inspired by the coding and cryptography literature, namely error-correcting codes (ECC), threshold signatures, and vector commitments.
This combination of techniques yields an MBRB algorithm that strikes a balance between theoretical guarantees and practical efficiency, making it suitable for real-world deployment.
This algorithm represents a significant advancement in Byzantine Reliable Broadcast under a Message Adversary (MBRB), demonstrating that it is possible to achieve near-optimal communication complexity without sacrificing resilience.
This contribution is especially significant for distributed systems where bandwidth is a precious resource.
// offering a practical solution to the MBRB problem that 

== Future directions <sec:future-work>
// The contributions of this thesis have several important implications for the field of distributed systems.
// While our work has made significant strides#FT[A bit too self-promoting :-) Let the reader judge how significant your contributions are, e.g. "While we hope our work will prove to be of interest to the wider research community, it also ..."] in the field of fault-tolerant distributed systems, it also opens up several avenues for future research.
While we hope our work will prove to be of interest to the wider research community, it also opens up several avenues for future research.
The following section discusses several promising axes of research that warrant additional scrutiny.
// #FT[All what follows is relevant, but a bit too concise. Can you expand on each point? Reference works that might are related/might offer interesting angles of attack?]
// #FT[At the movement the list is a bit flat. Can you group items together? (E.g. short-term, medium-term, long-term, or some other valid grouping)? In particular I'd separate implications and future work.]
// #TA[TO FINISH]

#paragraph[Enhancing the efficiency and resilience of our algorithms]
While we have shown the good theoretical guarantees of our proposed algorithms regarding performance and fault-tolerance, there is still potential to optimize them further.

For instance, the $k2l$-cast primitive of @sec:k2l-cast demonstrates that signature-free MBRB is feasible, but the resulting implementations exhibit sub-optimal resilience and delivery power.
Investigating whether these metrics could be optimized while staying in a cryptography-free context demands further exploration.

Moreover, the signature-based $k2l$-cast implementation presented in @sec:sb-k2lcast suffers from a prohibitive message cost of $O(n^2)$ messages sent per correct process $p_i$ during an execution, as $p_i$ broadcasts its set of known signatures every time it receives a new signature.
This results in an overall cubic message complexity of $O(n^3)$, which also inevitably affects the bit-communication complexity of the algorithm.
Decreasing this message complexity could be done by integrating a more refined mechanism for forwarding signatures in the algorithm.
// #FT[Such as TS]

// *Optimizing $k2l$-cast:* While we have demonstrated the utility of $k2l$-cast for reliable broadcast, there is potential to optimize this primitive further and explore its applications in other distributed algorithms and systems.

Another intriguing question raised by our work is whether it is possible to devise an MBRB algorithm that offers _optimal_ communication cost of $bcc=O(n|v|+n^2)$ (unlike Coded MBRB, which is only _near-optimal_ as it has an additional $secp$ factor in its asymptote) while maintaining _optimal_ delivery power of $lmbrb=c-d$ (#ie without the $epsilon$ parameter of the Coded MBRB algorithm).
Such a solution could possibly be attained by leveraging randomization or error-freedom techniques~@ADDRVXZ22.

#paragraph[Experimental evaluations and practical applications]
While our algorithms are designed with practicality in mind, future work should focus on implementing these solutions in real-world systems and conducting comprehensive performance evaluations under various network conditions.
In particular, we have started prototyping some of our algorithms in the Rust programming language and performing preliminary latency measurements on them in an experimental setting. 

To further illustrate the usability of our solutions, we can also delve into their potential applications in other distributed algorithms and systems.
Given the relevance of reliable broadcast to decentralized payment systems~@AFRT20 @BDS20 @CGKKMPPSTX20 @GKMPS22, exploring how our MBRB solutions could be applied to improve the scalability and resilience of cryptocurrencies and blockchain platforms is a promising direction.

Additionally, our conjecture about the potential benefits of $k2l$-cast for self-stabilizing and self-healing systems (@sec:k2lcast-conclusion) warrants further investigation.
Developing concrete algorithms in this domain could lead to more robust and adaptive distributed systems.
// #TA[Talk about DMT?]#FT[I'd say yes.]

#paragraph[Developing the theory of hybrid fault models]
Our current computing model considers an asynchronous message-passing system prone to Byzantine faults and message losses caused by a Message Adversary (see @sec:model).
Future work could focus on exploring the computability limits of this model and how to enrich it with additional types of failures, synchrony assumptions, and interactions between processes to increase its expressiveness.
// to overcome said limits

For instance, message corruption or spurious message creation could also be considered in an extended version of our model.
From an initial examination, it seems that an asynchronous model where the Message Adversary can arbitrarily corrupt some messages broadcast by correct processes might be overly restrictive, as the asynchrony can delay non-altered messages, so that altered and Byzantine messages are received first by correct processes.
// #FT[might be overly restrictive/might grant too much power to the adversary]
As any correct process may appear Byzantine to other correct processes, existing algorithms would require significant changes to thwart these message corruptions caused by the adversary.
On the process fault side, if we want our solutions to be applicable to open large-scale peer-to-peer systems, we have to take into account Sybil attacks~@D02, where the attacker creates many fake identities to surpass the prescribed maximum number of Byzantine processes tolerated in the system.
Common strategies to attain Sybil-resistance rely on a scarce resource that the adversary cannot control in too large quantities, such as computing power (in the case of _Proof-of-Work_~@N08) or cryptocurrency (in the case of _Proof-of-Stake_~@GHMVZ17).

Our current solutions are primarily asynchronous and deterministic.
Investigating whether (partial) synchrony or randomization could help to circumvent our model's impossibilities or improve our algorithms' efficiency and resilience is an interesting lead.

// algorithms for MBRB could potentially lead to improved efficiency or resilience under certain conditions.

// explore additional types of failures or more nuanced adversarial behaviors to capture an even wider range of real-world scenarios.
  
// + *Impossibility results:* Further theoretical work could focus on identifying impossible problems in the context of hybrid fault models.

While this thesis has concentrated on distributed _message-passing_ systems, it is worthwhile to consider whether our findings can be extended to the other principal paradigm of distributed computing: _shared memory_.
It is a known fact that a distributed memory can be emulated on top of a message-passing system~@ABD95.
In particular, reliable broadcast enables the construction of a memory where each process of the system has its dedicated _single-writer multi-reader_ register.
To do that, all processes maintain their local view of the entire memory, in which they can immediately read the value of any register.
To write a value in its own register, a process $p_i$ simply has to reliably broadcast this value to the system, and upon its delivery, every receiving process directly updates $p_i$'s register in its local view.

This begs a natural question: Can MBRB, which generalizes reliable broadcast to hybrid failures, implement a distributed memory tolerant to both Byzantine faults and a Message Adversary?
As the Message Adversary can hamper the delivery of messages, it appears that the classical guarantees of shared registers (#eg every written value can eventually be read) have to be relaxed.
The thorough study of the consistency levels and possible constructions that can be achieved in this hybrid-fault-tolerant distributed memory constitutes a promising line of work.
// This research direction could potentially lead to new paradigms for building resilient distributed storage systems, with applications ranging from cloud computing to decentralized databases.
  
== Final words

In conclusion, this thesis has made several strides in the field of fault-tolerant distributed systems by introducing new models, abstractions, and algorithms for reliable broadcast in the presence of hybrid failures.
Our work bridges the gap between theoretical bounds and practical implementations, thus aiming to provide a solid foundation for building more resilient and efficient distributed systems.
This increased resilience is essential for applications in critical infrastructure, financial systems, and other domains where robustness is paramount.
Indeed, as the scale and complexity of distributed systems continue to grow, the need for communication solutions that can withstand diverse failure scenarios becomes increasingly crucial.
We believe that the concepts and techniques presented in this thesis can play a role in shaping the next generation of fault-tolerant distributed systems, enabling more reliable, scalable, and secure applications.

// offering a practical solution for robust communication in challenging network 


