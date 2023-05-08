#!/bin/bash
pin=manual
user=hak
userid=1000
systemctl restart pcscd
killall gpg-agent
if [[ "$1" == "add" ]]; then
  		echo "Device added">>/home/$user/.keyring-unlocker.log
		if gpg --card-status ;then
			echo "detected->decrypting">>/home/$user/.keyring-unlocker.log
			if [[ $pin == "manual" ]];then
                            	pass=$(DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/'$userid'/bus' /usr/bin/gpg -q --decrypt /home/$user/.pass)
                                envo="XDG_RUNTIME_DIR=\"/run/user/$userid\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$userid/bus\" /usr/local/bin/keyring-unlock unlock \"$pass\" \"$user\""
                                su -c "$envo" $user

			else
				pass=$(DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS='unix:path=/run/user/'$userid'/bus' /usr/bin/gpg -q --pinentry-mode loopback --passphrase $pin --decrypt /home/$user/.pass)
				envo="XDG_RUNTIME_DIR=\"/run/user/$userid\" DBUS_SESSION_BUS_ADDRESS=\"unix:path=/run/user/$userid/bus\" /usr/local/bin/keyring-unlock unlock \"$pass\" \"$user\""
				su -c "$envo" $user
			fi
		else
			echo "detection fail">>/home/$user/.keyring-unlocker.log
		fi
elif [[ "$1" == "remove" ]]; then
  echo "Device removed">>/home/$user/.keyring-unlocker.log
  su -c 'XDG_RUNTIME_DIR="/run/user/'$userid'" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/'$userid'/bus" /usr/local/bin/keyring-unlock lock'" $user" $user
else
  echo "Error: Invalid argument provided">>/home/$user/.keyring-unlocker.log
  exit 1

fi