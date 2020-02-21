FROM centos:7

# Install dependencies
RUN yum install epel-release -y; yum clean all; \
    yum update -y; \
    yum install -y systemd* java-1.8.0-openjdk java-1.8.0-openjdk-devel wget vim curl netcat jq \
                yum-utils yum-plugin-ovl tar git bind-utils unzip initscripts mysql mysql-connector-java; \
    yum clean all

# Set JAVA env variables
ENV JAVA_HOME=/usr/lib/jvm/jre-openjdk
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar

# Install Zookeeper
#ENV ZOO_DIR /opt/zookeeper
#ENV ZOO_DATA_DIR /var/lib/zookeeper
#ENV ZOO_LOG_DIR /var/log/zookeeper
#ENV ZOO_CONF $ZOO_DIR/conf

#RUN groupadd -r zookeeper; useradd -r -g zookeeper zookeeper; \
#    cd /usr/src; \
#    wget "https://www-us.apache.org/dist/zookeeper/stable/apache-zookeeper-3.5.6-bin.tar.gz"; \
#    tar -xzvf "apache-zookeeper-3.5.6-bin.tar.gz"; rm "apache-zookeeper-3.5.6-bin.tar.gz"; \
#    mv "/usr/src/apache-zookeeper-3.5.6-bin" "$ZOO_DIR"; \
#    mkdir -p "$ZOO_DATA_DIR" "$ZOO_LOG_DIR"; \
#    chown zookeeper:zookeeper "$ZOO_DIR" "$ZOO_DATA_DIR" "$ZOO_LOG_DIR"

#VOLUME ["$ZOO_DATA_DIR", "$ZOO_LOG_DIR", "$ZOO_CONF"]

#ENV PATH=$PATH:$ZOO_DIR/bin \
#    ZOOCFGDIR=$ZOO_CONF

# Install Apache Kafka
ENV KAFKA_DIR /opt/kafka
ENV KAFKA_LOG4J_OPTS="-Dlog4j.configuration=file:${KAFKA_DIR}/config/tools-log4j.properties"

RUN cd /usr/src; \
    wget http://www-us.apache.org/dist/kafka/2.4.0/kafka_2.12-2.4.0.tgz; \
    tar -xzvf kafka_2.12-2.4.0.tgz; rm kafka_2.12-2.4.0.tgz; \
    mv /usr/src/kafka_2.12-2.4.0 $KAFKA_DIR

ENV PATH $PATH:/$KAFKA_DIR/bin

# Install Mongo shell
#RUN echo $'[mongodb-org-4.2]\n\
#name=MongoDB Repository\n\
#baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/\n\
#gpgcheck=1\n\
#enabled=1\n\
#gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc\n'\
#> /etc/yum.repos.d/mongodb.repo

#RUN yum install -y mongodb-org-shell-4.2.3; yum clean all

# Install Apache Storm
ENV STORM_DIR /opt/storm
ENV STORM_CONF_DIR $STORM_DIR/conf
ENV STORM_DATA_DIR /var/lib/storm
ENV STORM_LOG_DIR /var/log/storm

ENV STORM_JAVA_LIB /usr/local/lib:/opt/local/lib:/usr/lib:/usr/lib64:$STORM_DIR/lib

RUN groupadd -r storm; useradd -r -g storm storm; \
    cd /usr/src; \
    wget https://www-us.apache.org/dist/storm/apache-storm-2.1.0/apache-storm-2.1.0.tar.gz; \
    tar -xzvf apache-storm-2.1.0.tar.gz; rm apache-storm-2.1.0.tar.gz; \
    mv /usr/src/apache-storm-2.1.0 "$STORM_DIR"; \
    rm "$STORM_CONF_DIR"/storm.yaml; \
    mkdir -p "$STORM_DATA_DIR" "$STORM_LOG_DIR"; \
    chown storm:storm "$STORM_DIR" "$STORM_DATA_DIR" "$STORM_LOG_DIR"

VOLUME ["$STORM_DATA_DIR", "$STORM_LOG_DIR"]

ENV PATH $PATH:/$STORM_DIR/bin

# Install Eagle
ENV EAGLE_DIR /opt/eagle
ENV EAGLE_CONF_DIR $EAGLE_DIR/conf
ENV EAGLE_LOG_DIR $EAGLE_DIR/log
ENV PATH $PATH:/$EAGLE_DIR/bin

COPY eagle $EAGLE_DIR
RUN rm "$EAGLE_CONF_DIR"/server.yml; rm "$EAGLE_CONF_DIR"/eagle.conf; 

VOLUME ["$EAGLE_LOG_DIR"]

# Configuration variables
ENV EAGLE_ZOOKEEPER_QUORUM "zookeeper:2181"
ENV EAGLE_KAFKA_TOPIC_NAME audit_topic
ENV EAGLE_KAFKA_REPLICATION_FACTOR 1
ENV EAGLE_KAFKA_PARTITIONS 1

ENV EAGLE_DB_USERNAME eagle
ENV EAGLE_DB_PASSWORD eagle
ENV EAGLE_DB_DATABASE eagle
ENV EAGLE_DB_HOSTNAME eagle-db
ENV EAGLE_DB_PORT 3306

ENV STORM_ZOOKEEPER_SERVERS ["zookeeper"]

ENV SERVICE_CONFIGURATIONS /configurations
ENV PATH $PATH:$SERVICE_CONFIGURATIONS/bin

ADD configurations $SERVICE_CONFIGURATIONS
RUN chmod +x $SERVICE_CONFIGURATIONS/bin/*.sh

ADD entrypoint.sh /entrypoint.sh

WORKDIR $EAGLE_DIR

EXPOSE 9090 8080 6667

CMD ["/entrypoint.sh"]

