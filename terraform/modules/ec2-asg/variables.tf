variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t2.micro"
}

# variable "network_interface_id" {
#   description = "ID of the network interface to attach"
#   type        = string
# }


variable "desired_capacity" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 2
}

variable "private_subnet_id" {
  description = "Private subnet where EC2 will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group for the EC2 instance"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
}
