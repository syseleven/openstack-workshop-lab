# Webserver with loadbalancer

## Overview

With this guide you can deploy a simple web application and publish it through a loadbalancer.

## Goal

* Create two webservers with a simple web application
* The application will be served behind a loadbalancer and you can request it by a public IP address

## Preparation

* You need your credentials for Openstack

---

### Connection and Preparation

* Make sure you have sourced an openstack rc file

`source openstack.sh`

* Look at the Terraform code in `./terraform/`
  * What resources are being created?
  * What is the expected result of this?
  * Also take note of the cloud-init happening in `./terraform/cloud-init/`
* Check out this git repo and cd into `05-lbaas/terraform`

---

### Rollout via Terraform

* Initialise the terraform project

`terraform init`

* Take a look at the Terraform plan

`terraform plan`

* When prompted enter the name of the ssh key (e.g. workshop)
* Apply the code and roll out the setup that way

`terraform apply`

* Enter the name of the ssh key and also confirm rollout with `yes`

---

### Conclusion

* Get the floating IP of your LB in Dashboard or command line
* Browse your IP like this: `http://$IP_ADRESS` using a browser or curl
* Refresh or repeat multiple times and examine the roundrobin

`upstream0` -> `upstream1` -> `upstream0` and so on...

---

#### Other tasks

The loadbalancer itself contains several sub-components:

* Listener
* Pools
* Health Monitors
* Members

* Display thoses components in Dashboard and verify they are in a healthy state
* Examine how these objects are linked with each other
