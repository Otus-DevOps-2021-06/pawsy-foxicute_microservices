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

## Lesson 17 : _Docker: сети. Docker-compose._

Сделано:
 + Работа с сетями _none, host, bridge_
 + Работа с Docker-compose

<details closed>
<summary>Установка контейнера joffotron/docker-net-tools</summary>
<br>

```
Unable to find image 'joffotron/docker-net-tools:latest' locally
latest: Pulling from joffotron/docker-net-tools
3690ec4760f9: Pull complete
0905b79e95dc: Pull complete
Digest: sha256:5752abdc4351a75e9daec681c1a6babfec03b317b273fc56f953592e6218d5b5
Status: Downloaded newer image for joffotron/docker-net-tools:latest
```
</details>

Результат команды `docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig`

```
lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```

Результат команды `docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig`

Появились виртуальные интерфейсы `docker0` нужен для общения между контейнерами и `eth0` для выхода не внешку.

<details closed>
<summary> Интерфейсы </summary>
<br>

```
docker0   Link encap:Ethernet  HWaddr 02:42:F2:8F:81:2B
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:f2ff:fe8f:812b%32748/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:2 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:176 (176.0 B)

eth0      Link encap:Ethernet  HWaddr D0:0D:12:7D:F4:62
          inet addr:10.128.0.7  Bcast:10.128.0.255  Mask:255.255.255.0
          inet6 addr: fe80::d20d:12ff:fe7d:f462%32748/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:102936 errors:0 dropped:0 overruns:0 frame:0
          TX packets:71237 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:133512064 (127.3 MiB)  TX bytes:8429280 (8.0 MiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32748/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:276 errors:0 dropped:0 overruns:0 frame:0
          TX packets:276 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:25178 (24.5 KiB)  TX bytes:25178 (24.5 KiB)
```
</details>

После выполнения команды `docker run --network host -d nginx` 4 раза, рузультат:

```
0dc95b9ce855   nginx     "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes             peaceful_maxwell
```

Думаю проблема в конфликте сети и назначения портов. Поэтому может использоваться один экземпляр контейнера с уникальными какими-то настройками сети.

После выполнения команд `sudo ln -s /var/run/docker/netns /var/run/netns` и `sudo ip netns` начались создаваться экземпляры nginx в любом кол-во только с сетью _bridge_.

```
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS     NAMES
9eb4d66d62c2   nginx     "/docker-entrypoint.…"   2 seconds ago   Up 1 second    80/tcp    hardcore_gould
68093f7dcc7d   nginx     "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp    trusting_shockley
eee74175a0fd   nginx     "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   80/tcp    hungry_carson
1d5919fb5c1a   nginx     "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes   80/tcp    pedantic_bhaskara
d74e46569046   nginx     "/docker-entrypoint.…"   3 minutes ago   Up 3 minutes             hardcore_feynman
```

Установка `docker-compose` только не через `pip`, а через `pip3`.
Версия `docker-compose -v`:

```
docker-compose version 1.29.2, build unknown
```

Выполение комманд `export USERNAME=foxy`,  `docker-compose up -d`, `docker-compose ps`.

```
CONTAINER ID   IMAGE              COMMAND                  CREATED         STATUS         PORTS                                       NAMES
69f373d8286c   mongo:3.2          "docker-entrypoint.s…"   2 minutes ago   Up 2 minutes   27017/tcp                                   src_post_db_1
706763c6f1eb   foxy/ui:1.0        "puma"                   2 minutes ago   Up 2 minutes   0.0.0.0:9292->9292/tcp, :::9292->9292/tcp   src_ui_1
ec05f9e64fe7   foxy/comment:1.0   "puma"                   2 minutes ago   Up 2 minutes                                               src_comment_1
52b4461211bb   foxy/post:1.0      "python3 post_app.py"    2 minutes ago   Up 2 minutes                                               src_post_1
```

Cборка `docker-compose.yml` с отдельным файлом переменных выглядит так `docker-compose --env-file=docker.env up -d`. Нужно указывать путь до файла.

---

## Lesson 20 _Устройство Gitlab CI. Построение процесса непрерывной поставки_

Задание в `infro` репозитории, в будущем будет переделанно.

---

## Lesson 22 _Введение в мониторинг. Системы мониторинга._

Сделано:
 + Создание нового VM, накатка Docker'a, установка контейнера с `Prometheus`.
 + Мониторинг состояния микросервисов.
 + Сбор метрик хоста с использованием экспортера
 + Задания со *
   - Создан Makefile.
   - Добавлен эксплолеры.


После поднятия VM, установки Докера через `docker-machine` поднимам микросервисы командой `docker-compose --env-file=docker-compose.env up -d`.

```
Creating network "docker_backend_network" with the default driver
Creating network "docker_frontend_network" with the default driver
Creating docker_post_db_1          ... done
Creating docker_post_1             ... done
Creating docker_ui_1               ... done
Creating docker_comment_1          ... done
Creating docker_node-exporter_1    ... done
Creating docker_prometheus_1       ... done
Creating docker_mongodb-exporter_1 ... done
```

Добавлен `Makefile` по пути `pawsy-foxicute_microservices/docker/Makefile`.
Файл прокомментирован.

Добавлены эксплолеры смотреть в файле `pawsy-foxicute_microservices/docker/docker-compose.yml`.

Добавлены `job`ы в файле `pawsy-foxicute_microservices/monitoring/prometheus/prometheus.yml`.

---

## Lesson 23 _Мониторинг приложения и инфраструкт фраструктуры_

Сделано:
 + Мониторинг Docker контейнеров с помощью `cAdvisor`
 + Визуализация метрик с помощью `Grafana`
 + Сбор метрик приложения
 + Настройка и проверка алертинга
 + Заданяи со * _Кроме последнего пока что_
 + Добавлен Telegraf

Поднимаем контейнеры:
> `docker-compose up -d`

```
Creating network "docker_backend_network" with the default driver
Creating network "docker_frontend_network" with the default driver
Creating docker_comment_1 ... done
Creating docker_post_db_1 ... done
Creating docker_ui_1      ... done
Creating docker_post_1    ... done
```

> `docker-compose -f docker-compose-monitoring.yml up -d`

```
Creating docker_cadvisor_1      ... done
Creating mongodb-exporter       ... done
Creating docker_node-exporter_1 ... done
Creating docker_prometheus_1    ... done
Creating docker_grafana_1       ... done
```

Смотрим сетевые записи.
> `docker network ls`

```
NETWORK ID     NAME                      DRIVER    SCOPE
20e31a486d31   bridge                    bridge    local
d92bae6632a4   docker_backend_network    bridge    local
23dc20f4a584   docker_default            bridge    local
13e47f705726   docker_frontend_network   bridge    local
87dc18da7b05   docker_prometheus         bridge    local
32466cc754e1   host                      host      local
66fce8bd8822   none                      null      local
```

`Grafana` нужно добавить в группу сети.

```
...
networks:
      prometheus:
```

Был скачен Dashboard [Docker and system monitoring](https://grafana.com/grafana/dashboards/893)

В Grafan'e были созданы дашборды. Есть проблема по остелживанию `Rate of UI HTTP Requests with Error`.

Не один из фильтров метрики не работает:
  + `rate(ui_request_count{http_status=~"[45].."}[1m])`
  + `rate(ui_request_count{http_status=~"^[45].*"}[1m])`


`AlertManager rule` работает, проверить результат можно в чате Slack'a `#denis_yusupov`


Добавление `Telegraf`'a

В `prometheus.yml` добавляем:

```
- job_name: 'telegraf'
    scrape_interval: 10s
    static_configs:
      - targets: ['mynode:9126']
```

В `docker-compose-monitoring.yml` добавляем:

```
telegraf:
    image: telegraf:latest
    container_name: telegraf
    network_mode: "host"
    volumes:
      - ./telegraf.conf:/etc/telegraf/telegraf.conf:ro
    environment:
      INFLUXDB_URI: "http://localhost:8086"
    networks:
      prometheus:
```

---

## Lesson 25 _Логирование и распределенная трассировка_

Сделано:
 + Подготовка окружения
 + Логирование Docker-контейнеров
 + Сбор неструктурированных логов
 + Визуализация логов
 + Сбор структурированных логов
 + Установка и работа с `Zipkin`.
 + Задание со *, найдены ошибки.

Билдим новые образы из [git'a](https://github.com/express42/reddit/tree/logging) и пушим в _Docker Hub_ c тегом `logging`.

Cтавим `goland`.

Добавляем путь `export PATH=/$HOME/go/bin:$PATH` для драйвера в файл `~/.bashrc`.
Создаем переменную в сессии `export SA_KEY_PATH='~/key.json'`. Путь для ключа SA YC.

В конечном итоге был создан docker-machine c драйвером `generic`.

Пример лога из Kibana:

| Time          | Source |
|---------------|--------|
| ``` Jul 4, 2021 @ 17:36:29.000 ``` | ``` container_id:f3f1bb960b163ec0c7969b97bdfbd27773a1b46818d16c370bf72b82a9d4c4bb container_name:/reddit-post source:stdout log:{"addr": "172.20.0.2", "event": "request", "level": "info", "method": "GET", "path": "/healthcheck?", "request_id": null, "response_status": 200, "service": "post", "timestamp": "2021-07-04 13:36:29"} @timestamp:Jul 4, 2021 @ 17:36:29.000 @log_name:service.post _id:N5e8cXoBgixQ_5kZFoJM _type:access_log _index:fluentd-20210704 ``` |

Настройка `grok'ов` шаблонов.

Установка и работа с `Zipkin`.

Все сервисы работают.

```
CONTAINER ID   IMAGE                      COMMAND                  CREATED              STATUS              PORTS                                                                                                    NAMES
88f6e66f31fe   felitsia/ui:logging        "puma"                   About a minute ago   Up About a minute   0.0.0.0:9292->9292/tcp, :::9292->9292/tcp                                                                reddit-front
6fb1ac563440   mongo:3.2                  "docker-entrypoint.s…"   About a minute ago   Up About a minute   27017/tcp                                                                                                mongodb
86c869a3ca7a   felitsia/post:logging      "python3 post_app.py"    About a minute ago   Up About a minute                                                                                                            reddit-post
6e7addd3b336   felitsia/comment:logging   "puma"                   About a minute ago   Up About a minute                                                                                                            reddit-comment
4e60738134d3   felitsia/fluentd:latest    "tini -- /bin/entryp…"   2 minutes ago        Up About a minute   5140/tcp, 0.0.0.0:24224->24224/tcp, 0.0.0.0:24224->24224/udp, :::24224->24224/tcp, :::24224->24224/udp   fluentd
ba31805eb76e   openzipkin/zipkin:2.21.0   "/busybox/sh run.sh"     6 minutes ago        Up 6 minutes        9410/tcp, 0.0.0.0:9411->9411/tcp, :::9411->9411/tcp                                                      zipkin
67dc8d3f57ef   kibana:7.4.0               "/usr/local/bin/dumb…"   6 minutes ago        Up 6 minutes        0.0.0.0:5601->5601/tcp, :::5601->5601/tcp                                                                kibana
1d191c917e7b   elasticsearch:7.4.0        "/usr/local/bin/dock…"   6 minutes ago        Up 6 minutes        0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp
```

Билдим баговые образы, на них будет тег `bug`. Список:

```
REPOSITORY          TAG       IMAGE ID       CREATED          SIZE
felitsia/ui         bug       7d57134ee5b1   27 seconds ago   786MB
felitsia/post       bug       c25159e3485c   2 minutes ago    916MB
felitsia/comment    bug       1fe68ef3a403   3 minutes ago    764MB
```

### Задание со *
Ошибка в логах сервиса `reddit-post`

```
 "event":"internal_error",
   "level":"error",
   "method":"GET",
   "path":"/posts?",
   "remote_addr":"172.18.0.2",
   "request_id":"3d414155-43b5-49c2-8d4d-eebd96e4e92f",
   "service":"post",
   "timestamp":"2021-07-05 08:31:57",
   "traceback":"Traceback (most recent call last):\n  File \"/usr/local/lib/python3.6/site-packages/flask/app.py\", line 1612, in full_dispatch_request\n    rv = self.dispatch_request()\n  File \"/usr/local/lib/python3.6/site-packages/flask/app.py\", line 1598, in dispatch_request\n    return self.view_functions[rule.endpoint](**req.view_args)\n  File \"/app/post_app.py\", line 96, in posts\n    posts = find_posts()\n  File \"/usr/local/lib/python3.6/site-packages/py_zipkin/zipkin.py\", line 296, in __exit__\n    self.stop(_exc_type, _exc_value, _exc_traceback)\n  File \"/usr/local/lib/python3.6/site-packages/py_zipkin/zipkin.py\", line 314, in stop\n    self.logging_context.stop()\n  File \"/usr/local/lib/python3.6/site-packages/py_zipkin/logging_helper.py\", line 76, in stop\n    self.log_spans()\n  File \"/usr/local/lib/python3.6/site-packages/py_zipkin/logging_helper.py\", line 185, in log_spans\n    transport_handler=self.transport_handler,\n  File \"/usr/local/lib/python3.6/site-packages/py_zipkin/logging_helper.py\", line 325, in log_span\n    transport_handler(message)\n  File \"/app/post_app.py\", line 53, in http_transport\n    body = '\\x0c\\x00\\x00\\x00\\x01' + encoded_span\nTypeError: must be str, not bytes\n"
```

Первая ошибка в коде, файл `/app/post_app.py`, метод `def http_transport(encoded_span)` , 53 линия:

`body = '\x0c\x00\x00\x00\x01' + encoded_span` здесь нужно указать явное приведение типов в byte, в итоге приводим все в такой вид `body = b'\x0c\x00\x00\x00\x01' + encoded_span` и пересобираем образ.

Вторая ошибка была в методе c POST запросом `db_find_single_post`, куда ссылается Zipkin.
Методом `time.sleep(3)` приостанавливался поток на 3 секунды.

```
@zipkin_span(service_name='post', span_name='db_find_single_post')
def find_post(id):
    start_time = time.time()
    try:
        post = app.db.find_one({'_id': ObjectId(id)})
    except Exception as e:
        log_event('error', 'post_find',
                  "Failed to find the post. Reason: {}".format(str(e)),
                  request.values)
        abort(500)
    else:
        stop_time = time.time()  # + 0.3
        resp_time = stop_time - start_time
        app.post_read_db_seconds.observe(resp_time)
        time.sleep(3)
        log_event('info', 'post_find',
                  'Successfully found the post information',
                  {'post_id': id})
        return dumps(post)
```

---

## Lesson 27 _Введение в Kubernetes_

Сделано:
 + Поднятие инстансов.
 + Установка Kubernates на все инстансы.
 + Создание Master и Worker нод.
 + Задание со *.
   - Созданы модули в `Terraform` для поднятия определенных типов инстансов под `Kubernates`.
   - Созданы плейбуки для настройки определенных типов инстансов.

Создаем две VM, одна будет `master`, другая `worker` для Kubernates.
MASTER:

```
yc compute instance create \
 --name master-node-1 \
 --zone ru-central1-a \
 --cores=2 --memory=2 \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
 --ssh-key ~/.ssh/yandex-cloud.pub
```

WORKER:

```
yc compute instance create \
 --name worker-node-1 \
 --zone ru-central1-a \
 --cores=2 --memory=2 \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
 --ssh-key ~/.ssh/yandex-cloud.pub
```

Переходим по SSH в master ноду и [ставим kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). Но для начала на VM надо [установить Docker](https://docs.docker.com/engine/install/ubuntu/). Или поставить Docker, через docker-machine.

На мастер ноду ставим: `kubelet kubeadm kubectl`.
На воркер ноду ставим: `kubelet kubeadm`.

>` kubeadm` — инструмент командной строки, который устанавливает и настраивает различные компоненты кластера стандартным образом.
> `kubelet` — системная служба / программа, которая работает на всех узлах и обрабатывает операции на уровне узлов.
> `kubectl` — инструмент командной строки, используемый для отправки команд на кластер через сервер API.

После установки трех компонентов Kuber'a запускаем команду:

```
sudo kubeadm init --apiserver-cert-extra-sans=178.154.224.211 --apiserver-advertise-address=0.0.0.0 --control-plane-endpoint=178.154.224.211 --pod-network-cidr=10.244.0.0/16
```

После успешной установки получим сообщение о настройке использования кластера.

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities
and service account keys on each node and then running the following as root:

kubeadm join 178.154.224.211:6443 --token ce31vc.dtsl1x476vo3rczq \
        --discovery-token-ca-cert-hash
        sha256:e3c28e9f831794c279a3877****************************************** \
        --control-plane

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 178.154.224.211:6443 --token ce31vc.dtsl1x476vo3rczq \
        --discovery-token-ca-cert-hash sha256:e3c28e9f831794c279a3877*******************************************

```

Делаем аналогичную установку на Worker ноде, за исключением что не ставим `kubectl`.

Не делаем инициализацию. Джоиним воркер ноду с мастером:

```
sudo kubeadm join 178.154.224.211:6443 --token ce31vc.dtsl1x476vo3rczq \
        --discovery-token-ca-cert-hash sha256:e3c28e9f831794c279a38773******************************************
```

Скачиваем `calico.yaml`меняем значение `CALICO_IPV4POOL_CIDR` на `10.244.0.0/16`.
Получаем статус нод:

```
NAME                   STATUS   ROLES                  AGE    VERSION
fhm8m0t9k9ogrlq59s75   Ready    <none>                 25m    v1.21.2
fhmjnt1farqiimi3l37c   Ready    control-plane,master   103m   v1.21.2
yc-user@fhmjnt1farqiimi3l37c:~$
```

С помощью `Terraform` автоматизируем создание инстансов.
Можно создавать любое кол-во master'ов worker'ов и кластерных init'ов.
В моем случае 1 init, 1 master, 2 worker.


```
module.init[0].yandex_compute_instance.init: Creating...
module.worker[1].yandex_compute_instance.worker: Creating...
module.master[0].yandex_compute_instance.master: Creating...
module.worker[0].yandex_compute_instance.worker: Creating...
module.worker[1].yandex_compute_instance.worker: Still creating... [10s elapsed]
module.init[0].yandex_compute_instance.init: Still creating... [10s elapsed]
module.master[0].yandex_compute_instance.master: Still creating... [10s elapsed]
module.worker[0].yandex_compute_instance.worker: Still creating... [10s elapsed]
module.worker[1].yandex_compute_instance.worker: Still creating... [20s elapsed]
module.init[0].yandex_compute_instance.init: Still creating... [20s elapsed]
module.master[0].yandex_compute_instance.master: Still creating... [20s elapsed]
module.worker[0].yandex_compute_instance.worker: Still creating... [20s elapsed]
module.worker[1].yandex_compute_instance.worker: Creation complete after 23s [id=fhm6kr7lgmnd0mms7nh9]
module.worker[0].yandex_compute_instance.worker: Creation complete after 23s [id=fhmrc4j7s47ciu13jc0k]
module.init[0].yandex_compute_instance.init: Creation complete after 24s [id=fhmefd52mp55ven7jtpc]
module.master[0].yandex_compute_instance.master: Creation complete after 26s [id=fhm5jpmu6i2594q7pb7k]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

Ансибл плейбуки созданы, но не проверенны. Есть роли для настройки init хоста, а также мастер и воркер хоста.
Есть общий плейбук для установки Docker на все хосты.

---

## Lesson 28 _Kubernetes. Запуск кластера и приложения. Модель безопасности_

Сделано:
 + Создан инстанс в YC для Kubernates.
 + На инстансе установлен Docker через docker-machine.
 + Установка `kubectl` и `minikube`.
 + Разворачивание Kubernates в облаке.
 + Задание со *.


Установка `kubectl` была осуществленна первым способ с [офф. сайта](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/).

Устновка VirtualBox'a была с локального репозитория. Версия:

```
5.2.42_Ubuntur137960
```

Так как на облаке нет поддержки VT-X/AMD-v, ставим Minikube через Docker driver.
Но для начала добаим пользователя в группе `docker` и ребутним сервер.

```
sudo groupadd docker
sudo usermod -aG docker $USER
```

```
minikube start --driver=docker --kubernetes-version 1.19.7
```

Установка Minikube:

<details closed>
<summary> Результат установки </summary>
<br>

```
😄  minikube v1.21.0 on Ubuntu 18.04 (vbox/amd64)
✨  Using the docker driver based on user configuration

🧯  The requested memory allocation of 1992MiB does not leave room for system overhead (total system memory: 1992MiB). You may face stability issues.
💡  Suggestion: Start minikube with less memory allocated: 'minikube start --memory=1992mb'

👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
    > gcr.io/k8s-minikube/kicbase...: 359.09 MiB / 359.09 MiB  100.00% 12.86 Mi
🔥  Creating docker container (CPUs=2, Memory=1992MB) ...
🐳  Preparing Kubernetes v1.19.7 on Docker 20.10.7 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: default-storageclass

❗  /usr/local/bin/kubectl is version 1.21.2, which may have incompatibilites with Kubernetes 1.19.7.
    ▪ Want kubectl v1.19.7? Try 'minikube kubectl -- get pods -A'
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```
</details>

Проверяем запущенные контейнеры командой `docker ps`.

```
CONTAINER ID   IMAGE                                 COMMAND                  CREATED              STATUS              PORTS                                                                                                                                  NAMES
d92a105a4512   gcr.io/k8s-minikube/kicbase:v0.0.23   "/usr/local/bin/entr…"   About a minute ago   Up About a minute   127.0.0.1:49157->22/tcp, 127.0.0.1:49156->2376/tcp, 127.0.0.1:49155->5000/tcp, 127.0.0.1:49154->8443/tcp, 127.0.0.1:49153->32443/tcp   minikube
```

Проверяем ноды `kubectl get nodes` :

```
NAME       STATUS   ROLES    AGE     VERSION
minikube   Ready    master   3m24s   v1.19.7
```

Создаем свой кластер и настраиваем контекст:

```
kubectl config set-cluster foxy-cluster
kubectl config set-credentials foxy

kubectl config set-context foxy-context \
 --cluster=foxy-cluster \
 --user=foxy

Context "context_name" created.
```

Создаем POD'ы:

```
kubectl apply -f ui-deployment.yml
```

Смотрим статус `kubectl get deployments`:

```
NAME   READY   UP-TO-DATE   AVAILABLE   AGE
ui     3/3     3            3           10m
```

Список подов `kubectl get pods`:

```
NAME                  READY   STATUS    RESTARTS   AGE
ui-5df49d4cb4-2rj42   1/1     Running   0          84s
ui-5df49d4cb4-nxm6q   1/1     Running   0          2m17s
ui-5df49d4cb4-xd5wt   1/1     Running   0          90s
yc-user@kubernates:~/pods$
```

Поднятие кластера и нодов на обалке.
Список нод в докерах:

```
NAME                        STATUS   ROLES    AGE   VERSION    INTERNAL-IP   EXTERNAL-IP     OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
cl1riji54gqj4lgp4jv6-ajyh   Ready    <none>   45m   v1.19.10   10.129.0.23   84.252.141.26   Ubuntu 20.04.2 LTS   5.4.0-72-generic   docker://20.10.6
cl1riji54gqj4lgp4jv6-upin   Ready    <none>   45m   v1.19.10   10.129.0.4    84.252.137.24   Ubuntu 20.04.2 LTS   5.4.0-72-generic   docker://20.10.6
```

Работа подов и сервисов на облаке (скрин есть):

```
pawsy@foxy-server:~$ kubectl get pods -n dev
NAME                      READY   STATUS    RESTARTS   AGE
comment-549b6d77c-6x9j7   1/1     Running   0          3m11s
mongo-6b9fcfd49f-x5kx7    1/1     Running   0          3m9s
post-7b6d4d87b5-tnjwf     1/1     Running   0          3m8s
ui-78f45df854-7bsz4       1/1     Running   0          3m6s
ui-78f45df854-bzq7l       1/1     Running   0          3m6s
ui-78f45df854-rpljq       1/1     Running   0          3m6s

pawsy@foxy-server:~$ kubectl get service -n dev
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
comment      ClusterIP   10.96.251.179   <none>        9292/TCP         30s
comment-db   ClusterIP   10.96.233.192   <none>        27017/TCP        31s
mongodb      ClusterIP   10.96.182.170   <none>        27017/TCP        28s
post         ClusterIP   10.96.202.149   <none>        5000/TCP         26s
post-db      ClusterIP   10.96.238.77    <none>        27017/TCP        27s
ui           NodePort    10.96.174.174   <none>        9292:31963/TCP   25s
```

---

## Lesson 29 _Kubernetes. Networks, Storages._

Сделано:
 + Работа с Kuberantes в YC.
 + Работа с Ingress, LoadBalancer, Secrets, NetworkPolicy и др.
 + Работа с Volume, VolumePerstince, VolumePerstinceClaim.

Создан сертификат в виде манифеста `pawsy-foxicute_microservices/kubernetes/reddit/secret.yaml`.

Создаем LoadBalancer:
```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl get services -n dev -o wide
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE   SELECTOR
comment      ClusterIP      10.96.128.57    <none>           9292/TCP       64m   app=reddit,component=comment
comment-db   ClusterIP      10.96.143.166   <none>           27017/TCP      64m   app=reddit,comment-db=true,component=mongo
mongodb      ClusterIP      10.96.236.138   <none>           27017/TCP      64m   app=reddit,component=mongo
post         ClusterIP      10.96.236.83    <none>           5000/TCP       64m   app=reddit,component=post
post-db      ClusterIP      10.96.239.91    <none>           27017/TCP      64m   app=reddit,component=mongo,post-db=true
ui           LoadBalancer   10.96.133.181   84.201.167.201   80:31380/TCP   14m   app=reddit,component=ui
```

Создаем Ingress `pawsy-foxicute_microservices/kubernetes/reddit/ui-ingress.yml` предварительно скачав [его](https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml).

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl get ingress -n dev
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME   CLASS    HOSTS   ADDRESS          PORTS   AGE
ui     <none>   *       84.201.167.240   80      2m21s

```

Создаем манифест сетевых политик `pawsy-foxicute_microservices/kubernetes/reddit/mongo-network-policy.yml`, предварительно включив в YC.

Сразу добавляем правило для `post` сервиса.

```
- podSelector:
        matchLabels:
          app: reddit
          component: post

```

Смотрим сколько сущностей с сетевыми политиками созданы.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl get networkpolicy -n dev
NAME              POD-SELECTOR                 AGE
deny-db-traffic   app=reddit,component=mongo   4m40s
```

Смотрим описание созданой сетевой политики.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl describe networkpolicy deny-db-traffic -n dev
Name:         deny-db-traffic
Namespace:    dev
Created on:   2021-07-09 12:47:03 +0000 UTC
Labels:       app=reddit
Annotations:  <none>
Spec:
  PodSelector:     app=reddit,component=mongo
  Allowing ingress traffic:
    To Port: <any> (traffic allowed to all ports)
    From:
      PodSelector: app=reddit,component=comment
    From:
      PodSelector: app=reddit,component=post
  Not affecting egress traffic
  Policy Types: Ingress
```

Создаем хранилище в YC указав обязательно зону, в которой у нас крутися Kuberantes.

```
Создание диска
yc compute disk create \
 --name k8s \
 --size 4 \
 --zone ru-central1-b \
 --description "disk for k8s"
```

Смотрим все сетевые хранилища.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ yc compute disk list
+----------------------+------+-------------+---------------+--------+----------------------+--------------+
|          ID          | NAME |    SIZE     |     ZONE      | STATUS |     INSTANCE IDS     | DESCRIPTION  |
+----------------------+------+-------------+---------------+--------+----------------------+--------------+
| epd380mu8731k8o5maim |      | 68719476736 | ru-central1-b | READY  | epdloud0fsi6jllut4e8 |              |
| epdfjufta1ooci7a2pih | k8s  |  4294967296 | ru-central1-b | READY  |                      | disk for k8s |
| epdt6s5dop0adgaigm08 |      | 68719476736 | ru-central1-b | READY  | epd3bbonj23ifn3j5cjo |              |
+----------------------+------+-------------+---------------+--------+----------------------+--------------+
```

Сотрим созданые Volume.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl get pv -n dev
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM           STORAGECLASS     REASON   AGE
mongo-pv   4Gi        RWO            Retain           Bound    dev/mongo-pvc   yc-network-hdd            40s
```

Смотрим все запросы к сетевым хранилищам.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes$ kubectl get pvc -n dev
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS     AGE
mongo-pvc   Bound    mongo-pv   4Gi        RWO            yc-network-hdd   22s
```

---

## Lesson 30. _CI/CD в Kubernetes_

Сделано:
 + Работа с Helm 3
 + Развертывание Gitlab в Kubernetes
 + Запуск CI/CD конвейера в Kubernetes

Создаем новый кластер в YC с двумя узлами.

Устанавливаем Helm 3, нужда в Tiller отпадает.

Установка чарта в Helm 3, флаг `-- name` ненужен.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices$ helm install test-ui-1 kubernetes/Charts/ui
W0712 11:13:12.812016   25221 warnings.go:70] extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
W0712 11:13:13.899349   25221 warnings.go:70] extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME: test-ui-1
LAST DEPLOYED: Mon Jul 12 11:13:10 2021
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

Проверка:

```
pawsy@foxy-server:~/pawsy-foxicute_microservices$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
test-ui-1       default         1               2021-07-12 11:13:10.261208542 +0000 UTC deployed        ui-1.0.0        1
```

Установка `mongodb` будет с репозитория `bitnami`.

```
Getting updates for unmanaged Helm repositories...
...Successfully got an update from the "https://charts.bitnami.com/bitnami" chart repository
Hang tight while we grab the latest from your chart repositories...
...Successfully got an update from the "nginx-stable" chart repository
Update Complete. ⎈Happy Helming!⎈
Saving 4 charts
Downloading mongodb from repo https://charts.bitnami.com/bitnami
Deleting outdated charts
```

Для того чтобы Ingress работал нужен [Ingress Nginx](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm). Установить можно в три команды:

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

Установка gitlab через Helm.

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes/Charts/gitlab-omnibus$ helm ls
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                APP VERSION
gitlab          default         1               2021-07-12 14:14:27.820908243 +0000 UTC deployed        gitlab-omnibus-0.1.37
ingress-nginx   default         1               2021-07-12 13:36:44.491461982 +0000 UTC deployed        ingress-nginx-3.34.0 0.47.0
```

Результат в Ingress:

```
pawsy@foxy-server:~/pawsy-foxicute_microservices/kubernetes/Charts/gitlab-omnibus$ kubectl get ingress
Warning: extensions/v1beta1 Ingress is deprecated in v1.14+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress
NAME            CLASS    HOSTS                                                                   ADDRESS         PORTS     AGE
gitlab-gitlab   <none>   gitlab-gitlab,registry.example.com,mattermost.example.com + 1 more...   84.252.136.32   80, 443   89s
```

Для работы с git'ом во избежание `server certificate verification failed. CAfile: none CRLfile: none` объявляем переменную `export GIT_SSL_NO_VERIFY=1`.

Для избежания ошибок в CI тестах создаим юзера, роль, группу и забайндим:

```
kubectl create clusterrolebinding serviceaccounts-cluster-admin   --clusterrole=cluster-admin   --group=system:serviceaccounts
```

---

## Lesson 31. _Kubernetes. Мониторинг и логирование_

Сделано:
 + Развертывание Prometheus в k8s
 + Настройка Prometheus и Grafana для сбора метрик
 + Настройка Alertmanager (Задание со *)
 + Настройка EFK для сбора логов


Использовался `Prometheus` [этот](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus).

Чтобы решить проблему отображение таргетов нод от Prometheus, повысим ему права:

```
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:prometheus-server
```

Прописываем сбор метрик эндпоинтов в конце файла `pawsy-foxicute_microservices/kubernetes/Charts/prometheus/custom_values.yml`.

```
      - job_name: 'reddit-endpoints'

        kubernetes_sd_configs:
          - role: endpoints

        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_app]
            action: keep # Используем действие keep, чтобы оставить
            regex: reddit
```

Разбиение Job'ов на сервисы. Конфиг:

```
# POST
      - job_name: 'post-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_component]
            action: keep
            regex: post

# UI
      - job_name: 'ui-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_component]
            action: keep
            regex: ui

# COMMENT
      - job_name: 'comment-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_component]
            action: keep
            regex: comment
```


Установка `Grafana`, добавим репозиторий:
helm repo add grafana https://grafana.github.io/helm-charts

Установка:

```
helm upgrade --install grafana stable/grafana --set "adminPassword=admin" \
--set "service.type=NodePort" \
--set "ingress.enabled=true" \
--set "ingress.hosts={reddit-grafana}"
```

Команда чтобы получить пароль:

```
kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

Новый файл с дашбордом находится по пути `pawsy-foxicute_microservices/monitoring/grafana/dashboards/UI_Service_Monitoring Lesson 31.json`.


Настройка Alertmanager:

```
alertmanager:
  enabled: true

  serviceAccountName: default

  name: alertmanager

  image:
    repository: prom/alertmanager
    tag: v0.22.2
    pullPolicy: IfNotPresent

  extraArgs: {}

  baseURL: "http://alert-prom/"

  extraEnv: {}

  configMapOverrideName: ""

  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    hosts: ["alert-prom"]
    tls: []

  nodeSelector: {}

  persistentVolume:
    enabled: false
    accessModes:
      - ReadWriteOnce
    annotations: {}
    existingClaim: ""
    mountPath: /data
    size: 2Gi
    subPath: ""

  podAnnotations: {}

  replicaCount: 1

  resources: {}

  service:
    annotations: {}
    labels: {}
    clusterIP: ""
    externalIPs: []
    loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    type: ClusterIP

configmapReload:
  name: configmap-reload
  image:
    repository: jimmidyson/configmap-reload
    tag: v0.1
    pullPolicy: IfNotPresent
  resources: {}

alertmanagerFiles:
  alertmanager.yml:
    global:
      slack_api_url: 'https://hooks.slack.com/services/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'

    route:
      receiver: 'slack-notifications'

    receivers:
    - name: 'slack-notifications'
      slack_configs:
      - channel: '#denis_yusupov'

serverFiles:
  alerting_rules.yml:
    groups:
      - name: alert_rules
        rules:
          - alert: InstanceDown
            expr: up == 0
            for: 10s
            labels:
              severity: page
            annotations:
              description: '{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 10 seconds'
              summary: 'Instance {{ $labels.instance }} down'

          - alert: k8s API server is down
            expr: up{job="kubernetes-apiservers"} == 0
            for: 10s
            labels:
              severity: page
            annotations:
              description: 'k8s API server is offline for more than 10 seconds'
              summary: 'k8s API server'

  alerts: {}
  rules: {}

  prometheus.yml:
    rule_files:
      - /etc/config/alerting_rules.yml
      - /etc/config/rules


    global:
      scrape_interval: 30s

    scrape_configs:
      - job_name: prometheus
        static_configs:
          - targets:
            - localhost:9090
```


---
