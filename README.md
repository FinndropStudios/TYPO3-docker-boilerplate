![License MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)

# TYPO3 docker boilerplate

This is an TYPO3 docker boilerplate which will be configured through a step-by-step bash script.
Most needed things as composer, git, git-flow-avh, nano and oh-my-zsh will be preinstalled.
It also provides an option to setup a blank dummy TYPO3 8.X instance (WIP - repo follows).

Supports:

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

This Docker boilerplate is based on the [TYPO3-docker-boilerplate by webdevops](https://github.com/webdevops/TYPO3-docker-boilerplate) and doesn't use too much magic. Configuration of each docker container is available in the `docker/` directory - feel free to customize.


## How to

Just download and unzip or clone this repository. Open your favourite Terminal and navigate to the boilerplate's folder.
Run `./boil.sh` to start the configuration of your container. Follow the steps and you're done.

## Further information

This boilerplate was designed just for developmet purposes. *We recommend not to use it in production environment!* In this boilerplate ssh will be activated and the whole environment is set to `development`. There are no plans to change this in future, because we really just need this boilerplate for development. 

## Credits

This Docker layout is based on https://github.com/webdevops/TYPO3-docker-boilerplate

Thanks for your support, ideas and issues.
- [Markus Blaschke](https://github.com/mblaschke)
