#!/bin/bash

function e {
        echo -e "$1"
}

wallet2_status() {
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

	while read line ;do
        	if [[ $line =~ \" ]];then
	                #set -- $line
        	        addr=`echo $line | tr -d '",'`
                	cmd="$cli2 z_getbalance $addr"
	                { echo "$addr:"; $cmd; echo " ("; $cmd 0; echo ")"; } | paste -d" " -s
        	fi
	done < <($cli2 z_listaddresses)
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

_wallet2_generate_addresses() {
        echo "Generating new addresses ..."
#	for a in {1..3}
#	do
#        	t1=$($cli2 getnewaddress)
#	        t1_priv=$($cli2 dumpprivkey $t1)
#		echo "$t1:$t1_priv" >> $datadir/new_addresses
#	done

	t1=$($cli2 getnewaddress)
        t1_priv=$($cli2 dumpprivkey $t1)
        echo "coinbase:$t1:$t1_priv" >> $datadir/new_addresses

	t2=$($cli2 getnewaddress)
        t2_priv=$($cli2 dumpprivkey $t2)
        echo "payer:$t2:$t2_priv" >> $datadir/new_addresses

	t3=$($cli2 getnewaddress)
        t3_priv=$($cli2 dumpprivkey $t3)
        echo "fee:$t3:$t3_priv" >> $datadir/new_addresses

	z1=$($cli2 z_getnewaddress)
        z1_priv=$($cli2 z_exportkey $z1)
        echo "shield:$z1:$z1_priv" >> $datadir/new_addresses

	cat $datadir/new_addresses
	e "\n"
}

import_old_addresses_no_rescan() {
	set -f                      # avoid globbing (expansion of *).
	echo	
	filename="$datadir/old_addresses"
	while read -r line; do
		array=(${line//:/ })
		label=${array[0]}
		addr=${array[1]}
		priv=${array[2]}

		echo "$label:$addr"
		if [ $label == "shield" ]; then
			echo "$cli2 z_importkey $priv no"
		else
			echo "$cli2 importprivkey $priv \"\" false"
			$cli2 importprivkey $priv "" false
		fi

		echo "======================================================================================="
	done < "$filename"

	echo
}

wallet2_get_new_z() {
	$cli2 z_getnewaddress
}

# first_tx is the tx of the first block found AFTER the old keys have been imported into the new wallet
# When this tx is changed from "immature" to "generate" we are safe to make the wallets switch :)
wallet2_check_first_tx() {
        set -f                      # avoid globbing (expansion of *).
        echo    
        filename="$datadir/old_addresses"
        while read -r line; do
                array=(${line//:/ })
                label=${array[0]}
		first_tx=${array[1]}
		
                if [ $label == "first_tx" ]; then
                        $cli2 gettransaction $first_tx
                	echo "======================================================================================="
                fi

        done < "$filename"

        echo
}

source config.sh

echo "Wallet Swipe tool"
echo "---------------------------------"
echo " Second Wallet  : $datadir"
echo " Cli : $cli"
echo

prompt="Pick an option:"
options=("Wallet2 Status" "Start $datadir" "Stop $datadir" "Erase $datadir/$wallet" "Generate new wallet2 t1,t2,t3,z addresses" "Import old t1,t2,t3 privkeys (norescan) into new wallet" "Get new Z address"  "Check first wallet2 tx status")

PS3="$prompt "
select opt in "${options[@]}" "Quit"; do
case $opt in

	${options[0]}) wallet2_status;;
	${options[1]}) wallet2_start;;
	${options[2]}) wallet2_stop;;
	${options[3]}) wallet2_erase;;
	${options[4]}) wallet2_generate_addresses;;
	${options[5]}) import_old_addresses_no_rescan;;
	${options[6]}) wallet2_get_new_z;;
	${options[7]}) wallet2_check_first_tx;;
	"Quit" ) echo "Bye"; break;;
	*) echo "$opt Invalid option"; continue;;
esac
done


