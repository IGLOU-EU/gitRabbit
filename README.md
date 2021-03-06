# ![logo](https://git.iglou.eu/Laboratory/gitRabbit/raw/branch/master/gitRabbit.png) *-* gitRabbit
*Le reproducteur le plus rapide de l'ouest*

**Papa lapin veille sur ses lapereaux et leurs fait faire beaucoup de choses, mais toujours avec amour :heart:**

---
**gitRabbit**, est un petit script qui permet de déployer des repos git en production, ainsi que de les garder a jour avec leur branche.
Il embarque un log info/erreur, un garde fou pour restreindre l'execution, un quiet mode et une gestion des "trap" 2/3.
Il est aussi possible de l'utiliser comme service avec [SystemD](#-utilisation-en-service-systemd) ou [SystemBSD](#-utilisation-en-service-systembsd).

**Il est possible:**
* D'ajouter un nombre illimité de repos
* D'utiliser des branches
* D'executer des commandes avant/aprés un "git pull"
* D'utiliser une clé *[avec ~/.ssh/config]*
* D'utiliser un combo user/passwd *[https://* **\<user>**:**\<passwd>** *@urldeclone/repos.git]*

**Il n'est pas encore possible:**
* D'utiliser une clé avec passphrase

**Il à besoin de:**
* Git
* Bash
* *... cd echo mkdir sleep exit*

## :rocket: Les options de lancement
```
    usage : gitRabbit [-q] [-c <path>] [-u <user>] [-w <path>]
                      [-g <parh>] [-n] [-l <path>] [-s <time>] [-t|-tt]

    -q        Afficher uniquement les erreur fatales

    -c        Spécifier un fichier de configuration alternatif

    -u        Définir l'utilisateur autorisé a lancer ce script
              Ceci est un garde fou, pour eviter de lancer en root par exemple
              Une entrés incorecte cause une erreur fatal

    -w        Emplacement des datas
              Il est préférable que ce soit un lien absolut

    -l        Définir un dossier de log alternatif

    -g        Path for storing all git repository separates from the work tree

    -n        Don't remove the .git file from work tree (from clone)

    -s        Temps a attendre avant de revérifier le repository

    -t, -tt   Afficher moins d'informations dans le log
              Doubler l'option(-tt) pour loguer uniquement les erreurs
```
*Les options suivantes peuvent uniquement étre définies au lancement du script*
*Ou avant, via des `export .*=".*"`*

### [-w] WORK_DIR *(workDir)*
*[DEFAULT: /tmp/gitrabbit]*
Définit le dossier principale, il est de base de tous le reste,
si les autres options *(-c -l -g)* ne sont pas définies.
Il doit étre un lien absolut (de preference) et ouvert en ecriture.

### [-c] forceConf
*[DEFAULT: \<datas -w>/lapereaux.conf]*
Permet de forcer un fichier de configuration à un autre emplacement,
ex: `/etc/gitrabbit/lapereaux.conf`.
Doit étre un lien absolut et ouvert en lecture.

### [-l] forceLog
*[DEFAULT: \<datas -w>/log]*
Pour forcer un dossier de log alternatif comme `/var/log/gitrabbit`,
il est pratique pour faire de la rotation de log.
L'emplacement doit étre un lien absolut et ouvert en ecriture.

### [-g] forceGitDir
*[DEFAULT: \<datas -w>/git]*
Tous les `.git` vont ce retrouver dans ce dossier,
ça permet de sécuriser les infos contenu en ne les plassant pas dans `work tree`.
Doit étre un lien absolut et ouvert en ecriture.

## :pencil: Fichier de configuration
*lapereaux.conf*
Les options suivantes, peuvent étre définies dans le fichier de conf ou en option de lancement(voir section précédente)

### tinyLog
*[DEFAULT: 0]*
Permet de réduire les log, les valeurs disponibles sont
**0/\*** Print les informations, informations importantes et erreurs
**1** Print les informations importantes et erreurs
**2** Print uniquement les erreurs

### forceUser
*[DEFAULT: null]*
C'est un garde fou, il permet d'éviter d'utiliser le script avec un utilisateur indésirable
Il n'est cependant pas a considérer comme une mesure de sécurité, mais uniquement de garde fou.
Pour une utilisation en Cron il est necessaire de définir avant tout la variable USER.

### sleepTime
*[DEFAULT: 60]*
Elle permet de définir le tems entre chaque passe de vérification des repository git,
une fois tous les repos considéré comme UpToDate, un temps de pause est marqué,
cette variable en définie le temps en secondes

### quietMode
*[DEFAULT: false]*
Permet de ne rien afficher dans la sortie console, ses valeurs sont:
**false** Affiche les infos et erreurs dans la sortie
**true** N'affiche que les erreurs fatales

### noGitDot
*[DEFAULT: true]*
Le script utilise `--separate-git-dir` un fichier .git est tout de même créer pour indiquer le `gitdir`,
ce fichier n'est pas necessaire pour le script et est donc supprimé
**false** ne pas supprimer le fichier .git
**true** supprime le fichier .git

--

*Voyons les options pour ajouter un repos*

### lapereaux
Est la variable contenant l'intégralité des dépos qu'il faut utiliser,
le nom donné au repos ne doit contenir que des caractaires alpha-numerique et _ [a-z0-9\_].
Toutes les variables de configuration suivante doivent étre préfixé, avec le nom ici renségné.
**ex:** lapereaux+=("mon_repos")

### \*_url
Pour définir l'emplacement du repos a cloner
Il est possible d'utiliser un repos privé *[https://* **\<user>**:**\<passwd>** *@urldeclone/repos.git]*
**ex:** toto_url='http(s)://blabla.com/montruc.git'

### \*_before
La variable utilisé pour définir des actions a définir avant le "git pull",
il est préférable d'utiliser les quotes simples (') aux doubles (").
Il est possible d'utiliser des variables du main script, je vous encourage
a ne pas redéfinir une de ses variable, sous peine de gros problémes:
- \_lapDir
- logDir
- workDir
- logFile
- confFile

**ex:** toto_after='mv ${\_lapDir}/conf.ini /tmp/maconfagarder'
**ps:** Éxecuté avec `eval` dans le dossier du repos

### \*_after
Exactement comme la variable précédente, mais aprés le "git pull"
**ex:** toto_before='mv /tmp/maconfagarder ${\_lapDir}/conf.ini'

### \*_branch
Pour définir la branche a utiliser, histoire de ne pas utiliser master pour la prod,
**ex:** toto_branch='prod'

### \*_remove
Est utilisé pour supprimer un repos en éditant simplement le fichier de conf
Attention, une fois supprimé, si vous ne retirez pas les lignes concernant ce
repos, cela générera une erreur dans les log, expliquant qu'il est impossible
de le suprimer étant donné qu'il n'existe plus.
Les valeurs possibles sont **false** ou **true**
**ex:** toto_remove='true'

### Exemple
Vous pouvez voir le fichier d'exemple [[ici]](https://git.iglou.eu/Laboratory/gitRabbit/src/branch/master/lapereaux.conf.sample)

## :alarm_clock: Utilisation en tache CRON
Au minimum, la configuration en cron est:
`@reboot /emplacement/script/gitRabbit -c /emplacement/conf/lapereaux.conf`

## :shipit: Utilisation en Service (systemd)

1. Création d'un compte utilisateur dédié `useradd -r -s /bin/bash -U -M gitrabbit`
2. Ajout d'un fichier de configuration `/etc/gitRabbit/lapereaux.conf` (root:gitrabbit / 740)
3. Ajout d'un dossier data `/var/lib/gitRabbit` (root:gitrabbit / 775)
4. Création de la fiche service [[gitrabbit.service]](https://git.iglou.eu/Laboratory/gitRabbit/raw/branch/master/gitrabbit.service) *(/etc/systemd/system/gitrabbit.service)*
5. Enable/Start `systemctl enable gitrabbit`

## :shipit: Utilisation en Service (systemBSD)

1. Création d'un compte utilisateur dédié `useradd -s /bin/bash gitrabbit`
2. Ajout d'un fichier de configuration `/etc/gitrabbit/lapereaux.conf` (root:gitrabbit / 740)
3. Ajout d'un dossier data `/var/gitrabbit` (root:gitrabbit / 775)
4. Création de la fiche service [[gitrabbitd]](https://git.iglou.eu/Laboratory/gitRabbit/raw/branch/master/gitrabbitd) *(/etc/rc.d/gitrabbitd)*
5. Enable/Start `rcctl enable gitrabbit`