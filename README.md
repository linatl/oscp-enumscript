# oscp-enumscript



### Requirements

nmap --> for port scanning and scripting engine

gobuster and ffuf --> for web directory busting

seclists --> for wordlists

nikto --> for web enumeration


Install tools with (on kali system):
```
$ sudo apt install nmap nikto seclists gobuster ffuf 
```



### Running the script
For a domain-based target:
```
$ chmod +x oscp-enumscript.sh
$ bash oscp-enumscript.sh -d domain.local
```
For ipv4 target:
```
$ chmod +x oscp-enumscript.sh
$ bash oscp-enumscript.sh -i 10.10.10.10
```


