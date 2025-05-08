#!/bin/bash

# use pwnquality to set the various password policies
# Check first if libpam-pwquality is installed
if ! dpkg -l | grep -q libpam-pwquality; then
    echo "Installing libpam-pwquality ....."
    sudo apt-get update > /dev/null 2>&1
    sudo apt-get install -y libpam-pwquality > /dev/null 2>&1
fi

# Check if a file path is provided as an argument if not revert 
# to the standard input to ask for the file path 
if [ -z "$1" ]; then
    echo "No CSV file provided. Please enter the path to the CSV file:"
    read -r csv_file
else
    csv_file="$1"
fi

# Check if the file exists and is readable
if [ ! -f "$csv_file" ] || [ ! -r "$csv_file" ]; then
    echo "The file '$csv_file' does not exist or is not readable. Exiting."
    exit 1
fi


# Read the provided file
echo "Reading file ..."

tail -n +2 "$csv_file" | while IFS=',' read -r username fullname group; do
    # Create groups based on the group column (only if the group doesn't exist yet)
    if ! getent group "$group" > /dev/null; then
        sudo groupadd "$group" > /dev/null 2>&1
    fi

    echo "Processing user: $username with group: $group"
    # Create users and assign them to the appropriate group
    sudo useradd -m "$username" -G "$group" > /dev/null 2>&1

    # Set the fullname for the user
    sudo usermod -c "$fullname" "$username" > /dev/null 2>&1

    # Create a temporary password for the user
    temp_password='ChangeMe123'

    # Set the temporary password for the user
    echo "$username:$temp_password" | sudo chpasswd > /dev/null 2>&1

    # Create password policy file for the user
    ./scripts/pass_policy.sh "$username" "$temp_password"

    # Force password change on first login.
    sudo passwd -e "$username" > /dev/null 2>&1

    # Ensure each user's home directory is only accessible by that user (`chmod 700`).
    sudo chmod 700 "/home/$username" > /dev/null 2>&1

    # Ensure the user owns their home directory.
    sudo chown -R "$username:$group" "/home/$username" > /dev/null 2>&1

    # Send the email
    ./scripts/send_mail.sh "$fullname" "$username" "$group" > /dev/null 2>&1

    # Log all actions to a file named `iam_setup.log` with a timestamp.
    echo "$(date): Created user $username with group $group" >> iam_setup.log
done

# Log the end of the script
echo "$(date): Script completed" >> iam_setup.log

echo "IAM setup completed" 
