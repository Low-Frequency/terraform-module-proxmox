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
  sshkeys   = var.user_public_key

  ip      = "10.11.12.13/16"
  gateway = "10.11.12.1"

  enable_ansible    = true
  ansible_playbook  = "playbook.yml"
  ansible_plain_vars = {
    iob_restore           = "true"
    iob_use_local_backup  = "false"
  }

}
