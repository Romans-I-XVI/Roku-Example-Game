#!/usr/bin/env bash
#
#	This must run with `. configure.sh`, or else export won't work
#

if  [ "$0" != "-bash" ]; then
	echo 'Warning: Please run this script using: ". configure.sh" to allow the enviornment variable ROKU_DEV_TARGET to be updated'
	echo ""
fi

touch .rokuTarget

targetip="$(head -1 .rokuTarget | cut -d\; -f1)"
targetmac="$(head -1 .rokuTarget | cut -d\; -f2)"
passwd="$(head -1 .rokuTarget | cut -d\; -f3)"

shouldUpdate=true;

# read args
shouldRunScript=true
shouldOpenTelnet=false
shouldOpenSG=false
shouldOpenWebInstaller=false
shouldShowHelp=false
shouldPickFromList=false
shouldOpenNRS=false

while [ "$1" != "" ]; do
	if [ "$1" == "-t" ]; then shouldOpenTelnet=true; fi
	if [ "$1" == "-s" ]; then shouldOpenSG=true; fi
	if [ "$1" == "-w" ]; then shouldOpenWebInstaller=true; fi
	if [ "$1" == "-p" ]; then shouldPickFromList=true; fi
	if [ "$1" == "-h" ]; then shouldShowHelp=true; fi
	if [ "$1" == "-n" ]; then shouldOpenNRS=true; fi
	if [ "$1" == "--help" ]; then shouldShowHelp=true; fi
	shift
done

# if it is help, then
if [ "$shouldShowHelp" == "true" ]; then
	shouldRunScript=false
	echo "True[X] Roku Dev Helper"
	echo 'This must run with `. configure.sh`, or else export would not work'
	echo ""
	echo "Args:"
	echo "-t		Open BrightScript console"
	echo "-s		Open SceneGraph console"
	echo "-w		Open web Development Application Installer"
	echo "-n		Open Not-A-RokuSimulator"
	echo "-p		Overwrite .rokuTarget by picking a new Roku from a list of local devices"
	echo "-h --help	Show current page"
fi

if [ "$shouldRunScript" == "true" ]; then
	if [ "$targetmac" == "" -o "$shouldPickFromList" == "true"  ]; then
		#first time set up, or trying to re-connect to another device
		echo "Add a Roku device"

		if [ "$shouldPickFromList" == "true" ]; then
			localSubnet=$(ifconfig en0 | grep broadcast | sed 's/.*broadcast //g' | cut -d'.' -f1-3)
			localDevices=$(arp -a | grep "$localSubnet" | cut -f1 -d')' | cut -d'(' -f2 | uniq)
			i=0;
			rokuIps="";
			for ip in $localDevices; do
				device_info=$(curl --max-time 0.5 "http://$ip:8060/query/device-info" 2>/dev/null);
				device_name=$(echo "$device_info"| grep "<user-device-name>" | cut -d'>' -f2 | cut -d'<' -f1);
				if [ "$device_name" != "" ]; then
					i=$(( $i + 1 ));
					rokuIps="$rokuIps$ip:";
					echo "$i: $ip ($device_name)";
				fi
			done
			echo "Which is your Roku?"
			read -p "Enter a number [1-$i]: " rokuNumber

			targetip=$(echo $rokuIps | cut -d':' -f $rokuNumber)
			echo "Picked $targetip as your device"
		else
			echo "Go to: Settings > Network > About"
			read -p 'IP Address: ' targetip
		fi

		echo ""
		echo "Roku's dev password, set as part of Developer Settings"
		read -sp 'Password: ' passwd

		echo ""
		echo "Looking up device mac address... This might take a second.";
		targetmac=$(arp -a | grep "$targetip" | head -1 | cut -d' ' -f4)

		echo "$targetip;$targetmac;$passwd" > .rokuTarget
		echo "Device Saved."
	else
		#ip not empty, try to connect
		echo "Updating device's IP Address..."

		arpResult=$(arp -a);

		targetip=$(echo "$arpResult" | grep -i "$targetmac" | head -1 | cut -d" " -f2 | sed "s/[^0-9.]//g")


		#check if we can ping to it
		echo "Pinging device..."
		ping -c1 -n -t1 "$targetip" > /dev/null
		if [ $? -ne 0 ]; then
			targetip=""
		fi

		if [ "$targetip" == "" ]; then
			# roku's wired and wireless mac address seems to be off by 1
			macPrefix=$(echo $targetmac | cut -d':' -f1-5);
			macPostfix=$(echo $targetmac | cut -d':' -f6);

			macPostfixP1Dec=$(echo "ibase=16; $macPostfix + 1" | bc);
			macPostfixM1Dec=$(echo "ibase=16; $macPostfix - 1" | bc);

			macP1=$macPrefix:$(echo "obase=16; $macPostfixP1Dec" | bc);
			macM1=$macPrefix:$(echo "obase=16; $macPostfixM1Dec" | bc);

			targetmac=$macP1;
			targetip=$(echo "$arpResult" | grep -i "$targetmac" | cut -d" " -f2 | sed "s/[^0-9.]//g")


			if [ "$targetip" == "" ]; then
				targetmac=$macM1;
				targetip=$(echo "$arpResult" | grep -i "$targetmac" | cut -d" " -f2 | sed "s/[^0-9.]//g")
			fi


			# if ip address is still empty, probably the device is disconnected, exit with error
			if [ "$targetip" == "" ]; then
				echo "Error: device is not connected. Remove .rokuTarget file if you think this is an error."
				shouldUpdate=false;
			else
			# ask user if it is really the right ip
				echo "Your device seems to have switched between wired and wireless connection";
				echo "Are you sure you want to use $targetip?";
				read -p  "(^C to exit, RETURN to continue)";
				if [ $? -ne 0 ]; then
		                        echo "Not saved. Remove .rokuTarget file if you need to redo the setup."
					shouldUpdate=false;
				fi
			fi

		fi

		if $shouldUpdate; then
			echo "$targetip;$targetmac;$passwd" > .rokuTarget
			echo "Updated"
		fi
	fi


	if [ "$shouldUpdate"=="true" ]; then
		echo "Updating ROKU_DEV_TARGET ($targetip) and DEVPASSWORD..."
		export ROKU_DEV_TARGET=$targetip
		export DEVPASSWORD=$passwd
		device_info=$(curl "http://$ROKU_DEV_TARGET:8060/query/device-info" 2>/dev/null)
		device_name=$(echo "$device_info"| grep "<user-device-name>" | cut -d'>' -f2 | cut -d'<' -f1)
		model_name=$(echo "$device_info"| grep "<model-name>" | cut -d'>' -f2 | cut -d'<' -f1)
		term_title="$device_name($model_name)@$ROKU_DEV_TARGET"
		echo -n -e "\033]0;$term_title\007"

		if [ "$shouldOpenTelnet" == "true" ]; then
			echo "opening BrightScript console"
			openBrightScriptScriptPath="/tmp/roku_$RANDOM"
			echo 'rm '"$openBrightScriptScriptPath"'' > $openBrightScriptScriptPath
			echo 'echo -n -e "\033]0;'"BrightScript - $term_title"'\007"' >> $openBrightScriptScriptPath
			echo 'telnet '"$ROKU_DEV_TARGET"' 8085' >> $openBrightScriptScriptPath
			osascript -e 'tell application "Terminal" to do script "sh '"$openBrightScriptScriptPath"'"'
		fi
		if [ "$shouldOpenSG" == "true" ]; then
			echo "opening SceneGraph console"
			openSceneGraphScriptPath="/tmp/roku_$RANDOM"
			echo 'rm '"$openSceneGraphScriptPath"'' > $openSceneGraphScriptPath
			echo 'echo -n -e "\033]0;'"SceneGraph - $term_title"'\007"' >> $openSceneGraphScriptPath
			echo 'telnet '"$ROKU_DEV_TARGET"' 8080' >> $openSceneGraphScriptPath
			osascript -e 'tell application "Terminal" to do script "sh '"$openSceneGraphScriptPath"'"'
		fi
		if [ "$shouldOpenWebInstaller" == "true" ]; then
			echo "opening web Development Application Installer"
			open "http://rokudev:$DEVPASSWORD@$ROKU_DEV_TARGET"
		fi
		if [ "$shouldOpenNRS" == "true" ]; then
			echo "opening Not-A-RokuSimulator"
			open "http://rokudev:$DEVPASSWORD@greenvalley.truex.com/nrs/0.0.9/index.html?roku_ip=$ROKU_DEV_TARGET&roku_passwd=$DEVPASSWORD"
		fi

	else
		echo "Updating ROKU_DEV_TARGET not updated"
	fi
fi
