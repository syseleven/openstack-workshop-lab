#
# Network
#
resource "openstack_networking_network_v2" "net" {
  name = "net-lb"
}

resource "openstack_networking_subnet_v2" "subnet" {
  name       = "subnet-lb"
  network_id = openstack_networking_network_v2.net.id
  cidr       = "10.0.10.0/24"
}

resource "openstack_networking_router_v2" "router" {
  name                = "router-lb"
  external_network_id = "2d5c0a31-8b40-4def-8dce-8c8ca4b5184c"
}

resource "openstack_networking_router_interface_v2" "router_interface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

#
# Security Group
#
resource "openstack_networking_secgroup_v2" "secgroup" {
  name        = "secgroup-lb"
  description = "Secgroup for LB"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_http" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_in_group" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.secgroup.id
  security_group_id = openstack_networking_secgroup_v2.secgroup.id
}

#
# Servers for Upstream
#
resource "openstack_compute_instance_v2" "vm01" {
  name            = "upstream-server-01"
  image_name      = "Ubuntu Noble 24.04"
  flavor_name     = "m2c.tiny"
  key_pair        = var.keypair
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]
  user_data       = templatefile("cloud-init/upstream-server.yaml", { hostname = "upstream-server-01" })

  network {
    uuid = openstack_networking_network_v2.net.id
  }
}

resource "openstack_compute_instance_v2" "vm02" {
  name            = "upstream-server-02"
  image_name      = "Ubuntu Noble 24.04"
  flavor_name     = "m2c.tiny"
  key_pair        = var.keypair
  security_groups = [openstack_networking_secgroup_v2.secgroup.name]
  user_data       = templatefile("cloud-init/upstream-server.yaml", { hostname = "upstream-server-02" })

  network {
    uuid = openstack_networking_network_v2.net.id
  }
}

#
# Loadbalancer
#
resource "openstack_lb_loadbalancer_v2" "lb" {
  name           = "lbaas"
  vip_subnet_id  = openstack_networking_subnet_v2.subnet.id
}

resource "openstack_lb_listener_v2" "listener_80" {
  protocol        = "HTTP"
  protocol_port   = 80
  loadbalancer_id = openstack_lb_loadbalancer_v2.lb.id
  insert_headers = {
    X-Forwarded-For = "true"
  }
}

resource "openstack_lb_pool_v2" "pool" {
  protocol    = "HTTP"
  lb_method   = "ROUND_ROBIN"
  listener_id = openstack_lb_listener_v2.listener_80.id
}

resource "openstack_lb_member_v2" "member01" {
  pool_id    = openstack_lb_pool_v2.pool.id
  address    = openstack_compute_instance_v2.vm01.network.0.fixed_ip_v4
  protocol_port = 80
}

resource "openstack_lb_member_v2" "member02" {
  pool_id    = openstack_lb_pool_v2.pool.id
  address    = openstack_compute_instance_v2.vm02.network.0.fixed_ip_v4
  protocol_port = 80
}

resource "openstack_lb_monitor_v2" "monitor" {
  pool_id     = openstack_lb_pool_v2.pool.id
  type        = "HTTP"
  delay       = 5
  timeout     = 3
  max_retries = 3
  url_path    = "/"
}

resource "openstack_networking_floatingip_v2" "lb_fip" {
  pool = "ext-net"
}

resource "openstack_networking_floatingip_associate_v2" "lb_fip" {
  floating_ip = openstack_networking_floatingip_v2.lb_fip.address
  port_id     = openstack_lb_loadbalancer_v2.lb.vip_port_id
}
