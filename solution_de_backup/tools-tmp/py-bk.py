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
import hashlib    # Import hashlib library (md5 method is part of it) 
import re,os,sys,random,subprocess

########
# Func #
def random_file_quick(dir):
    """ From http://stackoverflow.com/ 
    http://stackoverflow.com/questions/6411811/randomly-selecting-a-file-from-a-tree-of-directories-in-a-completely-fair-manner 
    """
    print ("REP " + dir)
    file = os.path.join(dir, random.choice(os.listdir(dir)));
    if os.path.isdir(file):
        return random_file(file)
    else :
        return file

# END random_file_quick

def random_file_long(dir):
    """
    TODO : ajout d'un la doc 
    """
    lst_files = []
    for dirname, dirnames, filenames in os.walk(dir):
        for filename in filenames:
            print ("The Filename :" + os.path.join(dirname, filename)) 
            lst_files.append(os.path.join(dirname, filename))

    return random.choice(lst_files)

# END random_file_long

def random_file(dir,short_search=True):
    """
        Get a random file
    """
    rnd_file = None

    try :
        if short_search :
            rnd_file = random_file_quick(dir)
        else :
            rnd_file = random_file_long(dir)
    except IndexError as e:
        # Maybe the quick search select the wrong directory try long search
        if short_search : 
           rnd_file =  random_file(dir,False)
    except PermissionError as e:
        print (" You don't have permissions for the directory  " + dir )

    return rnd_file

# END random_file

def get_md5sum(filename):

    # Open,close, read file and calculate MD5 on its contents 
    # Open file with RB << to be able to process any file binary OR text 
    with open(filename,'rb') as file_to_check:
        # read contents of the file
        data = file_to_check.read()    
        # pipe contents of the file through 
        # For sha1sum use : sha1 function
        md5_returned = hashlib.md5(data).hexdigest()

    return md5_returned

# END get_md5sum 

def remote_md5sum_file(user,host,filename):
    """
        TODO : ajouter ici 
    """

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
    else:
        print (str(result[0]).strip())

# END remote_md5sum_file
###############
## Variables ##
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
    o_verbose = True

# set parameters to vars
o_rsnapshot_conf_file = args.conf

##########
## MAIN ##
lst_bk_lines = []
snapshot_root = None
md5sumFile_BK_file = None

# variable validation
try :
    rconf_fd = open(o_rsnapshot_conf_file,"r")
    for line in rconf_fd.readlines():
        backup_line= re.search("^backup", line)
        if backup_line: 
                lst_bk_lines.append(line)
        elif re.search("^snapshot_root", line):
            re_root_clean = re.compile(r'^snapshot_root\t+(.*)\t?\s?$')
            re_root_clean_m = re_root_clean.match(line)
            snapshot_root=re_root_clean_m.group(1)

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
    dct_bk_info = re_line_clean_m.groupdict()
except sre_constants.error as e:
    print ("Error : with regular Expression , please take a look :D ")
    sys.exit(1)

#{'bkhost': '10.10.11.1', 'bklocalPath': '.', 'bkRemotePath': '//var/lib/iptables ', 'bkuser': 'root'}

BK_Directory =  str(snapshot_root).strip() + str(dct_bk_info['bklocalPath']).strip() + "/daily.0/" \
               + str(dct_bk_info['bkRemotePath']).strip()

snapshot_root="/"
BK_Directory = str(dct_bk_info['bkRemotePath']).strip()
the_bk_file = random_file(BK_Directory, True)

if the_bk_file != None :
    md5sumFile_BK_file = get_md5sum(the_bk_file)
    if o_verbose : 
        print (" File : " + the_bk_file )
        print (" MD5: " + md5sumFile_BK_file)
        

# Get remote md5sum value
remote_md5sum_file('xerus','127.0.0.1',the_bk_file)

#random_file():

