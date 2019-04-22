#!/bin/bash
cli="snowgem-cli"


echo -e "\n======== Status ============"
{ echo "versions:"; $cli getinfo |grep version |grep -Eo '[0-9]+'; } | paste -d" " -s


echo -e "\n======== Wallet synced ? Block info ============"
{ echo "cli block:"; $cli getinfo |grep block |grep -Eo '[0-9]+'; } | paste -d" " -s
{ echo "api block:"; curl -s https://explorer.snowgem.org/api/status |json_pp |grep blocks |grep -Eo '[0-9]+'; } | paste -d" " -s

echo -e "\n======== Balance ============"
#echo -e "\n$cli listaddressgroupings"
echo -e "\n$cli z_gettotalbalance"
$cli z_gettotalbalance

echo -e "\n======== Addresses ============"
while read line ;do
        if [[ $line =~ \" ]];then
                #set -- $line
                addr=`echo $line | tr -d '",'`
                cmd="$cli z_getbalance $addr"
                { echo "$addr:"; $cmd; echo " ("; $cmd 0; echo ")"; } | paste -d" " -s
        fi
done < <($cli getaddressesbyaccount "")

while read line ;do
        if [[ $line =~ \" ]];then
                #set -- $line
                addr=`echo $line | tr -d '",'`
                cmd="$cli z_getbalance $addr"
                { echo "$addr:"; $cmd; echo " ("; $cmd 0; echo ")"; } | paste -d" " -s
        fi
done < <($cli z_listaddresses)


echo -e "\n========== Executing OP ids ==============="
$cli z_listoperationids executing

echo -e "\n========== Queued OP ids ==============="
$cli z_listoperationids queued

echo -e "\n========== Failed OP ids ==============="
$cli z_listoperationids failed



#$cli listaddressgroupings |grep -i -E "22bac|ttqt|abpzt" -A 1
