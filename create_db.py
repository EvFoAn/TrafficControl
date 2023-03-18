#!/usr/bin/python3

import sqlite3
import os
import rrdtool
import time


# Connecting to a SQLite3 database
conn = sqlite3.connect('traffic.db')
c = conn.cursor()

# Create the ipaddres and traffic table if they don't already exist
c.execute('''CREATE TABLE IF NOT EXISTS ip_addresses
             (id INTEGER PRIMARY KEY AUTOINCREMENT, ip_address TEXT NOT NULL UNIQUE, comment TEXT)''')

c.execute('''INSERT INTO ip_addresses (ip_address, comment) VALUES (?, ?)''', ('192.168.1.1', 'WiFi'))

c.execute('''CREATE TABLE IF NOT EXISTS traffic
             (id INTEGER PRIMARY KEY AUTOINCREMENT,
             ip_address TEXT NOT NULL,
             timestamp INTEGER,
             in_bytes FLOAT,
             out_bytes FLOAT,
             total_bytes FLOAT,
             in_pks FLOAT,
             out_pks FLOAT,
             total_in_pks FLOAT,
             total_out_pks FLOAT,
             ip_id INTEGER,
             FOREIGN KEY(ip_id) REFERENCES ip_addresses(id))''')

conn.commit()


for period in ('hour', 'day', 'week', 'month', 'year'):
        rrd_file = 'rrd/{0}-{1}.rrd'.format('192.168.1.1', period)
        if not os.path.isfile(rrd_file):
           rrdtool.create(rrd_file,
            '--start', str(int(time.time()) - 360),
            '--step', '60',
            'DS:in_bytes:GAUGE:600:U:U',
            'DS:out_bytes:GAUGE:600:U:U',
            'RRA:AVERAGE:0.5:1:600',
            'RRA:AVERAGE:0.5:6:700',
            'RRA:AVERAGE:0.5:24:775',
            'RRA:AVERAGE:0.5:288:797',
            'RRA:MAX:0.5:1:600',
            'RRA:MAX:0.5:6:700',
            'RRA:MAX:0.5:24:775',
            'RRA:MAX:0.5:288:797')

