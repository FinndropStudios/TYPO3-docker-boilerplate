![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

# TYPO3 Docker Boilerplate

This is a TYPO3 docker boilerplate which will be configured through a step-by-step bash script.

## upcoming (WIP):

<!---
It also provides an option to setup a blank dummy [TYPO3 8.X instance](https://github.com/FinndropStudios/TYPO3-8.x-boilerplate).
-->

- include [TYPO3-8.x-boilerplate](https://github.com/FinndropStudios/TYPO3-8.x-boilerplate)
- include virtualhosts functionality through reverse proxy

## Supports:

- Nginx or Apache HTTPd
- PHP-FPM (with Xdebug)
- MySQL, MariaDB or PerconaDB
- PostgreSQL
- Solr (needs configuration)
- Elasticsearch (needs configuration)
- Redis
- Memcached
- Mailcatcher (if no mail sandbox is used, eg. [Vagrant Development VM](https://github.com/webdevops/vagrant-development))
- FTP server (vsftpd)
- PhpMyAdmin

## Preinstalled tools (optional):

- git
- git-flow-avh
- composer
- oh-my-zsh
- npm
- bower (installs npm)
- gulp (installs npm)

## How to

Just download and unzip or clone this repository. Open your favourite Terminal and navigate to the boilerplate's folder.
Run `./boil.sh` to start the configuration of your container. Follow the steps and you're done.

## Useful commands

- `ssh -p $SSHPORT application@localhost` Login to your container using ssh
- `docker-compose up -d` run your container
- `docker-compose up -d --build` rebuild your container
- `docker-compose stop` stop your container
- `docker rm $CONTAINERNAME` remove container
- `docker rmi $CONTAINERNAME` remove image
- `docker ps -a` show running containers

## Further information

This Docker boilerplate is based on the [TYPO3-docker-boilerplate by webdevops](https://github.com/webdevops/TYPO3-docker-boilerplate) and doesn't use too much magic. Configuration of each docker container is available in the `docker/` directory - feel free to customize. This boilerplate was designed just for developmet purposes. *We recommend not to use it in production environment!* In this boilerplate ssh will be activated and the whole environment is set to `development`. There are no plans to change this in future, because we really just need this boilerplate for development.

## Credits

This Docker layout is based on https://github.com/webdevops/TYPO3-docker-boilerplate

Thanks for your support, ideas and issues.
- [Markus Blaschke](https://github.com/mblaschke)
