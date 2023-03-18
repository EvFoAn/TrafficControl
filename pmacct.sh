#!/bin/bash

DB_DIR='/opt/TrafficControl'
device='wlan0'


crtChannelRRD(){
for period in hour day week month year; do
    rrdtool create $DB_DIR/rrd/$device-$period.rrd --step 60 --start 0 \
	     DS:in_bytes:GAUGE:600:U:U \
             DS:out_bytes:GAUGE:600:U:U \
             RRA:AVERAGE:0.5:1:600 \
             RRA:AVERAGE:0.5:6:700 \
             RRA:AVERAGE:0.5:24:775 \
             RRA:AVERAGE:0.5:288:797 \
             RRA:MAX:0.5:1:600 \
             RRA:MAX:0.5:6:700 \
             RRA:MAX:0.5:24:775 \
             RRA:MAX:0.5:288:797
done
}

if [ ! -f $DB_DIR/rrd/$device-day.rrd ]; then
	crtChannelRRD
   fi


# RRD file update function

function update_rrd_device() {

  ip_address=$1
  in_bytes=$2
  out_bytes=$3

  rrdtool update $DB_DIR/rrd/$device-hour.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$device-day.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$device-week.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$device-month.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$device-year.rrd N:$in_bytes:$out_bytes

}

function update_rrd() {

  ip_address=$1
  in_bytes=$2
  out_bytes=$3

  # Обновление RRD файла за последнюю минуту
  rrdtool update $DB_DIR/rrd/$ip_address-hour.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$ip_address-day.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$ip_address-week.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$ip_address-month.rrd N:$in_bytes:$out_bytes
  rrdtool update $DB_DIR/rrd/$ip_address-year.rrd N:$in_bytes:$out_bytes

}


while true; do

    pmacct -s -p /tmp/pmacct_in.pipe > /tmp/ipaddrcount_in
    pmacct -s -p /tmp/pmacct_out.pipe > /tmp/ipaddrcount_out

    _in_bytes01=$(cat /sys/class/net/$device/statistics/rx_bytes)
    _out_bytes01=$(cat /sys/class/net/$device/statistics/tx_bytes)
  
    sleep 60

    _in_bytes02=$(cat /sys/class/net/$device/statistics/rx_bytes)
    _out_bytes02=$(cat /sys/class/net/$device/statistics/tx_bytes)

    in_bytes=$(( $_in_bytes02 - $_in_bytes01 ))
    out_bytes=$(( $_out_bytes02 - $_out_bytes01 ))
    
    input_bytes=$(awk -v num1=$in_bytes 'BEGIN { printf "%3.3f\n", num1 * 8 / (1024 * 1024 * 60 )  }')
    output_bytes=$(awk -v num1=$out_bytes 'BEGIN { printf "%3.3f\n", num1 * 8 / (1024 * 1024 * 60 ) }')

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Записываем результат в базу данных
    sqlite3 ${DB_DIR}/traffic.db "INSERT INTO traffic ( ip_address, timestamp, total_in_pks, total_out_pks ) VALUES ( '127.0.0.1', '$timestamp', '$in_bytes', '$out_bytes' )"

    # Обновляем RRD файл
    echo  $device $input_bytes $output_bytes "|" $count_total_input_bytes "<>" $count_totla_output_bytes
    update_rrd_device $device $input_bytes $output_bytes

    _ip_addresses=$(sqlite3 ${DB_DIR}/traffic.db "SELECT ip_address FROM ip_addresses")

 for ip_address in $_ip_addresses; do

    s_ip_address=$( echo $ip_address | sed -e 's/\./\\./g' )

    in_last=$( cat /tmp/ipaddrcount_in | grep -w "$s_ip_address" | awk '{ print $3 }' | grep -e "[0-9]" )
    out_last=$( cat /tmp/ipaddrcount_out | grep -w "$s_ip_address" | awk '{ print $3 }' | grep -e "[0-9]"  )

    in_now=$( pmacct -s -p /tmp/pmacct_in.pipe | grep -w "$s_ip_address" | awk '{ print $3 }' | grep -e "[0-9]" )
    out_now=$( pmacct -s -p /tmp/pmacct_out.pipe | grep -w "$s_ip_address" | awk '{ print $3 }' | grep -e "[0-9]" )

    if [[ ! -z $in_now ]] || [[ ! -z $in_last ]]; then
       in=$( expr $in_now - $in_last ) ; 
    fi

    if [[ ! -z $out_now ]] || [[ ! -z $out_last ]]; then
       out=$( expr $out_now - $out_last )
    fi

    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # (speed_bits * 8) / (interval_seconds * 1000000)

    in_bytes=$(awk -v num1=$in 'BEGIN { printf "%3.3f\n", num1 * 8 /  ( 60 * 1000000 )  }')
    out_bytes=$(awk -v num1=$out 'BEGIN { printf "%3.3f\n", num1 * 8 / ( 60 * 1000000 )  }')

    # Выводим результат на экран по IP адресам:
    echo "$timestamp: IP $ip_address, Incoming speed: $in_bytes Kbps, Outgoing speed: $out_bytes Kbps | $in <> $out"

    # Записываем результат в базу данных
    sqlite3 ${DB_DIR}/traffic.db "INSERT INTO traffic (ip_address, timestamp, in_bytes, out_bytes, in_pks, out_pks ) VALUES ('$ip_address', '$timestamp', '$in_bytes', '$out_bytes', '$in', '$out' )"
  
    # Обновляем RRD файл
    update_rrd $ip_address $in_bytes $out_bytes
  
   done
   echo "Channel: In:$input_bytes Out:$output_bytes"
done
