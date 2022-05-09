#!/bin/sh
# Color code
BOLD="\e[1m"
ITALICS="\e[3m"
UNDERLINE="\e[4m"
RED="\e[32m"
GREEN="\e[32m"
LIGRAY="\e[37m"
RESET="\e[0m"

#********** ARCHITECTURE **********
arc=$(uname -a)

#********** CPU ***********
pCPU=$(lscpu | grep 'Socket' | awk '{n_cpu += $2} END {print n_cpu}')
vCPU=$(lscpu | grep 'CPU(s)' | awk '{n_vcpu += $2} END {print n_vcpu}')
CPU_load=$(cat /proc/stat | grep 'cpu' | awk '{LOAD=($2+$4)*100/($2+$4+$5)} END {printf("%0.1f"), LOAD}')

# Acquere les donnees relatives a l'espace memoire RAM total du systeme
#  La commande (free -m) recupere les infos concernant la memoire RAM du systeme. Puis, 
#  les resultats sont pipe vers la commande (awk). Avec la regle NR==2 awk indique d'utiliser 
#  les info de la deuxieme ligne seulement (mem:) pour etre en mesure ensuite de 'print' la valeur 
#  situee dans la deuxieme colonne (total) de cette seul ligne.
sys_memory=$(free -m | awk 'NR==2 {print $2}')

# Acquere les donnees relatives a l'espace memoire RAM utilisee
#  La commande (free -m) recupere les infos concernant la memoire RAM du systeme. Puis, 
#  les resultats sont pipe vers la commande (awk). Avec la regle NR==2 awk indique d'utiliser 
#  les info de la deuxieme lignes seulement (mem:) pour etre en mesure ensuite de 'print' la valeur 
#  situee dans la troisieme colonnes (used)  de cette seul ligne.
memory_usage=$(free -m | awk 'NR==2 {print $3}')

# Acquere les donnees relatives a l'espace memoire RAM utilisee sous forme de pourcentage
#  La commande (free -m) recupere les infos concernant la memoire RAM du systeme. Puis, 
#  le resultats sont pipe vers la commande (awk). (Awk) contient la regle NR==2 (qui indique que ce seront 
#  les enregistrements (records) de la deuxieme ligne qui seront traites depuis le fichier d'entre) 
#  S'en suit une action, qui est une formule mathematique {$3/$2*100} ce qui nous permettra d'afficher 
#  le resultat sous forme de pourcentage. Ici, $2 et $3 indique la deuxieme et troisieme enregistrement 
#  de ligne 2 (Colonne 2 et 3), soit la memoire total et celle utiisee.
memory_usage_p=$(free -m | awk 'NR==2 {printf("%.2f"), $3/$2*100}')

# Acquere les donnees relatives a l'espace disque du systeme
#  La fonction (df) avec l'option -Bg retrouvera les informations sur les differentes partitions montees sur le systeme. 
#  Ensuite, les donnes seront pipe vers la commande (grep) qui recherchera toutes les occurences commencant (^) par "/dev/" 
#  et qui transferera le resultats dans une autre commande (grep), qui lui exclura "/boot/" des resultats. pour terminer,
#  le resultat sera pipe vers la commande (awk) qui au passage declare une variable "t_disk" et additionnes a l'interieur  
#  les differentes valeur de la colonne 2 qui represente l espace disque total de chacune des partitions.
disk_on_sys=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{t_disk += $2} END {print t_disk}')

# Acquere les donnees relatives a l'espace disque utilisee
#  La fonction (df) avec l'option -Bg retrouvera les informations sur les differentes partitions montees sur le systeme. 
#  Ensuite, les donnes seront pipe vers la commande (grep) qui recherchera toutes les occurences commencant (^) par "/dev/" 
#  et qui transferera le resultats dans une autre commande (grep), qui lui exclura "/boot/" des resultats. pour terminer,
#  le resultat sera pipe vers la commande (awk) qui au passage declare une variable "t_disk" et additionnes a l'interieur  
#  les differentes valeur de la colonne 2 qui represente l espace disque total de chacune des partitions.
disk_usage=$(df -Bg | grep '^/dev/' | grep -v '/boot$' | awk '{u_disk += $3} END {print u_disk}')

# Acquere les donnees relatives aux taux d utilisation de l'espace disque en poucentage
#  La fonction (df) avec l'option -Bg retrouvera les informations sur les differentes partitions montees sur le systeme. 
#  Ensuite, les donnes seront pipe vers la commande (grep) qui recherchera toutes les occurences commencant (^) par "/dev/" 
#  et qui transferera le resultats dans une autre commande (grep), qui lui exclura "/boot/" des resultats. pour terminer,
#  le resultat sera pipe vers la commande (awk) qui au passage declare une variable "t_disk" et "u_disk" et additionnes  
#  a l'interieurs les differentes valeur de la colonne 2 et 3 respectivement qui represente l espace disque total 
#  de chacune des partitions et c'elle utilise. Puis, les variables sont utilisees dans une operation destinee a donner 
#  un resultat en pourcentage de l'utilisation actuel.
disk_usage_p=$(df -Bg | grep '^/dev/' | grep -v 'boot$' | awk '{t_disk += $2} {u_disk += $3} END {printf("%d"), (u_disk/t_disk)*100}')

# Acquere les donnees relatives au dernier demarrage systeme
last_reboot=$(who -b | awk '{NR==1} END {print $3" "$4}')

# Acquere le status de LVM
#  La condition (if) determinera l'action a prendre en fonction que le terme 'lvm' ce retrouve au moins fois 
#  ou pas dans a l'affichage de la commande (lsblk). Seul la colonne 'TYPE' affichee par (lsblk) sera garde grace avec 
#  la commande (cut). Ensuite la commande (grep) isolera les lignes ou l'occurence est trouvée. Puis finalement, 
#  la commande (wc -l) contera le nombre de ligne restante ce qui indiquera le nombre de fois que le terme 'lvm' est present.  
lvm_status=$(if [ $(lsblk | cut -f6 | grep 'lvm' | wc -l) -eq 0 ]; then echo no; else echo yes; fi) 

# Acquere le nombre de connection active sur le protocole TCP
connexion_tcp=$(ss -t | grep 'ESTAB' | wc -l)

# Aquiere le nombre d'utilisateur actifs sur le systeme 
active_user=$(who | wc -l)

# Acquere l'adresse IP du systeme
ip_addr=$(hostname -I)

# Aquiere l'adresse MAC du systeme 
mac_addr=$(ip link show | awk '{$1 == "link/ether"} END {print $2}')  

# Aquiere le nombre d'invocation de la commande sudo depuis le debut des temps
sudo_count=$(cat /var/log/sudo/log | grep 'COMMAND' | wc -l)

# Partie de Test
echo -e "Architecture: ${arc}"
echo -e "CPU physical : ${physical_CPU}" 
echo -e "vCPU : ${logical_CPU}"
echo -e "Memory Usage: ${memory_usage}/${sys_memory}MB (${memory_usage_p}%)"
echo -e "Disk Usage: ${disk_usage}/${disk_on_sys}Gb (${disk_usage_p}%)"
echo -e "CPU Load: ${CPU_load}%"
echo -e "Last boot: ${last_reboot}"
echo -e "LMV use: ${lvm_status}"
echo -e "Connexions TCP : ${connexion_tcp} ESTABLISHED"
echo -e "User log: ${active_user}"
echo -e "Network: IP ${ip_addr}(${mac_addr})"
echo -e "Sudo ${sudo_count} cmd"