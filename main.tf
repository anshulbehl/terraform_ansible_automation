terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.32.1"
    }

    aap = {
      source = "ansible/aap"
    }

    ansible = {
      version = "~> 1.3.0"
      source  = "ansible/ansible"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# Add security group for ssh
resource "aws_security_group" "ssh" {
  name = "ssh"
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Add security group for http
resource "aws_security_group" "http" {
  name = "http"
  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair"  "my_key"  {
  key_name =  "my_key"
  public_key =  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5L9bG5/gCYCxc2dra1BbGASzwPFlKNM8tIfr6GdZiMNhb+vjfI8H3Zz2hEhsoQwVAdtGApraDkn9GamL+GNPWFQL0nYbvDMYGhNEYOaB6JPlEHA2W8KtcE+SULHkG1xIIh4FKEajrw57GWDb0i3oK37KtMLA1rFk3DsHS4Tft+hzhbi/nZPdWSsygq5Wtrw7E66DcZmC1ikws2mLb0xNTSIETEG7XtLysW5nj8Vjo2GcrYt5lds4wznm2nsCuhdEIhLtQVmA/SPNqj0kFzlhWTiQG0i1INMiHhCTnZ+A711Udf3u45lov82uEG4/Cz4OpwEBHR9EBe4tBccce3RIX abehl@ansh.yyz.redhat.com"
}

resource "ansible_host" "app-server" {
  name   = aws_instance.app-server.public_dns
  groups = ["nginx"]
  variables = {
    ansible_user                 = "ec2-user",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3",
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }
}

resource "aws_instance" "app-server" {
  instance_type = "${var.instance_type}"
  ami           = "ami-0005e0cfe09cc9050"
  tags = {
      Name = "${var.instance_name}"
      }
  key_name = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.ssh.name, aws_security_group.http.name, "default"]
}

provider "aap" {
  host     = "https://localhost"
  username = "anshul"
  password = "ansible"
  insecure_skip_verify = true
}

resource "aap_host" "app-server" {
  inventory_id = 3
  name = aws_instance.app-server.public_dns
  description = "An EC2 instance created by Terraform"
  variables = jsonencode(aws_instance.app-server)
}
