#!/bin/bash

echo "Starting script..."

user_names_list="names.csv"

group_name="developers"

# Checks for the existence of a developer group and if not, creates one.
getent group | grep $group_name

if [[ $? -ne 1 ]]
then
	echo "Skipping...., group ${group_name} already exist "
else
    echo "Creating group: ${group_name} ... "
	groupadd $group_name
fi


# Checks for the existence of a `.ssh/` directory in the `/etc/skel` configuration folder and if not, it creates the directory. 
if [[ ! -d /etc/skel/.ssh/ ]]
then
    mkdir /etc/skel/.ssh/
else
	echo '.ssh/ dir exist ...'
	echo 'Skipping...'
fi

echo 'Reading data from CSV file ...' 

# Loops through user names from the names.csv file and checks for the existence of a user, if a user exist, it skips creation.
while read user
do
	if [[ $(id $user -u) -ge 1000 ]]
	then
		echo "User $user already exist in users DB"
		continue
	fi

	useradd -m -s /usr/bin/bash -g developers $user

	# Changes ownership and permission for ~/.ssh directory for each user
	chown $user:$group_name /home/$user/.ssh/ && chmod 700 /home/$user/.ssh/

	# Creates an authorized_keys for each user, changing both ownership and permission
    touch /home/$user/authorized_keys && chown $user:$group_name /home/$user/authorized_keys && chmod 644 /home/$user/authorized_keys

	# Manually adds public key to each user's authorized_keys
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCzKZyicHxIkklSrNlxsJyyTrcIdBIt84Z0cQb3R4k0jH53kxkaT5hP8tfWTe62LXi7vV86fY+SX7TBNM76XGCbw/6vrMGegm6J1x2i1AiLNwq5nqTjOGn0AIwku4IlCCLAB7tdfRyVuCarmBlwny3lzRyybIUAWXR/D6vpN09MsDILbKdhay+Q/p9OUBMSLPqXdY/QIh/Oe3rVv1lwY3AohNfq7V3tO88zKswfA5iiexNiSYX1myT0OrX8cBE771j9quoNZhQgaLI1mIMtAvnHQChrn9k2nUaO/BMBCQGol5XzGv1ado7hgoVPoluIUD+FGNo/pH4zcmDLICH6drXY/C9MESnkMUPLFxBXKO/OitApY71vRao9nAhAwpVMsy6FqiOb5uawhvhoHYIHTV/f4EtagVagRMP2PxYMYR6jykIV4MPJTkCm+lGhTyMlRu+qRQjdLn8AAtHf4aEV8dIkoGh088DI7eA/4o0wz4OV4upH5ewSFS+5IHmRECEW5Nc=" > /home/$user/authorized_keys
		
done < $user_names_list

echo "Script executed successfully!"