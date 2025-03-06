#import "../setup.typ": *

// creating a new context for custom rules
#[

#set page(header: none)
#set heading(numbering: none, outlined: false)

= Résumé en français

Le calcul distribué (ou réparti) est la science de la coopération : il intervient dès que plusieurs agents travaillent ensemble pour atteindre un objectif commun, malgré le fait que chacun de ces agents n'a qu'une connaissance partielle de l'environnement global.
À ce titre, le calcul distribué apparaît dans la vie de tous les jours, et formalise des problématiques qui existent depuis les premières civilisations, que ce soit s'assurer du secret et de l'authenticité de la communication, ou encore s'adapter à la lenteur ou la non-fiabilité de la propagation de l'information.
Avec le début des micro-ordinateurs et l'avènement d'Internet dans les années 1980, les serveurs informatiques et la fibre optique ont progressivement remplacé les généraux d'armée et les émissaires royaux, mais il est intéressant de constater que les choses n'ont pas fondamentalement changé depuis l'Antiquité, elles se sont simplement accéléré !

Des messageries instantanées aux systèmes de paiement, en passant par le vote électronique et le _cloud computing_, les systèmes distribués _informatiques_ sont omniprésents dans notre monde moderne interconnecté.
Cependant, avec le développement de la cyber-menace et les risques de bogues logiciels et de dysfonctionnements matériels, il est aujourd'hui capital d'avoir des garanties de robustesse et de disponibilité pour nos systèmes distribués actuels.
Cette thèse explore donc des outils théoriques et des techniques permettant de rendre les systèmes distribués modernes plus résilients à toutes ces sources d'incertitude.

== La modélisation de systèmes distribués

Afin de comprendre la complexité du monde réel, il est primordial de créer des simplifications de la réalité dans lesquelles il est plus facile de raisonner : c'est ce qu'on appelle des _modèles_.
// De par sa nature-même, un modèle ne peut pas être _vrai_ à proprement parler, mais on peut quand même estimer sa qualité, qui est proportionnelle au nombre de prédictions correctes qu'il permet de faire, mais qui est aussi inversement proportionnelle au nombre (et au coût) de ses hypothèse de travail.
// Comme disait George Box : _"Tous les modèles sont faux, mais certains sont utiles"_.
Le défi derrière la création d'un "bon" modèle réside dans la tension inhérente au fait de simplifier la réalité tout en y restant suffisamment fidèle, afin que le modèle fournisse un avantage déductif conséquent, mais que ses réponses restent quand même applicables aux conditions réelles.

Ainsi, plusieurs modèles facilitant les analyses formelles se sont progressivement imposés dans le domaine du calcul distribué.
Considérons tout d'abord qu'un système réparti est composé de plusieurs processus (parfois appelés nœuds, agents ou encore processeurs) qui exécutent un algorithme et communiquent en échangeant des données.
Dans la suite, nous explorerons deux familles de modèles permettant de représenter les échanges de données entre les processus d'un système distribué : les modèles d'interaction et les modèles de communication.

#paragraph[Interaction : le passage de messages et la mémoire partagée]
On distingue deux principaux paradigmes d'interaction entre les processus d'un système distribué : le passage de messages et la mémoire partagée.
Le passage de messages implique l'envoi et la réception de messages sur un réseau entre les processus, tandis que la mémoire partagée permet aux processus de lire et écrire directement dans un espace mémoire commun.
Le _web_ est un exemple de système à passage de messages de par son architecture client-serveur, tandis que les microprocesseurs multi-cœurs s'apparentent à des systèmes à mémoire partagée.
Bien que ces deux modèles présentent de nombreuses similitudes, ce manuscrit se concentrera sur les systèmes répartis à passage de messages.

#paragraph[Communication : la synchronie et l'asynchronie]
En plus des modèles standards d'interaction inter-processus, le calcul réparti discerne plusieurs modèles de communication différents, qui portent sur les latences de communication.
Le modèle _synchrone_ est le plus fort de ces modèles : on suppose que les messages échangés entre les processus ont un délai de communication maximum, et que ce délai est connu de tout le monde dans le système.
Ce modèle correspond à des conditions de communication idéales, et permet donc de résoudre de nombreux problèmes distribués.
Cependant, ce modèle peut aussi s'avérer irréaliste dans des systèmes comme Internet, où les congestions, les pics de latence ou les partitionnements peuvent (temporairement) violer les hypothèses de synchronie.
Pour répondre à cette problématique, l'autre modèle de communication majeur, le modèle _asynchrone_, ne fait aucune hypothèse sur le délai des messages : ces derniers peuvent rester en transit un temps arbitrairement long, du moment qu'ils sont _à terme_ reçus par leur destinataire.
Le modèle asynchrone étant le plus sévère, il permet donc de créer des systèmes distribués très résilients aux variations de latence du réseau.
En effet, si un système fonctionne dans un environnement asynchrone, alors il peut de surcroît fonctionner dans un environnement synchrone.
Pour cette raison, nous nous intéresserons exclusivement au modèle asynchrone dans cette thèse.

== Les différents modèles de panne

Après avoir examiné les différents modèles d'interaction et de communication du calcul réparti, il est essentiel de considérer un autre aspect crucial des systèmes distribués : les défaillances.
Dans la section suivante, nous explorerons les différents modèles de panne qui peuvent affecter ces systèmes : les pannes relatives aux processus (participants) du système, et les pannes relatives au réseau de communication.

// Outre les différents modèles vu précédemment, le calcul réparti étudie également les modèles de panne, c'est-à-dire les différents types de défaillances qui peuvent apparaître dans un système distribué.
// Dans cette dissertation, nous distinguerons deux types de pannes 

#paragraph[Pannes de processus : les crashes et byzantins]
Les pannes des processus peuvent être classées selon une hiérarchie allant des _crashes_ (arrêts brutaux) aux _défaillances byzantines_~@LSP82 @PSL80, où les processus "fautifs" (dits _byzantins_) adoptent un comportement déviant arbitrairement de l'algorithme prescrit, que ce soit à cause d'une erreur d'implémentation ou d'une intention malveillante (cyberattaque).
Nous pouvons observer de manière assez immédiate que le modèle byzantin est plus agressif que le modèle crash, étant donné que les byzantins peuvent "simuler" des crashes (simplement en restant silencieux), tandis qu'un processus qui crashe ne peut pas envoyer deux messages contradictoires à deux destinataires différents afin de compromettre le système, comme pourrait le faire un byzantin.

Par convention, nous appellons _processus corrects_ tous les processus non défaillants (que ce soit des crashes ou des défaillances byzantines).

#paragraph[Pannes réseau : l'adversaire de messages]
Les pannes réseau, quant à elles, ont été formalisées par le modèle de l'_Adversaire de Messages_ (en anglais, _Message Adversary_, ou _MA_), qui introduit des fautes "mobiles" pouvant affecter différents liens de communication au cours de l'exécution du système distribué @SW89 @SW07.
Ces défaillances peuvent être de plusieurs type : omissions de réception, omission d'envoi, corruptions, duplication, envoi erroné...
L'adversaire de messages est donc un attaquant extérieur ayant un certain pouvoir de perturbation sur les canaux de communication du système.
Ce modèle théorique permet de prendre en compte des phénomènes courants dans les systèmes distribués pratiques, comme les interférences de communication, les déconnexions temporaires de processus, ou encore les réseaux à topologie dynamique.

#paragraph[Modèles de pannes hybrides]
Les deux modèles vus dans cette section sont irréductibles l'un à l'autre, c'est-à-dire qu'on ne peut pas émuler des pannes réseau avec des pannes de processus, et inversement.
Par exemple, un adversaire de message ne pouvant que supprimer des messages ne peut pas simuler un processus byzantin, et à l'inverse, un processus byzantin ne peut pas supprimer des messages envoyés entre deux processus corrects (non-byzantins).
C'est pour cette raison que des modèles de pannes hybrides, combinant pannes de processus et pannes réseau, permettent de considérer des scénarios importants que ces paradigmes ne pourraient pas couvrir individuellement.
En un sens, _"le tout est plus grand que la somme des parties"_.

// Pour illustrer les pannes hybrides, nous pouvons considérer l'exemple suivant : durant un appel téléphonique entre deux personnes, il peut y avoir des problèmes liés au réseau téléphonique (#eg des interférences), mais l'un des interlocuteurs peut également dire des mensonges à l'autre.
// Les premiers problèmes font partie des pannes réseau, tandis que les seconds tombent dans la catégorie des pannes de processus.
Pour illustrer les modèles de pannes hybrides, considérons un système de stockage distribué.
Des pannes de processus peuvent survenir lorsqu'un serveur tombe en panne ou est compromis par un attaquant (devenant ainsi byzantin).
Simultanément, des pannes réseau peuvent se produire en raison de congestions du réseau ou d'attaques par déni de service, entraînant des pertes de messages entre les serveurs encore opérationnels.
Cette combinaison de pannes de processus et de réseau peut créer des scénarios de pannes complexes, que cette thèse vise à adresser.
// Ces modèles hybrides n'ont été que très peu étudiés dans la littérature scientifique, et ils constituent le sujet de cette thèse.

== Les multiples facettes du problème de l'accord

Maintenant que nous avons établi un cadre pour comprendre les différents types de défaillances dans les systèmes distribués, nous pouvons nous pencher sur les défis fondamentaux que ces systèmes doivent relever.
// Après avoir examiné les différents modèles de pannes, il est crucial de comprendre comment ces défaillances affectent les problèmes fondamentaux du calcul distribué.
Dans le calcul réparti, tous les problèmes impliquent la coopération de plusieurs participants vers un but commun.
Que ce soit pour concevoir un système d'élection, un service de noms de domaine ou un outil d'édition collaboratif, les algorithmes distribués cherchent à atteindre une certaine forme d'_accord_ entre les participants.
Cependant, comme nous allons voir dans la section suivante, l'accord est un problème protéiforme pouvant se manifester de diverses façons.
Dans cette section, nous mettrons l'accent sur deux des variantes les plus connues de ce problème : le _consensus_ @L96 @R18 et la _diffusion fiable_ @B87 @LSP82.

#paragraph[Le consensus]
Le _consensus_ est un problème primordial dans lequel tous les processus du système distribué doivent se mettre d'accord sur une même valeur parmi celles qu'ils ont proposées.
Il s'agit d'un des problèmes les plus connus de l'informatique distribuée, si ce n'est son problème le plus connu.
Le consensus a de nombreuses applications industrielles, notamment dans le contexte de la réplication de machines d'état (technologie essentielle de l'informatique en nuage), les bases de données distribuées, la synchronisation d'horloges, ou encore les systèmes de _blockchain_.

Cependant, le consensus est également contraint par un théorème d'impossibilité fondamental du calcul réparti, appelé couramment théorème FLP @FLP85, qui démontre qu'il est impossible de résoudre le consensus dans un système asynchrone en présence d'un seul crash de processus.
Pour contourner cette impossibilité, il est courant que les concepteurs de systèmes distribués renforcent leur modèle en rajoutant des hypothèses (de synchronie, typiquement), ou affaiblissent le problème  en implémentant un consensus probabiliste (et donc non-déterministe). 

En plus de cette contrainte théorique, les implémentations pratiques du consensus font également couramment face à des problèmes de passage à l'échelle, dûs au fort niveau de synchronisation entre les processus imposé par cette puissante primitive d'accord.
Mais il est intéressant de remarquer que ce haut niveau de synchronisation n'est en fait pas nécessaire pour beaucoup d'applications distribuées, comme par exemple le transfert d'argent.
En effet, comme détaillé ci-dessous, pour implémenter un système de transfert d'argent, des primitives d'accord plus faibles suffisent, comme par exemple la _diffusion fiable_.

#paragraph[La diffusion fiable]
La _diffusion fiable_ (en anglais, _reliable broadcast_, ou _RB_) est une autre primitive fondamentale qui permet à un processus émetteur de diffuser une valeur au reste du système, et ce en garantissant des propriétés de sûreté et de disponibilité bien définies, même en présence de pannes de processus.
Intuitivement, la diffusion fiable est une primitive d'accord "tout ou rien" : soit tout le monde accepte la même valeur diffusée par l'émetteur (et uniquement cette valeur), soit personne n'accepte de valeur.

La diffusion fiable byzantine (en anglais, _Byzantine reliable broadcast_, ou _BRB_) est une généralisation naturelle du RB dans des contextes byzantins.
En effet, le BRB garantit que tout le monde voit à terme la _même chose_ (soit la même valeur, soit aucune valeur), et ce en dépit d'un émetteur initial potentiellement byzantin qui peut faire preuve de duplicité en envoyant des messages contradictoires à différentes parties du réseau.

Même si la diffusion fiable est une primitive plus faible que le consensus, dans le sens qu'elle permet de résoudre moins de problèmes distribués, elle possède néanmoins de nombreuses applications concrètes intéressantes.
Par exemple, il a été démontré que le BRB était suffisant pour concevoir des systèmes de paiement distribués tolérants aux processus byzantins malveillants~@AFRT20 @BDS20 @CGKKMPPSTX20 @GKMPS22.
En outre, l'utilisation du BRB à la place du consensus possède de nombreux avantages.
Tout d'abord, le BRB n'est pas soumis à l'impossibilité FLP, et contrairement au consensus, il peut être réalisé dans des environnements asynchrones sujets aux pannes de processus.
De plus, les implémentations du BRB sont typiquement plus légères que celles du consensus, du fait des contraintes de synchronisation plus faibles.
De ce fait, de manière générale, les systèmes basés uniquement sur le BRB montent mieux en charge que les systèmes utilisant du consensus.

En raison de ses nombreux bénéfices, nous nous intéresserons particulièrement au problème de la diffusion fiable dans cette dissertation.

== Thèse

Ayant exploré les différentes facettes du problème de l'accord, nous sommes maintenant en mesure de formuler la thèse centrale de ce travail, qui se concentre sur la résolution efficace de la diffusion fiable dans des environnements sujets à des pannes hybrides.
// Ce manuscrit s'intéresse particulièrement aux systèmes distribués asynchrones sujets à des pannes hybrides, impliquant à la fois des pannes de processus et des pertes de messages réseau.
Dans ce manuscrit, nous nous appuierons donc sur l'hypothèse suivante.

- *Hypothèse* \ _Les modèles de pannes hybrides peuvent représenter avec précision les conditions réelles des systèmes distribués asynchrones à grande échelle._

Dans ce contexte, la présente dissertation se concentrera principalement sur le cas de la diffusion fiable et défendra la thèse suivante.

- *Thèse* \ _Certains problèmes intéressants, tels que la diffusion fiable, peuvent être efficacement résolus dans des environnements asynchrones sujets à des pannes hybrides._

#paragraph[Contributions]
Pour étayer la thèse précédente, ce manuscrit présente les contributions suivantes.

+ _Un nouveau modèle de système distribué capturant les pannes hybrides._ Ce modèle permet une représentation plus fidèle des défaillances complexes dans les systèmes réels, ouvrant la voie à des algorithmes plus robustes.
  En particulier, étant donné un système de $n$ processus, ce modèle combine au plus $t$ défaillances byzantines avec un adversaire de messages qui peut supprimer $d$ messages envoyés par n'importe quel processus durant une étape de communication sur le réseau.
  L'adversaire de messages est défini indépendamment de toute hypothèse de synchronie ou structure d'algorithme.
  Par conséquent, ce modèle de panne s'applique naturellement à n'importe quel algorithme s'exécutant dans un système asynchrone à passage de messages.
  // En particulier, ce modèle décrit un système à passage de message asynchrone de $n$ processus, parmi lesquels au plus $t$ peuvent être byzantins.
  // De plus, un adversaire de messages a le pouvoir de supprimer au plus $d$ messages envoyés par un processus quelconque durant une étape de communication sur le réseau.

+ _Une nouvelle définition formelle de la diffusion fiable (MBRB)._
  En se servant du modèle hybride précédent, cette thèse définit une nouvelle abstraction, appelée "diffusion fiable byzantine tolérante aux adversaires de messages" (en anglais, _Message-Adversary Byzantine Reliable Broadcast_, ou _MBRB_), généralise la diffusion fiable byzantine classique (BRB) et permet d'aborder des scénarios de défaillance plus larges, notamment ceux intégrant des pannes mobiles pouvant causer des pertes de messages.
  Spécifiquement, le MBRB impose une borne inférieure explicite (notée $lmbrb$ et appelée _"puissance de livraison"_) sur le nombre de processus corrects qui livrent les valeurs diffusées.
  Cela est dû au fait que, contrairement au BRB, il n'est plus possible de garantir que la totalité des processus livrent la valeur diffusée en présence d'un adversaire de message, car ce dernier peut totalement isoler du réseau au plus $d$ processus corrects.

+ _Un théorème d'optimalité pour le MBRB._
  Nous démontrons ensuite que, dans le cadre théorique que nous avons défini, le MBRB peut être implémenté si et seulement si la condition $n>3t+2d$ est respectée.
  Intuitivement, cette borne combine la condition $n>3t$, nécessaire et suffisante pour résoudre les problèmes d'accord dans des contextes asynchrones sujets aux pannes byzantines, avec la condition $n>2d$, qui empêche la présence de partitionnement réseau.
  Ce résultat théorique établit des limites fondamentales et guide la conception d'algorithmes optimaux.

+ _Une implémentation optimale et simple du MBRB._
  En s'appuyant sur les contributions précédentes, nous proposons un nouvel algorithme, basé sur les signatures électroniques, qui démontre de manière simple la faisabilité pratique du MBRB, avec une résilience et une puissance de livraison maximales.
  En effet, cet algorithme ne suppose que $n>3t+2d$, démontré précédemment comme étant la borne optimale, et sa puissance de livraison est de $lmbrb=c-d$, où $c$ est le nombre de processus effectivement corrects dans le système ($n-t <= c <= n$).

+ _L'abstraction $k2l$-cast._
  Bien que l'algorithme précédent fournit une implémentation du MBRB avec une résilience et une puissance de livraison optimales, il nécessite des signatures, qui ne fonctionnent en pratique que de manière probabiliste.
  Afin d'explorer comment le MBRB peut être implémenté sans cette hypothèse, nous introduisons une nouvelle primitive _plusieurs-vers-plusieurs_ appelée $k2l$-cast, qui permet de garantir que si une masse critique de $k$ processus corrects diffusent une même valeur, alors au moins $ell$ processus corrects vont à terme livrer cette valeur.
  Ainsi, le $k2l$-cast capture un mécanisme de contruction de quorums omniprésent dans la conception d'algorithmes distribués.
  Particulièrement, nous démontrons que le $k2l$-cast facilite la construction d'algorithmes MBRB sans signature, en arrivant à transformer des algorithmes classiques de BRB sans signatures, tels que celui de Bracha ou celui d'Imbs-Raynal, en les rendant non seulement tolérants aux pannes hybrides, mais aussi plus rapides d'exécution.
  Cela nous permet donc d'élargir l'applicabilité de nos travaux aux systèmes sans cryptographie.

+ _Une implémentation du MBRB utilisant des codes d'effacement._
  En contribution finale, nous revisitons l'implémentation du MBRB avec signatures du point de vue de la complexité de communication.
  Bien que notre premier algorithme MBRB avec signatures fournisse une résilience aux pannes et une puissance de livraison optimales, il présente un coût de communication élevé.
  En comparaison, notre nouvel algorithme amélioré, appelé _MBRB Codé_, atteint une complexité de communication quasi-optimale en utilisant des techniques de codes d'effacement, de signatures à seuil et d'engagements vectoriels.
  En effet, le MBRB Codé possède un coût de communication de $O(|v|+n secp)$ bits envoyés par processus correct, où $|v|$ est la taille de la valeur diffusée, et $secp$ est le paramètre de sécurité des primitives cryptographiques.
  Cela rend le MBRB Codé optimal à $secp$ près, étant donné que la borne de communication inférieure se situe à $Omega(|v|+n)$ bits envoyés par processus correct.
  En somme, le MBRB Codé est un algorithme plus efficace pour les déploiements sur les systèmes où la bande passante est une ressource précieuse, comme par exemple les systèmes blockchain ou encore les bases de données répliquées.

== Organisation

Le reste du manuscrit est organisé comme suit.

- Le @sec:intro[Chapitre] introduit la dissertation, fournissant le contexte essentiel pour comprendre les enjeux de cette thèse.

- Le @sec:background[Chapitre] présente l'état de l'art, positionnant notre travail dans le paysage scientifique actuel.
  // sur les modèles théoriques de pannes hybrides, ainsi que le problème de la diffusion fiable.

- Le @sec:model-and-mbrb[Chapitre] définit notre modèle de système hybride et le problème du MBRB, posant les bases théoriques de nos contributions.
  // définit un nouveau modèle de système hybride, ainsi que le problème du _Message-Adversary Byzantine Reliable Broadcast_ (_MBRB_), en démontrant un théorème d'optimalité sur la borne de résilience nécessaire et suffisante pour implémenter le MBRB.

- Le @sec:sig-mbrb[Chapitre] présente une implémentation simple du MBRB, démontrant sa faisabilité pratique.
  // introduit une implémentation simple du MBRB basée sur les signature électroniques, offrant une résilience optimale aux pannes hybrides.

- Le @sec:k2l-cast[Chapitre] introduit le $k2l$-cast, élargissant la portée de nos résultats aux systèmes sans signatures.
  // présente le $k2l$-cast, une abstraction _plusieurs-vers-plusieurs_ utile pour faire de l'ingénierie des quorums dans les systèmes répartis, et en particulier pour construire des implémentations du MBRB sans signature.

- Le @sec:coded-mbrb[Chapitre] optimise notre approche, rendant le MBRB plus efficace en communication pour les déploiements à grande échelle.
  // présente une implémentation de MBRB basée sur les codes d'effacement, offrant une complexité de communication quasi-optimale.

- Enfin, le @sec:conclusion[Chapitre] synthétise nos contributions et ouvre des perspectives pour de futures recherches.
  // revient sur les contributions de cette thèse et sur les perspectives de recherche futures.

- Pour des questions de présentation, certains développements apparaîssent en @sec:circumvent-flp[Annexes]-@sec:coded-mbrb-correctness-proof[], comme des détails supplémentaires sur le problème du consensus et des preuves de correction.

]

