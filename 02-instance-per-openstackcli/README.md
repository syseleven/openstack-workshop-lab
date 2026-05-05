# Creating an instance via Openstack client

## Overview

With this guide you can create a single instance via the Openstack client.

## Goal

* Create a single instance via Openstack client

## Preparation

* You need your Openstack credentials
  * Username
  * Password
* basic knowledge of using a Linux terminal and SSH
* pre-installed jumphost infrastructure provided by SysEleven

---

### Start

* Log into the jumphost

`ssh syseleven@<Jumphost-IP> -A -i /path/to/private-key`

* Source your openstack config

`source openstack.sh`

---

### Collect information about existing infrastructure

To integrate a new instance into the existing network topology we first need an overview
over the current components.

Obtain information with the following commands.

* print a list of available **Flavors**

`openstack flavor list`

* display existing operating system **Images**

`openstack image list`

* look for the **Network** the new instance should be placed in

`openstack network list`

* print the **Security Groups**

`openstack security group list`

* look for the existing SSH **Key Pairs**

`openstack keypair list`

---

### Import SSH Key for Service Account

Because we are using a Service Account who does not know of our SSH keypair yet,
we need to import for this account as well using th following command:

```bash
openstack keypair create workshop --public-key "/path/to/key"
```

---

### Creating a new instance

Now we create a new instance directly with Openstack client commands.
Enter the previously collected information into the following lines.

```bash
openstack server create \
  --flavor "<REPLACE>" \
  --image "<REPLACE>" \
  --network "<REPLACE>" \
  --security-group "<REPLACE>" \
  --key-name "<REPLACE>" \
  server-cli
```

Example:

* **This is just an example!** Below entries, IDs and names will be different on your machine!  

```bash
openstack server create \
  --flavor "SCS-1V-2-50n" \
  --image "Ubuntu Resolute 26.04" \
  --network "net-workshop-01" \
  --security-group "secgroup-workshop-01" \
  --key-name "workshop" \
  server-cli
```

---

### Verify the setup

Now we verify the current state of the instance

* Display all instances

`openstack server list`

* Display instance details

`openstack server show server-cli`

---

#### What did you notice?

* e.g. the instance has no public IP address

---

### Login

* Use the jumphost to log in to the instance:

`ssh ubuntu@<internal-IP>`

* we need to use the username "ubuntu", because the cloud-image of Ubuntu requires it

---

#### Other tasks

* display the instance in the Web-UI
* display the security groups assigned to the instance in Dashboard
