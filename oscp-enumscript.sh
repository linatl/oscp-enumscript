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
nmap -p- -Pn -sV -oN "$dir"/"$target"-nmap -oX "$dir"/"$target"-nmap-xml "$target"
printf "\n~ Running Nmap again with scripts ~ \n"
nmap -p- -Pn -sC -sV -oN "$dir"/"$target"-nmap-defaultscripts "$target"
printf "\n----- Nmap done -----\n"

# verify if dirb and nikto and seclists are installed
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
#Check if seclists is installed
if [ "$(dpkg -l | awk '/seclists/ {print }'|wc -l)" = 0 ]; then
        printf "\nseclists is not installed. Install on debian-like systems with:"
        printf "\n\$ sudo apt install seclists"
        printf "\nIf not, only the last part of enumeration wont work: finding directories on webpages using burp"
	sleep 3s
fi

printf "\n\n----- Starting Web Enumeration -----\n\n"

# identify http ports on the target system
nmapfile="$dir/$target"-nmap
httplist=$(cat "$nmapfile" | grep "open" | grep "http" | grep -v "ssl" | grep -v "ncacn" | cut -d " " -f 1 | cut -d "/" -f 1)
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
	printf "\n\n~~ Running dirb non-recursive for port $p .\n"
	printf "\n~~ Using the default wordlist for dirb, with only about 4600 entries ...\n"
	dirb http://"$target":"$p" -r -o $dir/"$target"-"$p"-dirb.txt
	printf "~~  > done; results saved."
done
for p in $httpslist; do
	printf "\n\n~~ Running dirb non-recursive for port $p ...\n"
	printf "\n~~ Using the default wordlist for dirb, with only about 4600 entries ...\n"
	dirb https://"$target":"$p" -r -o $dir/"$target"-"$p"-dirb.txt
	printf "~~  > done; results saved."
done

# run dirb recursive
for p in $httplist; do
	printf "\n\n~~ Running dirb recursive for port $p ...\n"
	printf "\n~~ Using wordlist /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt with about 220k entries, so this may take a while ...\n"
	dirb http://"$target":"$p" /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -o $dir/"$target"-"$p"-dirb-recursive.txt
	printf "\n~~  > done; results saved."

done
for p in $httpslist; do
	printf "\n\n~~ Running dirb recursive for port $p ...\n"
	printf "\n~~ Using wordlist /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt with about 220k entries, so this may take a while ...\n"
	dirb https://"$target":"$p" /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -o $dir/"$target"-"$p"-dirb-recursive.txt
	printf "~~  > done; results saved."
done

# End the script
printf "\n\n----- Finished!  -----\n"
