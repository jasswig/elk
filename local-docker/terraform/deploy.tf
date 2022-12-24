resource "docker_container" "hello_world_app" {
  image = "${docker_image.builder.name}:latest" 
  name  = docker_image.builder.name
  restart = "always"
  start = true
  env = var.env-var
  volumes {
    container_path  = "/wip"
    # replace the host_path with full path for your project directory starting from root directory /
    host_path = "/Users/Jaskaran.Singh/Downloads/github/elk/local-docker/hello-world/src" 
    read_only = false
  }
  ports {
    internal = 5000
    external = 5002
  }
  ports {
    internal = 22
  }
  networks_advanced {
    name = docker_network.private_network.name
  }
}

