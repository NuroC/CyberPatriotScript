## Before executing the script.

- make sure to answer the forensic questions.
- note down the users and admins from the readme file.

## List of featues
- [x] Password Policy
    - [x] System Access: (CONFIG in [here](./lib//secpol/System%20Access.json))
        - Minimum Password Age: 1
        - Maximum Password Age: 60
        - Minimum Password Length: 14
        - Password Complexity: Enabled
        - Password History Size: 24
        - Lockout Bad Count: 5
        - Lockout Duration: 30
        - Force Logoff When Hour Expired: Enabled
        - Clear Text Password: Disabled
        - Enable Admin Account: Disabled
        - Enable Guest Account: Disabled
    - [ ] Event Audit
        - Audit System Events: Success
        - Audit Logon Events: Success
        - Audit Object Access: Success
        - Audit Privilege Use: Success
        - Audit Policy Change: Success
        - Audit Account Management: Success
        - Audit Process Tracking: Success
        - Audit DS Access: Success
        - Audit Account Logon: Success
- [x] Firewalls
    - [x] FireWall Rules
        -  too much to list, see [here](./src/Firewalls//Firewall%20Rules.psm1)
    - [x] Firewall Profiles
        - make sure firewall service is running and configurable
        - Enable the entire firewall
        - set direction defaults
        - settings for profiles
        - Uniqe settings for Public profile
        - Logging for Domain, Private and Public profiles
- [x] remove all printers
- [x] remove unsecure services (see [here](./src/services/services.psm1))
- [x] remove unsecure scheduled tasks (see [here](./src/tasks/tasks.psm1))


        

## TODO: 
- [ ] add authorized users, and admins to a folder so the script can check through them