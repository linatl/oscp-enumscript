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
printf "\n~ Running Nmap without scripts ~ \n"
nmap -p- -sV -oN "$dir"/"$target"-nmap -oX "$dir"/"$target"-nmap-xml "$target"
printf "\n~ Running Nmap with scripts ~ \n"
nmap -p- -sC -sV -oN "$dir"/"$target"-nmap-defaultscripts "$target"
printf "\n----- Nmap done -----\n"

# verify if dirb and nikto are installed
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

printf "\n\n----- Starting Web Enumeration -----\n\n"

# identify http ports on the target system
nmapfile="$dir/nmap-$target"
httplist=$(cat "$nmapfile" | grep "open" | grep "http" | grep -v "ssl" | cut -d " " -f 1 | cut -d "/" -f 1)
httpslist=$(cat "$nmapfile" | grep "open" | grep "http" | grep "ssl" | cut -d " " -f 1 | cut -d "/" -f 1)

if [ "$httplist" = "" ]; then
	printf "\n~~ Couldn't identify any http ports\n"
else
	printf "\n~~ Identified these http ports on the target:\n"
	printf "$httplist\n"
fi
if [ "$httpslist" = "" ]; then
	printf "\n~~ Couldn't identify any https ports\n"
else
	printf "\n~~ Identified these https ports on the target:\n"
	printf "$httpslist\n"
fi

# if robots.txt exists: download and save it with curl.
for p in $httplist; do
	curl http://"$target"/robots.txt > $dir/"$target"-"$p"-robots.txt 2>/dev/null
	if [ -s $dir/"$p"-robots.txt ]; then
		rm $dir/"$target"-"$p"-robots.txt
		printf "\n~~ no robots.txt found for port $p\n"
	else
		printf "\n~~ Saved robots.txt for port $p\n"
	fi
done
for p in $httpslist; do
	curl https://"$target"/robots.txt > $dir/"$target"-"$p"-robots.txt 2>/dev/null
	if [ -s $dir/"$p"-robots.txt ]; then
		rm $dir/"$target"-"$p"-robots.txt
		printf "\n~~ no robots.txt found for port $p\n"
	else
		printf "\n~~ Saved robots.txt for port $p\n"
	fi
done


# run nikto for each webserver
for p in $httplist; do
	printf "\n\n~~ Running nikto for port $p ...\n"
	nikto -host http://"$target":"$p"/ > $dir/"$target"-"$p"-nikto.txt
	printf "~~  > done; results saved."
done
for p in $httpslist; do
	printf "\n\n~~ Running nikto for port $p ...\n"
	nikto -host https://"$target":"$p"/ > $dir/"$target"-"$p"-nikto.txt
	printf "~~  > done; results saved."
done

# run dirb non-recursive
for p in $httplist; do
	printf "\n\n~~ Running dirb non-recursive for port $p ...\n"
	dirb http://"$target":"$p" -r -o $dir/"$target"-"$p"-dirb.txt
	printf "~~  > done; results saved."
done
for p in $httpslist; do
	printf "\n\n~~ Running dirb non-recursive for port $p ...\n"
	dirb https://"$target":"$p" -r -o $dir/"$target"-"$p"-dirb.txt
	printf "~~  > done; results saved."
done

# run dirb recursive
#(maybe add later?)

# End the script
printf "\n\n----- Finished!  -----\n"
