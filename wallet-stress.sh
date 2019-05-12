#!/bin/bash

function e {
        echo -e "$1"
}

wallet2_detailed_balance() {
        $cli2 getinfo
        echo -e "\n======== Balance ============"
        echo -e "\n$cli2 z_gettotalbalance"
        $cli2 z_gettotalbalance

        echo -e "\n======== Addresses ============"
        while read line ;do
                if [[ $line =~ \" ]];then
                        #set -- $line
                        addr=`echo $line | tr -d '",'`
                        cmd="$cli2 z_getbalance $addr"
                        { echo "$addr:"; $cmd; echo " ("; $cmd 0; echo ")"; } | paste -d" " -s
                fi
        done < <($cli2 getaddressesbyaccount "")
}

wallet2_count_addresses() {
	addr_count=$($cli2 getaddressesbyaccount "" |wc -l)
	let "addr_count = $addr_count - 2"
	e "Wallet addresses: $addr_count\n"
}

wallet2_status() {
        $cli2 getinfo
	echo -e "\n======== Balance ============"
	echo -e "\n$cli2 z_gettotalbalance"
	$cli2 z_gettotalbalance

	echo -e "\n======== Addresses ============"
	$cli2 getaddressesbyaccount ""
	wallet2_count_addresses

	while read line ;do
        	if [[ $line =~ \" ]];then
	                #set -- $line
        	        addr=`echo $line | tr -d '",'`
                	cmd="$cli2 z_getbalance $addr"
	                { echo "$addr:"; $cmd; echo " ("; $cmd 0; echo ")"; } | paste -d" " -s
        	fi
	done < <($cli2 z_listaddresses)

	e "\n========== Wallet Info ============"
        $cli2 getwalletinfo
	
	e "\n========== Wallet Size ============"
	ls -lh $datadir | grep wallet
	e "\n========== Wallet Stats ============"
	echo -e $wallet_stats
	e "\n"
}

wallet2_start() {
        $daemon_path -datadir=$datadir -daemon
	e "\n"
}

wallet2_stop() {
        $cli2 stop
	e "\n"
}

wallet2_erase() {
        echo "Erasing $datadir/$wallet"
        wallet2_stop
	sleep 5
        rm -f $datadir/$wallet
        rm -f $datadir/new_addresses
	wallet2_start
	e "\n"
}

wallet2_generate1k_addresses() {
	echo "Generating new addresses ..."
	for a in {1..1000}
       	do
               t1=$($cli2 getnewaddress)
               #t1_priv=$($cli2 dumpprivkey $t1)
               #echo "$t1_priv:$t1" >> $datadir/new_addresses
       	done
}

wallet2_generate10k_addresses() {
	echo "Generating new addresses ..."
	for a in {1..10000}
       	do
               t1=$($cli2 getnewaddress)
               #t1_priv=$($cli2 dumpprivkey $t1)
               #echo "$t1_priv:$t1" >> $datadir/new_addresses
       	done
}

send_to_9999_addresses() {
	#skip random addresses
	start=$(( ( RANDOM % 52000 )  + 1 ))
	e "\n Start: $start"
	#then consider 1000 addresses
	stop=$(($start+1000))

	step=0
	recipients=""
        while read line ;do
                if [[ $line =~ \" ]];then
			step=$(($step+1))
			if [ "$step" -lt "$start" ] || [ "$step" -gt "$stop" ];then
				continue
			else
                        	addr=`echo $line | tr -d '",'`
	                        recipients="$recipients\\\"$addr\\\":0.0001,"
			fi
                fi
        done < <($cli2 getaddressesbyaccount "")

	cmd_test="$cli2 sendmany \"\" \"{
		\\\"s1ZBftmkGW7XUnJqYzsRbjExBGNBnjcpzR8\\\":0.0001,\
		\\\"s1kYKUtdG9UiR9uoGuNaoYfNaCZTLz9f2gD\\\":0.0001
	}\""
	
	cmd="$cli2 sendmany \"\" \"{${recipients%?}}\""
	echo $cmd
}

regroup_amount() {
        amount=$($cli2 getbalance)

        echo "$cli2 sendtoaddress $group_addr $amount \"\" \"\" true"
        $cli2 sendtoaddress $group_addr $amount "" "" true
}

list_unspent() {
        $cli2 listunspent
        $cli2 listunspent 0 10
}

source config.sh

echo "Wallet Stress tool"
echo "---------------------------------"
echo " Wallet dir : $datadir"
echo " Cli : $cli"
echo

prompt="Pick an option:"
options=("Wallet2 Status" "Start $datadir" "Stop $datadir" "Erase $datadir/$wallet" "Detailed balance" "Generate 1k addresses" "Generate 10k addresses" "Send 1 XSG to 9999 addresses, 0.0001 each" "Regroup balance to $group_addr" "List unspent")

PS3="$prompt "
select opt in "${options[@]}" "Quit"; do
case $opt in

	${options[0]}) wallet2_status;;
	${options[1]}) wallet2_start;;
	${options[2]}) wallet2_stop;;
	${options[3]}) wallet2_erase;;
	${options[4]}) wallet2_detailed_balance;;
	${options[5]}) wallet2_generate1k_addresses;;
	${options[6]}) wallet2_generate10k_addresses;;
	${options[7]}) send_to_9999_addresses;;
	${options[8]}) regroup_amount;;
	${options[9]}) list_unspent;;
	"Quit" ) echo "Bye"; break;;
	*) echo "$opt Invalid option"; continue;;
esac
done


