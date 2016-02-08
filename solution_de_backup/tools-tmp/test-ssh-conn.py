#!/usr/bin/python3
#
import subprocess
import sys

def remote_md5sum_file(user,host,filename):
#    cmd_to_run = "md5sum \"" + str(filename) + "\" | cut -d ' ' -f 1 "
    cmd_to_run = "md5sum " + str(filename) + " | cut -d ' ' -f 1 "
    print (cmd_to_run)
    # Ports are handled in ~/.ssh/config since we use OpenSSH
    ssh = subprocess.Popen(["ssh", "%s@%s" % (user, host) , cmd_to_run],
                            shell=False,
                            stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    result = ssh.stdout.readlines()
    if result == []:
        error = ssh.stderr.readlines()
        print ("ERROR: %s" % error)
    else :
        return result[0].decode('utf-8')

# END remote_md5sum_file


# Get remote md5sum value
md5sumFile_REMOTE_file = remote_md5sum_file('xerus','127.0.0.1','/home/xerus/Nathalie_doc/Nathalie Spitz.doc')

print (md5sumFile_REMOTE_file)
print (type(md5sumFile_REMOTE_file))

# 
