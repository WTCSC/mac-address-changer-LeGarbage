#!/bin/bash

# Checks if the supplied MAC addres sis in a valid format
ValidateMac()
{
    # Checks if the address is valid by using RegEx
    if [[ "$1" =~ ^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Checks if the network interface supplied exists on the device
ValidateInterface()
{
    # Checks if the file containing the address for the interface exists
    if [ -f "/sys/class/net/$1/address" ]; then
        return 0
    else
        return 1
    fi
}

ChangeMac()
{
    # echo "$1 $(cat /sys/class/net/$1/address)" >> backup.txt

    # Turns off the network
    ip link set dev $1 down
    # Changes the address
    ip link set dev $1 address $2
    # Turns on the network
    ip link set dev $1 up
    return
}

# WIP for EC
# if [[ $2 = "restore" ]]; then
#     backup=$(cat backup.txt)
#     ChangeMac
# fi


ValidateMac $2
# Check if the address was valid
if [[ $? -eq 1 ]]; then
    echo "Please enter a valid MAC Address"
    exit 1
fi

ValidateInterface $1
# Checks if the interface was valid
if [[ $? -eq 1 ]]; then
    echo "Please use a valid network interface for your device"
    exit 1
fi

ChangeMac $1 $2
# Check if the change was successful
if [[ $? -ne 0 ]]; then
    echo "Changing MAC Address failed please try again"
    exit
else
    echo "MAC Address changed successfully"
fi