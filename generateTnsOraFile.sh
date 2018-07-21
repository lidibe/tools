#! /bin/bash

# Execute this script only is the password less ssh is implemented. Otherwise, please implement it upfront.

filename="tnsnames.ora"
path="$ORACLE_HOME/network/admin"
localtnsnamespath=/tmp/tnsnames.ora
if [ $1 ]
then
    hostname=$1
    if [ $2 ]
    then
        username=$2
    else
        username="$USER"
    fi
else
    # Read the host, username, oracle SID, oracle server name to create the required file
    echo "What host you want to deploy the tnsnames.ora file ?"
    read hostname
    echo "What is your username on $hostname? ($USER?)"
    read username
    echo "What is your Oracle SID on $hostname? (ORCL?)"
    read sid
    echo "What is your Oracle Server name?"
    read server

    if [ ! $username ]
    then
        username="$USER"
    fi

    if [ ! $sid ]
    then
        sid="ORCL"
    fi

    if [ ! $server]
    then
        echo "The Oracle server details are required"
    	exit 255
    fi
fi

# Generate the local tnsnames.ora file on the local server
cat > "$localtnsnamespath" <<-EOF
$sid =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(Host = $server)(Port = 1521))
    (CONNECT_DATA =
      (SID = $sid)
   )
)
EOF


# Remote copy of the file content to the target servers
echo "We need to log into $hostname as $username to set create the tnsnames.ora file" 
cat "$localtnsnamespath" | ssh "$hostname" -l "$username" '[ -d .ssh ] || cat > "$path/$filename"; chmod 644 "$path/$filename"'
status=$?

if [ $status -eq 0 ]
then
    echo "Set up complete"
    exit 0
else
    echo "an error has occured"
    exit 255
fi
