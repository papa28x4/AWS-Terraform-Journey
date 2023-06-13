terraform {
required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2"
}

# Create a VPC
resource "aws_vpc" "my_company" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-company"
  }
}

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.app_vpc.id

#   tags = {
#     Name = "vpc_igw"
#   }
# }

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_company.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-subnet"
  }
}

# resource "aws_route_table" "public_rt" {
#   vpc_id = aws_vpc.app_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name = "public_rt"
#   }
# }

# resource "aws_route_table_association" "public_rt_asso" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public_rt.id
# }