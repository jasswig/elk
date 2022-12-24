resource "docker_image" "builder" {
  name = "hello-world"
  build {
    path = "../hello-world"
    target = "prod"
    dockerfile = "dockerfile"
    
    }
#  triggers = {
#    dir_sha1 = sha1(join("", [for f in fileset(path.module, "../hello-world/src/*") : filesha1(f)]))
#  }
}


resource "docker_network" "private_network" {
  name = "hello-world-challenge_elastic"
  driver = "bridge"
  attachable = true
}