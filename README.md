
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

### Architecture:  
![images](/images/arch.png)

### Steps & components to create:  
* [Compartment](#creating-a-compartment)  
* [Virtual Cloud Network](#creating-a-virtual-cloud-network-vcn)  
* [Public Subnet](#creating-a-public-subnet)  
* [Bastion Host](#creating-a-bastion-host)  
* [Private Subnet](#creating-a-private-subnet)  
* [Application Node](#creating-an-application-node)  
* [Autonomous Database](#creating-the-autonomous-database)  
* [Load Balancer](#creating-the-load-balancer)  
* [CGI Application](#developing-a-cgi-application)  
* [Scalling out](#scalling-out-using-oci-custom-images)  



#### Creating a compartment:  
A compartment is a logical container which helps organize and manage access control to OCI resources (Compute, Storage, Network, Database etc). By default, any OCI tenancy has a default root compartment, named after the tenancy itself. Best practice is to create a compartment to separate usage among projects, departments, scope etc. For the purpose of this tutorial I've created a container to host all resources for implementing my 3-tier architecture.

<a href="https://www.youtube.com/watch?v=XRPuwaaL2W8"><img src="http://img.youtube.com/vi/XRPuwaaL2W8/0.jpg" width="336" height="188"
   border="10" /></a>


#### Creating a Virtual Cloud Network (VCN):  

<a href="https://www.youtube.com/watch?v=V0G8X_Dbpz0"><img src="http://img.youtube.com/vi/V0G8X_Dbpz0/0.jpg" width="336" height="188"/></a>
   
#### Creating a Public Subnet:  
#### Creating a Bastion Host:  
#### Creating a Private Subnet:  
#### Creating an Application Node:  
#### Creating the Autonomous Database:
#### Creating the Load Balancer:
#### Developing a CGI application:  
#### Scalling out using OCI Custom Images:


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

<a href="http://www.youtube.com/watch?v=mP4qDgBTRDo><img src="http://img.youtube.com/vi/Czqin0UEYTQ/0.jpg" 
alt="imajine" width="240" height="180" border="10" /></a>

You can consume the entire tutorial on this [YouTube playlist][playlist].

Interested to join [Oracle][jd]?

[cert]: https://www.oracle.com/cloud/iaas/training/certification.html
[oci]: https://www.oracle.com/cloud/
[free]: https://www.oracle.com/cloud/free/
[puttygen]: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
[moba]: https://mobaxterm.mobatek.net/download-home-edition.html
[playlist]: https://www.youtube.com/watch?v=Czqin0UEYTQ&list=PLVQmt4FnJlnlJUimvlGN6iVXh1SFcD2ut&index=1
[jd]: https://www.linkedin.com/jobs/view/1566385417
