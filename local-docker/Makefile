plan:
	terraform -chdir=./terraform init
	terraform -chdir=./terraform plan
up:
	terraform -chdir=./terraform init
	terraform -chdir=./terraform apply -auto-approve
	docker-compose up  hw-filebeat hw-logstash hw-es01 hw-es02 hw-kibana hw-ansible -d
down:
	docker-compose rm -s -v -f hw-filebeat hw-logstash hw-es01 hw-es02 hw-kibana hw-ansible hw-kibana-update
	terraform -chdir=./terraform destroy -auto-approve
update-kibana:
	docker-compose up hw-kibana-update
update-env:
	ansible-playbook ./ansible/local.yml
	terraform -chdir=./terraform apply -auto-approve
