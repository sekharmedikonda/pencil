#Vpc


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Project VPC"
  }
}



module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  # cidr = "{var.vpc_cidr}"
  cidr = "10.0.0.0/16"

  # cidr = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  # vpc_cidr_block  = "${var.vpc_cidr_block}"


   azs             = data.aws_availability_zones.azs.names

 # azs = slice(data.aws_availability_zones.azs.names, 0, 3)

  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = var.public_subnets

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  enable_dns_hostnames = true



  tags = {
    Name        = "jenkins-vpc"
    Terraform   = "true"
    Environment = "dev"
  }

  public_subnet_tags = {

    Name = "jenkins-subnet"

  }
}



#SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "jenkins-sg"
  description = "Security Group for jenkins server"
  vpc_id      = module.vpc.vpc_id


  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_with_cidr_blocks =  [
{
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"


}

  ]
        tags = {
            Name        = "jenkins-sg"
    
  }

}
# resource "aws_instance" "example_server" {
#   ami           = "ami-04e914639d0cca79a"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "JacksBlogExample"
#   }
# }

# resource "aws_subnet" "vpc_id"{
#  vpc_id = aws_vpc.myvpc.id
#  cidr_block = "192.168.2.0/24"
#  availability_zone = "${var.availability_zone2}"
#  tags = {
#  Name = "private_subnet"
#  }
# }


#  resource "aws_subnet" "vpc_id"{
#   vpc_id = aws_vpc.main.id
#   cidr_block = "10.10.1.0/24"
#   availability_zone = "ap-south-1a"
#   tags = {
#   Name = "private_subnet"
#   }
#  }






#EC2

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-server"

  instance_type          = var.instance_type
  key_name               = "one"
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  
 # subnet_id              = "subnet-00d650b6c1ac3eada"


  
  associate_public_ip_address  = true

      user_data  =  file  ("jenkins-install.sh")
      availability_zone =  data.aws_availability_zones.azs.names[0]




  tags = {
    Name = "jenkins-server"
    Terraform   = "true"
    Environment = "dev"
  }
}