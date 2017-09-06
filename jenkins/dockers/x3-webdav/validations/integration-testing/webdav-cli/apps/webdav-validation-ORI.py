#!/usr/bin/env python
#
# Description : Realise un test de webdav envoie et recuperation de fichier
#
# Author : Thomas Boutry <thomas.boutry@x3rus.com>
# Licence : GPLv3+
#

###########
# Modules #
import webdav.client as wc
import os
import hashlib
import unittest

#############
# Variables #

URL = "http://webdav"

# Get Os Variables

try:
    lst_auth_username_pass = os.environ.get('USERS_PASS').split(" ")
except AttributeError:
    # Variable USERS_PASS not set so use default user / pass
    lst_auth_username_pass = ['thomas=toto']

#############
# Functions #


def f_sha1_file(filename):
    # BUF_SIZE is totally arbitrary, change for your app!
    BUF_SIZE = 65536  # lets read stuff in 64kb chunks!

    sha1 = hashlib.sha1()

    with open(filename, 'rb') as f:
        while True:
            data = f.read(BUF_SIZE)
            if not data:
                break
            sha1.update(data)

    return format(sha1.hexdigest())
# end f_sha1_file


class TestWebDavContainer(unittest.TestCase):

    # Voir : https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    def setUp(self):
        print("username " + username)
        print("pass " + password)

        options = {
            'webdav_hostname': url,
            'webdav_login':    username,
            'webdav_password': password
            }
        client = wc.Client(options)



def f_test_webdav_conn(username, password, url):

    print("username " + username)
    print("pass " + password)

    options = {
        'webdav_hostname': url,
        'webdav_login':    username,
        'webdav_password': password
        }
    client = wc.Client(options)

    # Create Dir :
    status = client.mkdir("uploads/intergrationTesting/")
    print(status)

    # get hash file
    sha1_file_ori = f_sha1_file('/x3-apps/tux_avatars1.jpg')

    # put file
    client.upload_sync(remote_path="uploads/intergrationTesting/tux.png",
                       local_path="/x3-apps/tux_avatars1.jpg")

    # list files
    lst_files = client.list("uploads/intergrationTesting")
    print(lst_files)

    info = client.check("uploads/intergrationTesting/tux.png")
    print(info)

    # get file
    client.download_sync(remote_path="uploads/intergrationTesting/tux.png",
                         local_path="/tmp/tux.png")

    sha1_file_download = f_sha1_file('/tmp/tux.png')

    if sha1_file_ori != sha1_file_download:
        print('ERROR: Sha1 original file and downloaded file not the same')
    else:
        print('File match')

# end f_test_webdav_conn

#########
# Main  #


for auth_info in lst_auth_username_pass:
    lst_auth_info = auth_info.split('=')
    f_test_webdav_conn(lst_auth_info[0], lst_auth_info[1], URL)
