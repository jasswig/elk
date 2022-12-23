
# resource "aws_instance" "ubuntu" {
#   ami           = "ami-0574da719dca65348"
#   instance_type = "t3.small"
#   count = 0

#   user_data = "${file("script-ubuntu.sh")}"
#   user_data_replace_on_change = true

#   # key_name = "ubuntu"

#   security_groups = [aws_security_group.allow_all.name]

#   tags = {
#     Name = "HelloWorld-ubuntu"
#   }
# }


# output "instances-ubuntu" {
#   value       = "${aws_instance.ubuntu.*.public_ip}"
#   description = "PrivateIP address details of ubuntu instance"
# }

