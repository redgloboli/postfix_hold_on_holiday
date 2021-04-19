# postfix_hold_on_holiday
Holds mail delivery in postfix if its a holiday, or a specified day or/and time.

I wrote this to set a specific user on hold queue in postfix for a specific time (e.g. when he's in vacation and on specific days and times during the week) or in general when we have holidays.

At the moment the vacation part only works with one user due to the vacation settings only implemented for this particular case.

The general hold for holidays would work for as many mail adresses you put in the hold file, even whole domains.

holiday.py uses the python module found here:

https://pypi.org/project/holidays/

**Usage:**

create the file **hold** in **/etc/postfix**

do a **'postmap hold'**

add the line **check_recipient_access hash:/etc/postfix/hold** to **smtpd_recipient_restrictions =** in **main.cf**

copy the scripts **hold.sh** and **holiday.py** to a location you like and adjust the script/crontab accordingly

add a crontab entry like this (runs every full hour ):

0 * * * * /bin/bash /etc/postfix/scripts/hold.sh

I uploaded this to get some experience in scripting/coding and git usage. 

Maye someone finds it useful :)
