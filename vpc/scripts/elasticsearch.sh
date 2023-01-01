#! /bin/bash

exec >> /var/log/elasticsearch.log 2>&1

yum update -y
yum install -y awslogs

cat <<EOF > /etc/awslogs/config/elasticsearch-log.conf
[/var/log/elasticsearch.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/elasticsearch.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/elasticsearch.log
EOF

cat <<EOF > /etc/awslogs/config/elasticsearch.conf
[/var/log/elasticsearch]
datetime_format = %b %d %H:%M:%S
file = /var/log/elasticsearch/elasticsearch.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/elasticsearch
EOF

systemctl start awslogsd.service
systemctl status awslogsd.service
systemctl enable awslogsd.service

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

VERSION="${VERSION}"

yum install elasticsearch-$VERSION.$(arch) -y 

mv /etc/elasticsearch/elasticsearch.yml /etc/elasticsearch/elasticsearch_backup.yml

cat <<EOF > /etc/elasticsearch/elasticsearch.yml 
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
xpack.security.enabled: false
xpack.security.enrollment.enabled: false

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: false
xpack.security.transport.ssl:
  enabled: false
cluster.initial_master_nodes: ["$(hostname)"]
http.host: 0.0.0.0
EOF

# cat <<EOF >> /etc/elasticsearch/jvm.options
# -Xms1g 
# -Xmx1g
# EOF

systemctl start elasticsearch.service
systemctl enable elasticsearch.service
systemctl status elasticsearch.service
