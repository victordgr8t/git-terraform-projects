#this will create key with RSA algorithm and 4096 rsa bits
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

#this will create a key pair using the private key defined above
resource "aws_key_pair" "Key-Pair" {
  depends_on = [tls_private_key.private_key]
  key_name   = var.keyname
  public_key = tls_private_key.private_key.public_key_openssh

}

# this terraform resource will save private key at specified path.
resource "local_file" "storekey" {
  content  = tls_private_key.private_key.private_key_pem
  filename = "${var.base_path}${var.keyname}.pem"
}

# we create bastion host security group and define inbound and outbound rule
resource "aws_security_group" "bastion-sg" {
  depends_on = [aws_vpc.prod_vpc] #this means the vpc resource will be created before the bastion host sg

  name        = "Bastion_Host_SG"
  description = "Security Group for Bastion Host"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
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

# created bastion host ec2 instance
resource "aws_instance" "bastion_host" {
  ami                    = lookup(var.awsprops, "ami")
  instance_type          = lookup(var.awsprops, "instancetype")
  key_name               = var.keyname
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  subnet_id              = aws_subnet.prod_public_subnet.id

  tags = {
    Name = "Bastion_host"
  }

  connection {
    user        = "ec2-user"
    private_key = file("/Users/mac/Desktop/terraform-projects/NV_R_key.pem")
    host        = aws_instance.bastion_host.public_ip

  }
}

#here we create wordpress security group and define inbound and outbound rule
resource "aws_security_group" "wordpress-sg" {
  depends_on = [aws_vpc.prod_vpc]

  name        = "Wordpress_SG"
  description = "Security Group for Wordpress EC2 Instance"
  vpc_id      = aws_vpc.prod_vpc.id

  #created an inbound rule for HTTP
  ingress {
    description = "Allow TCP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  #created an inbound rule for PING
  ingress {
    description = "Allow PING"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  #created an inbound rule for SSH
  ingress {
    description     = "Allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion-sg.id]

  }

  #created an outbound rule for the wordpress
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Wordpress-SG"
  }

}

#created wordpress EC2 Instance
resource "aws_instance" "wordpress" {
  ami                    = lookup(var.awsprops, "ami")
  instance_type          = lookup(var.awsprops, "instancetype")
  vpc_security_group_ids = [aws_security_group.wordpress-sg.id]
  subnet_id              = aws_subnet.prod_public_subnet.id
  key_name               = var.keyname
  user_data              = <<EOF
            #! /bin/bash
            yum update
            yum install docker -y
            systemctl restart docker
            systemctl enable docker
            docker pull wordpress
            docker run --name wordpress -p 80:80 -e WORDPRESS_DB_HOST=${aws_instance.mysql.private_ip} \
            -e WORDPRESS_DB_USER=root -e WORDPRESS_DB_PASSWORD=root -e WORDPRESS_DB_NAME=wordpressdb -d wordpress
  EOF

  tags = {
    Name = "Wordpress_Instance"
  }
}

resource "aws_security_group" "mysql-sg" {
  depends_on = [
    aws_vpc.prod_vpc,
  ]

  name        = "MYSQL_SG"
  description = "Security Group for MYSQL EC2 Instance"
  vpc_id      = aws_vpc.prod_vpc.id

  ingress {
    description     = "allow TCP"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.wordpress-sg.id]
  }

  ingress {
    description     = "allow SSH"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.bastion-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# created a mysql ec2 instance
resource "aws_instance" "mysql" {
  ami                    = lookup(var.awsprops, "ami")
  instance_type          = lookup(var.awsprops, "instancetype")
  key_name               = var.keyname
  vpc_security_group_ids = [aws_security_group.mysql-sg.id]
  subnet_id              = aws_subnet.prod_public_subnet.id
  user_data              = file("mysqlconfig.sh")

  tags = {
    Name = "MSQL-Instance"
  }
}
