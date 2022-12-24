# ELK local docker etc.

## Pre-requisite:
- Docker, docker-compose should be running on the host
- Terraform should be installed on the host
- Ansible should be installed on the host (to run it locally)


### All apps are running in docker
- Sample app (flask app) - installed using terraform (check terraform folder - creating network, building and deploying container), with environment variable `HW_ENV_VAR` displayed in UI
- elasticsearch, kibana, filebeat, logstash installed in same docker network
- hw-kibana-update python script to update/create index patterns, search, dashboard using saved_objects
- `ansible installed in same docker network, but not working as expected`
- Now running ansible in local

### Ansible:
1. docker exec -it ansible /bin/sh
2. `Able to ping other host (Enter password=test, when prompted)` ansible default -i hosts -u test -m ping -k -b
3. `Able to run command like hostname (Enter password = test)` ansible-playbook -i hosts test.yml -k -b -vvvv (It's able to ping back the container id of the hello-world app container)
4. Getting error on trying to use docker_container plugin ansible-playbook -i hosts main.yml -k -b -vvvv : `fatal: [hello-world]: FAILED! => {"changed": false, "msg": "Error connecting: Error while fetching server API version: ('Connection aborted.', FileNotFoundError(2, 'No such file or directory'))"}` Full [log](./ansible_error.log) attached for reference
5. Ansible should be installed on host, Running ansible locally to update the variables.tf file, where environment variable is stored, and then running tf again to re-deploy the container.

### Steps to start the exercise:

1. In the project folder execute: `make up` 
2. Apps: Sample python app (flask app), accessible on [localhost:5002](http://localhost:5002/)
3. Kibana, accessible on [localhost:5601](http://localhost:5601/)
4. To re-install/install index_patterns, search, dashboard execute: `make update-kibana`
5. Search [link](http://localhost:5601/app/discover#/view/hello-world-search?_g=(filters%3A!()%2CrefreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-7d%2Cto%3Anow)))
6. Dashboard [link](http://localhost:5601/app/dashboards#/view/hello-world-dashboard?_g=(filters%3A!()%2Cquery%3A(language%3Akuery%2Cquery%3A'')%2CrefreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-7d%2Cto%3Anow))) 
7. Update environment variable `make update-env`
8. To destroy all. execute: `make down`

