resource "aws_security_group" "allow_es" {
  name        = "allow_es"
  description = "Allow 9200 ingress traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 9200
    to_port          = 9200
    protocol         = "tcp"
    # security_groups  = [aws_security_group.allow_kibana.id, aws_security_group.allow_logstash.id]
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_es"
  }
}

resource "aws_security_group" "allow_kibana" {
  name        = "allow_kibana"
  description = "Allow kibana traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 5601
    to_port          = 5601
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_kibana"
  }
}

resource "aws_security_group" "allow_app" {
  name        = "allow_app"
  description = "Allow egress traffic"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_app"
  }
}

resource "aws_security_group" "allow_logstash" {
  name        = "allow_logstash"
  description = "Allow egress traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 5044
    to_port          = 5044
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    # security_groups  = [aws_security_group.allow_app.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_logstash"
  }
}
