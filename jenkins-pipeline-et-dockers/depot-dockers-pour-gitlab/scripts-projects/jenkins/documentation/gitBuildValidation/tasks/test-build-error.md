# Description

Ajuster pour que Jenkins retourne une erreur quand le build passe pas :

```
17:44:36        b' ---> 8f55c8b5918d\n'
17:44:36        b'Step 9/10 : COPY toto-bad-file /\n'
17:44:36        b"Service 'x3-webdav' failed to build: lstat toto-bad-file: no such file or directory\n"
17:44:36        b"Makefile:30: recipe for target 'build-and-test' failed\n"
17:44:36        b'make: *** [build-and-test] Error 1\n'
17:44:36        b"make: Leaving directory '/var/jenkins_home/workspace/test1/x3-webdav'\n"
17:44:36        ##################################################
17:44:36 ==================================================
17:44:36 ==========================================
17:44:36 Finished: SUCCESS
```

# Opération 

Suite à l'analyse ça fonctionne bien il y avait une erreur il y avait un echo après l'appel de mon script

```bash
python3 scripts-master/jenkins/gitBuildValidation.py  -v -D x3-webdav

echo "=========================================="

```

Suite à la suppression du echo c bon , on va poursuivre les testes de retour d'erreur rendu la !

* Changement du Dockerfile pour empécher l'upload de fichier résultat la build sera ok mais la validation applicative aura un problème

```
RUN mkdir /usr/local/apache2/uploads /usr/local/apache2/var \
    && chown root /usr/local/apache2/uploads /usr/local/apache2/var
    #    && chown daemon /usr/local/apache2/uploads /usr/local/apache2/var

```

* Jenkins fini avec une erreur c bon !!

```
08:42:03        b'======================================================================\n'
08:42:03        b'ERROR: test_03_ListDirectoy (__main__.TestWebDavContainer)\n'
08:42:03        b'----------------------------------------------------------------------\n'
08:42:03        b'Traceback (most recent call last):\n'
08:42:03        b'  File "/x3-apps/webdav-validation.py", line 61, in test_03_ListDirectoy\n'
08:42:03        b'    self.client.list("uploads/intergrationTesting")\n'
08:42:03        b'  File "/usr/local/lib/python3.5/site-packages/webdav/client.py", line 201, in list\n'
08:42:03        b'    raise RemoteResourceNotFound(directory_urn.path())\n'
08:42:03        b'webdav.exceptions.RemoteResourceNotFound: Remote resource: /uploads/intergrationTesting/ not found\n'
08:42:03        b'\n'
08:42:03        b'======================================================================\n'
08:42:03        b'ERROR: test_04_DownloadFile (__main__.TestWebDavContainer)\n'
08:42:03        b'----------------------------------------------------------------------\n'
08:42:03        b'Traceback (most recent call last):\n'
08:42:03        b'  File "/x3-apps/webdav-validation.py", line 66, in test_04_DownloadFile\n'
08:42:03        b'    local_path="/tmp/tux.png")\n'
08:42:03        b'  File "/usr/local/lib/python3.5/site-packages/webdav/client.py", line 418, in download_sync\n'
08:42:03        b'    self.download(local_path=local_path, remote_path=remote_path)\n'
08:42:03        b'  File "/usr/local/lib/python3.5/site-packages/webdav/client.py", line 358, in download\n'
08:42:03        b'    if self.is_dir(urn.path()):\n'
08:42:03        b'  File "/usr/local/lib/python3.5/site-packages/webdav/client.py", line 845, in is_dir\n'
08:42:03        b'    raise RemoteResourceNotFound(remote_path)\n'
08:42:03        b'webdav.exceptions.RemoteResourceNotFound: Remote resource: /uploads/intergrationTesting/tux.png not found\n'
08:42:03        b'\n'
08:42:03        b'----------------------------------------------------------------------\n'
08:42:03        b'Ran 9 tests in 0.097s\n'
08:42:03        b'\n'
08:42:03        b'FAILED (errors=3)\n'
08:42:03        b"Makefile:30: recipe for target 'build-and-test' failed\n"
08:42:03        b'make: *** [build-and-test] Error 1\n'
08:42:03        b"make: Leaving directory '/var/jenkins_home/workspace/test1/x3-webdav'\n"
08:42:03        ##################################################
08:42:03 ==================================================
08:42:03 Build step 'Execute shell' marked build as failure
08:42:03 Finished: FAILURE
```


