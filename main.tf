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



#1. Create vpc
resource "aws_vpc" "my_company" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my-company"
  }
}

#2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_company.id
}

#3. Create Custom Route Table
resource "aws_route_table" "route_entries" {
  vpc_id = aws_vpc.my_company.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_entries"
  }
}

#4. Create a Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_company.id
  cidr_block        = "10.0.1.0/24"
  #map_public_ip_on_launch = true
  availability_zone = "eu-west-2a"

  tags = {
    Name = "public-subnet"
  }
}

#5. Associate subnet with Route Table
resource "aws_route_table_association" "rt_assoc" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.route_entries.id
}

#6. Create Security Group to allow port 22, 80, 443
resource "aws_security_group" "allow_web_traffic" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.my_company.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web_traffic"
  }
}
#7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.public_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow_web_traffic.id]
}

#8. Create a network interface with an ip in the subnet that was created in step 7
resource "aws_eip" "eip" {

 network_interface         = aws_network_interface.nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}

#9. Create Ubuntu server and install/enable apache 2
resource "aws_instance" "web_server" {

    ami = "ami-0eb260c4d5475b901"  
    instance_type = "t2.micro" 
    key_name= "aws_key_one"
    availability_zone = "eu-west-2a"

    network_interface {
      device_index = 0
      network_interface_id = aws_network_interface.nic.id
    }

    user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install apache2 -y
                sudo systemct1 start apache2
                sudo bash -c 'echo your very first web server > /var/www/html/index.html'
                EOF
    
    tags = {
      Name = "web server"
    }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key_one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRLJoZFwpdN/4Ihc/uiYbdi2DbcIJOdO45QwMBmg/V4OQlTiQugAotnXBOh03KXUaGi+4o5v/B/qq8syCJkoEOO+yAzHp3tWAF0szLA63GABgmACiN6ZUlN0yKObIZxSvybniohPeFa5+iZHGp+Mo7n98bqBLfmUrbP8kFCD48XJ7eX6F2E3aY4KeN5LLfj6Gh34OVvG6K2N6hkW1D9jmCl5mhIfmwkVE1ou+yGsEtZoVzmGVfqwL3ARoFcUuSrwK7syiUgL8Q6kPyli8GEeXIO8rC73wyDyrzraKoNkdHJC1tFybjNjkm7rJSe+fqNzresXoOSW+tkV0GpXUNzrD3 USER@PAPA2"
}