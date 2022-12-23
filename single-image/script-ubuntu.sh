#! /bin/bash

exec >> /var/log/user-data.log 2>&1

HOME="/home/ec2-user"

VERSION=1:8.5.0-1

# https://www.elastic.co/guide/en/logstash/current/installing-logstash.html

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  apt-key add -

apt-get install apt-transport-https -y
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" |  tee -a /etc/apt/sources.list.d/elastic-8.x.list
apt-get update -y
apt-get install logstash=$VERSION -y 

mv /etc/logstash/logstash.yml /etc/logstash/logstash_backup.yml

cat <<EOF > /etc/logstash/logstash.yml 
path.data: /var/lib/logstash
api.http.host: 0.0.0.0
path.logs: /var/log/logstash
dead_letter_queue.enable: true
dead_letter_queue.max_bytes: 1mb
EOF

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

cat <<EOF > /etc/logstash/conf.d/p1.conf
input {
  file {
    id => "my_file"
    path => "/var/log/syslog"
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
  grok { 
    match => { "message" => "%{SYSLOGTIMESTAMP:timestamp} %{SYSLOGHOST:hostname} %{DATA:program}: %{GREEDYDATA:txt}" }    
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
 file {
    path => "/tmp/output-logstash.logs"
  }
}
EOF

chmod 777 var/log/syslog

# https://www.elastic.co/guide/en/logstash/8.5/running-logstash.html
systemctl start logstash.service
