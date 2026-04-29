resource "openstack_compute_instance_v2" "simple_instance" {
  name            = "INSTANCE_NAME"
  image_id        = "IMAGE_ID"
  flavor_name     = "FLAVOR_NAME"
  key_pair        = "KEYPAIR_NAME"
  security_groups = ["SECGROUP_ID"]
  
  network {
    name = "NETWORK_NAME"
  }
}
