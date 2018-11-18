#!/bin/sh

## TODO: remove untrustworthy ca certificates
## TODO: disable guest login
## TODO: disable ssh v1
## TODO: add openssh support
## TODO: uncomment changes to sshd_config and other files
## TODO: password protect GRUB
## TODO: disable ipv6
## TODO: disable ctrl alt del
## TODO: check for home directory encryption
## TODO: add banner to SSH that says something about government properity
## TODO: SSH disable compression
## TODO: setup aide
## TODO: setup selinux or apparmor
## TODO: remove homebrew
## TODO: enforce password complexity
## TODO: disable bluetooth

PUR='\033[0;35m' ## Purple
NC='\033[0m' ## No Color

update(){
    echo "${PUR}*** Updating system ***${NC}"

    ## Full system update
    read -p "Would you like to completely update now (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for apt-fast (faster)"
        if [ $(dpkg-query -W -f='${Status}' aptfast 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "apt-fast installed" ## apt-fast

            apt-fast update
            apt-fast upgrade
            apt-fast dist-upgrade
            apt-fast autoremove
            apt-fast autoclean
            apt-fast check
        else
            echo "apt-fast not installed" ## apt-get
            echo "Using default process"

            apt-get update
            apt-get upgrade
            apt-get dist-upgrade
            apt-get autoremove
            apt-get autoclean
            apt-get check
        fi
    fi

    ## Automatic updates
    read -p "Would you like to enable automatic updates (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Enabling automatic updates"
        sed -i 's/Update-Package-Lists "0"/Update-Package-Lists "1"/g' /etc/apt/apt.conf.d/20auto-upgrades
    fi
}

sudo_check(){
    ## Root/sudo check
    if [ $(whoami) != "root" ];
    then
        echo "${PUR}Must be root to run script"
        exit
    fi
}

secure_system(){
    echo "${PUR}*** Securing system ***${NC}"

    ## auditd\
    read -p "Would you like to install auditd (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for auditd"
        if [ $(dpkg-query -W -f='${Status}' auditd 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing auditd"
            apt-get install auditd
            auditd -s enable
        else
            echo "auditd already installed"
            auditd -s enable ## enforce it to be enabled
        fi
    fi

    ## Clamav
    read -p "Would you like to install clamav (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for clamav"
        if [ $(dpkg-query -W -f='${Status}' clamav 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing anti-virus"
            apt-get install clamav

            read -p "Would you like to run a scan now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                echo "Running scan (Clamav)"
                clamscan -r --bell -i /
            fi
        else
            echo "Clamav already installed"

            echo "Updating database (Clamav)"
            /etc/init.d/clamav-freshclam stop ## stop auto-updater so we can update manually
            freshclam
            sudo /etc/init.d/clamav-freshclam start ## restarting auto-updater

            read -p "Would you like to run a scan now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                echo "Running scan (Clamav)"
                clamscan -r --bell -i /
            fi
        fi
    fi

    ## rkhunter
    read -p "Would you like to install rkhunter (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for rkhunter"
        if [ $(dpkg-query -W -f='${Status}' rkhunter 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing anti-rootkit"
            sudo apt-get install rkhunter

            read -p "Would you like to run a scan now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                echo "Running scan (rkhunter)"
                rkhunter --check
            fi
        else
            echo "rkhunter already installed"

            echo "Updating rkhunter"
            rkhunter --update
            rkhunter --versioncheck

            read -p "Would you like to run a scan now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                echo "Running scan (rkhunter)"
                rkhunter --check
            fi
        fi
    fi

    ## Compilers
    read -p "Would you like to disable compilers (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Disabling compilers"

        chmod 000 /usr/bin/as >/dev/null 2>&1
        chmod 000 /usr/bin/byacc >/dev/null 2>&1
        chmod 000 /usr/bin/yacc >/dev/null 2>&1
        chmod 000 /usr/bin/bcc >/dev/null 2>&1
        chmod 000 /usr/bin/kgcc >/dev/null 2>&1
        chmod 000 /usr/bin/cc >/dev/null 2>&1
        chmod 000 /usr/bin/gcc >/dev/null 2>&1
        chmod 000 /usr/bin/*c++ >/dev/null 2>&1
        chmod 000 /usr/bin/*g++ >/dev/null 2>&1
    fi

    ## debsums
    read -p "Would you like to install debsums (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for debsums"
        if [ $(dpkg-query -W -f='${Status}' debsums 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing deb sums"
            apt-get install debsums

            read -p "Would you like to run debsums now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                debsums
            fi
        else
            echo "debsums already installed"

            read -p "Would you like to run debsums now (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                debsums
            fi
        fi
    fi
}

secure_hardware(){
    echo "${PUR}*** Securing hardware access ***${NC}"

    ## usbguard
    read -p "Would you like to install usbguard (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for usbguard"
        if [ $(dpkg-query -W -f='${Status}' usbguard 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing usbguard"

            apt-get install usbguard
        else
            echo "usbguard already installed"
        fi
    fi

    ## Insecure IO - thunderbolt
    read -p "Would you like to disable thunderbolt access (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        File="/etc/modprobe.d/thunderbolt.conf"
        if [ -e "$File" ];
        then
            if ! grep -q 'blacklist thunderbolt' "$File";
            then
                echo "Disabling thunderbolt access"
                echo "blacklist thunderbolt" >> /etc/modprobe.d/thunderbolt.conf
            fi
        fi
    fi

    ## Insecure IO - firewire
    read -p "Would you like to disable firewire access (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        File="/etc/modprobe.d/firewire.conf"
        if [ -e "$File" ];
        then
            if ! grep -q 'blacklist firewire-core' "$File";
            then
                echo "Disabling firewire access"
                echo "blacklist firewire-core" >> /etc/modprobe.d/firewire.conf
            fi
        fi
    fi
}

secure_connections(){
    echo "${PUR}*** Securing connections ***${NC}"

    ## Firewall
    read -p "Would you like to enable the firewall (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Enabling firewall"
        ufw enable
    fi

    ## Insecure protocols - need if statement
    read -p "Would you like to remove insecure protocols (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Removing insecure protocols"
        sudo apt-get --purge remove xinetd nis yp-tools tftpd atftpd tftpd-hpa telnetd rsh-server rsh-redone-server
    fi

    ## psad - need to 'noemail' with context
    read -p "Would you like to install psad (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for psad"
        if [ $(dpkg-query -W -f='${Status}' psad 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing psad"
            apt-get install psad

            sudo iptables -A INPUT -j LOG
            sudo iptables -A FORWARD -j LOG

            ## Make iptables rules persistent
            if [ $(dpkg-query -W -f='${Status}' iptables-persistent 2>/dev/null | grep -c "ok installed") -eq 0 ];
            then
                echo "Enforcing persistent iptables rules"

                apt-get install iptables-persistent
                service iptables-persistent start
            fi

            echo "Configuring psad settings"
            sed -i s/_CHANGEME_/$(whoami)/g /etc/psad/psad.conf ## Hostname
            sed -i s/ALERTING_METHODS            ALL/$(whoami)/g /etc/psad/psad.conf ## Alerting method
        else
            echo "psad already installed"

            echo "Updating psad"

            psad --sig-update
            psad -H
        fi
    fi

    ## Malicious domains
    read -p "Would you like to block malicious domains (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Black-listing malicious domains"
        File="hosts.txt"
        if [ -e "$File" ]; ## hosts.txt check if exists
        then
            File="/etc/hosts"
            if ! grep -q '# Malicious hosts to block (Full-Tilt-Bash/secureLinux.sh)' "$File";
            then
                cat hosts.txt >> /etc/hosts
            else
                echo "Malicious domains already blocked"
            fi
        else ## hosts.txt missing then download
            read -p "Host file missing. Would you like to download it (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                wget "https://raw.githubusercontent.com/TheRedSpy15/Full-Tilt-Bash/master/hosts.txt"

                File="hosts.txt"
                if [ -e "$File" ]; ## hosts.txt check if exists
                then
                    File="/etc/hosts"
                    if ! grep -q '# Malicious hosts to block (Full-Tilt-Bash/secureLinux.sh)' "$File";
                    then
                        cat hosts.txt >> /etc/hosts
                    else
                        echo "Malicious domains already blocked"
                    fi
                else
                    echo "Failed to find host file... Resuming"
                fi
            else
                echo "Resuming"
            fi
        fi
    fi
}

secure_ssh(){
    echo "${PUR}*** Securing SSH ***${NC}"

    ## fail2ban
    read -p "Would you like to install fail2ban (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for fail2ban"
        if [ $(dpkg-query -W -f='${Status}' fail2ban 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing fail2ban"
            sudo apt-get install fail2ban
        else
            echo "fail2ban already installed"
        fi
    fi

    ## Limit SSH connections
    read -p "Would you like to limit SSH connections (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Limiting SSH connections"
        ufw limit ssh
        ufw limit openssh
    fi

    ## Root login
    read -p "Would you like to disable SSH root login (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking if root login allowed"
        File="/etc/ssh/sshd_config"
        if ! grep -q 'DenyUsers root' "$File";
        then
            echo "Disabling root login sshd"
            echo "DenyUsers root" >> /etc/ssh/sshd_config
        else
            echo "Root login already disabled"
        fi

        sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config ## is a check within itself
    fi

    ## SSH port - review as default sshd_config might need to uncomment port number
    ## need check for this one as port number could be already changed to something other than 22 or 3333
    read -p "Would you like to change ssh port from default (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking SSH port number"
        if grep -q 'Port 22' "$File";
        then
            echo "Changing SSH port to 3333"
            sed -i 's/Port 22/Port 3333/g' /etc/ssh/sshd_config
        else
            echo "SSH port already changed from default"
        fi
    fi

    ## X11Forwarding
    read -p "Would you like to disable X11Forwarding (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        sed -i 's/X11Forwarding yes/X11Forwarding no/g' /etc/ssh/sshd_config
    fi

    ## TCPKeepAlive
    read -p "Would you like to disable TCPKeepAlive (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        sed -i 's/TCPKeepAlive yes/TCPKeepAlive no/g' /etc/ssh/sshd_config
    fi

    ## AllowTcpForwarding
    read -p "Would you like to disable AllowTcpForwarding (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        sed -i 's/AllowTcpForwarding yes/AllowTcpForwarding no/g' /etc/ssh/sshd_config
    fi

    ## AllowAgentForwarding
    read -p "Would you like to disable AllowAgentForwarding (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        sed -i 's/AllowAgentForwarding yes/AllowAgentForwarding no/g' /etc/ssh/sshd_config
    fi
}

secure_user(){
    echo "${PUR}*** Securing user ***${NC}"

    ## Maximum password age - no need for if statement
    read -p "Would you like to limit password age to 100 days for root (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Setting maximum password age of root (100 days)"
        chage -M 100 root
    fi
}

sudo_check
update
secure_system
secure_connections
secure_ssh
secure_hardware
secure_user
