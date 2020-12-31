import pexpect
import sys
import argparse
import os

def signReq ():
    PASS_CA = os.environ.get("PASS_CA")
    NAME = os.environ.get("NAME_SERVER")
    if NAME == None :
        NAME = "server"
    print("Signing Request")
    print("Using directory : "+sys.argv[2])
    print("Starting script FOR sign-req server" + NAME)
    child = pexpect.spawn(sys.argv[2]+"/easy-rsa/easyrsa sign-req server " + NAME)
    print("Spawn Child")
    child.expect("Confirm")
    print("Expecte Confirm")
    child.send("yes\n")
    print("Send confirm")
    child.expect("pass phrase")
    print("Expect Ca-PASS")
    child.send(PASS_CA+"\n")
    print("Send PASS")
    child.expect(pexpect.EOF)
    print("Expect End")
    child.close()
    print("Close child")

def genReq ():
    PASS = os.environ.get("PASS_SERVER")
    NAME = os.environ.get("NAME_SERVER")
    if NAME == None :
        NAME = "server"
    
    print("Generating Request")
    print("Using directory : "+sys.argv[2])
    print("Launching Script for GEN-REQ server")
    child = pexpect.spawn(sys.argv[2]+"/easy-rsa/easyrsa gen-req server")
    print("Child spawned")
    child.expect("pass phrase")
    print("PASS Expected")
    child.send(PASS+"\n")
    print("Send PASS")
    child.expect("pass phrase")
    print("PASS Expected")
    child.send(PASS+"\n")
    print("Send PASS")
    child.expect("Common Name")
    print("Expect NAME")
    child.send(NAME+"\n")
    print("Send NAME")
    child.expect(pexpect.EOF)
    print("END of Script")
    child.close()
    print("Close Child")

def buildCA ():
    PASS = os.environ.get("PASS_CA")
    NAME = os.environ.get("NAME_CA")
    if NAME == None :
        NAME = "ca"

    print("Building Certificat Authority");
    print("Using directory : "+sys.argv[2])
    print("Creating Certificat Authority")
    child = pexpect.spawn(sys.argv[2]+"/easy-rsa/easyrsa build-ca")
    print("Child Spawned")
    child.expect("Passphrase")
    print("Passphrase Expected")
    child.send(PASS+"\n")
    print("Send PASS")
    child.expect("Passphrase")
    print("Confirmation Passphrase Expected")
    child.send(PASS+"\n")
    print("Send PASS")
    child.expect("Common Name")
    print("Name Expected")
    child.send(NAME+"\n")
    print("Send NAME")
    child.expect(pexpect.EOF)
    print("END Expected")
    child.close()
    print("Program ENDS")

if sys.argv[1] == "-s":
    signReq()
elif sys.argv[1] == "-g":
    genReq()
elif sys.argv[1] == "-b":
    buildCA()
else:
    print("How did you do that")

if len(sys.argv) <= 1:
    sys.argv.append('--help')

