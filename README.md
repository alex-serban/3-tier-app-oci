
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
* [CGI Application (advanced)](#developing-a-cgi-application)  
* [Scalling out](#scalling-out-using-oci-custom-images)  



#### Creating a compartment:  
A compartment is a logical container which helps organize and manage access control to OCI resources (Compute, Storage, Network, Database etc). By default, any OCI tenancy has a default root compartment, named after the tenancy itself. Best practice is to create a compartment to separate usage among projects, departments, scope etc. For this tutorial I've created a container to host all resources for implementing my 3-tier architecture. 

[![Compartment](https://img.youtube.com/vi/XRPuwaaL2W8/0.jpg)](https://www.youtube.com/watch?v=XRPuwaaL2W8)

[^ back](#steps--components-to-create)

#### Creating a Virtual Cloud Network (VCN):  
When working with OCI, setting up a VCN is one of the first steps you'll have to undertake. The VCN is a virtual, private network that you set up in Oracle data centers. It closely resembles a traditional network, with firewall rules and specific types of communication gateways that you can choose to use. A VCN resides in a single Oracle Cloud Infrastructure region and covers a single, contiguous IPv4 CIDR block of your choice. You can read more about what a CIDR is [here][cidr], but for this tutorial is enough to understand that a CIDR is a method for allocating IP addresses. 

[![VCN](https://img.youtube.com/vi/V0G8X_Dbpz0/0.jpg)](https://www.youtube.com/watch?v=V0G8X_Dbpz0)

[^ back](#steps--components-to-create)
   
#### Creating a Public Subnet:  
Subnets are subdivisions you define in a VCN. They contain virtual network interface cards (VNICs), which attach to instances. Each subnet consists of a contiguous range of IP addresses that must not overlap with other subnets in the VCN.

For implementing the 3-tier architecture I will need an *Internet Gateway* which acts as a virtual router that permits direct internet access. All subneta require a *Route Table* for routing traffic to destinations outside the VCN and *Security Rules* that consist of the ingress (inbound) and egress (outbound) rules that specify the types of traffic (protocol and port) allowed in and out of the instances.

[![Public Subnet](https://img.youtube.com/vi/trp2b7mNJzI/0.jpg)](https://www.youtube.com/watch?v=trp2b7mNJzI)

[^ back](#steps--components-to-create)

#### Creating a Bastion Host:  
A bastion host is a special-purpose computer on a network specifically designed and configured to withstand attacks. In the architecture I'm proposing, the *Bastion Host* acts as a proxy through which I can access the *Application Nodes* which will sit in the Private Subnet. I've chosen for the *Bastion Host* to run Oracle Linux. To access it, I need first to generate a pair of SSH keys using [PuTTYgen][puttygen]. To connect to the instance I used [MobaXterm][moba]. The default user for login is `opc` and you can use the `sudo` command to run administrative tasks.

More on accessing an Oracle Linux Instance [here][accessol].  

[![Bastion Host](https://img.youtube.com/vi/AB6BWhG1Djs/0.jpg)](https://www.youtube.com/watch?v=AB6BWhG1Djs)

[^ back](#steps--components-to-create)

#### Creating a Private Subnet: 
Creating the private subnet is similar to creating the public subnet, difference is that I will restrict the VNICs to have public IPs allocated to them. Besides the mandatory *Route Table* and *Security List* I will need a *NAT Gateway* and *Service Gateway*.

The *NAT Gateway* is a virtual router, similar to the *Internet Gateway*, but available only for resources without public IP addresses that need to initiate connections to the internet (example: for software updates) but need to be protected from inbound connections from the internet.

A *Service Gateway* is yet another virtual router which provides a path for private network traffic between the VCN and the [Oracle Services Network][osn] (examples: Oracle Cloud Infrastructure Object Storage and Autonomous Database). For example, DB Systems in a private subnet in your VCN can back up data to Object Storage without needing public IP addresses or access to the internet.

[![Private Subnet](https://img.youtube.com/vi/G8VGoByCgiw/0.jpg)](https://www.youtube.com/watch?v=G8VGoByCgiw)

[^ back](#steps--components-to-create)

#### Creating an Application Node:  
The process of creating the *Application Node* is similar the *Bastion Host*, but placing it in the private subnet will inhibit a public IP to be assigned, so connection will only be possible through the *Bastion Host*. 

[![Application Node](https://img.youtube.com/vi/PV5ueOK1KXw/0.jpg)](https://www.youtube.com/watch?v=PV5ueOK1KXw)

[^ back](#steps--components-to-create)

#### Creating the Autonomous Database:
An autonomous database is a cloud database that uses machine learning to eliminate the human labor associated with database tuning, security, backups, updates, and other routine management tasks traditionally performed by database administrators (DBAs).

For authenticating access to the Autonomous Database an *Oracle Wallet* is used. To make the *Oracle Wallet* accessible I will upload it to an Object Storage which will allow for private download through the *Service Gateway* onto the *Application Node*.

[![Autonomous Database](https://img.youtube.com/vi/sIuCh63tLgo/0.jpg)](https://www.youtube.com/watch?v=sIuCh63tLgo)

[^ back](#steps--components-to-create)

#### Creating the Load Balancer:
The Load Balancing service provides automated traffic distribution from one entry point to multiple servers reachable from your virtual cloud network (VCN). The service offers a load balancer with your choice of a public or private IP address. In my 3-tier architecture, the *Load Balancer* will be deployed in the public subnet, to allow for connections from outside the VCN, but will route HTTP traffic to the *Application Node* which resides in the private subnet. 

For demonstrating this capability I'll create an [Apache HTTP Server][apache] on the *Application Node*.
Also, it's important to know that besides the *Security List* there is a local firewall running on the virtual machine (VM) running the *Application Node*. The `firewall-cmd` command will punch a hole in the local firewall running on the VM.
Here are the commands used to install and configure the HTTP server:

```bash
# installing Apache HTTP Server
sudo yum install -y httpd

# starting and enabling HTTP Server to start when the VM boots
sudo systemctl enable httpd
sudo systemctl start httpd

# opening port 80 (http) on the local VM firewall
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

# creating the index.html
cd /var/www/html/
echo "<p>This is Application Node - 1</p>" > index.html
```

[![Load Balancer](https://img.youtube.com/vi/djNfEnSBpiA/0.jpg)](https://www.youtube.com/watch?v=djNfEnSBpiA)

[^ back](#steps--components-to-create)

#### Developing a CGI application:  
The purpose of this step is to create a *content-generating program* which connects to the *Autonomous Database* and displays the content of a database table in HTML served through the browser using the *Apache HTTP Server*. 

The *Common Gateway Interface* or *CGI* is an interface specification for web servers to execute programs that execute like console applications running on a server that generates web pages dynamically. Enabling CGI support for my HTTP server requires editing the `httpd.conf` from file located in `/etc/httpd/conf`. It's enough to follow the video tutorial to enable this, more details for enabling CGI on Apache can be found [here][cgi].

Next step is to disable *SELinux*, which will by default forbids CGI scripts from running on the Application Node. *SELinux* or *Security-Enhanced Linux* is a Linux kernel module that provides a mechanism for supporting access control security policies. Disabling SELinux temporarily is done using the `sudo setenforce 0` command, to make this persistent after a reboot parameter `SELINUX` in the `/etc/selinux/config` needs to be changed to:
```bash
SELINUX=disabled
```

Connecting to the Autonomous Database is achieved through the *Oracle Instant Client*. The [Oracle Instant Client][instantclient] enables applications to connect to an Oracle Database. The Instant Client libraries provide the necessary network connectivity, as well as basic and high end data features, to make full use of Oracle Database.

Here are the commands used for installation:  
```bash
sudo yum install -y oracle-instantclient18.3-basic.x86_64 
sudo yum install -y oracle-instantclient18.3-devel.x86_64 
sudo yum install -y oracle-instantclient18.3-sqlplus.x86_64
sudo yum install -y oracle-instantclient18.3-tools.x86_64
```
or in one line
```bash
sudo yum install -y oracle-instantclient18.3*
```

Resolving the path dependencies (`sudo su` command needs to be executed to run the following as *root*):
```bash
export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH
echo "export LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib:$LD_LIBRARY_PATH" >>/etc/bashrc
echo "/usr/lib/oracle/18.3/client64/lib/" > /etc/ld.so.conf.d/oracle.conf
ldconfig
```
To authenticate to the *Autonomous Database* the *Oracle Wallet* needs to be downloaded from the Object Storage and unzipped in the `/usr/lib/oracle/18.3/client64/lib/network/admin/` directory. 

Final step is to write the application. In the `/var/www/html` director the `index.html` file needs to be replaced with `index.sh` containing:

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
also available for download [here](/index.sh).

[![CGI Application](https://img.youtube.com/vi/yYNX3xv69MQ/0.jpg)](https://www.youtube.com/watch?v=yYNX3xv69MQ)

[^ back](#steps--components-to-create)

#### Scaling out using OCI Custom Images:
The purpose of this step is to scale out (horizontally scale) my CGI architecture by adding an second *Application Node* using the *OCI Custom Images* feature.

Custom Images enables the capturing of snapshots from a Virtual Machine and using them to launch other instances running the same customizations, configuration, and software installed when the image was created. More on this is available [here][customimg]. 

[![OCI Custom Images](https://img.youtube.com/vi/DtawSf085-s/0.jpg)](https://www.youtube.com/watch?v=DtawSf085-s)

[^ back](#steps--components-to-create)

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
[apache]: https://httpd.apache.org/
[cgi]: https://httpd.apache.org/docs/2.4/howto/cgi.html
[instantclient]: https://www.oracle.com/database/technologies/instant-client.html
[customimg]: https://docs.cloud.oracle.com/iaas/Content/Compute/Tasks/managingcustomimages.htm
