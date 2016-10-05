#!/usr/bin/python
#
#
# Autheur : Thomas Boutry <thomas.boutry@x3rus.com>
####################################################

# Modules
import os
import subprocess

DB_FILE_NAME="./db.txt"

# Main

lst_reps = [line.rstrip('\n') for line in open('reps.conf','r')]
db_file = open(DB_FILE_NAME, 'w')


for rep in lst_reps:
    print (rep)
    for root, dirs, files in os.walk(rep, topdown=False):
        for name in files:
            filename = (os.path.join(root, name))
            sha1Result= subprocess.run(["sha1sum", filename  ], stdout=subprocess.PIPE)
            db_file.write(str(sha1Result.stdout))
            db_file.write("\n")
        for name in dirs:
            filename = (os.path.join(root, name))
            sha1Result= subprocess.run(["sha1sum", filename ], stdout=subprocess.PIPE)
            db_file.write(str(sha1Result.stdout))
            db_file.write("\n")


