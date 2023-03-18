
1.  apt-get install librrd-dev sqlite3 libsqlite3-dev libsqlite3-0 rrdtool python3.X-dev python3 python3-pip pmacct

2.  pip3 install rrdtool 
    pip3 install flask-login 
    pip3 install flesk

3.  cd /opt/ ; git clone repository

4.  Merge configuration file from catalog
    cd /opt/tInspector/ ; cp -Rp pmacct_config/etc/* to /etc/pmacct/

5.  Change the device name and IP network addresses in file - /etc/pmacct/pmacctd-pnrg.conf

6.  Create SQLite3 DB file: 
    cd /opt/tInspector/ ; ./create_db.py

7.  Example run PMACCT command from screen:
    cd /opt/tInspector
    # screen -d -m -A -S PMACCT ./pmacct.sh

8.  Example run TC command from screen:
    cd /opt/tInspector
    # screen -d -m -A -S TRAFFIC ./traffic_controle.py 0.0.0.0 10000 wlan0

