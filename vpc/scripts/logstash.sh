#! /bin/bash

exec >> /var/log/logstash.log 2>&1

yum update -y
yum install -y awslogs

cat <<EOF > /etc/awslogs/config/logstash-log.conf
[/var/log/logstash.log]
datetime_format = %b %d %H:%M:%S
file = /var/log/logstash.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/logstash.log
EOF

cat <<EOF > /etc/awslogs/config/logstash.conf
[/var/log/logstash]
datetime_format = %b %d %H:%M:%S
file = /var/log/logstash/logstash-plain.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = /var/log/logstash
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

yum install logstash-$VERSION.$(arch) -y 


mv /etc/logstash/logstash.yml /etc/logstash/logstash_backup.yml

cat <<EOF > /etc/logstash/logstash.yml 
path.data: /var/lib/logstash
api.http.host: 0.0.0.0
path.logs: /var/log/logstash
EOF

# https://www.elastic.co/guide/en/logstash/current/multiple-pipelines.html

cat <<EOF > /etc/logstash/pipelines.yml
- pipeline.id: start-pipeline
  path.config: "/etc/logstash/conf.d/p1.conf"
  pipeline.workers: 3
- pipeline.id: process-pipeline
  path.config: "/etc/logstash/conf.d/p2.conf"
  queue.type: persisted
- pipeline.id: final-pipeline
  path.config: "/etc/logstash/conf.d/p3.conf"
  queue.type: persisted
EOF

cat <<EOF > /etc/logstash/logstash-helloworld.json
{
  "index_patterns" : ["hello*"],
  "priority" : 1,
  "template": {
    "settings" : {
      "number_of_replicas": 0
    },
    "mappings": {
    "_source": {
      "enabled": true
    },
    "properties": {
      "parsed-message": {
        "properties": {
          "datetime": {
            "type": "date",
            "format": "strict_date_optional_time_nanos"
          }
        }
      }
    }
  }
  }
}
EOF

cat <<EOF > /etc/logstash/conf.d/p1.conf
input {
  beats {
    port => 5044
  }
}

output {
 pipeline { send_to => processor }
}
EOF


cat <<EOF > /etc/logstash/conf.d/p2.conf
input {
  pipeline { address => processor }
}

filter {
      mutate {
        add_field => { "hello-world" => "week2" }
      }
    }

output {
 pipeline { send_to => output }
}
EOF


cat <<EOF > /etc/logstash/conf.d/p3.conf
input {
  pipeline { address => output }

}


output {
      elasticsearch {
        hosts => "http://${ES}:9200"
        index => "hello-world-jassi"
        manage_template => true
        template => "/etc/logstash/logstash-helloworld.json"
        template_name => "logstash-helloworld"
        template_overwrite => true
      }
}
EOF


systemctl start logstash.service
systemctl enable logstash.service
systemctl status logstash.service
