from sys import argv
import re
import subprocess
import os

def validate_mac(mac):
    return re.fullmatch("([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}", mac)

def validate_interface(net_interface):
    return os.path.exists(f"/sys/class/net/{net_interface}/address")

def find_backup(net_interface):
    backup_file = open("backup.txt", "r")
    mac = ""
    for line in backup_file.readlines():
        if net_interface in line:
            return line.split()[1]
    backup_file.close()
    return mac

def remove_backup(net_interface):
    if find_backup(net_interface):
        backup_file = open("backup.txt", "r")
        lines = backup_file.readlines()
        backup_file.close()
        backup_file = open("backup.txt", "w")
        for line in lines:
            if net_interface not in line:
                backup_file.write(line)

def make_backup(net_interface, mac):
    if not find_backup(net_interface):
        backup_file = open("backup.txt", "a")
        backup_file.write(f"{net_interface} {mac}\n")
        backup_file.close()

def change_mac(net_interface, mac):
    make_backup(net_interface, mac)
    first = subprocess.run(["ip", "link", "set", "dev", net_interface, "down"], capture_output=True, text=True)
    second = subprocess.run(["ip", "link", "set", "dev", net_interface, "address", mac], capture_output=True, text=True)
    third = subprocess.run(["ip", "link", "set", "dev", net_interface, "up"], capture_output=True, text=True)
    if first.returncode == second.returncode == third.returncode == 0:
        return True
    else:
        return False

interface = argv[1]
address = argv[2]

if address == "restore":
    backup = find_backup(interface)
    if backup:
        result = change_mac(interface, address)
        if result:
            print("MAC Address restored successfully")
        else:
            print("Could not restore MAC Address. Please try again")
    else:
        print("Backup not found")
elif address == "clear":
    remove_backup(interface)
    print(f"Backup for {interface} interface removed")
else:
    if validate_mac(address):
        if validate_interface(interface):
            result = change_mac(interface, address)
            if result:
                print("MAC Address changed successfully")
            else:
                print("Changing MAC Address failed. Please try again")
        else:
            print("Network interface not valid. Please use a valid network interface for your device")
    else:
        print("MAC Address not valid. Please use a valid MAC Address")