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
    # Checks if the backup file already has a backup for the provided interface
    grep "^$1 " backup.txt
    # Checks if grep failed to find a backup
    if [[ $? -ne 0 ]]; then
        # Create a backup using the interface and the current address
        echo "$1 $(cat /sys/class/net/$1/address)" >> backup.txt
    fi
        

    # Turns off the network
    ip link set dev $1 down
    # Changes the address
    ip link set dev $1 address $2
    # Turns on the network
    ip link set dev $1 up
    return
}

# Create the backup file if it doesn't exist
if [ ! -f "backup.txt" ]; then
    touch "backup.txt"
fi

# Checks if the user wants to restore from a backup
if [[ $2 = "restore" ]]; then
    # Finds the user-provided interfece in the backup file. Anything after the interface is the address
    backup=$(grep -o "^$1 .*" backup.txt | cut -f2- -d" ")
    # Check if grep couldn't find a backup for the interface
    if [[ -z $backup ]]; then
        echo "Backup not found"
        exit 1
    else
        # Change the address using the backup
        ChangeMac $1 $backup
        if [[ $? -ne 0 ]]; then
            echo "Restoring MAC Address failed. Please try again"
            exit
        else
            echo "MAC Address restored successfully"
            exit
        fi
    fi
# Checks if the user wants to clear their backup
elif [[ $2 = "clear" ]]; then
    # Looks for the interface and removes the line containing it
    sed -i "/^$1 .*/d" backup.txt
    echo "Backup for $1 interfece removed"
    exit
fi


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
    echo "Changing MAC Address failed. Please try again"
    exit
else
    echo "MAC Address changed successfully"
fi