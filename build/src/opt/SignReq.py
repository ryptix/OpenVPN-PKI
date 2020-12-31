import pexpect
import os

PASS_CA = os.environ.get("PASS_CA")
NAME = os.environ.get("NAME_SERVER")
if NAME == None :
    NAME = "server"

print("Using directory : "+sys.argv[1])

print("Starting script FOR sign-req server" + NAME)
child = pexpect.spawn(sys.argv[1]+"/easy-rsa/easyrsa sign-req server " + NAME)
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

