#import "../setup.typ": *

#{
  set page(numbering: none)
}

#heading(numbering: none, level: 1, outlined: false)[Remerciements]

Cette thèse a été non seulement possible, mais également fructueuse et épanouissante, grâce au soutien de nombreuses personnes ; en tout premier lieu mes directeurs de thèse, François et Davide, qui m'ont fait confiance et (sup)porté durant trois ans.
J'ai eu le privilège d'avoir des encadrants à l'écoute des idées, questions et doutes que je leur exprimais, et qui restaient enthousiastes et impliqués à chacun des projets que l'on a commencés ensemble.

Je souhaite ensuite exprimer ma reconnaissance à Alessia Milani et Giuliano Losa, qui ont accepté d'être rapporteurs de cette thèse, ainsi que Sara Tucci-Piergiovanni et Cédric Tedeschi, qui, avec mes directeurs, complètent mon jury de soutenance.

Cette thèse a été réalisée grâce au soutien financier du projet ANR ByBloS et de la bourse de mobilité internationale de la Région Bretagne, et aux moyens mis à ma disposition par l'IRISA et l'Université de Rennes.
Pour leur aide précieuse et bienveillante, je témoigne aussi de ma reconnaissance envers tout le personnel technique ou administratif, en particulier Virginie, notre assistante d'équipe.

L'équipe WIDE aura été un environnement très enrichissant pour réaliser mon doctorat, que cela soit du point de vue personnel ou professionnel, et ce en grande partie grâce à la présence de ses membres permanents.
En particulier, Michel aura aussi été très présent durant mon doctorat, et, en échange de quelques petits dépannages informatiques de temps en temps, il m'a volontiers appris les ficelles du métier de scientifique, et transmis la capacité à savoir "dézoomer" et se questionner sur la nature de notre profession de chercheur.

Naturellement, je remercie tou(te)s les camarades et ami(e)s de l'équipe WIDE, que ce soit les doctorant(e)s, stagiaires, post-docs ou ingénieurs.
L'équipe ayant connu une croissance et un renouvellement significatifs durant les trois dernières années, j'espère que l'on ne m'en voudra pas trop de ne pas dresser une liste exhaustive ici.
Sachez néanmoins que les souvenirs de nos pauses café, parties de ping-pong et sorties au bar garderont une place spéciale dans ma mémoire (partagée), et que, même si nous ne travaillions pas tous sur les mêmes sujets, l'émulation qu'il y a au sein de l'équipe m'a forcé à me donner un mal de chien pour rester au niveau !
Je vous souhaite à toutes et tous une bonne continuation dans vos travaux respectifs.

J'aimerais cependant remercier particulièrement Arthur et Mathieu, qui font partie de la même fournée de doctorants que moi, et avec qui la relation est devenue avec le temps bien plus que seulement scientifique.
Merci Arthur pour les longues soirées montage Lego au bureau jusqu'à ce que le vigile nous demande gentiment de rentrer chez nous, ou pour les discussions au jargon plein de _ZKP_, de _Vector Commitment_ ou de _Polylog_.
Merci Mathieu pour m'avoir (presque) appris à faire de l'escalade, et pour les nombreux échanges sur le problème du nommage ou du _CAC_ (qui, soit dit en passant, n'a rien à voir avec un quelconque indice boursier !).

Je salue également Dimitrios, qui a très gentiment relu ma thèse, et rajoute une mention spéciale à Augustin, qui m'a guidé vers la lumière de Typst alors que j'étais encore plongé dans les affres typographiques de LaTeX.
Avec les autres bénévoles de l'atelier la Rustine, il m'a aussi beaucoup aidé à retaper ma bicyclo-épave, notamment en m'apprenant la technique secrète du _"si t'arrives pas à le réparer, découpe-le à la disqueuse"_ !
J'aimerais également remercier la communauté Typst, grâce à laquelle je suis aujourd'hui fier de présenter une des premières thèses de doctorat écrite intégralement en Typst.

Au delà des frontières bretonnes, je souhaite exprimer ma sincère gratitude envers Elad et Ran, qui nous ont non seulement invités à travailler avec eux, mais qui ont aussi accepté que le fruit de nos recherches apparaisse dans cette thèse.
Je suis également reconnaissant envers les personnes avec qui la collaboration depuis mon séjour à Madrid est intense et féconde : Antonio, Chryssis, Nicolas et Junlang.
Je garde un souvenir chaleureux de l'incroyable _melting pot_ qui m'a accueilli durant l'été torride de 2023 à IMDEA Networks Institute (dédicace au petit groupe qui s'était formé autour de Lucky la plante, le petit géranium parti trop tôt).

La réussite de cette thèse doit également beaucoup aux différents cercles d'amis de Bretagne et de Navarre (scouts, études sup', aumôneries ou colocs, ...) qui m'ont permis de m'évader, ne serait-ce que temporairement, du quotidien parfois éprouvant de doctorant.
J'ai bien sûr aussi une pensée pour toutes les personnes avec qui je me suis rapproché par le sport, que ce soit les gymbros du Sycrew, les footeux du calcetto, ou bien les compagnons de pédale des routes de Bretagne.

Pour conclure, je tiens à remercier ma famille proche comme élargie, dont le soutien indéfectible, tant moral que matériel, a été le pilier de cette aventure intellectuelle.
Je garde une dette éternelle envers vous.

Merci à tous.



// Mes remerciements vont aussi à ceux qui m'ont chaleureusement accueilli durant l'été torride de 2023 à l'IMDEA Networks Institute, un incroyable _melting pot_ de cultures du monde entier (dédicace au petit groupe qui s'était formé autour de Lucky la plante, le petit géranium parti trop tôt).

// Merci aussi pour l'aide et les nombreux conseils vélo des bénévoles de la Rustine m'ont apportés pour réparer ma bicyclo-épave, notamment en m'apprenant la technique secrète _"si t'arrives pas à le réparer, découpe-le à la disqueuse"_ !

#{
  set align(horizon + center)
  grid(
    columns: 3, column-gutter: 2em, row-gutter: 1em,
    // LINE 1
    image("dessins/objectif_these.jpg", width: 14em),
    image("dessins/arboule_a_neige.jpg", width: 10em),
    image("dessins/etoile.jpg", width: 14em),
    // LINE 2
    image("dessins/mouton_godzilla.jpg", width: 14em),
    image("dessins/chaborg.jpg", width: 10em),
    image("dessins/ovipare_petrochimique.jpg", width: 14em),
  )
}