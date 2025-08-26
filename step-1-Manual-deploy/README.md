# nagios-project
Nagios DevOps project

# Step 1 – Manual Deployment of Nagios

## Region and VM Details
- **AWS Region:** us-east-2 (Ohio)
- **Bastion Host:** Ubuntu 22.04 (used for SSH access to the target VM)
- **Target Instance Type:** t3.small
- **AMI:** Ubuntu Server 22.04 LTS (official Canonical image)
- **Key Pair:** nagios_key (generated locally and added to AWS)

## Security Group – Open Ports
- **22/tcp (SSH):** allowed only from Bastion host security group
- **80/tcp (HTTP):** allowed from 0.0.0.0/0 (to access Nagios web UI)

## Manual Installation Commands (on the target Nagios VM)

```bash
# Update package list
sudo apt update

# Install Nagios and required dependencies
sudo apt install -y nagios4 nagios-nrpe-plugin apache2 apache2-utils

# (Optional) Create admin user for web interface authentication:
sudo htpasswd -c /etc/nagios4/htpasswd.users nagiosadmin
password: kaizen123

# Enable CGI module in Apache (required for Nagios web interface)
sudo a2enmod cgi

# Restart and enable Apache and Nagios services
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl enable nagios4
sudo systemctl restart nagios4

# By default, Nagios web access is restricted to private IP ranges
sudo nano /etc/apache2/conf-enabled/nagios4-cgi.conf
- Require ip ... (list of private networks)
- Require all granted
sudo systemctl restart apache2

# After all steps, verify that Nagios web UI is accessible:
http://18.188.156.208/nagios4


# Step 2 - Ansible

cd step-2-Ansible
ansible-playbook site.yml

# Step 3 - Packer

cd step-3-Packer
packer init .
packer validate .
packer build .