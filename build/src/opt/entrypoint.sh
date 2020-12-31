#!/bin/bash

directory=/root/openvpn
params=(EASYRSA_REQ_COUNTRY EASYRSA_REQ_PROVINCE EASYRSA_REQ_CITY EASYRSA_REQ_ORG EASYRSA_REQ_EMAIL EASYRSA_REQ_OU EASYRSA_REQ_SIZE)

# Create the specified directory
if [ ! -d $directory ];then
    mkdir $directory
fi
cd $directory

# Create easy-rsa directory
if [ ! -d $directory/easy-rsa ];then
    mkdir $directory/easy-rsa
fi

# link easy-rsa executable to root easy-rsa directory
ln -s /usr/share/easy-rsa/* /root/openvpn/easy-rsa/

# Create user directory
if [ -d $directory/client ];then
	mkdir $directory/client
fi

# Copy base config for user config
if [ -f $directory/client/base.conf ];then
	cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf $directory/client/base.conf
fi

# Create vars file if not created
if [ ! -f $directory/easy-rsa/vars ];then
    cp $directory/easy-rsa/vars.example $directory/easy-rsa/vars    

    for var in "${params[@]}";do
       if [ -z ${var} ];then
           echo "Please set $var -> ${var}"
           exit 2 
       else
           echo "$var -> $("$var")"
           echo "Changing $var"
           sed -i 's/#set_var\ '$var'.*/set_var\ '$var'\ \"'${var}'\"/g' $directory/easy-rsa/vars
       fi
    done
fi

# Test IF pki directory is created AND usefull file are available
# ELSE delete ALL file and recreate everything
if [ ! -d $directory/easy-rsa/pki ] || 
    [ ! -f $directory/ca.crt ] && 
    [ ! -f $directory/${NAME_CA}.crt ] || 
    [ ! -f $directory/ta.key ] || 
    [ ! -f $directory/server.crt ] && 
    [ ! -f $directory/${NAME_SERVER}.crt ] || 
    [ ! -f $directory/dh.pem ];then
	
    echo " -- You're missing important file... Creating"
	
	if [ -f $directory/ca.crt ];then
		rm $directory/ca.crt
	elif [ -f $directory/${NAME_CA}.crt ];then
		rm $directory/${NAME_CA}.crt
	fi
	
    if [ -f $directory/ta.key ];then
		rm $directory/ta.key
	fi
	
    if [ -f $directory/server.crt ];then
		rm $directory/server.crt
	elif [ -f $directory/${NAME_SERVER}.crt ];then
		rm $directory/${NAME_SERVER}.crt
	fi

	if [ -f $directory/dh.pem ];then
		rm $directory/dh.pem
	fi
	
    if [ -d $directory/pki ];then
		rm -rf $directory/pki
	fi
	
	echo "Initialisation of pki"
    # initialise the PKI
	$directory/easy-rsa/easyrsa init-pki
	
    # Build the Certificat Authority
    echo -e "${PASS_CA}"	
	if [ ! -z "${PASS_CA}" ];then
		echo "building ca"
		python3 /opt/VPN.py -b $directory
	else
		echo "Please set PASS_CA"
	fi

    # Copy the CA to $directory
	if [ ! -z "${NAME_CA}" ];then
		cp $directory/pki/${NAME_CA}.crt $directory/
	else
		cp $directory/pki/ca.crt $directory/
	fi

    # Create Server Certificat
	if [ ! -z "${PASS_SERVER}" ] && [ ! -z "${PASS_CA}" ];then
		echo "Generating server cert"
		python3 /opt/VPN.py -g $directory
		echo "Signing server cert"
		python3 /opt/VPN.py -s $directory
	else
		echo "Please set PASS_SERVER"
	fi

    # Copy the Server Cert to $directory
	if [ ! -z "${NAME_SERVER}" ];then
		cp $directory/pki/issued/${NAME_SERVER}.crt $directory/
		cp $directory/pki/private/${NAME_SERVER}.key $directory/
	else
		ls -la $directory/pki/issued 
		cp $directory/pki/issued/server.crt $directory/
		cp $directory/pki/private/server.key $directory/
	fi
	
	echo "Generating dh.pem"
    # Generate gen-dh and copy it to $directory
    $directory/easy-rsa/easyrsa gen-dh
	cp $directory/pki/dh.pem $directory/
	
	echo "Generating ta.key"
    # Generate ta.key and copy it to $directory
	openvpn --genkey --secret $directory/ta.key
    cp $directory/ta.key $directory/

fi

if [ ! -z "${UserPassFile}" ];then
    if [ -f "$directory/${UserPassFile}" ];then
		echo "Generating Users Creds"
		# python3 ../gen_creds.py	
	else
		echo "No file found to create users from."
	fi	
fi
