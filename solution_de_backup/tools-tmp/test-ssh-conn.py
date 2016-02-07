#!/usr/bin/python3
#
import subprocess
import sys

user="xerus"
HOST="127.0.0.1"

# Ports are handled in ~/.ssh/config since we use OpenSSH
COMMAND="uname -a"

ssh = subprocess.Popen(["ssh", "%s@%s" % (user, HOST), COMMAND ],
        shell=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE)
result = ssh.stdout.readlines()
if result == []:
    error = ssh.stderr.readlines()
    print >>sys.stderr, "ERROR: %s" % error
else :
    print (result)
