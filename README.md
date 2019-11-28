
![images](/images/banner.png)

# Implementing a 3-tier application
## Deploy a secure 3-tier application on Oracle Cloud Infrastructure (OCI) using Free Tier resources
---  
This is a tutorial that shows how to deploy a very simple 3-tier architecture on the [Oracle Cloud Infrastructure (OCI)][oci]. 
The purpose of the tutorial is to familiarize the viewer with the OCI Web Console as well as introduce basic infrastructure concepts for users making the first steps using cloud services, providing good practice for those who are pursuing the [OCI Architect Associate certification][cert]. 

### Pre-requisities:
   1. Register for an **OCI Trial & Free Tier account** [here][free].
   2. Download a **SSH key generator tool** and install it on your workstation. For this demo I've used [PuTTYgen][puttygen]. 
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

[![Compartment](https://img.youtube.com/vi/XRPuwaaL2W8/0.jpg)](https://www.youtube.com/watch?v=XRPuwaaL2W8)

#### Creating a Virtual Cloud Network (VCN):  
When working with OCI, setting up a VCN is one of the first steps you'll have to undertake. The VCN is a virtual, private network that you set up in Oracle data centers. It closely resembles a traditional network, with firewall rules and specific types of communication gateways that you can choose to use. A VCN resides in a single Oracle Cloud Infrastructure region and covers a single, contiguous IPv4 CIDR block of your choice. You can read more about what a CIDR is [here][cidr], but for the purpose of this tutorial is enough to understand that a CIDR is a method for allocating IP addresses. 

[![VCN](https://img.youtube.com/vi/V0G8X_Dbpz0/0.jpg)](https://www.youtube.com/watch?v=V0G8X_Dbpz0)
   
#### Creating a Public Subnet:  
Subnets are subdivisions you define in a VCN. They contain virtual network interface cards (VNICs), which attach to instances. Each subnet consists of a contiguous range of IP addresses that must not overlap with other subnets in the VCN.

For implementing the 3-tier architecture I will need an *Internet Gateway* which acts as a virtual router that permits direct internet access. All subnet require a *Route Table* for routing traffic to destinations outside the VCN and *Security Rules* that consist of the ingress (inbound) and egress (outbound) rules that specify the types of traffic (protocol and port) allowed in and out of the instances.

[![Public Subnet](https://img.youtube.com/vi/trp2b7mNJzI/0.jpg)](https://www.youtube.com/watch?v=trp2b7mNJzI)

#### Creating a Bastion Host:  
A bastion host is a special-purpose computer on a network specifically designed and configured to withstand attacks. In the architecture I'm proposing, the Bastion Host acts as a proxy through which I can access the Application Nodes which will sit in the Private Subnet. I've chosen for the Bastion Host to run Oracle Linux. To access it, I need first to generate a pair of SSH keys using [PuTTYgen][puttygen]. To connect to the instance I used [MobaXterm][moba]. The default user for login is `opc` and you can use the `sudo` command to run administrative tasks.

More on accessing an Oracle Linux Instance [here][accessol].  

[![Bastion Host](https://img.youtube.com/vi/AB6BWhG1Djs/0.jpg)](https://www.youtube.com/watch?v=AB6BWhG1Djs)

#### Creating a Private Subnet: 
Creating the private subnet is similar to creating the public subnet, difference is that I will restrict the VNICs to have public IPs allocated to them. Besides the mandatory *Route Table* and *Security List* I will need a *NAT Gateway* and *Service Gateway*.

The *NAT Gateway* is a virtual router, similar to the *Internet Gateway*, available only for resources without public IP addresses that need to initiate connections to the internet (example: for software updates) but need to be protected from inbound connections from the internet.

A *Service Gateway* is yet another virtual router which provides a path for private network traffic between the VCN and the [Oracle Services Network][osn] (examples: Oracle Cloud Infrastructure Object Storage and Autonomous Database). For example, DB Systems in a private subnet in your VCN can back up data to Object Storage without needing public IP addresses or access to the internet.

[![Private Subnet](https://img.youtube.com/vi/G8VGoByCgiw/0.jpg)](https://www.youtube.com/watch?v=G8VGoByCgiw)

#### Creating an Application Node:  

[![Application Node](https://img.youtube.com/vi/PV5ueOK1KXw/0.jpg)](https://www.youtube.com/watch?v=PV5ueOK1KXw)

#### Creating the Autonomous Database:

[![Autonomous Database](https://img.youtube.com/vi/sIuCh63tLgo/0.jpg)](https://www.youtube.com/watch?v=sIuCh63tLgo)

#### Creating the Load Balancer:

[![Load Balancer](https://img.youtube.com/vi/djNfEnSBpiA/0.jpg)](https://www.youtube.com/watch?v=djNfEnSBpiA)

#### Developing a CGI application:  

[![CGI Application](https://img.youtube.com/vi/yYNX3xv69MQ/0.jpg)](https://www.youtube.com/watch?v=yYNX3xv69MQ)

#### Scalling out using OCI Custom Images:

[![OCI Custom Images](https://img.youtube.com/vi/DtawSf085-s/0.jpg)](https://www.youtube.com/watch?v=DtawSf085-s)

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

You can consume the entire tutorial on this [YouTube playlist][playlist].

Interested to join [Oracle][jd]?

[cert]: https://www.oracle.com/cloud/iaas/training/certification.html
[oci]: https://www.oracle.com/cloud/
[free]: https://www.oracle.com/cloud/free/
[puttygen]: https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
[moba]: https://mobaxterm.mobatek.net/download-home-edition.html
[playlist]: https://www.youtube.com/watch?v=Czqin0UEYTQ&list=PLVQmt4FnJlnlJUimvlGN6iVXh1SFcD2ut&index=1
[jd]: https://www.linkedin.com/jobs/view/1566385417
[cidr]: https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
[accessol]: https://docs.cloud.oracle.com/iaas/Content/GSG/Tasks/testingconnection.htm
[osn]: https://www.oracle.com/cloud/networking/service-gateway.html
