# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
  # access_key ="value"
  # secret_key ="value"
}
data "aws_ami" "amazon-lunix-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}
resource "aws_vpc" "terra-vpc" {
  cidr_block = var.vpc_cir_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  
}
resource "aws_subnet" "terra-pub-sub1" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = var.pub_sub1_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "terra-pub-sub1"
  }
}
resource "aws_subnet" "terra-priv-sub1" {
  vpc_id     = aws_vpc.terra-vpc.id
  cidr_block = var.priv_sub1_cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = "terra-pub-sub2"
  }
}
resource "aws_internet_gateway" "terra-igw" {
  vpc_id = aws_vpc.terra-vpc.id 
}

resource "aws_route_table" "my_table" {
  vpc_id = aws_vpc.terra-vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra-igw.id
  }

}
resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = aws_subnet.terra-pub-sub1.id
  route_table_id = aws_route_table.my_table.id
}

resource "aws_security_group" "terra-web-sg" {
  name        = "my_web_security"
  description = "Allow http,ssh,icmp"
  vpc_id      =  aws_vpc.terra-vpc.id


  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
 }  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mywebserver_sg"
  }
}



resource "aws_instance" "Terra-instance" {
  ami           = data.aws_ami.amazon-lunix-2.id
  instance_type = var.aws_instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.terra-pub-sub1.id
  vpc_security_group_ids = [aws_security_group.terra-web-sg.id]
  key_name = var.instance_key_pair
  


  
}

resource "aws_instance" "Priv-Terra-instance" {
  ami           = data.aws_ami.amazon-lunix-2.id
  instance_type = var.aws_instance_type
  associate_public_ip_address = true
  subnet_id = aws_subnet.terra-priv-sub1.id
  vpc_security_group_ids = [aws_security_group.terra-web-sg.id]
  key_name = var.instance_key_pair
  
}

# region variable
variable "vpc_cir_block" {
  description = "vpc network id"
  type = string
  default = "10.0.0.0/16"
  
}
variable "aws_region" {
  description = "region value"
  type = string
  default = "us-east-1"
  
}
variable "pub_sub1_cidr_block" {
  description = "vpc network id"
  type = string
  default = "10.0.0.0/24"
  
}
variable "priv_sub1_cidr_block" {
  description = "vpc network id"
  type = string
  default = "10.0.1.0/24"
  
}
variable "aws_instance_type" {
  description = "instance type"
  type = string
  default = "t2.micro"
  
}
variable "instance_key_pair" {
  description = "instance key"
  type = string
  default = "Public_Subnet_EC2"
  
}







# resource "aws_instance" "name" {
# resource "aws_instance" "volf" {
#   ami           = "ami-03d5c68bab01f3496"
#   instance_type = "t2.micro"
#   tags = {
#     "Name" = "Helloworld"
#   }



# }
