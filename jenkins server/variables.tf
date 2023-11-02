variable "vpc_cidr" {
  type        = string
  description = "The IP range to use for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {

  description = "subnets CIDR"
  type        = list(string)

}
# variable "aws_availability_zones" {

#   description = "subnets CIDR"
#   type        = list(string)
# }

variable "instance_type" {

  description = "instance Type"
  type        = string

}

#variable "instance_type" {} 