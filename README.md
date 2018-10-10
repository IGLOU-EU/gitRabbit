# ![logo](https://git.iglou.eu/Laboratory/gitRabbit/raw/branch/master/gitRabbit.png) *-* gitRabbit
*Le reproducteur le plus rapide de l'ouest*

**Papa lapin veille sur ses lapereaux et leurs fait faire beaucoup de choses, mais toujours avec amour :heart:**

---
**gitRabbit**, est un petit script qui permet de déployer des repos git en production, ainsi que de les garder a jour avec leur branche.
Il embarque un log info/erreur, un garde fou pour restreindre l'execution et un quiet mode.

**Il est possible:**
* D'ajouter un nombre ilimité de repos
* D'utiliser des branches
* D'executer des commandes avant/aprés un "git pull"

**Il n'est pas encore possible:**
* D'utiliser une clé spécifique
* D'utiliser un combo user/passwd

## Les options de lancement
```
    usage : gitRabbit [-q] [-c <path>] [-u <user>] [-w <path>]
                      [-l <path>] [-s <time>] [-t|-tt]

    -q        Afficher uniquement les erreur fatales

    -c        Spécifier un fichier de configuration alternatif

    -u        Définir l'utilisateur autorisé a lancer ce script
              Ceci est un garde fou, pour eviter de lancer en root par exemple
              Une entrés incorecte cause une erreur fatal

    -w        Emplacement des datas
              Il est préférable que ce soit un lien absolut

    -l        Définir un fichier de log alternatif

    -s        Temps a attendre avant de revérifier le repository

    -t, -tt   Afficher moins d'informations dans le log
              Doubler l'option(-tt) pour loguer uniquement les erreurs
```

## Fichier de configuration
*lapereaux.conf*
Les options suivantes, peuvent étre définies dans le fichier de conf ou en option de lancement(voir section précédente)

### tinyLog
Permet de réduire les log, les valeurs disponibles sont
**0/\*** Print les informations, informations importantes et erreurs
**1** Print les informations importantes et erreurs
**2** Print uniquement les erreurs

### forceUser
C'est un garde fou, il permet d'éviter d'utiliser le script avec un utilisateur indésirable
Il n'est cependant pas a considérer comme une mesure de sécurité, mais uniquement de garde fou.
Pour une utilisation en Cron il est necessaire de définir avant tout la variable USER.

### sleepTime
Elle permet de définir le tems entre chaque passe de vérification des repository git,
une fois tous les repos considéré comme UpToDate, un temps de pause est marqué,
cette variable en définie le temps en secondes

### quietMode
Permet de ne rien afficher dans la sortie console, ses valeurs sont:
**false** Affiche les infos et erreurs dans la sortie
**true** N'affiche que les erreurs fatales

--

*Voyons les options pour ajouter un repos*

### lapereaux
Est la variable contenant l'intégralité des dépos qu'il faut utiliser,
le nom donné au repos ne doit contenir que des caractaires alpha-numerique et _ [a-z0-9\_].
Toutes les variables de configuration suivante doivent étre préfixé, avec le nom ici renségné.

### Exemple
Vous pouvez voir le fichier d'exemple [[ici]](https://git.iglou.eu/Laboratory/gitRabbit/src/branch/master/lapereaux.conf.sample)