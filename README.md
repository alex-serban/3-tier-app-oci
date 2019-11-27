
![images](/images/banner.png)

# Implementing a 3-tier application
## Deploy a secure 3-tier application on Oracle Cloud Infrastructure (OCI) using Free Tier resources
---

This is a tutorial that shows how to deploy a very simple 3-tier architecture on the [Oracle Cloud Infrastructure (OCI)][oci]. 
The purpose of the tutorial is to familiarize the viewer with the OCI Web Console as well as introduce basic infrastructure concepts for users making the first steps using cloud services, providing good practice for those who are pursuing the [OCI Architect Associate certification][cert]. 

### Pre-requisities:
   1. Register for an **OCI Trial & Free Tier account** [here][free].
   2. Download a **SSH key generator tool** available on your workstation. For this demo I've used [PuTTYgen][puttygen]. 
   3. Install a **SSH/SCP terminal client**. [MobaXterm][moba] was my choice for the demo. 

```bash
#cloud-config
write_files:
    - path: /etc/environment
      permissions: 0777
      content: |
        LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH
runcmd:
 - mkdir idcs-sample-app
 - cd idcs-sample-app/
 - [ wget, --output-document=idcsapp2.zip, "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/YCbO7RYzKscSU5uOemIGon9SOiz948NMzzO_3BV2sN4/n/frvly4ywct1p/b/security/o/idcsapp2.zip"]
 - unzip idcsapp2.zip
 - touch /idcs-sample-app/python/.env
 - echo "CONSTRING=admin/oracleORACLE123@security_high" >> /idcs-sample-app/python/.env
 - systemctl stop firewalld
 # - bash firewall.sh
 - sudo yum install -y python-pip
 - sudo python -m pip install "django<2"
 - pip install -r requirements.txt
 - pip install cx_Oracle
 - yum install -y oracle-instantclient18.3-basic.x86_64 
 - yum install -y oracle-instantclient18.3-devel.x86_64 
 - yum install -y oracle-instantclient18.3-sqlplus.x86_64
 - yum install -y oracle-instantclient18.3-tools.x86_64
 - [ wget,  --output-document=wallet.zip, "https://objectstorage.eu-frankfurt-1.oraclecloud.com/p/bEIRP-U7NiU1KgCWWPvm8JoE-sRnTZ1gLvnIAccYxCo/n/frvly4ywct1p/b/security/o/Wallet_security_3.zip", -P, /usr/lib/oracle/18.3/client64/lib/network/admin]
 - [ unzip, /idcs-sample-app/wallet.zip, -d, /usr/lib/oracle/18.3/client64/lib/network/admin/]
 - echo "export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH" >>/home/opc/.bash_profile
 - echo "cd /idcs-sample-app" >> /home/opc/.bash_profile
 - export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH
 - echo "export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH" >>/etc/bashrc
 - source /etc/bashrc
 - nohup python /idcs-sample-app/manage.py runserver 0.0.0.0:8080 &
```

```bash
#!/bin/sh

echo Content-type: text/html
echo

echo "<html>"
echo "<head><title>Application</title></head>"
echo "<body>"

echo "<p>This application is running on <b><u>"`hostname`"</u></b>!</p>"

sqlplus64 -s ADMIN/ORACLEoracle_123@AUTDB_high <<!
        SET MARKUP HTML ON
        SET FEEDBACK OFF
        SELECT PROD_NAME, PROD_DESC
        FROM SH.PRODUCTS
        ORDER BY PROD_NAME;
        QUIT
!

echo "</body></html>"
```

[![IMAGE ALT TEXT HERE](http://img.youtube.com/vi/Czqin0UEYTQ/0.jpg)](https://www.youtube.com/watch?v=mP4qDgBTRDo&list=PLVQmt4FnJlnlJUimvlGN6iVXh1SFcD2ut&index=1)

Interested to join [Oracle](https://www.linkedin.com/jobs/view/1566385417)?

[cert]: https://www.oracle.com/cloud/iaas/training/certification.html
[oci]: https://www.oracle.com/cloud/
[free]: https://www.oracle.com/cloud/free/
[puttygen]: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
[moba]: https://mobaxterm.mobatek.net/download-home-edition.html
