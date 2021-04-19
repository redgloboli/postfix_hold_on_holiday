#!/bin/bash

# for debugging
#set -x

# Configuration:
# VDAYFROM = first day of vacation
# VDAYTILL = last day of vacation
# VTIMEFROM = hold from time at first day of vacation
# VTIMETILL = hold off at time from lat day of vacation
# ONTIME = hold from time on saturday
# OFFTIME = hold off at time on monday

DAYOFWEEK=$(date +"%u")
HOLIDAY=$(/usr/bin/python3 /etc/postfix/scripts/holidays.py | grep `date +%F`)
NOW=$(date +"%H%M")
ONTIME=1300
OFFTIME=0600

# Vacation
VDATE=$(date +"%F")
VDAYFROM=2021-03-29
VDAYTILL=2021-04-01
VTIMEFROM=0600
VTIMETILL=2000

if [[ -n $HOLIDAY || ($DAYOFWEEK -eq 7) ]]; then
   # Holiday -> HOLD or Sunday = Holiday -> HOLD
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ($DAYOFWEEK -eq 1) && ! -n $HOLIDAY && "$NOW" < "$OFFTIME" ]]; then
   # Monday and not holiday before 6 o'clock am -> HOLD
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ($VDATE == $VDAYFROM) && ($NOW > $VTIMEFROM) ]]; then
   # Vacation -> redirect e-mail
   grep -qsxF 'redirect "user@redirect.to";' /path/to/sieve-script/sieve/sogo.sieve || printf "redirect \"user@redirect.to\";\n" >> /path/to/sieve-script/sogo.sieve
   chown vmail:vmail /path/to/sieve-script/sieve/sogo.sieve
   chmod 600 /path/to/sieve-script/sieve/sogo.sieve
   ln -fs sieve-script/sogo.sieve /path/to/sieve-script/.dovecot.sieve
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ($VDATE > $VDAYFROM) && ($VDATE < $VDAYTILL) ]]; then
   # Vacation -> HOLD
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ($VDATE == $VDAYTILL) && ($NOW < $VTIMETILL) ]]; then
   # Vacation -> HOLD
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ($VDATE == $VDAYTILL) && ($NOW > $VTIMETILL) ]]; then
   # End of vacation -> undo redirect -> HOLD OFF
   sed -i '/redirect "user@redirect.to";/d' /path/to/sieve-script/sieve/sogo.sieve
   sed -i '/^[^#]/ s/^/#/' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold
   sleep 20
   /usr/sbin/postsuper -r ALL

elif [[ ($DAYOFWEEK -eq 1) && ! -n $HOLIDAY && "$NOW" > "$OFFTIME" ]]; then
   # Monday and not holiday from 6 o'clock am -> HOLD OFF
   sed -i '/^[^#]/ s/^/#/' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold
   sleep 20
   /usr/sbin/postsuper -r ALL

elif [[ ($DAYOFWEEK -eq 6) && ! -n $HOLIDAY && "$NOW" > "$ONTIME" ]]; then
   # Saturday and not holiday from 1 o'clock pm -> HOLD
   sed -i 's|[#,]||g' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold

elif [[ ! -n $HOLIDAY ]]; then
   # not holiday  -> HOLD OFF
   sed -i '/^[^#]/ s/^/#/' /etc/postfix/hold
   /usr/sbin/postmap hash:/etc/postfix/hold
   sleep 20
   /usr/sbin/postsuper -r ALL
fi
