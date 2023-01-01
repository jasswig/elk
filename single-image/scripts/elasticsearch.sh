#! /bin/bash

exec >> /var/log/elasticsearch.log 2>&1

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

# kibana
yum install kibana-$VERSION.$(arch) -y 
cp /etc/kibana/kibana.yml /etc/kibana/kibana_backup.yml

cat <<EOF > /etc/kibana/kibana.yml 
server.port: 5601
server.host: "0.0.0.0"
server.ssl.enabled: false
elasticsearch.hosts: ["http://localhost:9200"]
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
