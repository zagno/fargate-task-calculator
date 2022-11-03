# This module helps to size a Fargate task correctly
# 
# If you sized all your containers correctly, sum up the memory and CPU for all your containers, and 
# pass in those values to this module which will then return the allowed values for your task definition.
#
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/AWS_Fargate.html#fargate-task-defs

variable "cpu" {
  description = "The total number of cpus units allocated to all your containers"
  type = number
}

variable "memory" {
  description = "The total amount of memory, in MiB, allocated to all your containers"
  type = number
}

locals {
  cpus = [256, 512, 1024, 2048, 4096, 8192, 16384]

  cpu_memorys = {
     256:   [512, 1024, 2048],
     512:   [1024, 2048, 3073, 4096],
     1024:  range(1024, 8*1024+1, 1024)
     2048:  range(4*1024, 16*1024+1, 1024),
     4096:  range(8*1024, 30*1024+1, 1024),
     8096:  range(16*1024, 60*1024+1, 4096),
     16384: range(32*1024, 120*1024+1, 8096),
  }

  cpu = [for cpu in local.cpus: cpu if var.cpu <= cpu]

  memory = [for memory in lookup(local.cpu_memorys, local.cpu[0]): memory if var.memory <= memory]
}

output "cpu" {
  value = local.cpu[0]
}

output "memory" {
  value = local.memory[0]
}
