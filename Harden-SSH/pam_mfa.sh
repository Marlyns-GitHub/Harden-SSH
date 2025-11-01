#!/usr/bin/env bash
echo ""
echo "_____________________________________Information_____________________________________________"
echo "                                                                                             "
echo "You want to configure secure shell multifactor authentication."
echo "Keep in mind that, this script enforce multifactor authentication by default for all users."
echo "You can modify this configuration, for more information read the README.md file."
echo "_____________________________________________________________________________________________"
echo ""

while true; do
    read -r -p 'Do you want to continue (y/n)? ' choice
    echo ""
    case "$choice" in
      y|Y)
          echo "[Task 0] : Gathering operating system and Secure Shell information"

          SSHDCFG="/etc/ssh/sshd_config"
          PAMSSHD="/etc/pam.d/sshd"
          GOOGLE_AUTH="auth required pam_google_authenticator.so"
          AUTH_METHODS="AuthenticationMethods publickey,password keyboard-interactive"
          SSHGROUP=$(awk -F: '/sshgroup/ {print $1}' /etc/group)
          SELINUX="/etc/selinux/config"

          echo "[Task 1] : Installing google-authenticator packages"
          sleep 2

          if command -v apt-get >/dev/null; then

               echo "Debian Operating System Family"
               PKG="apt-get"
               $PKG install libpam-google-authenticator -y > /dev/null 2>&1

          elif command -v dnf >/dev/null; then

               REDHAT_OS=$(awk '{print $1}' /etc/redhat-release)
               PKG="dnf"

               if [[ $REDHAT_OS == Fedora ]]; then

                    echo "$REDHAT_OS distribution"
                    $PKG install google-authenticator -y > /dev/null 2>&1 # Fedora

               elif [[ $REDHAT_OS == Rocky ]] || [[ $REDHAT_OS == CentOS ]]; then

                    echo "$REDHAT_OS distribution"
                    $PKG instll epel-release -y > /dev/null 2>&1
                    $PKG install google-authenticator qrencode qrencode-libs -y > /dev/null 2>&1 # Rocky Linux

               else
                    echo "Operating system does not supported"
                    exit
               fi
          else
               echo "This Linux OS is not supported"
               exit 1
          fi

          echo "[Task 2] : Checking if UsePAM yes and SELINUX is disabled"
          sleep 2

          if grep -q -e "UsePAM yes" $SSHDCFG; then
               echo "UsePAM is configured" >/dev/null
          else
               echo "UsePAM is not configured"
               exit 1
          fi

          if command -v dnf >/dev/null; then

               if grep -q -e "^SELINUX=disabled" $SELINUX; then
                    echo "SELINUX is disabled" >/dev/null
               else
                    echo "SELINUX is not disabled"
                    exit 1
               fi
          fi

          echo "[Task 3] : Configuring Secure shell and PAM Secure Shell"
          sleep 2
          mfa_cfg ()
               {
                    if grep -q -e "Match Group" $SSHDCFG; then
                         echo "Match Group already configured" >/dev/null
                    else
                         sed -i "s/^# End of file*//" $SSHDCFG
                         { echo "Match Group $SSHGROUP"
                           echo '      PasswordAuthentication yes'
                           echo '      KbdInteractiveAuthentication yes'
                           echo "      $AUTH_METHODS"
                           echo '# End of file'
                         } >> $SSHDCFG
                    fi

                    if [[ $VERBOSE == 'Y' ]]; then
                         grep -v '#' $SSHDCFG | uniq
                         echo
                    fi

                    if grep -q -e "$GOOGLE_AUTH" $PAMSSHD; then
                         echo "Pam google-authenticator already configured" >/dev/null
                    else
                         sed -i "s/^# End of file*//" $PAMSSHD
                         { echo "$GOOGLE_AUTH"
                           echo '# End of file'
                         } >> $PAMSSHD
                    fi

                    if [[ $VERBOSE == 'Y' ]]; then
                         grep -v '#' $PAMSSHD | uniq
                         echo
                    fi
               }
          mfa_cfg

          echo "[Task 4] : Restarting Secure Shell Service"

          if command -v apt-get >/dev/null; then
               systemctl restart ssh.service

          elif command -v dnf >/dev/null; then
               systemctl restart sshd.service

          else
               echo "This Linux distribution is not supported"
               exit 1
          fi

          echo "[Task 5] : Configuring MFA Google Authenticator"
          sleep 2
          add_mfa_user()
               {
                    read -p "Enter username : " name
                    export USERNAME=$name
                    awk -F: '{print $1}' /etc/passwd > /tmp/AllUsers.md

                    if grep -q -e "$USERNAME" /tmp/AllUsers.md; then
                         sudo -u $USERNAME google-authenticator -t -f -d -w 3 -e 10 -r 3 -R 30
                         echo "MFA Configured for $USERNAME"
                    else
                         echo "User $USERNAME does not exist"
                    fi
               }
          add_mfa_user
          echo "[Task 6] : Successful"
          break
          ;;
      n|N) clear
           break
           ;;
      *) echo 'Response not valid';;
    esac
done
