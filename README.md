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

## Lesson 17 : _Docker-образы. Микросервисы._

Сделано:
 + Запуск разбитого на микросервисы приложения.
 + Работа на удаленном Docker хосте (*Мне пришлось пересоздавать аккаунт Yandex Cloud*)
 + Выполенение задания со звездочкой.

Сборка наших образов с свервисми. Докер файлы обновлены.
Выполняем команду `docker build -t felitsia/post:1.0 ./post-py` в каталоге `src`.

<details closed>
<summary>Результат выполнения команды</summary>
<br>

```
(1/19) Purging build-base (0.4-r1)
(2/19) Purging make (4.1-r1)
(3/19) Purging fortify-headers (0.8-r0)
(4/19) Purging g++ (5.3.0-r0)
(5/19) Purging gcc (5.3.0-r0)
(6/19) Purging binutils (2.26-r1)
(7/19) Purging isl (0.14.1-r0)
(8/19) Purging libatomic (5.3.0-r0)
(9/19) Purging pkgconfig (0.25-r1)
(10/19) Purging pkgconf (0.9.12-r0)
(11/19) Purging libc-dev (0.7-r0)
(12/19) Purging musl-dev (1.1.14-r16)
(13/19) Purging libstdc++ (5.3.0-r0)
(14/19) Purging binutils-libs (2.26-r1)
(15/19) Purging mpc1 (1.0.3-r0)
(16/19) Purging mpfr3 (3.1.2-r0)
(17/19) Purging gmp (6.1.0-r0)
(18/19) Purging libgomp (5.3.0-r0)
(19/19) Purging libgcc (5.3.0-r0)
Executing busybox-1.24.2-r13.trigger
OK: 31 MiB in 33 packages
Removing intermediate container d11c8ee3c34b
 ---> f3e49f2af689
Step 5/7 : ENV POST_DATABASE_HOST post_db
 ---> Running in 252b2480ddf7
Removing intermediate container 252b2480ddf7
 ---> 4db3ba2df69b
Step 6/7 : ENV POST_DATABASE posts
 ---> Running in 061f131bf892
Removing intermediate container 061f131bf892
 ---> 9bd398c9c40e
Step 7/7 : ENTRYPOINT ["python3", "post_app.py"]
 ---> Running in fe849dcf000c
Removing intermediate container fe849dcf000c
 ---> 9c4ae23f3763
Successfully built 9c4ae23f3763
Successfully tagged felitsia/post:1.0
```
</details>

Выполняем команду `docker build -t felitsia/comment:1.0 ./comment` в каталоге `src`.

<details closed>
<summary>Результат выполнения команды</summary>
<br>

```
Sending build context to Docker daemon  14.85kB
Step 1/11 : FROM ruby:2.2
2.2: Pulling from library/ruby
3d77ce4481b1: Pull complete
534514c83d69: Pull complete
d562b1c3ac3f: Pull complete
4b85e68dc01d: Pull complete
52134d825d3e: Pull complete
b2262ff3b75c: Pull complete
4d1332abe17f: Pull complete
Digest: sha256:4987b5e2f03b7086c493208ef616b711fe73228391a80faf451975f9e0195236
Status: Downloaded newer image for ruby:2.2
 ---> 6c8e6f9667b2
Step 2/11 : RUN apt-get update -qq && apt-get install -y build-essential
 ---> Running in 41b82957a0c4
Reading package lists...
Building dependency tree...
Reading state information...
The following extra packages will be installed:
  dpkg-dev fakeroot libalgorithm-diff-perl libalgorithm-diff-xs-perl
  libalgorithm-merge-perl libdpkg-perl libfakeroot libfile-fcntllock-perl
  libtimedate-perl
Suggested packages:
  debian-keyring
The following NEW packages will be installed:
  build-essential dpkg-dev fakeroot libalgorithm-diff-perl
  libalgorithm-diff-xs-perl libalgorithm-merge-perl libdpkg-perl libfakeroot
  libfile-fcntllock-perl libtimedate-perl
0 upgraded, 10 newly installed, 0 to remove and 162 not upgraded.
Need to get 2916 kB of archives.
*** Здесь было много информации об установке ***
Removing intermediate container 41b82957a0c4
 ---> 39b21a63082a
Step 3/11 : ENV APP_HOME /app
 ---> Running in 40a056d74c54
Removing intermediate container 40a056d74c54
 ---> 17651a46d198
Step 4/11 : RUN mkdir $APP_HOME
 ---> Running in 27ac59835a60
Removing intermediate container 27ac59835a60
 ---> b7eff47f37b2
Step 5/11 : WORKDIR $APP_HOME
 ---> Running in 5f0ab0c8d786
Removing intermediate container 5f0ab0c8d786
 ---> 088a7e931b30
Step 6/11 : ADD Gemfile* $APP_HOME/
 ---> 673a4601987b
Step 7/11 : RUN bundle install
 ---> Running in 9f185dc47fd5
*** Здесь было много информации об установке ***
Bundle complete! 8 Gemfile dependencies, 19 gems now installed.
Bundled gems are installed into `/usr/local/bundle`
Removing intermediate container 9f185dc47fd5
 ---> 66c02288b8de
Step 8/11 : ADD . $APP_HOME
 ---> 85d6dc4bef7c
Step 9/11 : ENV COMMENT_DATABASE_HOST comment_db
 ---> Running in 0204b631b51a
Removing intermediate container 0204b631b51a
 ---> 1376b60fe4d0
Step 10/11 : ENV COMMENT_DATABASE comments
 ---> Running in 14b1db7513be
Removing intermediate container 14b1db7513be
 ---> a9e0cc591cfd
Step 11/11 : CMD ["puma"]
 ---> Running in 2c4bb922a1a3
Removing intermediate container 2c4bb922a1a3
 ---> 54c9cacf2004
Successfully built 54c9cacf2004
```
</details>

Выполняем команду `docker build -t felitsia/ui:1.0 ./ui` в каталоге `src`.
Стоит отметить что Docker файл сразу обновленный.

<details closed>
<summary>Результат выполнения команды</summary>
<br>

```
Sending build context to Docker daemon  30.72kB
Step 1/13 : FROM ubuntu:16.04
16.04: Pulling from library/ubuntu
61e03ba1d414: Pull complete
4afb39f216bd: Pull complete
e489abdc9f90: Pull complete
999fff7bcc24: Pull complete
Digest: sha256:6aab78d1825b4c15c159fecc62b8eef4fdf0c693a15aace3a605ad44e5e2df0c
Status: Downloaded newer image for ubuntu:16.04
 ---> 065cf14a189c
Step 2/13 : RUN apt-get update     && apt-get install -y ruby-full ruby-dev build-essential     && gem install bundler --no-ri --no-rdoc
 ---> Running in 8be3db2d6514

The following additional packages will be installed:
  binutils bzip2 ca-certificates cpp cpp-5 dpkg-dev...
*** Здесь было много информации об установке ***
Suggested packages:
  binutils-doc bzip2-doc cpp-doc gcc-5-locales ...
*** Здесь было много информации об установке ***
0 upgraded, 106 newly installed, 0 to remove and 0 not upgraded.
Need to get 65.9 MB of archives.
After this operation, 281 MB of additional disk space will be used.
*** Здесь было много информации об установке ***
129 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
Successfully installed bundler-2.2.21
1 gem installed
Removing intermediate container 8be3db2d6514
 ---> 6f1c0e3b87ba
Step 3/13 : ENV APP_HOME /app
 ---> Running in 9e197bdb3d07
Removing intermediate container 9e197bdb3d07
 ---> b01b91a64207
Step 4/13 : RUN mkdir $APP_HOME
 ---> Running in 840259bad9c5
Removing intermediate container 840259bad9c5
 ---> 8d9709b84ead
Step 5/13 : WORKDIR $APP_HOME
 ---> Running in e9140de3d692
Removing intermediate container e9140de3d692
 ---> 18cefb050056
Step 6/13 : ADD Gemfile* $APP_HOME/
 ---> 387ebe2091e6
Step 7/13 : RUN bundle install
 ---> Running in 8624bf6b081e
Don't run Bundler as root. Bundler can ask for sudo if it is needed, and
installing your bundle as root will break this application for all non-root
users on this machine.
*** Здесь было много информации об установке ***
Removing intermediate container 8624bf6b081e
 ---> 6c664ec412f9
Step 8/13 : ADD . $APP_HOME
 ---> 07c720c372d5
Step 9/13 : ENV POST_SERVICE_HOST post
 ---> Running in b023fde37559
Removing intermediate container b023fde37559
 ---> 0119f670db5e
Step 10/13 : ENV POST_SERVICE_PORT 5000
 ---> Running in 01b1954e9cc8
Removing intermediate container 01b1954e9cc8
 ---> 6e25c2507014
Step 11/13 : ENV COMMENT_SERVICE_HOST comment
 ---> Running in a4f73272bb68
Removing intermediate container a4f73272bb68
 ---> d5c28c5b87d2
Step 12/13 : ENV COMMENT_SERVICE_PORT 9292
 ---> Running in 0eb0a0f4b675
Removing intermediate container 0eb0a0f4b675
 ---> bedba7029f52
Step 13/13 : CMD ["puma"]
 ---> Running in 9787e58892a5
Removing intermediate container 9787e58892a5
 ---> 8f55256b974a
Successfully built 8f55256b974a
Successfully tagged felitsia/ui:1.0
```
</details>

<details open>
<summary>Конечный список образов</summary>
<br>

```
REPOSITORY         TAG            IMAGE ID       CREATED          SIZE
felitsia/ui        1.0            8f55256b974a   7 minutes ago    462MB
felitsia/comment   1.0            54c9cacf2004   11 minutes ago   769MB
felitsia/post      1.0            9c4ae23f3763   19 minutes ago   111MB
<none>             <none>         a07bb0c31398   23 minutes ago   88.6MB
mongo              latest         0e120e3fce9a   5 days ago       449MB
ubuntu             16.04          065cf14a189c   11 days ago      135MB
ruby               2.2            6c8e6f9667b2   3 years ago      715MB
python             3.6.0-alpine   cb178ebbf0f2   4 years ago      88.6MB
```
</details>

---
