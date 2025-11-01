# Harden-SSH
Overview

Secure Shell, SSH is a software package that enables secure system administration.
It is essential in the Linux environment, used in nearly every data center and in every entreprise.
As it is used everywhere, it is a target for threat actors, Secure Shell must be hardened and secured.

Cybersecurity has changed, today entreprise need solutions that block attacks by default, not just detect after the incident occurred. Industry framworks NIST, ISO, CIS and HIPAA provide guidance, but sometimes these steps are complex to implement.

That's why I wrote this script shell to simplify Secure Shell hardening and multifactor authentication (MFA) configuration. I referred to CIS Ubuntu Linux Benchmark framwork and I used google authenticator for MFA authentication.

How a simple step can stop a cyberattack before they start, Security by defaut like deny-by-default, MFA enforcement can eliminate risks. The simple strategies create a hardened environment that attackers can't easy penetrate.

1. Use

This script has been tested in several Linux distributions such as Ubuntu 20 to 24, Debian 12, Fedora 40 and Rocky 9 Linux. You can test the script with other Linux distributions and let me know. Not mush about requirements :

- Update Operating System
- Disable SELINUX for RedHat distribution family
- Run the script Harden-SSH

Note : 

- For additional configuration see PDF file.
- For the Redhat distribution family SELINUX must be isabled.
- keep in mind that, multifactor authentication will apply by defaut for all users.        
- Both authentication methods can be used password and publickey, by default password is used.
- If you want to use publickey, you must generate an ssh key and copy it to the remote server.
- The user who executes the script will automatically be a member of the sshgroup.

Reference : https://www.cisecurity.org/cis-benchmarks