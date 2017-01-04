#!/bin/bash

#
# include config arrays
#
source ingredients/os.sh
source ingredients/webserver.sh
source ingredients/database.sh
source ingredients/mailservice.sh
source ingredients/globals.sh

#
# cleanup function
#
function cleanup {
    rm -rf .git
    if [ -e "docker-compose.yml" ]; then
        rm docker-compose.yml
    fi
    if [ -e "Dockerfile.development" ]; then
        rm Dockerfile.development
    fi
    if [ -e "ssh/authorized_keys" ]; then
        rm ssh/authorized_keys
    fi
}

#
# set name of project
#
function setProjectName {
    read -r -p "Please set the projects name: " PROJECTNAME
}

#
# php version selection (including OS)
#
function selectOS {
    echo -e "${ORANGE}Select your php-version:${NC}"
    echo -e "Ubuntu:"
    echo -e "  1)  ubuntu-12.04 -> PHP 5.3         (precise)  LTS"
    echo -e "  2)  ubuntu-14.04 -> PHP 5.5         (trusty)   LTS"
    echo -e "  3)  ubuntu-15.04 -> PHP 5.6         (vivid)"
    echo -e "  4)  ubuntu-15.10 -> PHP 5.6         (wily)"
    echo -e "  5)  ubuntu-16.04 -> PHP 7.0         (xenial)   LTS"
    echo -e ""
    echo -e "CentOS:"
    echo -e "  6)  centos-7     -> PHP 5.4"
    echo -e ""
    echo -e "Debian:"
    echo -e "  7)  debian-7     -> PHP 5.4         (wheezy)"
    echo -e "  8)  debian-8     -> PHP 5.6 and 7.x (jessie)"
    echo -e "  9)  debian-9     -> PHP 7.0         (stretch)"
    echo -e ""
    read -r -p "Enter the number of the desired option: " SELECTEDOS
    echo -e "${GREEN}Selected: ${OS[$SELECTEDOS]}${NC}"
}

#
# server selection
#
function selectWebServer {
    echo -e "${ORANGE}Select your webserver:${NC}"
    echo -e "  1)  Apache 2"
    echo -e "  2)  Nginx"
    echo -e ""
    read -r -p "Enter the number of the desired option: " SELECTEDWEBSERVER
    echo -e "${GREEN}Selected: ${WEBSERVER[$SELECTEDWEBSERVER]}${NC}"
}

#
# database selection
#
function selectDatabase {
    echo -e "${ORANGE}Select your database type:${NC}"
    echo -e "MySQL:"
    echo -e "  1)  MySQL 5.5"
    echo -e "  2)  MySQL 5.6"
    echo -e "  3)  MySQL 5.7"
    echo -e ""
    echo -e "MariaDB:"
    echo -e "  4)  MariaDB 5.5"
    echo -e "  5)  MariaDB 10"
    echo -e ""
    echo -e "Percona:"
    echo -e "  6)  Percona 5.5"
    echo -e "  7)  Percona 5.6"
    echo -e "  8)  Percona 5.7"
    echo -e ""
    echo -e "Postgres:"
    echo -e "  9)  Postgres 9.4"
    echo -e "  10) Postgres 9.5"
    echo -e ""
    read -r -p "Enter the number of the desired option: " SELECTEDDATABASE
    echo -e "${GREEN}Selected: ${DATABASE[$SELECTEDDATABASE]}${NC}"
}

#
# mail service selection
#
function selectMailService {
    echo -e "${ORANGE}Select your mailservice:${NC}"
    echo -e "  1)  Mailhog"
    echo -e "  2)  Mailcatcher"
    echo -e "  3)  Mailsandbox"
    echo -e ""
    read -r -p "Enter the number of the desired option: " SELECTEDMAILSERVICE
    echo -e "${GREEN}Selected: ${MAILSERVICE[$SELECTEDMAILSERVICE]}${NC}"
}

#
# select services to include in image
#
function selectServices {
    echo -e "${ORANGE}Select the services which should be included:${NC}"
    read -r -p "Do you want to include Solr (needs configuration)? [y/N] " INCLUDESOLR
    read -r -p "Do you want to include Elasticsearch (needs configuration)? [y/N] " INCLUDEELASTICSEARCH
    read -r -p "Do you want to include Redis? [y/N] " INCLUDEREDIS
    read -r -p "Do you want to include Memcached? [y/N] " INCLUDEREDIS
    read -r -p "Do you want to include FTP? [y/N] " INCLUDEREDIS
    case ${SELECTEDDATABASE} in
        [1-3]*)
            read -r -p "Do you want to include PhpMyAdmin? [y/N] " INCLUDEPHPMYADMIN
            ;;
        *)
            ;;
    esac
    echo -e "${GREEN}Service selection complete!${NC}"
}

#
# select tools to include in image
#
function selectTools {
    echo -e "${ORANGE}Select the tools which should be installed:${NC}"
    read -r -p "Do you want to install composer? [y/N] " INSTALLCOMPOSER
    read -r -p "Do you want to install git? [y/N] " INSTALLGIT
    case ${INSTALLGIT} in
        [yY][eE][sS]|[yY])
            read -r -p "Do you want to install git-flow? [y/N] " INSTALLGITFLOW
            ;;
        *)
            ;;
    esac
    read -r -p "Do you want to install oh-my-zsh? [y/N] " INSTALLOHMYZSH
    read -r -p "Do you want to install npm? [y/N] " INSTALLNPM
    case ${INSTALLNPM} in
        [yY][eE][sS]|[yY])
            INSTALLNPM=true
            ;;
        *)
            ;;
    esac
    read -r -p "Do you want to install bower? [y/N] " INSTALLBOWER
    case ${INSTALLBOWER} in
        [yY][eE][sS]|[yY])
            INSTALLBOWER=true
            ;;
        *)
            ;;
    esac
    read -r -p "Do you want to install gulp? [y/N] " INSTALLGULP
    case ${INSTALLGULP} in
        [yY][eE][sS]|[yY])
            INSTALLGULP=true
            ;;
        *)
            ;;
    esac
    echo -e "${GREEN}Tool selection complete!${NC}"
}

#
# grab ports
#
function setPorts {
    echo -e "${ORANGE}Set the ports for this container:${NC}"
    if [ -e "~/.dockercontainers" ]; then
        read -r -p "Do you want to see a list of already used ports? [y/N] " response
        case ${response} in
            [yY][eE][sS]|[yY])
                cat ~/.dockercontainers
                ;;
            *)
                ;;
        esac
    else
        touch ~/.dockercontainers
    fi
    read -r -p "http port (80): " HTTPPORT
    read -r -p "ftp port (443): " FTPPORT
    read -r -p "ssh port (22): " SSHPORT
    read -r -p "database port (3306): " DBPORT
    case ${INCLUDEELASTICSEARCH} in
        [yY][eE][sS]|[yY])
            read -r -p "Elasticsearch port 1 (9200): " ELASTICSEARCHPORT1
            read -r -p "Elasticsearch port 2 (9300): " ELASTICSEARCHPORT2
            ;;
        *)
            ;;
    esac
    case ${SELECTEDMAILSERVICE} in
        1)
            read -r -p "mail port (8025): " MAILPORT
            ;;
        *)
            ;;
    esac
    echo -e "$PROJECTNAME\t\t-\t$HTTPPORT\t$FTPPORT\t$SSHPORT\t$DBPORT\t$MAILPORT\t$ELASTICSEARCHPORT1\t$ELASTICSEARCHPORT2" >> ~/.dockercontainers
    PROJECTID=$(wc -l < "~/.dockercontainers")
    echo -e "${GREEN}Port configuration complete!${NC}"
}

#
# add ssh key to container
#
function prepareSsh {
    echo -e "${ORANGE}Expose your public key to container:${NC}"
    # cat ~/.ssh/id_rsa.pub
    if [ ! -e "$HOME/.ssh/id_rsa.pub" ]; then
        ssh-keygen -b 2048 -t rsa -f "" -q -N ""
    fi
    echo -e "Writing your public key to authorized_keys"
    cat ~/.ssh/id_rsa.pub >> ssh/authorized_keys
    echo -e "${GREEN}Ssh preparation complete!${NC}"
}

#
# write docker-compose.yml
#
function writeDockerCompose {
    file=docker-compose.yml
    echo -e "${ORANGE}Writing ${file}${NC}"
    echo "version: '2'" >> ${file}
    echo "services:" >> ${file}
    echo "  app:" >> ${file}
    echo "    container_name: app_${PROJECTID}" >> ${file}
    echo "    build:" >> ${file}
    echo "      context: ." >> ${file}
    echo "      dockerfile: Dockerfile.development" >> ${file}
    echo "    links:" >> ${file}
    echo "      - mail" >> ${file}
    case ${SELECTEDDATABASE} in
        [1-8]*)
            echo "      - mysql" >> ${file}
            ;;
        *)
            echo "      - postgres" >> ${file}
            ;;
    esac
    case ${INCLUDESOLR} in
        [yY][eE][sS]|[yY])
            echo "      - solr" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEELASTICSEARCH} in
        [yY][eE][sS]|[yY])
            echo "      - elasticsearch" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEREDIS} in
        [yY][eE][sS]|[yY])
            echo "      - redis" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEMEMCACHED} in
        [yY][eE][sS]|[yY])
            echo "      - memcached" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEFTP} in
        [yY][eE][sS]|[yY])
            echo "      - ftp" >> ${file}
            ;;
        *)
            ;;
    esac
    echo "    ports:" >> ${file}
    echo "      - \"${HTTPPORT}:80\"" >> ${file}
    echo "      - \"${FTPPORT}:443\"" >> ${file}
    echo "      - \"${SSHPORT}:22\"" >> ${file}
    echo "    volumes:" >> ${file}
    echo "      - ./app/:/app/" >> ${file}
    echo "      - /tmp/debug/:/tmp/debug/" >> ${file}
    echo "      - ./:/docker/" >> ${file}
    echo "      - ./ssh:/home/application/.ssh" >> ${file}
    case ${INSTALLOHMYZSH} in
        [yY][eE][sS]|[yY])
            echo "      - ./oh-my-zsh/:/oh-my-zsh/" >> ${file}
            ;;
        *)
            ;;
    esac
    echo "    volumes_from:" >> ${file}
    echo "      - storage_${PROJECTID}" >> ${file}
    echo "    cap_add:" >> ${file}
    echo "      - SYS_PTRACE" >> ${file}
    echo "    privileged: true" >> ${file}
    echo "    env_file:" >> ${file}
    echo "      - etc/environment.yml" >> ${file}
    echo "      - etc/environment.development.yml" >> ${file}
    echo "    environment:" >> ${file}
    echo "      - VIRTUAL_HOST=.app.boilerplate.docker" >> ${file}
    echo "      - VIRTUAL_PORT=80" >> ${file}
    echo "      - POSTFIX_RELAYHOST=[mail]:1025" >> ${file}
    case ${SELECTEDDATABASE} in
        [1-8]*)
            echo "  mysql:" >> ${file}
            echo "    container_name: database_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/mysql/" >> ${file}
            echo "      dockerfile: ${DATABASE[$SELECTEDDATABASE]}.Dockerfile" >> ${file}
            echo "    ports:" >> ${file}
            echo "      - ${DBPORT}:3306" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    volumes:" >> ${file}
            echo "      - /tmp/debug/:/tmp/debug/" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            ;;
        *)
            echo "  postgres:" >> ${file}
            echo "    container_name: database_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/postgres/" >> ${file}
            echo "      dockerfile: ${DATABASE[$SELECTEDDATABASE]}.Dockerfile" >> ${file}
            echo "    ports:" >> ${file}
            echo "      - ${DBPORT}:5432" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            ;;
    esac
    case ${INCLUDESOLR} in
        [yY][eE][sS]|[yY])
            echo "  solr:" >> ${file}
            echo "    container_name: solr_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/solr/" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - SOLR_STORAGE=/storage/solr/server-master/" >> ${file}
            echo "      - VIRTUAL_HOST=solr.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=8983" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEELASTICSEARCH} in
        [yY][eE][sS]|[yY])
            echo "  elasticsearch:" >> ${file}
            echo "    container_name: elasticsearch_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/elasticsearch/" >> ${file}
            echo "    ports:" >> ${file}
            echo "      - ${ELASTICSEARCHPORT1}:9200" >> ${file}
            echo "      - ${ELASTICSEARCHPORT2}:9300" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - VIRTUAL_HOST=elasticsearch.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=9200" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEREDIS} in
        [yY][eE][sS]|[yY])
            echo "  redis:" >> ${file}
            echo "    container_name: redis_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/redis/" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEMEMCACHED} in
        [yY][eE][sS]|[yY])
            echo "  memcached:" >> ${file}
            echo "    container_name: memcached_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/memcached/" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${SELECTEDMAILSERVICE} in
        1)
            echo "  mail:" >> ${file}
            echo "    container_name: mail_${PROJECTID}" >> ${file}
            echo "    image: mailhog/mailhog" >> ${file}
            echo "    ports:" >> ${file}
            echo "      - ${MAILPORT}:8025" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - VIRTUAL_HOST=mail.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=8025" >> ${file}
            ;;
        2)
            echo "  mail:" >> ${file}
            echo "    container_name: mail_${PROJECTID}" >> ${file}
            echo "    image: schickling/mailcatcher" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - VIRTUAL_HOST=mail.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=1080" >> ${file}
            ;;
        3)
            echo "  mail:" >> ${file}
            echo "    container_name: mail_${PROJECTID}" >> ${file}
            echo "      image: webdevops/mail-sandbox" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - VIRTUAL_HOST=mail.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=80" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEFTP} in
        [yY][eE][sS]|[yY])
            echo "  ftp:" >> ${file}
            echo "    container_name: ftp_${PROJECTID}" >> ${file}
            echo "    build:" >> ${file}
            echo "      context: docker/vsftpd/" >> ${file}
            echo "    volumes_from:" >> ${file}
            echo "      - storage_${PROJECTID}" >> ${file}
            echo "    volumes:" >> ${file}
            echo "      - ./:/application/" >> ${file}
            echo "    env_file:" >> ${file}
            echo "      - etc/environment.yml" >> ${file}
            echo "      - etc/environment.development.yml" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INCLUDEPHPMYADMIN} in
        [yY][eE][sS]|[yY])
            echo "  phpmyadmin:" >> ${file}
            echo "    container_name: phpmyadmin_${PROJECTID}" >> ${file}
            echo "    image: phpmyadmin/phpmyadmin" >> ${file}
            echo "    links:" >> ${file}
            echo "      - mysql" >> ${file}
            echo "    environment:" >> ${file}
            echo "      - PMA_ARBITRARY=1" >> ${file}
            echo "      - VIRTUAL_HOST=pma.boilerplate.docker" >> ${file}
            echo "      - VIRTUAL_PORT=80" >> ${file}
            echo "    volumes:" >> ${file}
            echo "      - /sessions" >> ${file}
            ;;
        *)
            ;;
    esac
    echo "  storage:" >> ${file}
    echo "    container_name: storage_${PROJECTID}" >> ${file}
    echo "    build:" >> ${file}
    echo "      context: docker/storage/" >> ${file}
    echo "    volumes:" >> ${file}
    echo "      - /storage_${PROJECTID}" >> ${file}
    echo -e "${GREEN}Written ${file}!${NC}"
}

#
# write Dockerfile.development
#
function writeDockerfile {
    file=Dockerfile.development
    echo -e "${ORANGE}Writing ${file}${NC}"
    echo "FROM webdevops/php-${WEBSERVER[$SELECTEDWEBSERVER]}-dev:${OS[$SELECTEDOS]}" >> ${file}
    echo "" >> ${file}
    echo "ENV PROVISION_CONTEXT \"development\"" >> ${file}
    echo "" >> ${file}
    echo "# Deploy scripts/configurations" >> ${file}
    echo "COPY etc/             /opt/docker/etc/" >> ${file}
    echo "COPY provision/       /opt/docker/provision/" >> ${file}
    echo "" >> ${file}
    echo "RUN sudo apt-get update" >> ${file}
    echo "RUN sudo apt-get -y upgrade" >> ${file}
    echo "RUN sudo apt-get -y install apt-utils" >> ${file}
    echo "RUN /opt/docker/bin/provision run --tag bootstrap --role boilerplate-main --role boilerplate-main-development --role boilerplate-deployment \
    && /opt/docker/bin/bootstrap.sh" >> ${file}
    echo "" >> ${file}
    case ${INSTALLGIT} in
        [yY][eE][sS]|[yY])
            GITINSTALLED=true
            echo "# Install git" >> ${file}
            echo "RUN sudo apt-get -y install git-all" >> ${file}
            echo "" >> ${file}
            case ${INSTALLGITFLOW} in
                [yY][eE][sS]|[yY])
                    echo "# Install git-flow" >> ${file}
                    echo "RUN wget --no-check-certificate -q  https://raw.github.com/petervanderdoes/gitflow-avh/develop/contrib/gitflow-installer.sh && sudo bash gitflow-installer.sh install stable; rm gitflow-installer.sh" >> ${file}
                    echo "" >> ${file}
                    ;;
                *)
                    ;;
            esac
            ;;
        *)
            ;;
    esac

    case ${INSTALLOHMYZSH} in
        [yY][eE][sS]|[yY])
            if [ "${GITINSTALLED}" = false ] ; then
                echo "# Install git" >> ${file}
                echo "RUN sudo apt-get install git-all" >> ${file}
                echo "" >> ${file}
            fi
            echo "# Install oh-my-zsh" >> ${file}
            echo "RUN sudo apt-get update && sudo apt-get -y install zsh" >> ${file}
            echo "RUN wget –no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O – | sh" >> ${file}
            echo "RUN cp oh-my-zsh/.zshrc ~/.zshrc" >> ${file}
            echo "RUN cp oh-my-zsh/font/* /usr/share/fonts/truetype/*" >> ${file}
            echo "RUN fc-cache -f -v" >> ${file}
            echo "RUN chsh -s /bin/zsh" >> ${file}
            echo "RUN git clone git://github.com/sigurdga/gnome-terminal-colors-solarized.git ~/.solarized" >> ${file}
            echo "RUN THISDIR=\$(pwd)" >> ${file}
            echo "RUN cd ~/.solarized" >> ${file}
            echo "RUN ./solarize" >> ${file}
            echo "RUN cd ${THISDIR}" >> ${file}
            echo "" >> ${file}
            ;;
        *)
            ;;
    esac
    case ${INSTALLCOMPOSER} in
        [yY][eE][sS]|[yY])
            echo "# Install composer" >> ${file}
            echo "RUN php -r \"copy('https://getcomposer.org/installer', 'composer-setup.php');\"" >> ${file}
            echo "RUN php composer-setup.php" >> ${file}
            echo "RUN php -r \"unlink('composer-setup.php');\"" >> ${file}
            echo "RUN mv composer.phar /usr/local/bin/composer" >> ${file}
            echo "" >> ${file}
            ;;
        *)
            ;;
    esac
    if [ "${INSTALLNPM}" = true ] || [ "${INSTALLBOWER}" = true ] || [ "${INSTALLGULP}" = true ]; then
        echo "# Install npm" >> ${file}
        echo "RUN sudo apt-get -y install nodejs" >> ${file}
        echo "RUN sudo apt-get -y install npm" >> ${file}
        echo "" >> ${file}
        NPMINSTALLED=true
    fi
    if [ "${INSTALLBOWER}" = true ]; then
        echo "# Install bower" >> ${file}
        echo "RUN sudo npm install bower" >> ${file}
        echo "" >> ${file}
    fi
    if [ "${INSTALLGULP}" = true ]; then
        echo "# Install gulp" >> ${file}
        echo "RUN sudo npm install gulp" >> ${file}
        echo "" >> ${file}
    fi
    echo "# Activate ssh" >> ${file}
    echo "RUN mkdir -p /home/application/.ssh" >> ${file}
    echo "RUN /opt/docker/bin/control.sh service.enable ssh" >> ${file}
    echo "" >> ${file}
    echo "# Configure volume/workdir" >> ${file}
    echo "RUN mkdir -p /app/" >> ${file}
    echo "WORKDIR /app/" >> ${file}
    echo "" >> ${file}
    echo -e "${GREEN}Written ${file}!${NC}"
}

#
# clone typo3-boilerplate repository into /app
#
function cloneTypo3Boilerplate {
    read -r -p $'\e[33mDo you want to clone the TYPO3 boilerplate?\e[0m [y/N] ' response
    case ${response} in
        [yY][eE][sS]|[yY])
            echo -e "Cloning TYPO3 boilerplate into /app"
            git clone git@github.com:FinndropStudios/TYPO3-8.x-boilerplate.git app
            touch app/dockermode
            file=app/ingredients/database.sh
            echo "DATABASEUSERNAME=dev" >> ${file}
            echo "DATABASEUSERPASSWORD=dev" >> ${file}
            echo "DATABASENAME=typo3" >> ${file}
            echo "DATABASEHOSTNAME=mysql" >> ${file}
            echo "DATABASEHOSTPORT=" >> ${file}
            echo -e "${GREEN}TYPO3 boilerplate successfully cloned!${NC}"
            CLONEDTYPO3BOILERPLATE=true
            ;;
        *)
            mkdir app app/web
            echo "<?php" >> app/web/index.php
            echo "phpinfo();" >> app/web/index.php
            ;;
    esac
}

#
# finish boiling
#
function startContainer {
    read -r -p $'\e[33mDo you want to run the container now (make sure docker is running)?\e[0m [y/N] ' response
    case ${response} in
        [yY][eE][sS]|[yY])
            docker-compose up -d
            ;;
        *)
            ;;
    esac
    echo -e ""
    echo -e "###############################################################################"
    echo -e "${GREEN}Your docker container is now ready to use!${NC}"
    echo -e "###############################################################################"
    echo -e ""
    echo -e "${ORANGE}Run your container manually using the following command:${NC}"
    echo -e "docker-compose up -d"
    echo -e ""
    echo -e "${ORANGE}Shutdown your container using the following command:${NC}"
    echo -e "docker-compose stop"
    echo -e ""
    echo -e "${ORANGE}You can ssh into your container using the following command:${NC}"
    echo -e "ssh -p ${SSHPORT} application@localhost"
    echo -e ""
    echo -e "${ORANGE}Access your new project:${NC}"
    echo -e "Type localhost:${HTTPPORT} in your favourite browser"
    echo -e ""
    if [ "${CLONEDTYPO3BOILERPLATE}" = true ] ; then
        echo -e "${ORANGE}Instructions for TYPO3 boilerplate:${NC}"
        echo -e "ssh into your container, navigate to /app/ and run boil.sh"
        echo -e ""
    fi
    echo -e "${GREEN}Have fun!${NC}"
    echo -e ""
    echo -e ""
}

#
# main function
#
function main {
    clear
    echo -e ""
    echo -e "###############################################################################"
    echo -e "${GREEN}Welcome to the typo3-docker-boilerplate!${NC}"
    echo -e "Please follow the instructions and provide the requested information when asked"
    echo -e "###############################################################################"
    echo -e ""
    echo -e ""
    if [ -e "app/dockermode" ] || [ -e "Dockerfile.development" ] || [ -e "docker-compose.yml" ] || [ -e "ssh/authorized_keys" ]; then
        read -r -p "Seems you already set up your container. Are you sure to rewrite? [y/N] " response
        case ${response} in
            [yY][eE][sS]|[yY])
                REBUILD=true
                ;;
            *)
                REBUILD=false
                ;;
        esac
    else
        REBUILD=true
    fi
    if [ "${REBUILD}" = true ] ; then
        cleanup
        setProjectName
        selectOS
        selectWebServer
        selectDatabase
        selectMailService
        selectServices
        selectTools
        setPorts
        prepareSsh
        writeDockerCompose
        writeDockerfile
        cloneTypo3Boilerplate
        startContainer
    else
        echo -e "${RED}Stopped boiling!${NC}"
        echo -e ""
        exit 0
    fi
}

main;