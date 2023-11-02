module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "jenkins-vpc"
  # cidr = "{var.vpc_cidr}"
  cidr = "10.0.0.0/16"

  # cidr = "${cidrsubnet(var.vpc_cidr, 8, count.index + 1)}"
  # vpc_cidr_block  = "${var.vpc_cidr_block}"


  azs = data.aws_availability_zones.azs.names

  # azs = slice(data.aws_availability_zones.azs.names, 0, 3)

  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  # enable_nat_gateway = true
  # enable_vpn_gateway = true

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {

    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = 1

  }
  private_subnet_tags = {

    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = 1

  }
}


module "eks" {
  version = "19.3.1"
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.24"

  # cluster_endpoint_private_access = true
  # cluster_endpoint_public_access  = true

  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.private_subnets
  enable_irsa = true

  # eks_managed_node_group_defaults = {
  #   disk_size = 50
  # }

  eks_managed_node_groups = {
    node = {
      instance_types = ["t2.small"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      #labels = {
      #  role = "general"
      #}
    }
  }
  tags = {
    Environment = "dev"
    Terraform   = "true"

  }

}



