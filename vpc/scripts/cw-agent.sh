# #! /bin/bash

# yum update -y
# yum install -y awslogs

# cat <<EOF > /etc/awslogs/config/filebeat.conf
# [/var/log/filebeat]
# datetime_format = %b %d %H:%M:%S
# file = /var/log/filebeat/filebeat*
# buffer_duration = 5000
# log_stream_name = {instance_id}
# initial_position = start_of_file
# log_group_name = /var/log/filebeat
# EOF

# cat <<EOF > /etc/awslogs/config/logstash.conf
# [/var/log/logstash]
# datetime_format = %b %d %H:%M:%S
# file = /var/log/logstash/logstash-plain.log
# buffer_duration = 5000
# log_stream_name = {instance_id}
# initial_position = start_of_file
# log_group_name = /var/log/logstash
# EOF

# # cat <<EOF > /etc/awslogs/config/elasticsearch.conf
# # [/var/log/elasticsearch]
# # datetime_format = %b %d %H:%M:%S
# # file = /var/log/elasticsearch/elasticsearch.log
# # buffer_duration = 5000
# # log_stream_name = {instance_id}
# # initial_position = start_of_file
# # log_group_name = /var/log/elasticsearch
# # EOF

# # cat <<EOF > /etc/awslogs/config/kibana.conf
# # [/var/log/kibana]
# # datetime_format = %b %d %H:%M:%S
# # file = /var/log/kibana/kibana.log
# # buffer_duration = 5000
# # log_stream_name = {instance_id}
# # initial_position = start_of_file
# # log_group_name = /var/log/kibana
# # EOF

# # cat <<EOF > /etc/awslogs/config/install.conf
# # [/var/log/install]
# # datetime_format = %b %d %H:%M:%S
# # file = /var/log/*.log
# # buffer_duration = 5000
# # log_stream_name = {instance_id}
# # initial_position = start_of_file
# # log_group_name = /var/log/install
# # EOF

# systemctl start awslogsd.service
# systemctl status awslogsd.service
# systemctl enable awslogsd.service