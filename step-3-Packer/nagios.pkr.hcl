packer {
  required_plugins {
    amazon = {
      version = ">= 1.3.0"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"   # или твой регион
}

locals {
  ami_name = "nagios-ami-{{timestamp}}"
}

source "amazon-ebs" "ubuntu_nagios" {
  region                  = var.region
  instance_type           = "t3.small"
  ssh_username            = "ubuntu"
  ami_name                = local.ami_name
  associate_public_ip_address = true

  source_ami = "ami-0bbdd8c17ed981ef9"

  tags = {
    Name    = "nagios-ami"
    Project = "nagios"
    BuiltBy = "packer"
  }
}

build {
  name    = "nagios-ami"
  sources = ["source.amazon-ebs.ubuntu_nagios"]

  provisioner "ansible" {
    playbook_file = "/home/ubuntu/nagios-project/step-2-Ansible/site.yml"   # путь к плейбуку из шага 2
    ansible_env_vars = [
      "ANSIBLE_CONFIG=../step-2-Ansible/ansible.cfg"
    ]
    extra_arguments = ["-e", "@/home/ubuntu/nagios-project/step-2-Ansible/group_vars/all.yml"]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
