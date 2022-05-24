#!/bin/sh

#minutes and seconds form boot time
BOOT_m=$(uptime -s | cut -d ":" -f 2)
BOOT_s=$(uptime -s | cut -d ":" -f 3)

#%10 will get the min passed the previous 10th min of an hour
#if 9h53--> 53 % 10 = 3min (so 3min after the prvious 10th (50))
#convert 3 min into seconds and add seconds from boot time
#if 9h53m45s : 3min = 180s +45s = 225s.
#so we need to delay by 225s after each 10th min of a hour.
#10min +225s, 20min +225s, etc...
#bc = basic calculator
#<<< = here string
DELAY=$(bc <<< $BOOT_m%10*60+$BOOT_s)

sleep $DELAY