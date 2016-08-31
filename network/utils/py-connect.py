#!/usr/bin/python2
#
################################

import httplib
import ssl

# This restores the same behavior as before.
context = ssl._create_unverified_context()

h2 = httplib.HTTPSConnection('172.17.0.1',context=context)
h2.request("GET","/")
r1 = h2.getresponse()

if r1.status == 200 :
    print ("Super ca marche ")
else :
    print ("Nope, bonne chance :D")

