
>>> h2 = httplib.HTTPConnection('172.17.0.1')
>>> h2.request("GET","/")
>>> r1 = h2.getresponse()
>>> print r1.status, r1.reason
200 OK
>>> h2 = httplib.HTTPConnection('172.17.0.1')
>>> h2.request("GET","/hejhdke")
>>> r1 = h2.getresponse()
>>> print r1.status, r1.reason
404 Not Found

