# OpenVPN-PKI
An OpenVPN PKI creator which run in docker

## Start-up

Copy the files in a directory, place yourself in a directory and simply : 
> Set ENV Variable in the docker-compose.yml <br>
> run docker-compose up --build

## Server Configuration
When you launch the docker for the first time it will create a server.conf with a basic configuration depending on the Environnement Variable you've set and depending on the default value.

If you want to further configure your server please edit the server.conf directly they will be used on the next restart. 

You can edit it like a standard OpenVPN Server every modification will be effective at the next restart.

## Env Variable
The **bold text** are the default value.

Please **don't put file extension** in the ENV variable.

* Mandatory
  * **OPENVPN_COUNTRY**
  * **OPENVPN_PROVINCE**
  * **OPENVPN_CITY**
  * **OPENVPN_ORG**
  * **OPENVPN_EMAIL**
  * **OPENVPN_OU**
  * **PASS_CA**
    > Password for the CA
  * **PASS_SERVER**
    > Password for the server
* Optional
  * **NAME_CA**
    > Name of the CA
  * **NAME_SERVER**
    > Name of the server
  * **OPENVPN_KEY**
    > Size of the DH key used (**2048**)
  * **UserPassFile**
    > Name of the file used to create user and password (Pattern = **user:password**)

## How to reset the configuration

To reset the configuration you just need to delete all the file in data and restart the docker.

