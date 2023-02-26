module "module-test" {
  source  = "git@github.com:Low-Frequency/terraform-module-proxmox.git?ref=main"

  name  = "module-test-01"
  tags  = "test"
  id    = 100

  memory  = 2048
  cores   = 2
  disk = [
    {
      disk_size = "32G"
    }
  ]
  
  user      = "some_user"
  password  = var.user_password
  sshkeys   = file(var.path_to_public_key)

  network   = "vlan_10"
  ip_index  = 10

  enable_ansible    = true
  ansible_playbook  = "playbook.yml"
  ansible_plain_vars = {
    iob_restore           = "true"
    iob_use_local_backup  = "false"
  }

}
