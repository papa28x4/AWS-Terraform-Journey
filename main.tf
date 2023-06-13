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

resource "aws_instance" "ec2_example" {

    ami = "ami-0eb260c4d5475b901"  
    instance_type = "t2.micro" 
    key_name= "aws_key_one"
    vpc_security_group_ids = [aws_security_group.main.id]

  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner >> hello.txt",
    ]
  }
  connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ubuntu"
      private_key = file("./aws_key_one") //This is here because we want to auto-login and do some post installation config
      timeout     = "4m"
   }
}

resource "aws_security_group" "main" {
  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
}


resource "aws_key_pair" "deployer" {
  key_name   = "aws_key_one"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRLJoZFwpdN/4Ihc/uiYbdi2DbcIJOdO45QwMBmg/V4OQlTiQugAotnXBOh03KXUaGi+4o5v/B/qq8syCJkoEOO+yAzHp3tWAF0szLA63GABgmACiN6ZUlN0yKObIZxSvybniohPeFa5+iZHGp+Mo7n98bqBLfmUrbP8kFCD48XJ7eX6F2E3aY4KeN5LLfj6Gh34OVvG6K2N6hkW1D9jmCl5mhIfmwkVE1ou+yGsEtZoVzmGVfqwL3ARoFcUuSrwK7syiUgL8Q6kPyli8GEeXIO8rC73wyDyrzraKoNkdHJC1tFybjNjkm7rJSe+fqNzresXoOSW+tkV0GpXUNzrD3 USER@PAPA2"
}
