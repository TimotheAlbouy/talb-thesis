#import "../setup.typ": *

// = Addendum on Consensus <sec:consensus-addendum>
// == FLP impossibility: an axiomatic proof

= Circumventing the FLP impossibility <sec:circumvent-flp>

In the following, we review some of the most notable solutions to circumvent the FLP impossibility theorem.

Some of these solutions involve adding synchrony assumptions.
In a synchronous setting, consensus can be implemented, not only with one crash, but with any number of Byzantine faults @LSP82#footnote[
  Two algorithms were presented in @LSP82: one that tolerates any number of Byzantines (as long as this number is known by all processes) but requires digital signatures (the "signed messages" model), and the other that tolerates less than one-third of Byzantines in the system but is signature-free (the "oral messages" model).
  This shows that signatures also significantly enrich the underlying computing model.
], demonstrating the sheer difference in computability power between synchrony and asynchrony.
Resilient consensus can also be implemented under partial synchrony, as illustrated by the Paxos @L98 and PBFT @CL99 algorithms.
Failure detectors also belong to this category: processes have access to a (possibly imperfect) oracle that provides information on other processes' failures and allows the system to solve consensus @CHT92.
Failure detectors thus bridge the gap between full asynchrony, where crashes can never be detected, and full synchrony, where they can always be detected.

Randomization is another technique to implement consensus in asynchronous and fault-prone systems @B83 @B87 @MMR14.
For instance, the algorithms presented in @B83 @B87 rely on a random coin tossed by all system processes at each round, and there is a non-null chance that all processes get the same coin value during one round.
These solutions weaken consensus liveness: It is possible to have an execution that never terminates, but the probability becomes asymptotically null as the number of rounds increases.

Another approach involves restricting the occurrence of failures in the system.
For instance, it is not widely known that the original FLP paper also presented an asynchronous consensus algorithm that tolerates less than half of faulty processes, only if all these faults happen at the start of the execution @FLP85.
Another example comes from the shared-memory world: mutual exclusion (which requires the same computability power as consensus) can tolerate process failures as long as they do not happen inside the critical section @L74.

Other solutions circumvent the impossibility either by restricting the set of possible inputs (proposals) or expanding the set of possible outputs (decisions).
An example of the former category is given in @MRR03, where the authors fully characterize the set of favorable input vectors (#ie proposals for each process) for which consensus can be solved.
Conversely, an example of the latter category is approximate agreement @DLPSW86, which relaxes the guarantee of strong agreement of consensus, and permits a small divergence among processes on their decision values.
The smaller we want this divergence to be, the longer it takes for the approximate agreement algorithm to terminate under asynchrony and process faults.

#TA[Talk about quantum consensus]

Another example from this last category is $k$-set agreement @C90, which is a natural generalization of consensus: processes can decide at most $k$ different values out of the proposed ones (so consensus is $1$-set agreement).
Later, it was shown that the FLP impossibility can also be naturally generalized: asynchronous $k$-set agreement cannot be implemented in the presence of $k$ faults @AFGGNW24-1 @HC13 @BRS11 @BG93 @HS99 @SZ00.
Intuitively, this impossibility can be understood in 2 steps: (1) in an asynchronous wait-free system of $n$ processes (#ie where at most $n sm 1$ processes may fail), $(n sm 1)$-set agreement is impossible, as, due to asynchrony, each process must make a decision "in isolation" (#ie without communicating), which can trivially lead to safety violations (more than $n sm 1$ different values decided); and (2) the _BG simulation_ technique generalizes this result from wait-free systems to non-wait-free systems, by showing that adding more non-faulty processes to a system does not increase its computability power @BG93 @R22 @R16-1.