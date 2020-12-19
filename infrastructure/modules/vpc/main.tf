resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "main"
  }
}

resource "aws_security_group" "default" {
  name        = "scannerfleetsc"
  description = "Security group for AWS lambda and AWS RDS connection"
  vpc_id      = aws_vpc.default.id
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["127.0.0.1/32"]
    self = true
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["5.81.206.174/32"]
    self = true
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["5.81.206.174/32"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "default1" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "default2" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "default3" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}c"
}

resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.default1.id, aws_subnet.default2.id, aws_subnet.default3.id]
}
