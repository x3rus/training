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
import webdav.exceptions as wcException
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
# Classe    #


class TestWebDavContainer(unittest.TestCase):

    # Voir:https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # setup user password
    username = "thomas"
    password = "toto"
    url = "http://webdav"

    def setUp(self):

        options = {
            'webdav_hostname': self.url,
            'webdav_login':    self.username,
            'webdav_password': self.password
            }
        self.client = wc.Client(options)

    def test_01_CreateDirectory(self):
        self.client.mkdir("uploads/intergrationTesting/")

    def test_02_UploadFile(self):
        # put file
        self.client.upload_sync(remote_path="uploads/intergrationTesting/tux.png",
                                local_path="/x3-apps/tux_avatars1.jpg")

    def test_03_ListDirectoy(self):
        # list files
        self.client.list("uploads/intergrationTesting")

    def test_04_DownloadFile(self):
        # get file
        self.client.download_sync(remote_path="uploads/intergrationTesting/tux.png",
                                  local_path="/tmp/tux.png")

        sha1_file_download = self.f_sha1_file('/tmp/tux.png')
        sha1_file_ori = self.f_sha1_file('/x3-apps/tux_avatars1.jpg')

        self.assertEqual(sha1_file_ori, sha1_file_download)

    def test_05_BadLoginGetFile(self):
        with self.assertRaises(wcException.RemoteResourceNotFound):
            self.client.download_sync(remote_path="uploads/intergrationTesting/tuxNot.png",
                                      local_path="/tmp/tux.png")

    def f_sha1_file(self, filename):
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
# END TestWebDavContainer


class TestWebDavContainerBadLogin(unittest.TestCase):

    # Voir:https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # setup user password
    username = "Notthomas"
    password = "Nottoto"
    url = "http://webdav"

    def setUp(self):

        options = {
            'webdav_hostname': self.url,
            'webdav_login':    self.username,
            'webdav_password': self.password
            }
        self.client = wc.Client(options)

    def test_01_CanNotCreateDirectory(self):
        with self.assertRaises(wcException.RemoteParentNotFound):
            self.client.mkdir("uploads/intergrationTesting/")

    def test_02_CanNotListFile(self):
        # list files
        with self.assertRaises(wcException.RemoteResourceNotFound):
            self.client.list("uploads/")


class TestWebDavContainerAnonymous(unittest.TestCase):

    # Voir:https://stackoverflow.com/questions/11380413/python-unittest-passing-arguments
    # setup user password
    url = "http://webdav"

    def setUp(self):

        options = {
            'webdav_hostname': self.url,
            }
        self.client = wc.Client(options)

    def test_01_CanNotCreateDirectory(self):
        with self.assertRaises(wcException.RemoteParentNotFound):
            self.client.mkdir("uploads/intergrationTesting/")

    def test_02_CanNotListFile(self):
        # list files
        with self.assertRaises(wcException.RemoteResourceNotFound):
            self.client.list("uploads/")


#########
# Main  #

if __name__ == '__main__':
    unittest.main()
