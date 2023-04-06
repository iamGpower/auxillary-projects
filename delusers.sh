#!/bin/bash

user_names_list="names.csv"
group_name="developers"

echo "Starting script"

while read user
do
        if [[ $(id $user -u) -gt 1000 ]]
        then
        userdel -r $user &>/dev/null
        echo "user has been deleted"
        fi
done < $user_names_list

getent group | grep $group_name

if [[ ! $? -ne 1 ]]
then
	groupdel $group_name
else
    echo "Skipping...., group $group_name already exist "
fi