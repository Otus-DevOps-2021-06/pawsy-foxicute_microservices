## Denis Yusupov Microservices_Repository

## Lesson 16 : _Docker контейнеры. Docker под капотом_
Сделано:
 + Установка докера
 + Запуск образа на докере Ubuntu 18.04
 + Работа с командами Docker'a
 + Установка `docker-machine`
 + Создание докер хоста
 + Работа с Docker Hub
 + Создание образа с докером с помощью `Ansible` и `Packer`
 + Создание любое кол-во инстансов с помощью `Terraform` и готового образа.
 + Deploy приложения на всех созданых инстансов.


Информация о докере:
<details open>
<summary>Информация о версии Docker'a</summary>
<br>

```
Client: Docker Engine - Community
 Version:           20.10.7
 API version:       1.41
 Go version:        go1.13.15
 Git commit:        f0df350
 Built:             Wed Jun  2 11:56:38 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          20.10.7
  API version:      1.41 (minimum version 1.12)
  Go version:       go1.13.15
  Git commit:       b0f5bc3
  Built:            Wed Jun  2 11:54:50 2021
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.6
  GitCommit:        d71fcd7d8303cbf684402823e425e9dd2e99285d
 runc:
  Version:          1.0.0-rc95
  GitCommit:        b9ee9c6314599f1b4a7f497e1f1f856fe433d3b7
 docker-init:
  Version:          0.19.0
```
</details>

Результат команды `docker images` после команды `sudo docker commit 75465d89ebaa docker-monolith/docker-1.log`

```
REPOSITORY                     TAG       IMAGE ID       CREATED          SIZE
docker-monolith/docker-1.log   latest    d87014e4b62e   24 seconds ago   63.1MB
ubuntu                         18.04     7d0d8fa37224   10 days ago      63.1MB
hello-world                    latest    d1165f221234   3 months ago     13.3kB
```
Цитата из файлы `./pawsy-foxicute_microservices/dockermonolith/docker-1.log`

> + Образ это state который состоит из слоев файловой системы.
> + Образ состоит из слоев которые в режиме read-only.
> + Из образов создаются экзмемпляры контейнеров.
> + Контейнер это слой над обраом в который можно записывать изменения.
> + Контейнер можно закомитеть и он станет образом с режимом чтения.

Установка `docker-machine`. Версия:

```
docker-machine version 0.16.0, build 702c267f
```

<details open>
<summary>Создание инстанса в YC</summary>
<br>

```
yc compute instance create \
>   --name docker-host \
>   --zone ru-central1-a \
>   --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
>   --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
>   --ssh-key ~/.ssh/yandex-cloud.pub
```

Проверка статуса машины:

```
yc compute instance list
+----------------------+-------------+---------------+---------+----------------+-------------+
|          ID          |    NAME     |    ZONE ID    | STATUS  |  EXTERNAL IP   | INTERNAL IP |
+----------------------+-------------+---------------+---------+----------------+-------------+
| fhmmcj7iihque659k1r8 | docker-host | ru-central1-a | RUNNING | 217.28.231.152 | 10.128.0.28 |
+----------------------+-------------+---------------+---------+----------------+-------------+
```
</details>

<details open>
<summary>Создание Docker хоста в YC</summary>
<br>

```
docker-machine create \
  --driver generic \
  --generic-ip-address=217.28.231.152 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/yandex-cloud \
  docker-host
```
</details>

Проверка создания Docker machine командой `docker-machine ls`

```
NAME          ACTIVE   DRIVER    STATE     URL                         SWARM   DOCKER     ERRORS
docker-host   *        generic   Running   tcp://217.28.231.152:2376           v20.10.7
```

После регистрации тегаем образ и пушим его в Docker Hub.

```
docker tag reddit:latest felitsia/otus-reddit:1.0
docker push felitsia/otus-reddit:1.0
```
В папке `./docker-monolith/infra`

Имеется вся конфигурация:
`./docker-monolith/infra/ansible/playbooks/docker-for-packer.yml` playbook по созданию VM c докером, нужен для packer'a.

`./docker-monolith/infra/ansible/playbooks/up-docker.yml` playbook для поднятия контейнера с образом full-reddit.

<details closed>
<summary>Выполнение создания образа с помощью Packer'a и Ansible</summary>
<br>

```
==> yandex: Creating temporary ssh key for instance...
==> yandex: Using as source image: fd83klic6c8gfgi40urb (name: "ubuntu-2004-lts-1623345129", family: "ubuntu-2004-lts")
==> yandex: Use provided subnet id e9bmfnr0jifjdfrff2n4
==> yandex: Creating disk...
==> yandex: Creating instance...
==> yandex: Waiting for instance with id fhm9gb02ej2cfofjs8tj to become active...
    yandex: Detected instance IP: 178.154.206.223
==> yandex: Using SSH communicator to connect: 178.154.206.223
==> yandex: Waiting for SSH to become available...
==> yandex: Connected to SSH!
==> yandex: Provisioning with Ansible...
    yandex: Setting up proxy adapter for Ansible....
==> yandex: Executing Ansible: ansible-playbook -e packer_build_name="yandex" -e packer_builder_type=yandex --ssh-extra-args '-o IdentitiesOnly=yes' -e ansible_ssh_private_key_file=/tmp/ansible-key830690945 -i /tmp/packer-provisioner-ansible476259820 /home/pawsy/pawsy-foxicute_microservices/docker-monolith/infra/ansible/playbooks/docker-for-packer.yml
    yandex:
    yandex: PLAY [all] *********************************************************************
    yandex:
    yandex: TASK [Gathering Facts] *********************************************************
    yandex: ok: [default]
    yandex:
    yandex: TASK [Update apt cache] ********************************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Upgrade all apt packages] ************************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Install dependencies] ****************************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Add an apt signing key for Docker] ***************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Add apt repository for stable version] ***********************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Install Docker] **********************************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Add user to the docker group.] *******************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Install pip dependencies] ************************************************
    yandex: changed: [default]
    yandex:
    yandex: TASK [Ensure pip is updated] ***************************************************
    yandex: ok: [default]
    yandex:
    yandex: TASK [Install pip packages for docker-compose] *********************************
    yandex: changed: [default]
    yandex:
    yandex: PLAY RECAP *********************************************************************
    yandex: default                    : ok=11   changed=9    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    yandex:
==> yandex: Stopping instance...
==> yandex: Deleting instance...
    yandex: Instance has been deleted!
==> yandex: Creating image: docker-1624916400
==> yandex: Waiting for image to complete...
==> yandex: Success image create...
==> yandex: Destroying boot disk...
    yandex: Disk has been deleted!
Build 'yandex' finished after 9 minutes 55 seconds.

==> Wait completed after 9 minutes 55 seconds

==> Builds finished. The artifacts of successful builds are:
--> yandex: A disk image was created: docker-1624916400 (id: fd8psi86rd4o8ah7s764) with family name docker-base
```
</details>

Создание с помощью Terraform инстансов, кол-во VM указывается в файле `docker-monolith/infra/terraform/docker/terraform.tfvars`, поле `node_count`.

<details open>
<summary>Результат выполнения работы Terraform</summary>
<br>

```
yandex_compute_instance.docker[0]: Creating...
yandex_compute_instance.docker[1]: Creating...
yandex_compute_instance.docker[2]: Creating...
yandex_compute_instance.docker[0]: Still creating... [10s elapsed]
yandex_compute_instance.docker[1]: Still creating... [10s elapsed]
yandex_compute_instance.docker[2]: Still creating... [10s elapsed]
yandex_compute_instance.docker[0]: Still creating... [20s elapsed]
yandex_compute_instance.docker[1]: Still creating... [20s elapsed]
yandex_compute_instance.docker[2]: Still creating... [20s elapsed]
yandex_compute_instance.docker[0]: Still creating... [30s elapsed]
yandex_compute_instance.docker[1]: Still creating... [30s elapsed]
yandex_compute_instance.docker[2]: Still creating... [30s elapsed]
yandex_compute_instance.docker[0]: Still creating... [40s elapsed]
yandex_compute_instance.docker[1]: Still creating... [40s elapsed]
yandex_compute_instance.docker[2]: Still creating... [40s elapsed]
yandex_compute_instance.docker[0]: Still creating... [50s elapsed]
yandex_compute_instance.docker[1]: Still creating... [50s elapsed]
yandex_compute_instance.docker[2]: Still creating... [50s elapsed]
yandex_compute_instance.docker[0]: Still creating... [1m0s elapsed]
yandex_compute_instance.docker[1]: Still creating... [1m0s elapsed]
yandex_compute_instance.docker[2]: Still creating... [1m0s elapsed]
yandex_compute_instance.docker[0]: Still creating... [1m10s elapsed]
yandex_compute_instance.docker[1]: Still creating... [1m10s elapsed]
yandex_compute_instance.docker[2]: Still creating... [1m10s elapsed]
yandex_compute_instance.docker[1]: Creation complete after 1m11s [id=fhm3v1ohqmvs1pqm9pht]
yandex_compute_instance.docker[2]: Creation complete after 1m11s [id=fhm5hsojmusp01m7qgid]
yandex_compute_instance.docker[0]: Creation complete after 1m12s [id=fhmarhhqv24bvjq42oh5]

Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_docker = [
  "178.154.205.183",
  "84.252.131.84",
  "84.252.128.206",
]
```
</details>

Поднятие образов прошло успешно. VM будут для проверки работать какое-то время.

<details open>
<summary>Результат плейбука по поднятию контейнеров</summary>
<br>

```
PLAY [Install Docker Container] *******************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************
ok: [docker1]
ok: [docker2]
ok: [docker3]

TASK [Start reddit docker container] *******************************************************************************************************
--- before
+++ after
@@ -1,4 +1,4 @@
 {
-    "exists": false,
-    "running": false
+    "exists": true,
+    "running": true
 }

changed: [docker1]
--- before
+++ after
@@ -1,4 +1,4 @@
 {
-    "exists": false,
-    "running": false
+    "exists": true,
+    "running": true
 }

changed: [docker2]
--- before
+++ after
@@ -1,4 +1,4 @@
 {
-    "exists": false,
-    "running": false
+    "exists": true,
+    "running": true
 }

changed: [docker3]

PLAY RECAP
*******************************************************************************************************
docker1                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
docker2                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
docker3                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
</details>
---
