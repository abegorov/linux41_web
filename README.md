# Развертывание веб приложения

## Задание

Развернуть стенд **angie + php-fpm (wordpress) + python (django) + js(node.js)** с помощью **docker-compose**.

## Реализация

Задание сделано на **rockylinux/9** версии **v9.5-20241118.0**. Для автоматизации процесса написан **Ansible Playbook** [playbook.yml](playbook.yml) который последовательно запускает следующие роли:

- **docker** - устанавливает **docker**, включает и запускает его сервис;
- **docker_users** - добавляет пользователя **vagrant** в группу **docker**;
- **compose** - разворачивает и запускает на сервере проект [dynamicweb](roles/compose/files/dynamicweb) для **docker compose**, переменные для проекта берутся из шаблона [dynamicweb.env](roles/compose/templates/dynamicweb.env).

Все переменные для ролей находятся в файле [host_vars/dynamicweb.yml](host_vars/dynamicweb.yml). Пароли для [.env](roles/compose/templates/dynamicweb.env) сохраняются в директории `passwords`.

## Запуск

Необходимо скачать **VagrantBox** для **rockylinux/9** версии **v9.5-20241118.0** и добавить его в **Vagrant** под именем **rockylinux/9/v9.5-20241118.0**. Сделать это можно командами:

```shell
curl -OL https://dl.rockylinux.org/pub/rocky/9.5/images/x86_64/Rocky-9-Vagrant-Vbox-9.5-20241118.0.x86_64.box
vagrant box add Rocky-9-Vagrant-Vbox-9.5-20241118.0.x86_64.box --name "rockylinux/9/v9.5-20241118.0"
rm Rocky-9-Vagrant-Vbox-9.5-20241118.0.x86_64.box
```

Для того, чтобы **vagrant 2.3.7** работал с **VirtualBox 7.1.0** необходимо добавить эту версию в **driver_map** в файле **/usr/share/vagrant/gems/gems/vagrant-2.3.7/plugins/providers/virtualbox/driver/meta.rb**:

```ruby
          driver_map   = {
            "4.0" => Version_4_0,
            "4.1" => Version_4_1,
            "4.2" => Version_4_2,
            "4.3" => Version_4_3,
            "5.0" => Version_5_0,
            "5.1" => Version_5_1,
            "5.2" => Version_5_2,
            "6.0" => Version_6_0,
            "6.1" => Version_6_1,
            "7.0" => Version_7_0,
            "7.1" => Version_7_0,
          }
```

После этого нужно сделать **vagrant up**.

Протестировано в **OpenSUSE Tumbleweed**:

- **Vagrant 2.3.7**
- **VirtualBox 7.1.4_SUSE r165100**
- **Ansible 2.17.6**
- **Python 3.11.10**
- **Jinja2 3.1.4**

## Проверка

Посмотрим запущенные на сервере контейнеры:

```text
❯ vagrant ssh -c 'docker compose ls'
NAME                STATUS              CONFIG FILES
dynamicweb          running(5)          /docker/dynamicweb/compose.yml

❯ vagrant ssh -c 'docker compose -f /docker/dynamicweb/compose.yml watch'
[+] Running 5/0
 ✔ Container wordpress-db Running 0.0s
 ✔ Container wordpress    Running 0.0s
 ✔ Container django-app   Running 0.0s
 ✔ Container node-app     Running 0.0s
 ✔ Container angie        Running 0.0s
none of the selected services is configured for watch, consider setting an 'develop' section

❯ vagrant ssh -c 'docker ps'
CONTAINER ID   IMAGE                                      COMMAND                  CREATED         STATUS         PORTS                                      NAMES
e4ff26cfeb11   docker.angie.software/angie:1.7.0-alpine   "angie -g 'daemon of…"   9 minutes ago   Up 9 minutes   80/tcp, 0.0.0.0:8081-8083->8081-8083/tcp   angie
e477252009b5   wordpress:6.7.1-fpm-alpine                 "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes   9000/tcp                                   wordpress
317fe26748d0   node:23.3.0-alpine                         "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes                                              node-app
aa572016e17d   mysql:9.1.0                                "docker-entrypoint.s…"   9 minutes ago   Up 9 minutes   3306/tcp, 33060/tcp                        wordpress-db
47fdac0d584d   abegorov/django-app:1.0.0                  "/bin/sh django-app.…"   9 minutes ago   Up 9 minutes   8000/tcp                                   django-app
```

Откроем [http://localhost:8081](http://localhost:8081):

[!django](images/django.png)

Попробуем войти в админку по адресу [http://localhost:8081/admin](http://localhost:8081/admin), используя имя пользователя **admin** и пароль в файле **passwords/compose_dynamicweb_djangoapp_passwd.txt**:

[!django login](images/django_login.png)

Вход успешен:

[!django admin](images/django_admin.png)

Откроем [http://localhost:8082](http://localhost:8082):

[!Hello from node js server](images/node.png)

Откроем [http://localhost:8083](http://localhost:8083):

[!WordPress Installation](images/wordpress.png):
