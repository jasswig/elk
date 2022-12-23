#! /bin/bash

exec >> /var/log/filebeat.log 2>&1

VERSION="${VERSION}"
echo $VERSION

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
  hosts: ["127.0.0.1:5044"]

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

