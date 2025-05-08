#!/bin/bash

local username=$1
local temp_password=$2

# Create password policy file for the user,
echo 'minlen=12
    dcredit=-1
    ucredit=-1
    lcredit=-1
    ocredit=-1
    maxrepeat=3
    difok=7
    reject_username
    dictcheck=1' | sudo tee "/etc/pam.d/password-policy-$username" > /dev/null

# Configure PAM to use the password policy for this user, if not configured. 
if ! grep -q "password.*pam_pwquality.so.*file=/etc/pam.d/password-policy-$username" /etc/pam.d/common-password; then
    sudo sed -i "1i password requisite pam_pwquality.so retry=3 file=/etc/pam.d/password-policy-$username" /etc/pam.d/common-password > /dev/null 2>&1
fi

# check to prevent reuse of default password -check-password-policy
echo -e "#!/bin/sh\n
if [ \"\$PAM_AUTHTOK\" = \"$temp_password\" ]; then
echo 'You cannot use the default password. Please choose a different one.'
exit 1
fi" | sudo tee "/etc/pam.d/check-password-$username" > /dev/null
sudo chmod +x "/etc/pam.d/check-password-$username" > /dev/null 2>&1

# check if the check-password-policy is already configured, if not, add it.
if ! grep -q "password.*pam_exec.so.*seteuid.*/etc/pam.d/check-password-$username" /etc/pam.d/common-password; then
    sudo sed -i "1i password requisite pam_exec.so seteuid /etc/pam.d/check-password-$username" /etc/pam.d/common-password > /dev/null 2>&1
fi

