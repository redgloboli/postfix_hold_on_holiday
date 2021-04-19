#!/usr/bin/env python3

import datetime
import holidays

now = datetime.datetime.now()
for Holiday in holidays.DE(prov='BY', years=[now.year, now.year+1], expand='False'):
    print(Holiday)
