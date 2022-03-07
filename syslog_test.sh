#!/bin/bash
# rsyslog testing
# version 0.3
# use ssh-copy-id to allow remote command execution


TEST_PROTO=tcp
TEST_NAME=file_queue_1
RECEIVER=192.168.233.32

systemctl restart rsyslog
ssh $RECEIVER 'rm /var/log/messages'
ssh $RECEIVER 'systemctl restart rsyslog'


ssh $RECEIVER 'killall -9 tcpdump'
ssh $RECEIVER "tcpdump -pnns0 port 514 -w ${TEST_NAME}_${TEST_PROTO}_receiver.pcap &>/dev/null &"

killall -9 tcpdump
tcpdump -pnns0 port 514 -w ${TEST_NAME}_${TEST_PROTO}_sender.pcap &>/dev/null &

let eventid=0

date
echo starting $TEST_NAME $TEST_PROTO

while true
  do 
    let eventid=$eventid+1
    modulo=$(($eventid%10000))
    logger "test=${TEST_NAME}_${TEST_PROTO} eventid=${eventid}"

    if [[ $modulo -eq 0 ]]
      then
        date | tr -d "\n"
        echo -n " $eventid "
        ps aux | grep [r]syslog | awk '{print $2,$3,$4,$5,$6}'
    fi

    if [[ $eventid -eq 30000 ]]
      then
        date | tr -d "\n"
        echo " blocking port"
        iptables -A OUTPUT -p $TEST_PROTO --dport 514 -j DROP
    fi

    if [[ $eventid -eq 130000 ]]
      then
        date | tr -d "\n"
        echo " unblocking port"
        iptables -F OUTPUT
    fi

    if [[ $eventid -eq 150000 ]]
      then
        date | tr -d "\n"
        echo " stop sending"
        echo waiting 10 sec
        sleep 10
        echo killing remote tcpdump
        ssh $RECEIVER 'killall tcpdump'
        echo killing local tcpdump
        killall -9 tcpdump
        exit
    fi


  done
