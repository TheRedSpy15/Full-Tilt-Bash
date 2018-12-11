#!/bin/sh

## TODO: remove untrustworthy ca certificates
## TODO: disable guest login
## TODO: disable ssh v1
## TODO: add openssh support
## TODO: uncomment changes to sshd_config and other files
## TODO: password protect GRUB
## TODO: check for home directory encryption
## TODO: add banner to SSH that says something about government properity
## TODO: SSH disable compression
## TODO: setup aide
## TODO: setup selinux or apparmor
## TODO: enforce password complexity (after installing libpam-cracklib support)
## TODO: attempt a script updater
## TODO: check for hosts.txt and templates at start

PUR='\033[0;35m' ## Purple
RED='\033[0;31m' ## Red
YEL='\033[1;33m' ## Yellow
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
            update-grub
        else
            echo "${YEL}apt-fast not installed${NC}" ## apt-get
            echo "Using default process"

            apt-get update
            apt-get upgrade
            apt-get dist-upgrade
            apt-get autoremove
            apt-get autoclean
            apt-get check
            update-grub
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

## Root/sudo check
sudo_check(){
    if [ $EUID -ne 0 ];
    then
        echo "Must be root to run script"
        exit
    fi
}

secure_system(){
    echo "${PUR}*** Securing system ***${NC}"

    ## Homebrew - need check for homebrew
    ## TODO: only run if homebrew is installed
    read -p "Would you like to remove homebrew (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for ruby (needed to remove)"
        if [ $(dpkg-query -W -f='${Status}' ruby-full 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
        else
            echo "${YEL}ruby not installed${NC}"

            read -p "Would you like to install ruby (y/n)?" CONT
            if [ "$CONT" = "y" ];
            then
                sudo apt-get install ruby-full
                sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
            fi
        fi
    fi

    ## ctrl alt del
    read -p "Would you like to disable ctrl + alt + del (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Disabling ctrl + alt + del"
        systemctl mask ctrl-alt-del.target
        systemctl daemon-reload
    fi

    ## auditd
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

    ## Secure /tmp
    read -p "Would you like to create a secure /tmp (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Creating a FileSystem for the /tmp Directory and set Proper Permissions"
        dd if=/dev/zero of=/usr/tmpDISK bs=1024 count=2048000
        mkdir /tmpbackup
        cp -Rpf /tmp /tmpbackup
        mount -t tmpfs -o loop,noexec,nosuid,rw /usr/tmpDISK /tmp
        chmod 1777 /tmp
        cp -Rpf /tmpbackup/* /tmp/
        rm -rf /tmpbackup
        echo "/usr/tmpDISK  /tmp    tmpfs   loop,nosuid,nodev,noexec,rw  0 0" >> /etc/fstab
        sudo mount -o remount /tmp
    fi

    ## Secure kernal
    ## TODO: add handling for missing templates
    ## TODO: stop printing to screen
    read -p "Would you like to secure the kernal (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Securing Linux Kernel"
        echo "* hard core 0" >> /etc/security/limits.conf
        cp templates/sysctl.conf /etc/sysctl.conf; echo " OK"
        cp templates/ufw /etc/default/ufw
        sysctl -e -p
    fi

    ## Unused file systems
    read -p "Would you like to disable unused filesystems (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Disabling filesystems"
        echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
        echo "install vfat /bin/true" >> /etc/modprobe.d/CIS.conf
    fi

    ## umask
    read -p "Would you like to set a more secure umask (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Securing umask"
        cp templates/login.defs /etc/login.defs
    fi

    ## Protect grub
    read -p "Would you like to set a password for grub (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Protecting grub"

        grub-mkpasswd-pbkdf2 | tee grubpassword.tmp
        grubpassword=$(cat grubpassword.tmp | sed -e '1,2d' | cut -d ' ' -f7)
        echo " set superusers="root" " >> /etc/grub.d/40_custom
        echo " password_pbkdf2 root $grubpassword " >> /etc/grub.d/40_custom
        rm grubpassword.tmp
        update-grub

        sleep 2
        chown root:root /boot/grub/grub.cfg
        chmod og-rwx /boot/grub/grub.cfg
    fi

    ## file permissions
    read -p "Would you like to set permissions on system files (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        sleep 2
        chmod -R g-wx,o-rwx /var/log/*
        chown root:root /etc/ssh/sshd_config
        chmod og-rwx /etc/ssh/sshd_config
        chown root:root /etc/passwd
        chmod 644 /etc/passwd
        chown root:shadow /etc/shadow
        chmod o-rwx,g-wx /etc/shadow
        chown root:root /etc/group
        chmod 644 /etc/group
        chown root:shadow /etc/gshadow
        chmod o-rwx,g-rw /etc/gshadow
        chown root:root /etc/passwd-
        chmod 600 /etc/passwd-
        chown root:root /etc/shadow-
        chmod 600 /etc/shadow-
        chown root:root /etc/group-
        chmod 600 /etc/group-
        chown root:root /etc/gshadow-
        chmod 600 /etc/gshadow-

        sleep 2

        df --local -P | awk {'if (NR!=1) print $6'} | xargs -I '{}' find '{}' -xdev -type d -perm -0002 2>/dev/null | xargs chmod a+t
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

    ## Bluetooth
    read -p "Would you like to disable bluetooth (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Disabling bluetooth"
        systemctl disable bluetooth
    fi

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
    ## TODO: add handling for missing template
    read -p "Would you like to install psad (y/n)?" CONT
    if [ "$CONT" = "y" ];
    then
        echo "Checking for psad"
        if [ $(dpkg-query -W -f='${Status}' psad 2>/dev/null | grep -c "ok installed") -eq 0 ];
        then
            echo "Installing psad"
            echo -n "Type an Email Address to Receive PSAD Alerts: " ; read email
            echo -n "Type a Name to Identify this server : "; read host_name
            echo -n "Type a Domain name : "; read domain_name
            apt-get install psad

            ## Make iptables rules persistent
            if [ $(dpkg-query -W -f='${Status}' iptables-persistent 2>/dev/null | grep -c "ok installed") -eq 0 ];
            then
                echo "Enforcing persistent iptables rules"

                apt-get install iptables-persistent
                service iptables-persistent start
            fi

            sudo iptables -A INPUT -j LOG
            sudo iptables -A FORWARD -j LOG

            echo "Configuring psad settings"
            sed -i s/INBOX/$email/g templates/psad.conf
            sed -i s/CHANGEME/$host_name.$domain_name/g templates/psad.conf
            cp templates/psad.conf /etc/psad/psad.conf

            psad --sig-update
            psad -H
            service psad restart
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
            read -p "${YEL}Host file missing. Would you like to download it (y/n)?${NC}" CONT
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
                    echo "${RED}Failed to find host file... Resuming${NC}"
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
            sudo apt-get install sendmail
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
