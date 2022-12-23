#! /bin/bash

set -ex

exec >> /var/log/app.log 2>&1

cat <<EOF > /tmp/sample.py
#! /usr/bin/env python3

import logging
import datetime
import time

# https://stackoverflow.com/questions/10706547/add-encoding-parameter-to-logging-basicconfig

root_logger= logging.getLogger()
root_logger.setLevel(logging.DEBUG) 
handler = logging.FileHandler('/tmp/sample.log', 'a+', 'utf-8') 
formatter = logging.Formatter('%(levelname)s:%(name)s:%(message)s') 
handler.setFormatter(formatter) 
root_logger.addHandler(handler)

i = 1
while i > 0:
    logging.info('%s: This message line number is %s', str(datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ")), str(i))
    time.sleep(1)
    i = i + 1

EOF

chmod +x /tmp/sample.py
nohup /tmp/sample.py >/dev/null 2>&1 &  
