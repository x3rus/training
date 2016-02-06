#!/usr/bin/python
#
# Description :
#   Analyse ou valide un fichier du bk
#   
# 
# Auteur : Boutry Thomas <thomas.boutry@x3rus.com>
# Date de création : 2016-02-05
# Licence : GPL v3.
###############################################################################

import argparse
import re,sys,random

# Variables
o_verbose = False
o_rsnapshot_conf_file= None

# Parse parameters
parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", help="increase output verbosity",
                            action="store_true")
parser.add_argument("-c","--conf", 
                            help="configue file to process")
args = parser.parse_args()
if args.verbose:
        print ("verbosity turned on")

# set parameters to vars
o_rsnapshot_conf_file = args.conf

lst_bk_lines=[]
# variable validation
try :
    rconf_fd = open(o_rsnapshot_conf_file,"r")
    for line in rconf_fd.readlines():
        backup_line= re.search("^backup", line)
        if backup_line: 
                lst_bk_lines.append(line)
except IOError as e:
        print ("I/O error({0}): {1})".format(e.errno, e.strerror))
        sys.exit(1)

if len(lst_bk_lines) == 0 :
    print ("No backup lines found in file  : " + o_rsnapshot_conf_file )
    sys.exit(1)

rdm_line_num=random.randrange(1,len(lst_bk_lines))

# TODO remove juste debug
print (rdm_line_num)
print (lst_bk_lines[rdm_line_num])

try :
    re_line_clean = re.compile(r'^backup\t+(?P<bkuser>[\w0-9-_]+)@(?P<bkhost>.*):(?P<bkRemotePath>.*)\t+(?P<bklocalPath>.*)\t?$')
    re_line_clean_m = re_line_clean.match(lst_bk_lines[rdm_line_num])

    # TODO remove juste debug
    print (re_line_clean_m.groupdict())
except sre_constants.error as e:
    print ("Error : with regular Expression , please take a look :D ")
    sys.exit(1)

#{'bkhost': '10.10.11.1', 'bklocalPath': '.', 'bkRemotePath': '//var/lib/iptables ', 'bkuser': 'root'}

# TODO : ajout except sre_constants.error:

