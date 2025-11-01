#!/usr/bin/env bash
clear
function option_one ()
   {
     #echo "Running function for option 1 "
     bash ./harden_ssh.sh
   }

function option_two ()
   {
     #echo "Running function for option 2 "
     bash ./pam_mfa.sh
   }

while true; do
      cat ./banner.md
      echo "" && echo ""
      echo "1) Harden Secure Shell"
      echo "2) Configure SSH MFA"
      echo "0) Exit"
      echo ""
      read -p "Enter choise [0-2]: " choise
      case $choise in
           1) option_one;;
           2) option_two;;
           0) echo "Exiting program."; break;;
           *) echo "Invalid option. Try again.";;
      esac
done
sleep 3
clear
