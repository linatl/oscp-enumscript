#!/bin/bash

#Check if ipv4 and/or domain are specified
if [ $# -eq 0 ]; then
	printf "\nNo arguments provided"
	printf "\nFor ipv4 target, specify:"
	printf "\n   \$$0 -i 127.0.0.1"
	printf "\nFor dns target, specify:"
	printf "\n   \$$0 -d domain.local"
	printf "\n\n"
	exit 1
fi

printf "\n----- Starting -----\n"

#Check if nmap is installed
if [ "$(dpkg -l | awk '/nmap/ {print }'|wc -l)" = 0 ]; then
        printf "\nnmap is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install nmap\n"
        exit
fi

# process command line arguments
while getopts i:d: flag
do
        case "${flag}" in
                i) ipv4=${OPTARG};;
		d) domain=${OPTARG};;
	esac
done

#validate if an ipv4 or domain is present
if [[ "$ipv4" = "" && "$domain" = "" ]]; then
	printf "\nYou didnt specify a domain or ipv4 address"
	### print help
	exit
fi

# specify target variable based on domain or ipv4. domain is preferred
if [ "$domain" != "" ]; then
	target="$domain"
elif [ "$ipv4" != "" ]; then
	target="$ipv4"
fi

# specify directory to put the outputfiles in
dir="enum"

# run nmap, and send the results to 3 different output files
printf "\n\n----- Nmap starting -----\n"
mkdir "$dir"
touch "$dir/nmap$target"
touch "$dir/nmap-grep$target"
printf "\n~ Running Nmap without scripts ~ \n"
#nmap -p- -sV -oN "$dir/nmap-$target" -oX "$dir/nmap-$target-xml" "$target"
printf "\n~ Running Nmap with scripts ~ \n"
#nmap -p- -sC -sV -oN "$dir/nmap-$target-defaultscripts" "$target"
printf "\n----- Nmap done -----\n"

# identify http ports on the target system
httpports=""
nmapfile="$dir/nmap-$target"
#cat "$nmapfile" | grep "open"
####################################TODO dit afmaken


# verify if dirb, nikto and curl are installed
#Check if curl is installed
if [ "$(dpkg -l | awk '/curl/ {print }'|wc -l)" = 0 ]; then
        printf "\ncurl is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install curl\n"
        exit
fi
#Check if nikto is installed
if [ "$(dpkg -l | awk '/nikto/ {print }'|wc -l)" = 0 ]; then
        printf "\nnikto is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install nikto\n"
        exit
fi
#Check if dirb is installed
if [ "$(dpkg -l | awk '/dirb/ {print }'|wc -l)" = 0 ]; then
        printf "\ndirb is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install dirb\n"
        exit
fi



# if robots.txt exists: download it



# run nikto



# run dirb non-recursive



# run dirb recursive





#verification; delete this later
printf "\n"
printf "\ndomain: "

if [ "$domain" = "" ]; then
	printf "-"
else
	printf "$domain"
fi


printf "\nipv4 address: ";
if [ "$ipv4" = "" ]; then
	printf "-"
else
	printf "$ipv4"
fi

printf "\ndirname: "
if [ "$dir" = "" ]; then
	printf "-"
else
	printf "$dir"
fi

printf "\ntarget: "
if [ "$target" = "" ]; then
	printf "-"
else
	printf "$target"
fi

# End the script

printf "\n\n----- Finished!  -----\n"

