#!/usr/bin/env bash
echo ""
echo "__________________________________________Information_____________________________________________"
echo "                                                                                                  "
echo "You want to harden the security of Secure Shell, the Secure Shell configuration will be modified."
echo "If you perform this script, the login behavior of the Secure Shell will be changed."
echo "You must be sure that all SSH users are members of the sshgroup to connect via Secure Shell."
echo "By default password authentication is used, if you want to use pubkey, read the README.md file."
echo "__________________________________________________________________________________________________"
echo ""
while true; do
    read -r -p 'Do you want to continue (y/n)? ' choice
    echo ""
    case "$choice" in
        y|Y)
            echo "[Task 1] : Gathering Operating system and Secure Shell information"
            sleep 2
            UBUNTU_VERSION=$(awk -F'=' '/^UBUNTU_CODENAME/{print $2}' /etc/os-release)
            ID_OS=$(awk -F'=' '/^ID=/{print $2}' /etc/os-release)
            SSHD=/etc/ssh/sshd_config
            SSHDBKP=/etc/ssh/sshd_config_BKP

            grep -Ev '^#|^$' $SSHD > /tmp/SSHDCONF_OUTPUT.md

            # Default User and SSH group
            echo "[Task 2] : Creating Secure shell and SSH group variables"
            sleep 2
            user_cfg ()
                {
                    default_user=$(awk -F: '$3 == 1000 {print $1}' /etc/passwd)  # Show me the default user
                    CheckSSHGroup=$(awk -F: '/sshgroup/ {print $1}'  /etc/group)

                    if [[ $CheckSSHGroup == sshgroup ]]; then
                        echo "sshgroup already exists"
                    else
                        groupadd sshgroup && usermod -aG sshgroup $default_user      # Add default user to sshgroup
                    fi
                }

            # SSH Hardening config
            sshd_cfg ()
                {
                    cp $SSHD $SSHDBKP
                    cat ./issue.md > /etc/ssh/banner.md

                    if grep -q -e "^UsePAM yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "UsePAM yes"                                : "[Pass]"
                    else
                        sed -i 's/^#UsePAM no/UsePAM yes/' $SSHD
                    fi

                    if grep -q -e "^LogLevel VERBOSE" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "LogLevel VERBOSE"                         : "[Pass]"
                    else
                        sed -i 's/.*LogLevel INFO/LogLevel VERBOSE/' $SSHD
                    fi

                    if grep -q -e "^PermitRootLogin no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "PermitRootLogin no"                        : "[Pass]"
                    else
                        sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' $SSHD
                    fi

                    if grep -q -e "^HostbasedAuthentication no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "HostbasedAuthentication no"                : "[Pass]"
                    else
                        sed -i 's/.*HostbasedAuthentication no/HostbasedAuthentication no/' $SSHD
                    fi

                    if grep -q -e "^PermitEmptyPasswords no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "PermitEmptyPasswords no"                   : "[Pass]"
                    else
                        sed -i 's/.*PermitEmptyPasswords no/PermitEmptyPasswords no/' $SSHD
                    fi

                    if grep -q -e "^PermitUserEnvironment no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "PermitUserEnvironment no"                 : "[Pass]"
                    else
                        sed -i 's/.*PermitUserEnvironment no/PermitUserEnvironment no/' $SSHD
                    fi

                    if grep -q -e "^IgnoreRhosts yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "IgnoreRhosts yes"                         : "[Pass]"
                    else
                        sed -i 's/.*IgnoreRhosts yes/IgnoreRhosts yes/' $SSHD
                    fi

                    if grep -q -e "^PubkeyAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "PubkeyAuthentication yes"                 : "[Pass]"
                    else
                        sed -i 's/.*PubkeyAuthentication yes/PubkeyAuthentication yes/' $SSHD
                    fi

                    if grep -q -e "^PasswordAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "PasswordAuthentication yes"               : "[Pass]"
                    else
                        sed -i 's/.*PasswordAuthentication yes/PasswordAuthentication yes/' $SSHD
                    fi

                    if grep -q -e "^X11Forwarding no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "X11Forwarding no"                         : "[Pass]"
                    else
                        sed -i 's/.*X11Forwarding yes/X11Forwarding no/' $SSHD
                    fi

                    if grep -q -e "^TCPKeepAlive no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "TCPKeepAlive no"                          : "[Pass]"
                    else
                        sed -i 's/.*TCPKeepAlive yes/TCPKeepAlive no/' $SSHD
                    fi

                    if grep -q -e "^AllowAgentForwarding no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "AllowAgentForwarding no"                  : "[Pass]"
                    else
                        sed -i 's/.*AllowAgentForwarding yes/AllowAgentForwarding no/' $SSHD
                    fi

                    if grep -q -e "^AllowTcpForwarding no" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "AllowTcpForwarding no"                    : "[Pass]"
                    else
                        sed -i 's/.*AllowTcpForwarding yes/AllowTcpForwarding no/' $SSHD
                    fi

                    if grep -q -e "^Banner etc/ssh/banner.md" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "Banner etc/ssh/banner.md"                 : "[Pass]"
                    else
                            sed -i 's/\#Banner none/Banner \/etc\/ssh\/banner\.md/' $SSHD
                    fi

                    if grep -q -e "^MaxAuthTries 3" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "MaxAuthTries 3"                           : "[Pass]"
                    else
                        sed -i 's/.*MaxAuthTries 6/MaxAuthTries 3/' $SSHD
                    fi

                    if grep -q -e "^MaxStartups 10:30:60" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "MaxStartups 10:30:60"                     : "[Pass]"
                    else
                        sed -i 's/.*MaxStartups 10:30:100/MaxStartups 10:30:60/' $SSHD
                    fi

                    if grep -q -e "^LoginGraceTime 60" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "LoginGraceTime 60"                        : "[Pass]"
                    else
                        sed -i 's/.*LoginGraceTime 2m/LoginGraceTime 60/' $SSHD
                    fi

                    if grep -q -e "^MaxSessions 2" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "MaxSessions 2"                            : "[Pass]"
                    else
                        sed -i 's/.*MaxSessions 10/MaxSessions 2/' $SSHD
                    fi

                    if grep -q -e "^ClientAliveInterval 15" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "ClientAliveInterval 15"                   : "[Pass]"
                    else
                        sed -i 's/.*ClientAliveInterval 0/ClientAliveInterval 15/' $SSHD
                    fi

                    if grep -q -e "^ClientAliveCountMax 1" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "ClientAliveCountMax 1"                    : "[Pass]"
                    else
                        sed -i 's/.*ClientAliveCountMax 3/ClientAliveCountMax 1/' $SSHD
                    fi

                    if grep -q -e "^X11UseLocalhost yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "X11UseLocalhost yes"                      : "[Pass]"
                    else
                        sed -i 's/.*X11UseLocalhost yes/X11UseLocalhost yes/' $SSHD 
                    fi

                    if grep -q -e "^MACs [a-z/@/0-9]" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256"
                    else
                        sed -i '/Cipher*/a MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256' $SSHD
                    fi

                    if grep -q -e "^Ciphers [a-z/-/0-9]" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" : "[Pass]"
                    else
                        sed -i '/Cipher*/a Ciphers aes128-ctr,aes192-ctr,aes256-ctr' $SSHD
                    fi

                    if grep -q -e "AllowGroups sshgroup" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "AllowGroups sshgroup"                     : "[Pass]"
                    else
                        sed -i '/\Port 22/a AllowGroups sshgroup' $SSHD
                    fi
                }

            echo "[Task 3] : Creating SSH Connexion group"
            sleep 2
            user_cfg

            if command -v apt-get >/dev/null; then

                PKG="apt-get"
                echo "[Task 4] : Updating Operating System and Installing requirement packages"
                sleep 2
                $PKG update  > /dev/null 2>&1 && $PKG upgrade -y > /dev/null 2>&1

                if [[ $ID_OS == ubuntu ]]; then
                    if [[ $UBUNTU_VERSION == focal ]]; then

                        echo "[Task 5] : Hardening Secure Shell"
                        sleep 2
                        echo "Linux distribution ubuntu focal"
                        sshd_cfg

                        if grep -q -e "ChallengeResponseAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                            echo "ChallengeResponseAuthentication yes"   : "[Pass]"
                        else
                            sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' $SSHD
                        fi

                    elif [[ $UBUNTU_VERSION == jammy ]]; then

                        echo "[Task 5] : Hardening Secure Shell"
                        sleep 2
                        echo "Linux distribution ubuntu Jammy"
                        sshd_cfg

                        if grep -q -e "KbdInteractiveAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                            echo "KbdInteractiveAuthentication yes"    : "[Pass]"
                        else
                            sed -i 's/.*KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' $SSHD
                        fi
                    elif [[ $UBUNTU_VERSION == noble ]]; then

                        echo "[Task 5] : Hardening Secure Shell"
                        sleep 2
                        echo "linux distribution ubuntu Noble"
                        sshd_cfg

                        if grep -q -e "KbdInteractiveAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                            echo "KbdInteractiveAuthentication yes"    : "[Pass]"
                        else
                            sed -i 's/.*KbdInteractiveAuthentication no/KbdInteractiveAuthentication yes/' $SSHD
                        fi
                    else
                        echo "This Ubuntu version is not supported"
                        exit
                    fi
                else
                    echo "[Task 5] : Hardening Secure Shell"
                    sleep 2
                    echo "Linux distribution debian"
                    sshd_cfg

                    if grep -q -e "KbdInteractiveAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                        echo "KbdInteractiveAuthentication yes"    : "[Pass]"
                    else
                        sed -i 's/.*KbdInteractiveAuthentication yes/KbdInteractiveAuthentication yes/' $SSHD
                    fi
                fi
            elif command -v dnf >/dev/null; then

                echo "Linux distribution redhat"
                echo "[Task 4] : Updating Operating System and Installing requirement packages"
                sleep 2
                PKG="dnf"
                $PKG update -y > /dev/null 2>&1

                echo "[Task 5] : Hardening Secure Shell"
                sleep 2
                sshd_cfg

                if grep -q -e "KbdInteractiveAuthentication yes" /tmp/SSHDCONF_OUTPUT.md; then
                    echo "KbdInteractiveAuthentication yes"    : "[Pass]"
                else
                    sed -i 's/.*KbdInteractiveAuthentication yes/KbdInteractiveAuthentication yes/' $SSHD
                fi
            else
                echo "This Linux OS is not supported"
                exit 1
            fi

            echo "[Task 6] : Restarting Secure Shell service"
            if command -v apt-get >/dev/null; then
                systemctl restart ssh.service

            elif command -v dnf >/dev/null; then
                systemctl restart sshd.service

            else
                echo "This Linux distribution is not supported"
                exit 1
            fi

            echo "[Task 7] : Sucessful"
            break
            ;;
        n|N)
            clear
            break
            ;;
        *) echo 'Response not valid';;
    esac
done
