locals {
  # Define the number of subnets
  subnets = {
    lambda1      = 1
    aurora1      = 2
    aurora2      = 3
    elasticache1 = 4
  }
}

locals {
  instance_count = 2
}