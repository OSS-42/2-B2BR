#!/bin/sh
# Color code
#BOLD="\e[1m"
#ITALICS="\e[3m"
#UNDERLINE="\e[4m"
#RED="\e[32m"
#GREEN="\e[32m"
#LIGRAY="\e[37m"
#RESET="\e[0m"

#********** ARCHITECTURE **********
ARC=$(uname -a)

#*********** CPU Usage ************
pCPU=$(lscpu | grep 'Socket' | awk '{print $2}')
vCPU=$(lscpu | grep -m 1 'CPU(s)' | awk '{print $2'})
CPU_load=$(vmstat | 'NR==3 {printf("%.2f %%\n"), 100 - $15}')

#******** RAM & HDD Usage *********
RAM_tot=$(free -m | grep 'Mem' | awk '{print $2}')
RAM_used=$(free -m | grep 'Mem' | awk '{print $3}')
RAM_perc=$(free -m | grep 'Mem' | awk '{used += $3} {tot += $2} END {printf("%.2f"), used/tot*100}')

HDD_tot=$(df -Bm | grep ^/dev/ | awk '{tot += $2} END {print tot}')
HDD_used=$(df -Bm | grep ^/dev/ | awk '{used += $3} END {print used}')
HDD_perc=$(df -Bm | grep ^/dev/ | awk '{tot += $2} {used += $3} END {printf("%.2f"), used/tot*100}')

#********** SYSTEM Usage **********
LVM_status=$(lsblk | awk '{if ($6 = "lvm") {print "active";exit} else print "inactive";exit}')
TCP_conn=$(ss -t | grep 'ESTAB' | wc -l)
IP_add=$(hostname -I)
MAC_add=$(ip a | grep 'ether' | awk '{print $2}')
LAST_reboot=$(who -b | awk '{NR==1} END {print $3" "$4}')

#*********** USER Stats ***********
USER_act=$(who | wc -l)
SUDO_count=$(cat /var/log/sudo/log | grep 'COMMAND' | wc -l)

#******** PROMPT PRINTING *********
printf "ARCHITECTURE : %s\n" "$ARC"
printf "pCPU : % 33d\n" "$pCPU"
printf "vCPU : % 33d\n" "$vCPU"
printf "Memory Usage : % 20d%s%d%s%.2f%s\n" "$RAM_used" "/" "$RAM_tot" "MB (" "$RAM_perc" "%)"
printf "Disk Usage : % 22d%s%d%s%.2f%s\n" "$HDD_used" "/" "$HDD_tot" "MB (" "$HDD_perc" "%)"
printf "CPU Load : % 29.2f %%\n" "$CPU_load"
printf "Last Reboot : % 26s\n" "$LAST_reboot"
printf "LVM Status : % 27s\n" "$LVM_status"
printf "Active TCP Connexions : % 16d\n" "$TCP_conn"
printf "Connected Users : % 22d\n" "$USER_act"
printf "Network : % 31s%s%s%s\n" "$IP_Add" "(/)" "$MAC_add" ")"
printf "Sudo Commands : % 24s\n" "$SUDO_count"