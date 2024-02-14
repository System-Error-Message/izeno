
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

//resource "aws_instance" "example" {
//  ami           = "ami-2757f631"
//  instance_type = "t2.micro"
//}
//resource "aws_vpc" "main" {
//  cidr_block = var.base_cidr_block
//}

variable "awsprops" {
  type = map(string)
  default = {
    region       = "us-east-1"
    vpc          = "vpc-0638d9647efa23cea"
    ami          = "ami-0fe630eb857a6ec83"
    itype        = "t2.micro"
    subnet       = "subnet-0bc8514d594b7570e"
    publicip     = true
    keyname      = "AAP"
    secgroupname = "sg-0a178768e55f38286"
  }
}

//provider "aws" {
//  region = lookup(var.awsprops, "region")
//}
/*
resource "aws_security_group" "project-iac-sg" {
  name        = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id      = lookup(var.awsprops, "vpc")
  /*
  // To Allow SSH Transport
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  // To Allow Port 80 Transport
  ingress {
    from_port = 80
    protocol = ""
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}*/


resource "aws_instance" "project-iac" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  subnet_id                   = lookup(var.awsprops, "subnet") #1F
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name                    = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    //aws_security_group.project-iac-sg.id
	lookup(var.awsprops, "secgroupname")
  ]
  root_block_device {
    delete_on_termination = true
    //iops = 50
    volume_size = 15
    volume_type = "gp3"
  }
  tags = {
    Name        = "SERVER01"
    Environment = "DEV"
    OS          = "RHEL"
    Managed     = "IAC"
  }

  //depends_on = [aws_security_group.project-iac-sg]
}
resource "aws_instance" "VM2" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  subnet_id                   = lookup(var.awsprops, "subnet") #1F
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name                    = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    //aws_security_group.project-iac-sg.id
        lookup(var.awsprops, "secgroupname")
  ]
  root_block_device {
    delete_on_termination = true
    //iops = 50
    volume_size = 10 #minimum amount
    volume_type = "gp3"
  }
  tags = {
    Name        = "SERVER02"
    Environment = "DEV"
    OS          = "RHEL"
    Managed     = "IAC"
  }

  //depends_on = [aws_security_group.project-iac-sg]
}

resource "local_file" "my_file" {
  content  = "[all]\n${aws_instance.project-iac.public_ip}"
  filename = "../deploy/inventory"
}
resource "local_file" "my_file22" {
  content  = "[all]\n${aws_instance.project-iac.private_ip}\n${aws_instance.VM2.private_ip}"
  filename = "../update/inventory"
}
output "all" {
  value = [aws_instance.project-iac.public_ip,aws_instance.VM2.public_ip]
}

