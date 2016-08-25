#!/usr/bin/python2
#
################################

import httplib
h2 = httplib.HTTPConnection('www.x3rus.com')
h2.request("GET","/kkjhk")
r1 = h2.getresponse()
print (r1.status, r1.reason)
