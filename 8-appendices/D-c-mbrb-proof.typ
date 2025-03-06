#import "../setup.typ": *

= Correctness Proof \ of Coded MBRB (@alg:coded-mbrb-helpers[Algorithms]-@alg:coded-mbrb[]) <sec:coded-mbrb-correctness-proof>

In this appendix, we prove that the Coded MBRB algorithm of @sec:coded-mbrb (composed of @alg:coded-mbrb-helpers and @alg:coded-mbrb) satisfies the single sender/single shot version of the MBRB abstraction (defined in @sec:mbrb).
More specifically, we prove the following theorem.

#theorem(number: [@thm:coded-mbrb-correctness[]])[
If #c-mbrb-assum, _@alg:coded-mbrb-helpers[Algorithms]_ _@alg:coded-mbrb[_and_]_ implement MBRB with the guarantee $lmbrb = c-(1+epsilon)d$, where $epsilon > 0$.
]

The safety proofs of Coded MBRB are given in @lem:c-mbrb-validity (MBRB-Validity), @lem:c-mbrb-no-duplication (MBRB-No-duplication), and @lem:c-mbrb-no-duplicity (MBRB-No-duplicity), while the liveness proofs of Coded MBRB are given in @lem:c-mbrb-local-delivery (MBRB-Local-delivery) and @lem:c-mbrb-global-delivery (MBRB-Global-delivery).
Let us recall that the Coded MBRB algorithm relies on the following assumption (the "c" prefix stands for "coded").

#c-mbrb-assumption(numbering: none)[$n>3t+2d$ and $k<= n-t-2d$.]

We begin with a few technical lemmas.

#lemma[
If a correct process $p_u$ saves a value fragment $tilde(v)_j$ associated to a proof of inclusion $pi_j$ for some commitment $C'$ and process identity $j$, then $pi_j$ is valid with respect to~$C'$, that is $vcverify(C',pi_j,tilde(v)_j,j)=ttrue$.
] <lem:save-valid-frags>

#proof[
A correct process saves fragments for a commitment $C'$ at @line:c-mbrb:rcv-send-save[lines], @line:c-mbrb:rcv-forward-save-frag[], @line:c-mbrb:rcv-bundle-save-other[], or @line:c-mbrb:rcv-bundle-save-own[], when receiving $sendm$, $forwardm$, or $bundlem$ messages, respectively.
The fragments saved at these lines and their proof have been received through the corresponding message, whose content is verified by a call to $isValid$ (at @line:c-mbrb:rcv-send-isvalid[lines], @line:c-mbrb:rcv-forward-isvalid[], or @line:c-mbrb:rcv-bundle-isvalid[]).
The $isValid$ function (described in @alg:coded-mbrb-helpers) checks that inclusion proofs are valid for the corresponding commitment.
]

The following notion of _valid messages_ will be used throughout the analysis to indicate messages containing only valid information, as the algorithm dictates.

#definition([Valid messages])[
We say that a message of type $sendm$, $forwardm$, or $bundlem$ is _valid_ if and only if $isValid$ returns $ttrue$ at @line:c-mbrb:rcv-send-isvalid, @line:c-mbrb:rcv-forward-isvalid, or @line:c-mbrb:rcv-bundle-isvalid, respectively, upon the receipt of that message.
] <def:valid-msg>

Operatively, valid messages satisfy the following, which is immediate from the definition of the $isValid$ function (@alg:coded-mbrb-helpers).

#corollary[
To be valid, a message must meet the following criteria: (i) all the signatures shares or threshold signatures it contains must be valid and correspond to the commitment included in the message; (ii) if it is of type $sendm$ or $forwardm$, it must contain a signature by the designated sending process $p_s$; and (iii) all inclusion proofs must be valid with respect to the commitment included in the message.
] <cor:valid-msg-expand>

We now show that the correct parties always send valid messages.
However, they might receive invalid messages sent by Byzantine processes. 

#lemma[
All $sendm$, $forwardm$, or $bundlem$ messages sent by a correct process~$p_u$, are valid.
] <lem:msgs-sent-valid>

#proof[
The only correct process that sends $sendm$ messages is~$p_s$ at @line:c-mbrb:snd-comm.
Indeed, when $p_s$ is correct, this message will contain a valid signature share by~$p_s$ produced at @line:c-mbrb:snd-sign, and one of the valid proofs of inclusion produced at @line:c-mbrb:snd-compute-frag-vc.

Now, consider a $forwardm$ message sent either at @line:c-mbrb:rcv-send-bcast or @line:c-mbrb:rcv-forward-bcast.
To reach there, $p_u$ must have passed @line:c-mbrb:rcv-send-isvalid or @line:c-mbrb:rcv-forward-isvalid, which guarantee that $p_u$ received a valid signature for~$C'$ made by~$p_s$ (where $C'$ is the commitment in the received message triggering this code). 
Then, at @line:c-mbrb:rcv-send-save or at @line:c-mbrb:rcv-forward-save-sigs, $p_u$ saves a signature of~$p_s$ for this~$C'$, and at @line:c-mbrb:rcv-send-sign and @line:c-mbrb:rcv-forward-sign, $p_u$ signs the same~$C'$.
Thus, conditions (i) and (ii) of @cor:valid-msg-expand hold, and if the $forwardm$ is sent at @line:c-mbrb:rcv-forward-bcast, then condition (iii) vacuously holds as well.
If the $forwardm$ message is sent at @line:c-mbrb:rcv-send-bcast, it contains a fragment that was saved by~$p_u$ for the same~$C'$, and by @lem:save-valid-frags, its associated proof of inclusion is valid; thus condition (iii) holds in this case as well.

Finally, consider a $bundlem$ message.
First off, condition~(ii) of @cor:valid-msg-expand does not concern this type of message.
For the transmission at @line:c-mbrb:quorum-comm, condition (i) follows from the construction of the threshold signature $Sigma_C$ at @line:c-mbrb:quorum-get-tsig.
$Sigma_C$ is guaranteed to be non-$bot$ by the condition at @line:c-mbrb:quorum of @alg:coded-mbrb, and is provided by the helper function $getThreshSig(dot)$ (@line:c-mbrb-helpers:get-tsig-ret of @alg:coded-mbrb-helpers).
When executing $getThreshSig(dot)$, the first possibility is that $Sigma_C$ is already known by $p_u$ because it was received by $p_u$ at @line:c-mbrb:rcv-bundle and saved at @line:c-mbrb:rcv-bundle-save-other.
In this case, the validity of $Sigma_C$ is ensured by the check at @line:c-mbrb:rcv-bundle-isvalid.
The second possibility is that $Sigma_C$ aggregates $tau=floor((n+t)/2)+1$ signature shares received by $p_u$ at @line:c-mbrb:rcv-send or @line:c-mbrb:rcv-forward, and saved at @line:c-mbrb:rcv-send-save or @line:c-mbrb:rcv-forward-save-sigs, respectively.
In this case, the validity of all these signature shares is ensured by the checks at @line:c-mbrb:rcv-send-isvalid and @line:c-mbrb:rcv-forward-isvalid, respectively, and thus the aggregated threshold signature $Sigma_C$ is also valid.
Condition (iii) follows since the proofs of inclusion were computed at @line:c-mbrb:quorum-comp-frag-vc by $p_u$ and match the same commitment~$C'$ used in that $bundlem$ message, as enforced by @line:c-mbrb:quorum-cond-diff-vc. 
For the broadcast at @line:c-mbrb:rcv-bundle-bcast, conditions (i) and (iii) follow since the threshold signature $Sigma$ and the fragment tuple $(tilde(v)'_j,pi'_j,j)$ come from the incoming $bundlem$ message at @line:c-mbrb:rcv-bundle, whose validity (w.r.t. $C'$) has been verified at @line:c-mbrb:rcv-bundle-isvalid.
]

#lemma[
A correct process $p$ signs a most one commitment~$C$.
] <lem:single-sign>

#proof[
Some process $p$ signs a commitment either at @line:c-mbrb:snd-sign (for $p_s$), @line:c-mbrb:rcv-send-sign, or @line:c-mbrb:rcv-forward-sign.
We consider two cases, depending on whether $p$ is $p_s$ or not.

- _Case 1:_ $p != p_s$.
  Process $p$ can sign some commitment only at @line:c-mbrb:rcv-send-sign or @line:c-mbrb:rcv-forward-sign.
  By the conditions at @line:c-mbrb:rcv-send-cond-other-vc[lines] @line:c-mbrb:rcv-forward-cond-other-vc[and], @line:c-mbrb:rcv-send-sign[lines] or @line:c-mbrb:rcv-forward-sign[and] are executed only if either $p$ has not signed any commitment yet, or has already signed the exact same commitment $C'$.

- _Case 2:_ $p=p_s$.
  Because valid messages must contain $p_s$'s signature share (due to calls to $isValid()$ at @line:c-mbrb:rcv-send-isvalid[lines] @line:c-mbrb:rcv-forward-isvalid[and]), and because we have assumed that signatures cannot be forged, @line:c-mbrb:snd-sign is always executed before @line:c-mbrb:rcv-send-cond-other-vc[lines] @line:c-mbrb:rcv-forward-cond-other-vc[and].
  By the same reasoning as Case 1, $p_s$ therefore never signs a different commitment at @line:c-mbrb:rcv-send-sign or @line:c-mbrb:rcv-forward-sign. #qedhere
]

We recall that the above lemmas, and as a consequence, the upcoming theorems, hold with high probability, assuming a computationally-bounded adversary that forges signature shares/threshold signatures or finds commitment collisions with only negligible probability.
We can now prove the properties required for an MBRB algorithm.

#lemma([MBRB-Validity])[
If $p_s$ is correct and a correct process $p_i$ mbrb-delivers a value $v$, then $p_s$ has previously mbrb-broadcast~$v$.
] <lem:c-mbrb-validity>

#proof[
Suppose $p_i$ mbrb-delivers $v$ at @line:c-mbrb:quorum-dlv.
Consider $C'$ the commitment that satisfies the condition at @line:c-mbrb:quorum, and $C$ the commitment computed at @line:c-mbrb:quorum-comp-frag-vc.
It holds that $C'=C$ by @line:c-mbrb:quorum-cond-diff-vc, or otherwise $p_i$ could not have reached @line:c-mbrb:quorum-dlv.

Consider the threshold signature $Sigma_C$ returned by the $getThreshSig$ function at @line:c-mbrb:quorum-get-tsig.
Using the same reasoning as in the proof of @lem:msgs-sent-valid, $Sigma_C$ is valid, and must, therefore, aggregate at least $tau=floor((n+t)/2)+1$ valid signature shares for $C$.
Let us remark that, out of all these valid signature shares, at least $floor((n+t)/2)+1-t = floor((n-t)/2)+1 >= 1$ are generated by correct processes#footnote[
  Remind that, $forall x in RR, i in ZZ: floor(x)+i = floor(x+i)$.
].
Thus, at least one correct process $p_j$ must have produced a signature share for $C$, whether it be at @line:c-mbrb:rcv-send-sign or @line:c-mbrb:rcv-forward-sign if $p_j != p_s$, or at @line:c-mbrb:snd-sign if $p_j = p_s$.
However, in all these cases, the sender $p_s$ must have necessarily produced a signature share for $C$: the case $p_j=p_s$ is trivial, and in the case $p_j != p_s$, $p_j$ must have verified the presence of a valid signature share from $p_s$ in the message it received, at @line:c-mbrb:rcv-send-isvalid or @line:c-mbrb:rcv-forward-isvalid, respectively.

Under the assumption that the adversary cannot forge signature shares/threshold signatures (@sec:crypto-prim), and recalling that $p_s$ is correct, the only way in which $p_s$ could have signed~$C'$ is by executing @line:c-mbrb:snd-sign when mbrb-broadcasting some value $v'$ at @line:c-mbrb:mbrb; see also the proof of @lem:single-sign.
Furthermore, recall that the commitment is collision-resistant (or binding, see @sec:crypto-prim), meaning that except with negligible probability, the value $v'$ that $p_s$ uses in @line:c-mbrb:mbrb satisfies $v'=v$, since it holds that $C'=Commitment(v')=Commitment(v)=C$.
]

#lemma([MBRB-No-duplication])[
A correct process~$p_i$ mbrb-delivers at most one value~$v$.
] <lem:c-mbrb-no-duplication>

#proof[
The condition at @line:c-mbrb:quorum directly implies the proof.
]

#lemma([MBRB-No-duplicity])[
No two different correct processes mbrb-deliver different values.
] <lem:c-mbrb-no-duplicity>

#proof[
Suppose, towards a contradiction, that $p_i$ mbrb-delivers $v$ and $p_j$ mbrb-delivers $v' != v$, where $p_i$ and $p_j$ are both correct processes.
Let us denote by $C$, resp. $C'$, the commitment returned by $computeFragVC()$ for $v$, resp. for $v'$.
As commitments are assumed to be collision-resistant (@sec:crypto-prim), $v != v'$ implies $C != C'$.

By the condition at @line:c-mbrb:quorum, $p_i$ gets a threshold signature $Sigma_i != bot$ from the $getThreshSig$ function that aggregates a set $Q_i$ containing $tau=floor((n+t)/2)+1$ valid signature shares for $C$.
Similarly, $p_j$ gets a threshold signature $Sigma_j$ aggregating a set~$Q_j$ of signature shares for~$C'$.
We know that $|Q_i union Q_j| = |Q_i|+|Q_j|-|Q_i inter Q_j|$.
Moreover, we know that, $forall x in RR, k in ZZ: k = floor(x)+1 => k > x$, and hence we have $Q_i > (n+t)/2 < Q_j$.
Thus, $|Q_i union Q_j| >= |Q_i|+|Q_j|-n > 2 (n+t)/2-n = t$.
In other words, $Q_i$ and $Q_j$ have at least one _correct_ process, $p_u$, in common that has signed both $C$ and $C'$. 
@lem:single-sign[Line], and the fact that $p_u$ has signed both $C$ and $C'$ leads the proof to the needed contradiction.
Thus, $v=v'$, and the lemma holds.
]

#lemma([MBRB-Local-delivery])[
If $p_s$ is correct and mbrb-broadcasts $v$, then at least one correct process $p_j$ mbrb-delivers $v$.
] <lem:c-mbrb-local-delivery>

#proof[
Let us denote by $C_v$ the commitment computed at @line:c-mbrb:comp-frag-vc-commit when executing $computeFragVC(v)$.
The proof of the lemma will follow from @obs:msgs-have-vc[Observations] @obs:correct-dlv[to] stated and proven below.

#observation[
All valid $sendm$, $forwardm$, or $bundlem$ messages received by some correct process $p_u$ contain~$C_v$.
] <obs:msgs-have-vc>

#proof-of(<obs:msgs-have-vc>)[
Recall that $p_s$ mbrb-broadcasts $v$, thus we know that $p_s$ has included its own signature share, $sig_s = (tssignshare_s (C_v),s)$, when it propagates $sendm(C_v, (tilde(v)_j, pi_j, j), sig_s)$ (@line:c-mbrb:snd-compute-frag-vc[lines]-@line:c-mbrb:snd-comm[]).
Consider a correct process $p_u$ that receives a valid $sendm$, $forwardm$, or $bundlem$ message containing a commitment $C_u$ at @line:c-mbrb:rcv-send[lines], @line:c-mbrb:rcv-forward, or @line:c-mbrb:rcv-bundle[].
If the message is of type $sendm$ or $forwardm$, then, as it is valid, it must contain $p_s$'s signature on~$C_u$.
If the message is of type $bundlem$, then, similarly to @lem:c-mbrb-validity, its valid threshold signature for $C_u$ aggregates a set of valid signature shares for $C_u$ that contains at least one share produced by a correct process $p_x$.
But for $p_x$ to produce this share, $p_s$ must also have produced a valid signature share for $C_u$, either because $p_x$ must have checked its existence at @line:c-mbrb:rcv-send-isvalid or @line:c-mbrb:rcv-forward-isvalid (before signing, at @line:c-mbrb:rcv-send-sign or @line:c-mbrb:rcv-forward-sign, respectively), or because $p_x$ is the sender.
Hence, in any case, $p_s$ produces a signature share for $C_u$. 
Since $p_s$ is correct, by @lem:single-sign, it does not sign another commitment $C' != C_v$. 
Under the assumption that signatures cannot be forged, the above implies that $C_u=C_v$.
]

#observation[
A correct process~$p_u$ only signs valid signature shares for~$C_v$.
] <obs:sign-only-valid>

#proof-of(<obs:sign-only-valid>)[
If $p_u=p_s$, it mbrb-broadcasts a single value and executes @line:c-mbrb:snd-sign only once, signing $C_v$.
Besides @line:c-mbrb:snd-sign, a correct process $p_u$ only signs signature shares after receiving a valid $sendm$ or $forwardm$ message (at @line:c-mbrb:rcv-send-sign[line] @line:c-mbrb:rcv-forward-sign[or]), and when it does, $p_u$ only ever signs the commitment received in the message.
By @obs:msgs-have-vc, this implies $p_u$ never signs any $C' != C_v$.
]
	
#observation[
If a correct process $p_u$ broadcasts a $forwardm$ message, this message is of the form $forwardm(C_v, star, {sig_s,sig_u})$, where $sig_s,sig_u$ are $p_s$'s and $p_u$'s valid signature shares for~$C_v$.
] <obs:form-fwd>

#proof-of(<obs:form-fwd>)[
Consider a correct process $p_u$ that broadcasts a message $forwardm(C', star, sigs)$ either at @line:c-mbrb:rcv-send-bcast[lines] @line:c-mbrb:rcv-forward-bcast[or].
By @obs:msgs-have-vc, $C'=C_v$.
The observation then follows from @lem:msgs-sent-valid.
]

#let Frcv = $F_sans("recv")$
We now define $Frcv$ to be the set of correct processes that receive a valid message $forwardm(C_v, star, sigs)$ at @line:c-mbrb:rcv-forward, where $sigs$ contains $p_s$'s valid signature for~$C_v$.
We analyze its size and the behavior of such processes in the following observations.

#observation[
$Frcv$ contains at least one correct process, #ie $Frcv != diameter$.
] <obs:Frcv-not-empty>

#proof-of(<obs:Frcv-not-empty>)[
If $p_s$ is correct and mbrb-broadcasts $v$, it executes @line:c-mbrb:snd-comm and disseminates messages of the form $sendm(C_v, (tilde(v)_j, pi_j), sig_s)$ to all processes, where $sig_s$ is $p_s$'s signature share of $C_v$.
By definition of the message adversary, these $sendm$ messages are received by at least $c-d$ correct processes.
		
By #c-mbrb-assum, $n>3t + 2d$, and therefore $c-d >= n-t-d > 0$.
At least one correct process $p_x$, therefore, receives one of the $sendm$ messages disseminated by $p_s$ at @line:c-mbrb:snd-comm.
As $p_s$ is correct, by @lem:msgs-sent-valid, this message is valid, and is handled by $p_x$ at @line:c-mbrb:rcv-send[lines]-@line:c-mbrb:rcv-send-bcast[].
		
By @obs:sign-only-valid, $p_x$ only signs signature shares for $C_v$, and thus passes the test at @line:c-mbrb:rcv-send-cond-other-vc, and reaches @line:c-mbrb:rcv-send-bcast, where it disseminates a $forwardm$ message.
By @obs:form-fwd, this message is of the form $forwardm(C_v, star, {sig_s,sig_x})$, and is valid.
As above, by definition of the message adversary, this $forwardm$ message is received by at least $c-d>0$ correct processes.
By definition these processes belong to $Frcv$, which yield $|Frcv|>0$ and $Frcv != diameter$.
]

#observation[
Any $p_u in Frcv$ broadcasts a 
$forwardm(C_v, star, {sig_s,sig_u})$ message, where $sig_s$ and $sig_u$ are $p_s$ and $p_u$'s valid signature shares for~$C_v$, respectively.
] <obs:send-fwd-if-rcv-fwd>
	
#proof-of(<obs:send-fwd-if-rcv-fwd>)[
Let $p_u in Frcv$ upon receiving a valid $forwardm(C_v, star, sigs)$ message at @line:c-mbrb:rcv-forward.
By the condition of @line:c-mbrb:rcv-forward-cond-no-msg, $p_u$ has either previously sent a $forwardm$ message at @line:c-mbrb:rcv-send-bcast or it will send such a message at~@line:c-mbrb:rcv-forward-bcast.
In both cases, @obs:form-fwd applies and guarantees that this message contains $C_v$ and both $p_u$'s and $p_s$'s valid signature shares.
#linebreak()
]
	
Note that $Frcv$ is defined over an entire execution of @alg:coded-mbrb.
@obs:send-fwd-if-rcv-fwd therefore states that any correct process $p_u$ that receives a valid $forwardm$ message _at some point of its execution_ also broadcasts a matching $forwardm$ message _at some point of its execution_.
The two events (receiving and sending a $forwardm$ message) might, however, occur in any order.
For instance, $p_u$ might first receive a $sendm$ message from $p_s$ at @line:c-mbrb:rcv-send, disseminate a $forwardm$ message as a result at @line:c-mbrb:rcv-send-bcast, and later on possibly receive a $forwardm$ message from some other process at @line:c-mbrb:rcv-forward.
Alternatively, $p_u$ might first receive a $forwardm$ message at @line:c-mbrb:rcv-forward, and disseminate its own $forwardm$ message at @line:c-mbrb:rcv-forward-bcast as a result.
In this second case, $p_u$ might also eventually receive a $sendm$ message from $p_s$ (at @line:c-mbrb:rcv-send).
If this happens, $p_u$ will disseminate a second $forwardm$ message at @line:c-mbrb:rcv-send-bcast.
A correct process, however, never disseminates more than two $forwardm$ messages (at @line:c-mbrb:rcv-send-bcast[lines] @line:c-mbrb:rcv-forward-bcast[and]).

#observation[
Any broadcast of 
$forwardm(C_v, fragtuple, {sig_s,sig_u})$
by a correct process $p_u in Frcv$ arrives to at least $c-d$ correct processes that are each, eventually, in $Frcv$.
] <obs:chain-react>

#proof-of(<obs:chain-react>)[
At least $c-d$ correct processes eventually receive each broadcast of a $forwardm$ message by a correct process $p_u$ by definition of the message adversary.
By @obs:form-fwd the $forwardm$ message contains~$C_v$, by @lem:msgs-sent-valid it is valid.
Thus, each of its correct recipients, which are at least $c-d$, belong to $Frcv$, by definition.
]

Because $forwardm$ messages are disseminated at @line:c-mbrb:rcv-forward-bcast, the reception and sending of $forwardm$ messages by correct processes will induce a "chain reaction" until a correct process is reached that has already disseminated a $forwardm$ message.
This "chain reaction" mechanism is the intuitive reason why some correct process will eventually receive enough distinct $forwardm$ messages to trigger an mbrb-delivery, as captured by the following observation.

#observation[
There exists a correct process~$p_j$ that receives $forwardm(C_v, star, sigs_u={sig_s,sig_u})$ messages from at least $c-d$ distinct correct processes $p_u$, where $sig_s=(tssignshare_s (C_v),s)$ and $sig_u=(tssignshare_u (C_v),u)$ are $p_s$ and $p_u$'s valid signature shares for~$C_v$, respectively, and the $forwardm$ message is the _last_ message sent by $p_u$.
] <obs:proc-sees-quorum-sigs>

#proof-of(<obs:proc-sees-quorum-sigs>)[
By @obs:send-fwd-if-rcv-fwd, any processes $p_u in Frcv$ broadcasts at least one message $forwardm(C_v, star, sigs_u={sig_s,sig_u})$, that includes $p_u$'s valid signature share for~$C_v$, $sig_u=(tssignshare_u (C_v)}, u)$.
Consider all the $forwardm$ messages sent by processes in $Frcv$ during the _last time_ they perform such a broadcast.
By @obs:chain-react, there are $|Frcv|$ senders, $p_u in Frcv$, such that each of $p_u$'s last broadcast of a $forwardm$ message is guaranteed to be delivered to at least $c-d$ correct processes~$p_x$, such that eventually $p_x in Frcv$.
Thus, at least $|Frcv|(c-d)$ such messages are received by processes in~$Frcv$, overall.
By @obs:Frcv-not-empty, $Frcv$ contains at least one process.
We can, therefore, apply the pigeonhole principle, where $Frcv$ are the holes and the above $|Frcv|(c-d)$ messages are the pigeons, and observe that there exists a process~$p_j in Frcv$ that will receive at least $|Frcv|(c-d)\/|Frcv|$ such messages. 
Since we limit the discussion to a _single_, #ie the last, broadcast performed by each process in $Frcv$, no process in~$Frcv$ receives two of the above messages that were originated by the same process in~$Frcv$.
Therefore, we deduce that $p_j$ has received messages of the form $forwardm(C_v, star, sigs_u)$ from at least $c-d$ _distinct_ correct processes $p_u$ and the $forwardm$ message is the _last_ message sent by $p_u$.
]

#observation[
At least one correct process mbrb-delivers $v$ from $p_s$.
] <obs:correct-dlv>

#proof-of(<obs:correct-dlv>)[
By @obs:proc-sees-quorum-sigs, there is a correct process~$p_j$ that receives messages of the form $forwardm(C_v, star, sigs_u)$ from at least $c-d$ distinct correct processes $p_u$, such that these $forwardm$ messages are the _last_ message sent by each $p_u$.
Let us denote by $U$ the set of such processes~$p_u$, hence, $|U| >= c-d$.

Still by @obs:proc-sees-quorum-sigs, $p_j$ receives a valid signature share $sig_u=(tssignshare_u (C_v), u)$ from each process $p_u in U$.
It thus receives at least $c-d$ _distinct_ signature shares for~$C_v$.
#c-mbrb-assum says $3t+2d < n$, and thus, $n+3t+2d < 2n$ and $n+t < 2n-2t-2d$.
Since $n - t <= c$, we have $(n+t)/2 < n-t-d <= c-d$. 
Thus, $p_j$ receives more than $(n+t)/2 $ valid distinct signature shares for~$C_v$.

Let us now consider the set of correct processes $S$ that receive the initial $sendm$ messages disseminated by $p_s$ at @line:c-mbrb:snd-comm.
Any process $p_x in S$ receives through the $sendm$ message its allocated fragment $(tilde(v)_x, pi_x, x)$ from~$p_s$.
By definition of the message adversary, the $sendm$ messages disseminated at @line:c-mbrb:snd-comm are received by at least $c-d$ correct processes, therefore $|S| >= c-d$.
Furthermore, all processes in $S$ broadcast a $forwardm$ message at @line:c-mbrb:rcv-send-bcast, and this will be their _last_ $forwardm$ message, due to the condition at @line:c-mbrb:rcv-forward-cond-no-msg. 
By the above reasoning, this $forwardm$ message will contain their value fragment, that is, it will be of the form $forwardm(C_v, (tilde(v)_x, pi_x, x), sigs_u)$. 
By @lem:msgs-sent-valid, they are all valid.

By definition of $S$ and $U$, both these sets  contain only correct processes, thus, $|S union U| <= c$.
As a result, $|S inter U| = |S|+|U|-|S union U| >= 2(c-d)-c = c-2d$. 
The last $forwardm$ messages broadcast by processes in $S inter U$ are received by $p_j$ by the definition of $U$.
As argued above about processes in~$S$ (and thus applying to processes in $S inter U$), $forwardm$ messages sent by a process in $S inter U$ contain their valid value fragment and proof of inclusion~$(tilde(v)_x, pi_x, x)$.
It follows that $p_j$ accumulates at least $c-2d$ distinct such value fragments with their (valid) proof of inclusion.
By #c-mbrb-assum, $c-2d >= k$.

To conclude the proof, note that we have shown that $p_j$ eventually receives more than $(n+t)/2$ valid distinct signature shares for~$C_v$, and additionally, that $p_j$ accumulates at least $k$ valid value fragments with their proof of inclusion.
At this point, the condition of @line:c-mbrb:quorum becomes true for~$p_j$.
Because the commitment is collision-resistant (@sec:crypto-prim), once $C_v$ is fixed, we can assume that, except with negligible probability, all the value fragments that $p_j$ has received correspond to the fragments computed by $p_s$ at @line:c-mbrb:snd-compute-frag-vc.
By the parameters of the ECC we use, it can recover the value $v$ from any $k$ or more (correct) fragments generated by~$p_s$, where missing fragments are considered as erasures.
Therefore, the value $v_j$ reconstructed at @line:c-mbrb:quorum-reconstruct by $p_j$ is the value initially mbrb-broadcast by $p_s$.
As a result $v_j=v$, and $p_j$ mbrb-delivers~$v$ at @line:c-mbrb:quorum-dlv.
]

]

#lemma([MBRB-Global-delivery])[
If a correct process $p_i$ mbrb-delivers a value~$v$, then at least $lmbrb=c-d(1/(1-(k-1)/(c-d)))$ correct processes mbrb-deliver~$v$.
] <lem:c-mbrb-global-delivery>

#proof[
Suppose a correct process $p_i$ mbrb-delivers $v$ (@line:c-mbrb:quorum-dlv).
Let us denote by $C_v$ the commitment returned by $computeFragVC(v)$.
The proof follows a counting argument on the $bundlem$ messages disseminated by correct processes at @line:c-mbrb:quorum-comm[lines] @line:c-mbrb:rcv-bundle-bcast[and].
In the following, if a correct process disseminates a $bundlem$ message both at @line:c-mbrb:quorum-comm and @line:c-mbrb:rcv-bundle-bcast, we only consider the one from @line:c-mbrb:quorum-comm.

#observation[
All valid $bundlem$ messages exchanged during the execution of @alg:coded-mbrb contain~$C_v$, the vector commitment of value~$v$, where $v$ is the message mbrb-delivered by~$p_i$.
] <obs:valid-bundles-have-Cv>

#proof-of(<obs:valid-bundles-have-Cv>)[
Consider a valid message $bundlem(C', fragtuple'_j, fragtuple'_i, Sigma')$.
By definition of a valid $bundlem$ message, $Sigma'$ aggregates a set $sigs'$ of $tau=floor((n+t)/2)+1$ valid signature shares for $C'$.
Similarly, when $p_i$ mbrb-delivers $v$ at @line:c-mbrb:quorum-dlv, it has a threshold signature $Sigma_v$ which aggregates a set $sigs_v$ of $tau=floor((n+t)/2)+1$ valid signature shares for $C_v$.
By a reasoning identical to that of @lem:c-mbrb-no-duplicity, these two inequalities imply that $sigs' inter sigs_v$ contains the signature shares from at least one common correct process, $p_u$.
As signature shares cannot be forged, $p_u$ has issued signature shares for both $C'$ and $C_v$, and by @lem:single-sign, $C'=C_v$. 
To complete the proof, note that by the definition of a valid $bundlem$ message, the threshold signature it contains is valid with respect to the commitment it carries.
Hence, all valid $bundlem$ messages must contain the commitment~$C_v$ of the value~$v$ that matches the threshold signature $Sigma'$ they contain. 
]

Let $Bsnd$ be the set of correct processes that disseminate at least one $bundlem$ message during their execution.
Similarly, let $Brcv$ be the set of correct processes that receive at least one valid $bundlem$ message from a correct process during their execution.
The following holds.

#observation[
$c >= |Brcv| >= c-d$ and $c >= |Bsnd| >= c-d$.
] <obs:Brcv-Bsnd-quorums>

#proof-of(<obs:Brcv-Bsnd-quorums>)[
Since $Bsnd$ and $Brcv$ contain only correct processes, trivially $c >= |Bsnd|$ and $c >= |Brcv|$.
Since $p_i$ mbrb-delivers $v$ at @line:c-mbrb:quorum-dlv, it must have disseminated $bundlem(C_v, (tilde(v)'_i, pi'_i, i), (tilde(v)'_j, pi'_j, j), Sigma_C)$ messages at @line:c-mbrb:quorum-comm.
The $bundlem$ messages sent by~$p_i$ eventually reach at least $c-d$ correct processes, as the message adversary can remove at most~$d$ of these $bundlem$ messages.
By @lem:msgs-sent-valid, these $bundlem$ messages are valid. 
Hence, $Brcv >= c-d > 0$ proves the lemma's first part.
	
The processes in $Brcv$ (which are correct) execute @line:c-mbrb:rcv-bundle[lines] @line:c-mbrb:rcv-bundle-isvalid[and], and reach @line:c-mbrb:rcv-bundle-cond-no-bundle. 
Because $p_i$ has included a non-$bot$ second fragment in all its $bundlem$ message, any of the $(c-d)$ processes of $Brcv$ that receive one of $p_i$'s $bundlem$ messages and has not already sent a $bundlem$ message passes the condition at @line:c-mbrb:rcv-bundle-cond-no-bundle.
Each such process then disseminates a (valid) $bundlem$ message at @line:c-mbrb:rcv-bundle-bcast.
This behavior yields $|Bsnd| >= c-d$.
]

Let $Bkrcv$ be the set of correct processes that receive $bundlem$ messages from at least $k$ distinct correct processes.

#observation[
$|Bkrcv| times |Bsnd| + (k-1)(|Brcv|-|Bkrcv|) >= |Bsnd|(c-d)$.
] <obs:bundle-eq>

#proof-of(<obs:bundle-eq>)[
Let us denote by $nbundle$ the overall number of valid $bundlem$ messages received by correct processes from distinct correct senders.
More specifically, in the case when a correct process disseminates $bundlem$ messages both at @line:c-mbrb:quorum-comm and @line:c-mbrb:rcv-bundle-bcast, we only consider the _last_ $bundlem$ message, #ie the one of @line:c-mbrb:quorum-comm.
We know that each $p in Bsnd$ sends a $bundlem$ message, which is valid by @lem:msgs-sent-valid.
As the message adversary may drop up to~$d$ out of the $n$ messages of this $comm$, we are guaranteed that at least $c-d$ correct processes receive $p$'s $bundlem$ message.
This immediately implies that   
$ nbundle >= |Bsnd|(c-d). #<eq:nbundle-ge> $
		
As illustrated in @fig:c-mbrb-msg-dist (#pageref(<fig:c-mbrb-msg-dist>)), the processes in $Bkrcv$ may receive up to $|Bsnd|$ valid $bundlem$ messages from distinct correct senders (one from each sender in $Bsnd$), for a maximum of $|Bkrcv| times |Bsnd|$ $bundlem$ messages overall.
The remaining processes of $Brcv \\ Bkrcv$ may each receive up to $k-1$ valid $bundlem$ messages from distinct correct senders, by definition of $Bkrcv$. 
As $Bkrcv subset.eq Brcv$ by definition, $|Brcv \\ Bkrcv|=|Brcv|-|Bkrcv|$, and the processes of $Brcv \\ Bkrcv$ accounts for up to $(k-1)(|Brcv|-|Bkrcv|)$ valid $bundlem$ messages overall.
As the $bundlem$ messages counted by $nbundle$ are received either by correct processes in $Bkrcv$ or in $Bkrcv \\ Brcv$, these observations lead to
$ |Bkrcv| times |Bsnd| + (k-1)(|Brcv|-|Bkrcv|) >= nbundle. #<eq:nbundle-le> $
		
Combining @eq:nbundle-ge and @eq:nbundle-le yields the desired inequality.
]

#observation[
$|Bkrcv| >= c-d(1/(1-(k-1)/(c-d))).$
] <obs:Bkrcv-ge>

#proof-of(<obs:Bkrcv-ge>)[
Rearranging the terms of~@obs:bundle-eq, and recalling that $|Brcv| >= c$ and $k >= 1$, we get
$ |Bkrcv| times (|Bsnd|-k+1) >= |Bsnd|(c-d) - |Brcv|(k-1) >= |Bsnd|(c-d) -c(k-1). $
By @obs:Brcv-Bsnd-quorums and #c-mbrb-assum, $|Bsnd| >= c-d >= c-2d >= k$, therefore $|Bsnd|-k+1>0$, and the previous equation can be transformed into
$ |Bkrcv| >= (|Bsnd|(c-d)-c(k-1))/(|Bsnd|-k+1). #<eq:Bkrcv-ge> $
Note that the right-hand side of @eq:Bkrcv-ge is a monotone increasing function in~$|Bsnd|$ when $|Bsnd|>k-1$, as its derivative, $(d(k+1))/((|Bsnd|-k+1)^2)$, is positive.
By @obs:Brcv-Bsnd-quorums, $|Bsnd| in [c-d,c] subset.eq [k,c]$. 
The minimum of the right-hand side of @eq:Bkrcv-ge is therefore obtained for $Bsnd=c-d$, yielding
$|Bkrcv| >= ((c-d)^2-c(k-1))/((c-d)-k+1) = c-d(1/(1-(k-1)/(c-d))).$
]

#observation[
All processes in $Bkrcv$ mbrb-deliver~$v$.
] <obs:Bkrcv-dlv>

#proof-of(<obs:Bkrcv-dlv>)[
Consider $p_u in Bkrcv$.
By the definition of $Bkrcv$, the process~$p_u$ receives $k$ valid $bundlem$ messages from $k$ distinct correct processes.
Let us denote by $bundlem(C_x, (tilde(v)_x, pi_x, x), star, Sigma_x)$ these $k$ messages with $x in [k]$.
By @obs:valid-bundles-have-Cv, for all $x in [k]$, $C_x=C_v$.
In addition, $p_u$ saves each received threshold signature $Sigma_x$, which is valid for $C_v$.
		
Because the messages are valid, so are the proofs of inclusions $pi_x$, and as we have assumed that the commitments are collision-resistant, $C_x=C_v$ implies that the received fragments $tilde(v)_x$ all belong to the set of fragments computed by $p_s$ at @line:c-mbrb:snd-compute-frag-vc for $v$.
As the $bundlem$ messages were received from $k$ distinct correct processes, the process~$p_u$ receives at least $k$ distinct valid fragments for $v$ during its execution.
If $p_u$ has not mbrb-delivered any value yet, the condition at @line:c-mbrb:quorum eventually becomes true for $C_v$, and $p_u$ reconstructs $v$ at @line:c-mbrb:quorum-reconstruct, since it possesses at least $k$ (correct) value fragments, which are sufficient for the correct recovery of~$v$ by our choice of ECC.
Then, $p_u$ mbrb-delivers $v$ at @line:c-mbrb:quorum-dlv.
On the other hand, if $p_u$ has already mbrb-delivered some value~$v'$, then @lem:c-mbrb-no-duplicity (MBRB-No-duplicity) implies $v'=v$, since $p_i$ is known to have mbrb-delivered~$v$. 
Therefore, in all possible cases, $p_u$ mbrb-delivers~$v$.
// #linebreak()
]

@lem:c-mbrb-global-delivery (MBRB-Global-delivery) follows from @obs:Bkrcv-ge[Observations] @obs:Bkrcv-dlv[and], and the fact that all processes in $Bkrcv$ are correct.
]
<lem:c-mbrb-global-delivery-end>