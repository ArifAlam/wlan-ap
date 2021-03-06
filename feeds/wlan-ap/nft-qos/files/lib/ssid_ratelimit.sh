#!/bin/sh
. /lib/functions.sh
. /lib/nft-qos/core.sh

# append rule for ssid_ratelimit qos
qosdef_append_rule_ssid() { # <section> <operator> <bridge>
	local unit rate iface rlimit
	local operator=$2
	local bridge=$3

	iface=$1

	br=`/usr/opensync/bin/ovsh s Wifi_VIF_Config bridge -w if_name==$iface | grep -ic $bridge`
	if [ $br -eq 0 ]; then
		return
	fi

	config_get disabled $1 disabled
	if [ "$disabled" == "1" ]; then
		return
	fi

	config_get rlimit $1 rlimit
	if [ -z "$rlimit" -o "$rlimit" == "0" ]; then
		return
	fi

	config_get unit $1 unit
	if [ -z "$unit" ]; then
		unit=kbytes
	fi

	if [ $operator == "oif" ]; then
		config_get rate $1 drate $4
		# Convert from Kbits to KBytes
		rate=$((rate/8))
	fi

	if [ $operator == "iif" ]; then
		config_get rate $1 urate $4
		# Convert from Kbits to KBytes
		rate=$((rate/8))
	fi

	if [ -z "$iface" ]; then
		logger -t "nft-qos" "Error: No interface $iface present"
		return
	fi

	if [ -z "$rate" -o $rate == 0 ]; then
		logger -t "nft-qos" "ssid-rate disabled $iface, configure client-rate"
	        maclist=`iwinfo $iface assoclist | grep dBm | cut -f 1 -s -d" "`

		for mac in $maclist
		do
			logger -t "nft-qos" "Add $mac"
			/lib/nft-qos/mac-rate.sh add $iface $mac
		done
		return
	fi

	state=`cat /sys/class/net/$iface/operstate`
	if [ -f "/sys/class/net/$iface/carrier" ]; then
		logger -t "nft-qos" "$iface carrier exists"
	fi
	logger -t "nft-qos" "$iface state=$state"

	logger -t "nft-qos" "Add rule $iface $operator $unit $rate"
	qosdef_append_rule_iface_limit $iface $operator $unit $rate

	maclist=`iwinfo $iface assoclist | grep dBm | cut -f 1 -s -d" "`

	for mac in $maclist
	do
		logger -t "nft-qos" "Add $mac"
		/lib/nft-qos/mac-rate.sh add $iface $mac
	done
}

# append chain for static qos
qosdef_append_chain_ssid() { # <hook> <name> <section> <bridge>
	local hook=$1 name=$2
	local config=$3 operator
	local bridge=$4
	case "$name" in
		download*) operator="oif";;
		upload*) operator="iif";;
	esac

	uci_load wireless
	qosdef_appendx "\tchain $name {\n"
	qosdef_append_chain_def filter $hook 0 accept
	qosdef_append_rule_limit_whitelist $name
	config_foreach qosdef_append_rule_ssid $config $operator $bridge
	qosdef_appendx "\t}\n"
}

qosdef_flush_ssid_ratelimit() {
	logger -t "nft-qos" "flush"
	qosdef_flush_table "$NFT_QOS_BRIDGE_FAMILY" nft-qos-ssid-lan-bridge
}

# ssid ratelimit init
qosdef_init_ssid_ratelimit() {
	exec 500>/tmp/rlimit.lock
	flock 500
	local dchain
	local uchain

	logger -t "nft-qos" "`date -I'seconds'` "INIT" $0"

	qosdef_appendx "table $NFT_QOS_BRIDGE_FAMILY nft-qos-ssid-lan-bridge {\n"

	local hook_ul="forward" hook_dl="forward"
	uchain="upload"
	dchain="download"
	qosdef_append_chain_ssid $hook_ul $uchain wifi-iface wan
	qosdef_append_chain_ssid $hook_dl $dchain wifi-iface wan

	local hook_ul="input" hook_dl="output"
	uchain="upload_nat"
	dchain="download_nat"
	qosdef_append_chain_ssid $hook_ul $uchain wifi-iface lan
	qosdef_append_chain_ssid $hook_dl $dchain wifi-iface lan

	qosdef_appendx "}\n"

	exec 500>&-
}
