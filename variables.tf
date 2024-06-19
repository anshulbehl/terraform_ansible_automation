variable "aws_security_group" {
  default = "secure_me" # AWS Security Group name
}
variable "instance_name" {
  default = "Ansible_is_cool" # AWS Name of instance
}
variable "instance_type" {
  default = "t2.micro" # AWS Instance type
}
variable "private_ip_address" {
  type    = string
  default = "10.20.20.120"
}