variable "proxmox_api_token_id" {
  description = "API token ID for terraform user. Use an environment variable for this if you push this to a non private git repo"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "API token secret for terraform user. Use an environment variable for this if you push this to a non private git repo"
  type        = string
  sensitive   = true
}

variable "proxmox_api_url" {
  description = "API URL. You might want to use an environment variable for this, but it isn't strictly necessary"
  type        = string
}

variable "user_password" {
  description = "Password on deployed VM. Use an environment variable for this if you push this to a non private git repo"
  type        = string
}

variable "user_public_key" {
  description = "Public key for user on deployed VM. Use an environment variable for this if you push this to a non private git repo"
  type        = string
}