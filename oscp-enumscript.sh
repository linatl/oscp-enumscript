#!/bin/bash

printf "\n----- Starting -----\n"

#Check if nmap is installed
if [ "$(dpkg -l | awk '/nmap/ {print }'|wc -l)" = 0 ]; then
        printf "\nnmap is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install nmap"
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


# print help etc




# make directory based on domain or ipv4. domain is preferred
if [ "$domain" != "" ]; then
	target="$domain"
elif [ "$ipv4" != "" ]; then
	target="$ipv4"
fi

dirname = "enum-$target"
mkdir $dirname
printf "$dirname"
# run nmap

printf "\n\n----- nmap starting -----\n"
#nmap -v -p- -oN $dirname $target $target



# identify http ports on the target system




# verify if dirb, nikto and curl are installed



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

printf "\ndirname: $dirname"

# End the script

printf "\n\n----- Finished!  -----\n"

