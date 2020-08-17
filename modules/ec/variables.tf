variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    vm = "centos"
  }
}

variable "security_group_id" {
  default = "sg-04eb31b45d06b472a"
}



variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = null
}


variable "subnet_id" {
 
}


variable "instance_type" {
  default = "t2.medium"
}

variable "count_instance" {
} 
