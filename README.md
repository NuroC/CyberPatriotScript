# Cyber Patrior script
I made this script specifically for windows.


## What does this script do?


### Password Policy

- Enforce password history
- Maximum password age
- Minimum password age

### Lockout Policy

- Account lockout duration
- Account lockout threshold
- Reset account lockout counter

### Security Audit Policy

- Account Logon
- Account Management
- DS Access
- Logon/Logoff
- Object Access
- Policy Change
- Privelege Use
- Detailed Tracking
- System

reference:
https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/audit-policy

- disabling Guest account
- flushing DNS cache

### Windows Firewall

- Remote Assistance (DCOM-In)
- Remote Assistance (PNRP-In)
- Remote Assistance (RA Server TCP-In)
- Remote Assistance (SSDP TCP-In)
- Remote Assistance (SSDP UDP-In)
- Remote Assistance (TCP-In)

reference:
https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/netsh-advfirewall-firewall-control-firewall-behavior

### Windows net Firewall Rules

- sshTCP (port 22)
- ftpTCP (port 21)
- telnetTCP (port 23)
- SMTPTCP (port 25)
- POP3TCP (port 110)
- SNMPTCP (port 161)
- RDPTCP (port 3389)

reference:
https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=windowsserver2022-ps
