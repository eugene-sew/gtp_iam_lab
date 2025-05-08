#! /bin/bash

# Get full name from the command line argument and password
# api key made available for testing purposes 

full_name=$1
username=$2
team_name=$3

curl -X POST 'https://api.resend.com/emails' \
  -H 'Authorization: Bearer re_hDhgsZtT_NufayQ7QhAXekfC6JR5xjgVT' \
  -H 'Content-Type: application/json' \
  -d "{
  \"from\": \"CloudChef Ops <onboarding@info.ballotbase.online>\",
  \"to\": [\"eugene.sewor@amalitechtraining.org\"],
  \"subject\": \"New Account Creation\",
   \"html\": \"<div> <h1>Hello Admin</h1> <br> A new account has been created <br> <h3>Details</h3> Username:  ${username} <br> Fullname: ${full_name} <br> User Group: ${team_name}  </p>\"
}"