#!/bin/bash
# Reads teh command line input and loads customer fields
# in to .env file and then post them to my google contacts.
# Once loaded into the .env it fires a headless chrome
# browser which enters customers into the Promax CRM 
# rtroop wrote this
read -p 'First name: ' fName
read -p 'Last name: ' lName
read -p 'Phone number: ' phNum
read -p 'Email address: ' eMail
read -p 'Stock: ' stock
# read -p 'Lead Source: ' upSrc
# read -p 'Profile: ' bureau
# read -p 'Status: ' sitRep
# read -p 'Note: ' note
echo $phNum >> 'text\phoneNumbers.txt'
sed -i 's/PHONE=.*$/PHONE='$phNum'/' ./.env
sed -i 's/FIRST=.*$/FIRST='$fName'/' ./.env
sed -i 's/LAST=.*$/LAST='$lName'/' ./.env
sed -i 's/EMAIL=.*$/EMAIL='$eMail'/' ./.env
sed -i 's/STOCK=.*$/STOCK='$stock'/' ./.env
JSON_FMT='{"memberships":[{"contactGroupMembership":{"contactGroupResourceName":"contactGroups/25c7960c0f4c49e3"}}],"names":[{"givenName":"%s","familyName":"%s"}],"phoneNumbers":[{"type":"mobile","value":"%s"}],"emailAddresses":[{"value":"%s"}], "userdefined":[{"stock":"%s"}]}' \
JSON_STING=$(printf "$JSON_FMT" "$fName" "$lName" "$phNum" "$eMail" "$stock")
#get a new token
function newToken() {
curl -s \
--request POST \
--data 'client_id=897267378006-ov2rlkvujeb82nd0k3es5p167vfusij1.apps.googleusercontent.com&client_secret=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&refresh_token=1//04GQ08V6keUVsCgYIARAAGAQSNwF-L9Ir98nMf5e4Iq5SaiPU2ip-KI5oAfrIOoaEF6UYm-aKSafzkz-bnMPtupHq2JarEgKUOh4&grant_type=refresh_token' \
https://accounts.google.com/o/oauth2/token | grep 'access_token'| awk -F '"' '{print $4}'
} 
token='Authorization: Bearer '$(newToken)
# post to my google contacts
curl -s \
  --request POST \
  'https://people.googleapis.com/v1/people:createContact?key=AIzaSyDmKpuCG2h2zV47kwkcZlq98_ua9vAMyJg' \
  --header "${token}" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data   "${JSON_STING}" \
  --compressed >> "text/temp.json"

npm run start >> "text/temp.txt"
sed -i 's/^NOTE/;5NOTE/' ./.env
echo $?