# Test to create ilm policy via tf

# Allow all
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_all"
  }
}

resource "aws_instance" "es2" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.medium"
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_es.rendered)
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.public-1b.id  
  vpc_security_group_ids      = [aws_security_group.allow_all.id] 
  #   iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 15
  }
  tags = merge(
    var.default_tags,
    {
      Name = "ES-2"
    },
  )
}


data "template_cloudinit_config" "cloudinit_kibana2" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/kibana.sh",
      {
        VERSION = var.elastic-version,
        ES = aws_instance.es2.public_ip
      }
    )
  }
  
}

resource "aws_instance" "kibana2" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.medium"
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_kibana2.rendered)
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.public-1b.id
  vpc_security_group_ids      = [aws_security_group.allow_all.id]
#   iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 20
  }
  tags = merge(
    var.default_tags,
    {
      Name = "Kibana-2"
    },
  )
}

output "kibana-instances2" {
  value       = "http://${aws_instance.kibana2.public_ip}:5601"
  description = "Public IP address details of kibana"
}

# https://registry.terraform.io/providers/elastic/elasticstack/latest/docs/resources/elasticsearch_index_lifecycle

provider "elasticstack" {
  elasticsearch {
    endpoints = ["http://${aws_instance.es2.public_ip}:9200"]
  }
}

resource "null_resource" "previous" {}

resource "time_sleep" "wait_180_seconds" {
  depends_on = [null_resource.previous, aws_instance.es2]

  create_duration = "180s"
}

resource "elasticstack_elasticsearch_index_lifecycle" "test" {
  name = "policy-jassi"
  warm {
    min_age = "1d"
    allocate {
      number_of_replicas = 0
    }
  }
  depends_on = [
    time_sleep.wait_180_seconds
 ]
}


resource "elasticstack_elasticsearch_index_template" "my_template" {
  name = "my_index"

  index_patterns = ["my_index*"]
  template {
    settings = jsonencode({
      "number_of_replicas": 2,
      "index": {
        "lifecycle": {
          "name": "${elasticstack_elasticsearch_index_lifecycle.test.name}"
        }
      }
   })
  }
  
}