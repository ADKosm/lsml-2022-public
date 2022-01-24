# Создание кластера через терраформ

1.  Устанавливаем терраформ по этой инструкции: https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart
2. Создаем бакет в s3 и ssh по этой инструкции:
https://github.com/ADKosm/lsml-2022-public/blob/main/01.%20Cloud.ipynb
3. Прописываем все нужные поля в https://github.com/ADKosm/lsml-2022-public/blob/a4b4fa7a2f72d6a3ff73e9e3f7656691729ed32f/yandex-cloud-terraform/base.tf#L10
4. Делаем ```terraform apply```, пишем ```yes```
5. Добавляем в ```./ssh/config``` и жмем ```ssh-add ~/.ssh/yc_ssh```:
```
Host lsml-proxy
    HostName proxy_public_api
    User ubuntu
    IdentityFile ~/.ssh/yc_ssh

Host lsml-head
    HostName dataproc_master_private_FQDN
    User ubuntu
    ProxyJump lsml-proxy
```
6. Далее идем в нашу созданную ```subnet``` и включаем ```NAT```
7. Создаем ```datasphere``` по этой инструкции https://github.com/ADKosm/lsml-2022-public/blob/main/01.%20Cloud.ipynb