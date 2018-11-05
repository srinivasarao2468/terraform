#configure provider
provider "aws" {
  region = "${var.region}"
}

# Configuring instance for jenkins and ansible
resource "aws_instance" "instance" {
  count                  = "${var.instance_count}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${element(aws_subnet.public_subnet.*.id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.instance_security_groups.id}"]
  user_data              = "${file(var.user_data)}"

  tags {
    Name = "Jenkins-Ansible"
  }
}

#configuring instance for application deployment
resource "aws_instance" "app_instance" {
  count                  = "${var.app_instance_count}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  key_name               = "${var.key_name}"
  subnet_id              = "${element(aws_subnet.private_subnet.*.id,count.index)}"
  vpc_security_group_ids = ["${aws_security_group.app_security_groups.id}"]
  user_data              = "${file(var.app_user_data)}"

  tags {
    Name = "Application${count.index+1}"
  }
}

#Configuring instance security groups
resource "aws_security_group" "instance_security_groups" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.app_vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configuring app security groups
resource "aws_security_group" "app_security_groups" {
  name        = "app_security"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.app_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
