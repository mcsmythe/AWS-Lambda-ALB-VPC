variable "vpc_cidr" {
  default = "10.0.0.0/16"
  description = "VPC CIDR Block"
  type = string
}

variable "public-sub-1-cidr" {
  default = "10.0.0.0/24"
  description = "Public Subnet 1 CIDR Block"
  type = string
}

variable "public-sub-2-cidr" {
  default = "10.0.1.0/24"
  description = "Public Subnet 2 CIDR Block"
  type = string
}

