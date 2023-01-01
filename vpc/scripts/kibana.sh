#! /bin/bash

exec >> /var/log/kibana.log 2>&1

yum update -y
yum install -y awslogs

cat <<EOF > /etc/awslogs/config/kibana-log.conf
[/var/log/kibana.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/kibana.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/kibana.log
EOF

cat <<EOF > /etc/awslogs/config/kibana.conf
[/var/log/kibana]
datetime_format = %b %d %H:%M:%S
file = /var/log/kibana/kibana.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/kibana
EOF

systemctl start awslogsd.service
systemctl status awslogsd.service
systemctl enable awslogsd.service

VERSION="${VERSION}"
ES="${ES}"

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

yum install kibana-$VERSION.$(arch) -y 
cp /etc/kibana/kibana.yml /etc/kibana/kibana_backup.yml

cat <<EOF > /etc/kibana/kibana.yml 
server.port: 5601
server.host: "0.0.0.0"
server.ssl.enabled: false
elasticsearch.hosts: ["http://${ES}:9200"]
logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file
# Specifies the path where Kibana creates the process ID file.
pid.file: /run/kibana/kibana.pid
EOF

systemctl start kibana.service
systemctl enable kibana.service
systemctl status kibana.service
