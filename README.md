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
    - [ ] Registry Values
    - [ ] Privilege Rights
        

## TODO: 
- [ ] add authorized users, and admins to a folder so the script can check through them