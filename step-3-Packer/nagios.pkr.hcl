packer {
  required_plugins {
    amazon  = { source = "github.com/hashicorp/amazon",  version = ">= 1.3.0" }
    ansible = { source = "github.com/hashicorp/ansible", version = ">= 1.1.0" }
  }
}

variable "region"       { default = "us-east-1" }
variable "instance_type"{ default = "t3.small" }
# Ubuntu 22.04 LTS (us-east-1). Если у тебя другой регион — подмени на свой AMI.
variable "source_ami"   { default = "ami-0bbdd8c17ed981ef9" }

locals { ami_name = "nagios-ami-{{timestamp}}" }

source "amazon-ebs" "ubuntu_nagios" {
  region                      = var.region
  instance_type               = var.instance_type
  source_ami                  = var.source_ami
  ssh_username                = "ubuntu"
  ami_name                    = local.ami_name
  associate_public_ip_address = true

  tags = {
    Name    = "nagios-ami"
    Project = "nagios"
    BuiltBy = "packer"
  }
}

build {
  name    = "nagios-ami"
  sources = ["source.amazon-ebs.ubuntu_nagios"]

  # ВАЖНО: абсолютные пути к твоему плейбуку и ролям
  provisioner "ansible" {
    playbook_file = "/home/ubuntu/nagios-project/step-2-Ansible/main.yml"
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_ROLES_PATH=/home/ubuntu/nagios-project/step-2-Ansible/roles",
      "ANSIBLE_CONFIG=/home/ubuntu/nagios-project/step-2-Ansible/ansible.cfg"
    ]
    # Никаких -e @group_vars: не нужно, чтобы не ловить ошибки путей
  }

  # Неблокирующая проверка
  provisioner "shell" {
    inline = [
      "sudo systemctl enable apache2 nagios4 || true",
      "sudo systemctl start apache2 nagios4 || true",
      "curl -I http://127.0.0.1/nagios4 | head -n1 || true"
    ]
  }

  post-processor "manifest" {
    output = "manifest.json"
  }
}
