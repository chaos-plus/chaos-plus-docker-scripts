## Docker Deploy Scripts For Debian/Ubuntu

> 自用. 仅用于学习, 随时删库!

## 使用说明(基于 docker)

```bash

git clone https://github.com/chaos-plus/chaos-plus-docker-scripts.git

cd chaos-plus-docker-scripts

\cp env.example.sh env.release.sh

vim env.release.sh # 修改


# install all
bash install.sh


# install custom

bash install.sh acme
bash install.sh traefik
bash install.sh crproxy
bash install.sh ghproxy
bash install.sh gfw

```


