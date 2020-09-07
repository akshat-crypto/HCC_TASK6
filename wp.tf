resource "null_resource" "startminikube" {
    provisioner "local-exec" {
        command = "minikube start"
    }
}

provider "kubernetes" {
    config_context_cluster = "minikube"
}

resource "kubernetes_deployment" "wordpress" {
    metadata {
        name = "wordpress"
    }
    spec {
        replicas = 3
        selector {
            match_labels = {
                region = "IN"
                app = "wp"
            }
        }
        template {
            metadata {
                labels = {
                    region = "IN"
                    app = "wp"
                }
            }
            spec {
                container {
                    image = "wordpress:5.5-php7.2-apache"
                    name = "wp"
                }
            }
        }
    }
}

resource "kubernetes_service" "wplb" {
    metadata {
        name = "wplb"
    }
    spec {
        selector = {
            app = "wp"
        }
        port {
            protocol = "TCP"
            port = 80
            target_port = 80
        }
        type = "NodePort"
    }
}