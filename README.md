## Denis Yusupov Microservices_Repository

## Lesson 16 : _Docker контейнеры. Docker под капотом_  
Сделано:
 + Установка докера
 + Запуск образа на докере Ubuntu 18.04
 + Работа с командами Docker'a
 + Установка `docker-machine`
 + Создание докер хоста 
 + Работа с Docker Hub

 
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


---

