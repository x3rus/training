
$ cat formation.pem 
-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAnnwa38CRjUb6fAdVgb1V2s9t3fZL5Cg+lg5g1cO1AtKZvWO0BuB1N6IlK68b
lp4iW6C0YrbsxkyfKKdaipxFD4kLuQ3e+Tl6pC0Wtzo1/E8/qFlk4Phet/mtbhjtI3j544ERuzau
sU0/j5UUdqMTbN7zLFmgGRyIbOTP4AqXr9xxLL5kPvtNUi+BWgm/y8T1Bcvx9zhi82zKiRdSwluN
6a7zXeR15OMKJCptGnFE3PVNhrF4mtHZ3m+ikAghuVtCeaFExU3wH0Ec9ISMRIFkLmn/2PtiyBy0
sYqY6UWslMn7k2fnw2I/6fTSWjevxiADX4J82P594E5i8UHY73qXsQIDAQABAoIBABylhh4HqseE
....
...
....
-----END RSA PRIVATE KEY-----

$ ssh -i formation.pem ec2-user@52.15.95.51
The authenticity of host '52.15.95.51 (52.15.95.51)' can t be established.
ECDSA key fingerprint is d3:17:4a:2e:d2:8e:07:d8:8a:6d:1c:50:ac:8e:da:66.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.15.95.51' (ECDSA) to the list of known hosts.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0664 for 'formation.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
bad permissions: ignore key: formation.pem
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).


$ ls -l formation.pem 
-rw-rw-r-- 1 bthomas bthomas 1692 Apr  7 12:28 formation.pem

$ chmod g=,o= formation.pem

$ ls -l formation.pem                                                                                                                                         
-rw------- 1 bthomas bthomas 1692 Apr  7 12:28 formation.pem

$ ssh -i formation.pem ec2-user@52.15.95.51
[ec2-user@ip-172-31-23-65 ~]$

[ec2-user@ip-172-31-23-65 ~]$ cat /etc/redhat-release 
Red Hat Enterprise Linux Server release 7.3 (Maipo)

[ec2-user@ip-172-31-23-65 ~]$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9001 qdisc pfifo_fast state UP qlen 1000
    link/ether 06:1b:66:23:82:df brd ff:ff:ff:ff:ff:ff
    inet 172.31.23.65/20 brd 172.31.31.255 scope global dynamic eth0
       valid_lft 3316sec preferred_lft 3316sec
    inet6 fe80::41b:66ff:fe23:82df/64 scope link 
       valid_lft forever preferred_lft forever


[ec2-user@ip-172-31-23-65 ~]$ sudo yum groupinstall 'Development Tools'

[ec2-user@ip-172-31-23-65 ~]$ sudo yum install wget

[ec2-user@ip-172-31-23-65 ~]$ wget https://cdn.kernel.org/pub/linux/kernel/v4.x/testing/linux-4.11-rc5.tar.xz

Visualisation boot + yum install + tar -Jxvf  : demo-aws-cwatch-cpu-usage-install-untar-t2-micro.png


* Création d une configuration par default :

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ make defconfig
  HOSTCC  scripts/basic/fixdep
  HOSTCC  scripts/kconfig/conf.o
  SHIPPED scripts/kconfig/zconf.tab.c
  SHIPPED scripts/kconfig/zconf.lex.c
  SHIPPED scripts/kconfig/zconf.hash.c
  HOSTCC  scripts/kconfig/zconf.tab.o
  HOSTLD  scripts/kconfig/conf
*** Default configuration is based on 'x86_64_defconfig'
#
# configuration written to .config
#


[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ cp /boot/config-3.10.0-514.el7.x86_64 .config


[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ date
Fri Apr  7 12:46:27 EDT 2017

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$  make oldconfig

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ date
Fri Apr  7 12:48:06 EDT 2017

demo-aws-cwatch-avant-build-kernel-t2-micro.png

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$  make 
/bin/sh: bc: command not found
make[1]: *** [include/generated/timeconst.h] Error 1
make: *** [prepare0] Error 2
[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ sudo yum install bc

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$ sudo yum install openssl-devel

[ec2-user@ip-172-31-23-65 linux-4.11-rc5]$  make 

demo-aws-cwatch-pendant-1-build-kernel-t2-micro.png

demo-aws-cwatch-pendant-3-build-kernel-sans-cpuUsage-t2-micro.png

OUTPUT : 
  LD [M]  drivers/media/common/siano/smsdvb.o
  LD      drivers/media/common/v4l2-tpg/built-in.o
  LD      drivers/media/common/built-in.o
  CC [M]  drivers/media/common/cx2341x.o


$ date
Fri Apr  7 13:17:51 EDT 2017

Probablement des modules moins gourmant ... délais entre chaque....
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf.o
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf-phy.o
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf-i2c.o
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf-gpio.o
  LD [M]  drivers/media/usb/dvb-usb-v2/dvb-usb-mxl111sf.o
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf-demod.o
  CC [M]  drivers/media/usb/dvb-usb-v2/mxl111sf-tuner.o
  CC [M]  drivers/media/usb/dvb-usb-v2/rtl28xxu.o
  LD [M]  drivers/media/usb/dvb-usb-v2/dvb-usb-rtl28xxu.o
  LD      drivers/media/usb/em28xx/built-in.o


demo-aws-cwatch-pendant-5-build-kernel-sans-cpuUsage-t2-micro.png

top - 13:35:56 up  1:06,  2 users,  load average: 3.53, 2.88, 2.34
Tasks:  91 total,   5 running,  86 sleeping,   0 stopped,   0 zombie
%Cpu(s):  9.6 us,  1.6 sy,  0.6 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si, 88.1 st
KiB Mem :  1014976 total,   114152 free,   130304 used,   770520 buff/cache
KiB Swap:        0 total,        0 free,        0 used.   689944 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND                                                                                             
30837 ec2-user  20   0  168428  40428   8564 R 98.0  4.0   0:02.98 cc1                                                                                                
    1 root      20   0  128092   5000   2244 S  0.0  0.5   0:02.39 systemd 

demo-aws-cwatch-pendant-7-build-kernel-t2-micro.png

top - 13:46:16 up  1:16,  2 users,  load average: 3.12, 3.17, 2.77
Tasks:  90 total,   4 running,  86 sleeping,   0 stopped,   0 zombie
%Cpu(s):  9.0 us,  2.6 sy,  0.3 ni,  0.0 id,  0.0 wa,  0.0 hi,  0.0 si, 88.1 st
KiB Mem :  1014976 total,   116736 free,   131820 used,   766420 buff/cache
KiB Swap:        0 total,        0 free,        0 used.   685504 avail Mem 

  PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND                                                                                            
11398 ec2-user  20   0  165536  33588   4528 R 63.0  3.3   0:01.91 cc1                                                                                                
11106 ec2-user  20   0  108956   1788    812 S  1.3  0.2   0:00.11 make      



-rw-rw-r-- 1 bthomas bthomas  22516 Apr  7 12:18 demo-aws-home.png
-rw-rw-r-- 1 bthomas bthomas 166767 Apr  7 12:19 demo-aws-home-EC2-with-region.png
-rw-rw-r-- 1 bthomas bthomas 181990 Apr  7 12:21 demo-aws-lunch-ec2-step1-AMI.png
-rw-rw-r-- 1 bthomas bthomas 148223 Apr  7 12:22 demo-aws-lunch-ec2-step2-select-type-instance.png
-rw-rw-r-- 1 bthomas bthomas 117411 Apr  7 12:23 demo-aws-lunch-ec2-step3-config-instance.png
-rw-rw-r-- 1 bthomas bthomas  68594 Apr  7 12:24 demo-aws-lunch-ec2-step4-add-storage.png
-rw-rw-r-- 1 bthomas bthomas  55754 Apr  7 12:26 demo-aws-lunch-ec2-step5-tags.png
-rw-rw-r-- 1 bthomas bthomas  77100 Apr  7 12:26 demo-aws-lunch-ec2-step6-network-fw.png
-rw-rw-r-- 1 bthomas bthomas 113353 Apr  7 12:27 demo-aws-lunch-ec2-step7-review.png
-rw-rw-r-- 1 bthomas bthomas  58840 Apr  7 12:28 demo-aws-lunch-ec2-step8-key-ssh.png
-rw-rw-r-- 1 bthomas bthomas  29750 Apr  7 12:28 demo-aws-lunch-ec2-step8-1-key-download.png
-rw-rw-r-- 1 bthomas bthomas  53122 Apr  7 12:29 demo-aws-lunch-ec2-step9-view-instance.png
-rw-rw-r-- 1 bthomas bthomas  28595 Apr  7 12:40 demo-aws-cwatch-cpu-credit-balance-START-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  28441 Apr  7 12:40 demo-aws-cwatch-cpu-credit-usage-START-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  29722 Apr  7 12:43 demo-aws-cwatch-cpu-usage-install-untar-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  32386 Apr  7 12:43 demo-aws-cwatch-cpu-credit-usage-install-untar-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  29156 Apr  7 12:44 demo-aws-cwatch-cpu-balance-usage-install-untar-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  20682 Apr  7 12:49 demo-aws-cwatch-avant-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  22197 Apr  7 12:54 demo-aws-cwatch-pendant-1-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  20708 Apr  7 12:59 demo-aws-cwatch-pendant-2-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  18132 Apr  7 12:59 demo-aws-cwatch-pendant-2-build-kernel-sans-cpuUsage-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  20734 Apr  7 13:14 demo-aws-cwatch-pendant-3-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  20614 Apr  7 13:14 demo-aws-cwatch-pendant-3-build-kernel-sans-cpuUsage-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  23458 Apr  7 13:23 demo-aws-cwatch-pendant-4-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  20651 Apr  7 13:24 demo-aws-cwatch-pendant-4-build-kernel-sans-cpuUsage-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  23845 Apr  7 13:29 demo-aws-cwatch-pendant-5-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  21135 Apr  7 13:29 demo-aws-cwatch-pendant-5-build-kernel-sans-cpuUsage-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas 189774 Apr  7 13:38 demo-aws-cwatch-pendant-6-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  23830 Apr  7 13:45 demo-aws-cwatch-pendant-7-build-kernel-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  40496 Apr  7 13:47 demo-aws-cwatch-credit-balance-final-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  39185 Apr  7 13:48 demo-aws-cwatch-credit-usage-final-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  38774 Apr  7 13:48 demo-aws-cwatch-cpu-usage-final-t2-micro.png
-rw-rw-r-- 1 bthomas bthomas  29024 Apr  7 13:49 demo-aws-terminate-ec2.png
