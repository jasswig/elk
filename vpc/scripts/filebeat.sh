#! /bin/bash

exec >> /var/log/filebeat.log 2>&1

yum update -y
yum install -y awslogs

cat <<EOF > /etc/awslogs/config/filebeat-log.conf
[/var/log/filebeat.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/filebeat.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/filebeat.log
EOF

cat <<EOF > /etc/awslogs/config/filebeat.conf
[/var/log/filebeat]
datetime_format = %b %d %H:%M:%S
file = /var/log/filebeat/filebeat*
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/filebeat
EOF

systemctl start awslogsd.service
systemctl status awslogsd.service
systemctl enable awslogsd.service

VERSION="${VERSION}"
LOGSTASH="${LOGSTASH}"

rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch

cat <<EOF > /etc/yum.repos.d/elastic.repo
[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF

# sudo yum repolist 
# sudo yum repo-pkgs elastic-8.x list --show-duplicates

yum install filebeat-$VERSION.$(arch) -y 

mv /etc/filebeat/filebeat.yml /etc/filebeat/filebeat_backup.yml

cat <<EOF > /etc/filebeat/filebeat.yml 
path.data: /var/lib/filebeat
path.logs: /var/log/filebeat

filebeat.inputs:
- type: filestream
  id: my-filestream-id
  paths: 
    - /tmp/sample.log

processors:
  - dissect:
      tokenizer: "%%{level}:%%{user}:%%{datetime}: %%{message}"
      field: "message"
      target_prefix: "parsed-message"


output.logstash:
  hosts: ["${LOGSTASH}:5044"]

# logging.json: true
logging.metrics.enabled: false
logging.level: info
logging.to_files: true
logging.files:
  path: /var/log/filebeat
  rotateeverybytes: 10485760 # = 10MB
  keepfiles: 2
EOF


systemctl start filebeat.service
systemctl enable filebeat.service
systemctl status filebeat.service
