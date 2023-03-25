
<a href="https://git.io/typing-svg"><img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=900&size=25&pause=1000&width=900&height=200&lines=This+app+is+for+Raspberry+2%2F3%2F4%2C++OrangePi*+%26+Linux+OS+etc" alt="Typing SVG" /></a>


# This application can display the speed of internet traffic and calculate the transmitted data by IP addresses, as well as calculate all internet traffic. 


---

Here is the description, we have two Ethernet adapters:

ens18  - this internal interface [ 10.200.0.0/16 ]
ens19  - this external interface [ External IP   ]

pmacct listen internal interface ens18

traffic_control.py should listen on ens19 

In pmacct.sh file change $device=ens19 var to count global traffic.


---

apt-get install librrd-dev sqlite3 libsqlite3-dev libsqlite3-0 rrdtool python3.X-dev python3 python3-pip pmacct

pip3 install rrdtool

pip3 install flask-debugtoolbar

pip3 install flask

cd /opt/ ; git clone https://github.com/EvFoAn/TrafficControl.git

# Merge configuration file from catalog
cd /opt/TrafficControl/ ; cp -Rp pmacct_config/etc/* to /etc/pmacct/

# Change the device name and IP network addresses in file

/etc/pmacct/pmacctd-pnrg.conf

# Run pmacctd daemon

pmacctd -i ens18 -f /etc/pmacct/pmacctd-pnrg.conf

pmacctd -i ens18 -f /etc/pmacct/pmacctd.conf ;

# Create SQLite3 DB file:

cd /opt/TrafficControl/ ; ./create_db.py

# Example run PMACCT command from screen:

cd /opt/TrafficControl

screen -d -m -A -S PMACCT ./pmacct.sh


# Example run TC command from screen:

cd /opt/TrafficControl

screen -d -m -A -S TRAFFIC ./traffic_controle.py 0.0.0.0 10000 ens19


![alt text](https://github.com/EvFoAn/TrafficControl/blob/main/traffic_control.png)


# Traffic Control in Docker. 

# 1. Install pmacct on host system

apt install pmacct

# Clone remote repositoy

cd /opt ; git clone https://github.com/EvFoAn/TrafficControl.git

# Merge configuration file from catalog
mv /etc/pmacct/ /etc/pmacct.orig

ln -s /opt/TrafficControl/pmacct_config/etc /etc/pmacct

# Change the device name and IP network addresses in file:
/etc/pmacct/pmacctd-pnrg.conf

# Run pmacctd daemon

pmacctd -i ens18 -f /etc/pmacct/pmacctd-pnrg.conf

pmacctd -i ens18 -f /etc/pmacct/pmacctd.conf ;

# Change device
vim ./pmacct.sh
... device='ens18' ...

# Run pmacct_traffic_control
cd /opt/TrafficControl

/usr/bin/screen -d -m -A -S PMACCT ./pmacct.sh

# 2. Next build docker container

# Create dir for build

mkdir /opt/build ;

cd /opt/build ;

# Create Dockerfile

cat >> Dockerfile <<EOF

FROM debian:latest

RUN apt-get update && apt-get install -y python3 python3-pip git librrd-dev sqlite3 libsqlite3-dev libsqlite3-0 rrdtool pmacct

RUN pip3 install rrdtool flask-debugtoolbar flask

CMD ["python3", "/opt/TrafficControl/traffic_count.py", "0.0.0.0", "10000", "ens18"]

EOF

# Create container

docker build .


.......

.......

Step 4/4 : CMD ["python3", "/opt/TrafficControl/traffic_count.py", "0.0.0.0", "10000", "ens18"] ---> Running in 41cc4fb92e0d

Removing intermediate container 41cc4fb92e0d

---> a4fffd00378a

Successfully built a4fffd00378a

# Run container

docker run -it -p 10000:10000 -v /opt/TrafficControl:/opt/TrafficControl a4fffd00378a

# Commit container

docker commit 7634dab49b86 tc:latest

# Start container

docker start 7634dab49b86

Open browser and check connection to port 10000
