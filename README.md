# oscp-enumscript



### Requirements

nmap --> for port scanning and scripting engine

dirb --> for web directory busting

curl --> for downloads

nikto --> for web enumeration


Install with (debian-based systems):
```
$ sudo apt install nmap curl nikto dirb 
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


