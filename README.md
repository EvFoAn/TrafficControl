# Internet Traffic Control

#apt-get install librrd-dev sqlite3 libsqlite3-dev libsqlite3-0 rrdtool python3.X-dev python3 python3-pip pmacct

#pip3 install rrdtool
#pip3 install flask-login
#pip3 install flesk

#cd /opt/ ; git clone repository

#Merge configuration file from catalog
cd /opt/tInspector/ ; cp -Rp pmacct_config/etc/* to /etc/pmacct/

#Change the device name and IP network addresses in file - /etc/pmacct/pmacctd-pnrg.conf

#Create SQLite3 DB file:
cd /opt/tInspector/ ; ./create_db.py

#Example run PMACCT command from screen:\n
cd /opt/tInspector\n
screen -d -m -A -S PMACCT ./pmacct.sh

#Example run TC command from screen:\n
cd /opt/tInspector\n
screen -d -m -A -S TRAFFIC ./traffic_controle.py 0.0.0.0 10000 wlan0
