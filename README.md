# Harden-SSH
Overview

Secure Shell, SSH is a software package that enables secure system administration.
It is essential in the Linux environment, used in nearly every data center and in every entreprise.
As it is used everywhere, it is a target for threat actors, Secure Shell must be hardened and secured.

Cybersecurity has changed, today entreprise need solutions that block attacks by default, not just detect after the incident occurred. Industry framworks NIST, ISO, CIS and HIPAA provide guidance, but sometimes these steps are complex to implement.

That's why I wrote this script shell to simplify Secure Shell hardening and multifactor authentication (MFA) configuration. I referred to CIS Ubuntu Linux Benchmark framwork and I used google authenticator for MFA authentication.

How a simple step can stop a cyberattack before they start, Security by defaut like deny-by-default, MFA enforcement can eliminate risks. The simple strategies create a hardened environment that attackers can't easy penetrate.

1. Usage

This script has been tested in several Linux distributions such as Ubuntu 20 to 24, Debian 12, Fedora 40 and Rocky 9 Linux. You can test the script with other Linux distributions and let me know. Not mush about requirements :

- Update Operating System
- Disable SELINUX for RedHat distribution family

Note :       

- For the Redhat distribution family SELINUX must be isabled.
- keep in mind that, multifactor authentication will apply by defaut for all users.        
- Both authentication methods can be used password and publickey, by default password is used.
- If you want to use publickey, you must generate an ssh key and copy it to the remote server.         

2. In case.

a) To disabled SELINUX, Edit /etc/selinux/config, change enforcing to disabled

SELINUX=disabled

After that, restart the server

b) If you want to apply MFA only to some users, edit /etc/pam.d/sshd file and add nullok.

auth required pam_google_authenticator.so nullok

After that, restart Secure shell service

For Debian Family : systemclt restart ssh                                                                  
For RedHat Family : systemclt restart sshd

c) I limited SSH connection only to menbers of the sshgroup, add user to group

usermod -aG sshgroup username

d) If you want to use publickey authentication method
- Generate sshkey on your management host and copy the pubkey to the remote server

    ssh-keygen -t ed25519 -C "your_email@example.com"                                                      
    ssh-copy-id username@remote_host

- Edit /etc/ssh/sshd_config and change some parameters

PasswordAuthentication no                                                               PubkeyAuthentication yes

Match Group sshgroup                                                                                 
            PubkeyAuthentication yes                                                                       
            KbdInteractiveAuthentication yes                                                               
            AuthenticationMethods publickey keyboard-interactive                                           

4.3 Restart Secure shell service

For Debian Family : systemclt restart ssh                                                                  
For RedHat Family : systemclt restart sshd
