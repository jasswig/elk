
data "template_cloudinit_config" "cloudinit_es" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/elasticsearch.sh",
      {
        VERSION = var.elastic-version
      }
    )
  }
  
}

resource "aws_instance" "es" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.medium"
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_es.rendered)
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.private-1a.id  
  vpc_security_group_ids      = [aws_security_group.allow_es.id] # https://stackoverflow.com/questions/65628538/terraform-shows-invalidgroup-notfound-while-creating-an-ec2-instance
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 15
  }
  tags = merge(
    var.default_tags,
    {
      Name = "ES"
    },
  )
}


data "template_cloudinit_config" "cloudinit_kibana" {
  gzip          = false
  base64_encode = false
  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/kibana.sh",
      {
        VERSION = var.elastic-version,
        ES = aws_instance.es.private_ip
      }
    )
  }
  
}

resource "aws_instance" "kibana" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.medium"
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_kibana.rendered)
  user_data_replace_on_change = true
  subnet_id                   = aws_subnet.public-1a.id
  vpc_security_group_ids      = [aws_security_group.allow_kibana.id]
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  root_block_device {
    volume_type               = "gp2"
    volume_size               = 20
  }
  tags = merge(
    var.default_tags,
    {
      Name = "Kibana"
    },
  )
}

output "kibana-instances" {
  value       = "http://${aws_instance.kibana.public_ip}:5601"
  description = "Public IP address details of kibana"
}

data "template_cloudinit_config" "cloudinit_app" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content = templatefile("scripts/cloud-config.txt",{})
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/filebeat.sh",
    {
      VERSION = var.elastic-version,
      LOGSTASH = aws_instance.logstash.private_ip
    }
    )
  }

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/app.sh",{})
  }

}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.small"
  count                       = 1
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_app.rendered)
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.allow_app.id]
  subnet_id                   = aws_subnet.private-1a.id 
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  tags = merge(
    var.default_tags,
    {
      Name = "app-filebeat"
    },
  )
}

data "template_cloudinit_config" "cloudinit_logstash" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content = templatefile("scripts/logstash.sh",
      {
        VERSION = var.elastic-version,
        ES = aws_instance.es.private_ip
      }
    )
  }



}

resource "aws_instance" "logstash" {
  ami                         = data.aws_ami.awslinux.id 
  instance_type               = "t3.small"
  user_data                   = base64encode(data.template_cloudinit_config.cloudinit_logstash.rendered)
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.allow_logstash.id]
  subnet_id                   = aws_subnet.private-1a.id 
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch.name
  tags = merge(
    var.default_tags,
    {
      Name = "logstash"
    },
  )
}