

 ########
 # Vars #

variable "aws_region" { default = "us-west-2" } # US-oregon

 # var pour ansible
variable "my_cont_user" {}
variable "my_cont_pass" {}
variable "my_pi_user" {}
variable "my_pi_pass" {}

 # AWS SDK auth
provider "aws" {
    region = "${var.aws_region}"
#    access_key = "ABIASDLASDIHV6QNZASQ"
#    secret_key = "06mcwWI7MhP59cKss5PQjPyPGzvF7k/gNCdZGKYc"

    access_key = "AKIAJDLFSDIHN6QEZASQ"
    secret_key = "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"
}

 ############
 # SSH keys #

resource "aws_key_pair" "admin" {
  key_name   = "admin-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDReMyXDOfuGipgcQViDTr3kqfbLVbIegJI+j3Br2wgX5CQXkWoFqKKZv3JIS4RnZdyQ3HCf8hbwUA1SoW4ngOAARToLYbMA80bHilZK5AzpYoTVH9GgfruLeq/ljJJAyh33vQgk26VX63mBIlp7cgxMx96T2iSqUuNbylXHgEOhPXMytv7FT4JcxMhNIRCq9YnsS8nD7+6GrJ7tSnochTauXs3OrM8bTA0AgZfj0PrC8aDZRCEShPU9QEjGTrtIX5AVcRoP01UInk1JWfQIBk1x5WPKYUDXQIrZPyLkWJ0Y6H7qcLKyBmDqTrEuMZ6fi9zcpEFkkg3wyC9ERr/UmVx xerus@goishi"
}


resource "aws_key_pair" "ansible" {
  key_name   = "ansible-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDr1Av8Kj8LqsI6cK31n4IElsxsGemzDXAI8NSCSRtTlNh8dJIIXpWnrGFSM9NU8++4qQmlYv+5uRhKS1SMZcPgRlcNGIBGLQxolFVw437zvt5O5mgLePRjgXpQWF/0fwx4iKark9Djyt8eHjSbTHCqpflT2xgFPMq0sJFJWmIMcGMkIh436AbjubvlgB8K1CGJzbTM4xHhlEywrggDekUcvXD2IKQFHAbO1pU/47krLdaOEhY0KeHnxfrBLU4RLxn1lyQkWLqLvuM+7o4j5lcMS/v3CC5t8I80uMByK76TC7qFOmZdU0jdo0tJBDzCBw1EmjIkD9urO1ZfL+r7FSbH xerus@goishi"
}

 ##########
 # Subnet #

 # Get default VPC
resource "aws_default_vpc" "default" {
    tags {
        Name = "Default VPC"
    }
}

resource "aws_subnet" "web-public-2a" {
    cidr_block = "172.31.60.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = "${aws_default_vpc.default.id}"

    tags {
        Name = "Web"
    }
}

resource "aws_subnet" "bd-private-2a" {
    cidr_block = "172.31.50.0/27"
    availability_zone = "${var.aws_region}a"
    vpc_id     = "${aws_default_vpc.default.id}"
    tags {
        Name = "BD"
    }
}

 ##################
 # Security Group #
 
resource "aws_security_group" "allow_remote_admin" {
  name        = "allow_remote_admin"
  description = "Allow ssh and RDP inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_remote_admin"
  }
}

resource "aws_security_group" "allow_external_communication" {
  name        = "allow_external_communication"
  description = "Allow system reach other servers"

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_external_comm"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web traffic to server"

  ingress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_web"
  }
}

resource "aws_security_group" "allow_mysql_internal" {
  name        = "allow_mysql_internal"
  description = "Allow Mysql connexion from web server"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.web-public-2a.cidr_block}"]
  }

  tags {
    Name = "allow_mysql_internal"
  }
}

 #######
 # EC2 #

 # Extract last AWS ubuntu AMazon Image (AMI)
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

}


 # EC2 creation 

resource "aws_instance" "web-terra" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
    subnet_id = "${aws_subnet.web-public-2a.id}"   

    associate_public_ip_address = true

    tags {
        Name = "web-terra"
        scope = "training"
        role = "web"
    }

    security_groups = [
        "${aws_security_group.allow_web.id}",
        "${aws_security_group.allow_external_communication.id}",
        "${aws_security_group.allow_remote_admin.id}"
    ]

    root_block_device = {
        delete_on_termination = true
        volume_size = 10 
    }

    provisioner "remote-exec" {
        # Install Python for Ansible
         inline = ["sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y install python "]

        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = "${file("ssh-keys/ansible-user")}"
        }
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '${self.public_ip},' --extra-=\"mysqlContHost=${aws_instance.db-terra.0.private_ip} mysqlContUser=${var.my_cont_user} mysqlContPass=${var.my_cont_pass} mysqlContDB=contact  mysqlPiHost=${aws_instance.db-terra.1.private_ip} mysqlPiUser=${var.my_pi_user} mysqlPiPass=${var.my_pi_pass} mysqlPiDB=showpi\" --private-key ssh-keys/ansible-user -T 300 site.yml"
    }

    provisioner "local-exec" {
        command = "sudo sed -i -r  's/^([0-9]{1,3}\\.){3}[0-9]{1,3}\\s+contacts.x3rus.com/${aws_instance.web-terra.public_ip} contacts.x3rus.com/g' /etc/hosts"
     }
    provisioner "local-exec" {
        command = "sudo sed -i -r  's/^([0-9]{1,3}\\.){3}[0-9]{1,3}\\s+showpi.x3rus.com/${aws_instance.web-terra.public_ip} showpi.x3rus.com/g' /etc/hosts"
     }


}

resource "aws_instance" "db-terra" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.ansible.key_name}"  # assign ssh ansible key
    subnet_id = "${aws_subnet.bd-private-2a.id}"   

    associate_public_ip_address = true
   
    # Create 2 instance of the database
    count = 2

    tags {
        Name = "db${count.index}-terra"
        scope = "training"
        role = "database"
    }

    security_groups = [
        "${aws_security_group.allow_mysql_internal.id}",
        "${aws_security_group.allow_external_communication.id}",
        "${aws_security_group.allow_remote_admin.id}"
    ]

    root_block_device = {
        delete_on_termination = true
        volume_size = 20 
    }

    provisioner "remote-exec" {
        # Install Python for Ansible
         inline = ["sudo apt-get update && sudo apt-get -y dist-upgrade && sudo apt-get -y install python "]

        connection {
            type        = "ssh"
            user        = "ubuntu"
            private_key = "${file("ssh-keys/ansible-user")}"
        }
    }

    provisioner "local-exec" {
        command = "ansible-playbook -u ubuntu --ssh-common-args='-o StrictHostKeyChecking=no' -i '${self.public_ip},' --extra-=\"mysqlContUser=${var.my_cont_user} mysqlContPass=${var.my_cont_pass} mysqlPiUser=${var.my_pi_user} mysqlPiPass=${var.my_pi_pass}\" --private-key ssh-keys/ansible-user -T 300 bd.yml" 
    }                                                                                                                                                       

}

