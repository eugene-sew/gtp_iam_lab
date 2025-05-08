#! /bin/bash

# Read the users.txt file
while IFS=',' read -r username fullname group; do
    # Delete the user
    sudo userdel -r "$username"
    # Delete the group
    sudo groupdel "$group"
done < users.txt