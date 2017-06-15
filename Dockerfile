FROM cerebello/spark:2.1.1
MAINTAINER Robson Júnior <bsao@cerebello.co> (@bsao)

###########################################
#### USERS
###########################################
USER root
ARG ZEPPELIN_USER=zeppelin
ARG ZEPPELIN_GROUP=zeppelin
ARG ZEPPELIN_UID=8000
ARG ZEPPELIN_GID=8000
ARG ZEPPELIN_USER=${ZEPPELIN_USER}
ARG ZEPPELIN_GROUP=${ZEPPELIN_GROUP}
ARG ZEPPELIN_UID=${ZEPPELIN_UID}
ARG ZEPPELIN_GID=${ZEPPELIN_GID}
RUN addgroup -g ${ZEPPELIN_GID} -S ${ZEPPELIN_GROUP} && \
    adduser -u ${ZEPPELIN_UID} -D -S -G ${ZEPPELIN_USER} ${ZEPPELIN_GROUP} && \
    usermod -a -G ${SPARK_GROUP} ${ZEPPELIN_USER}

##########################################
### ARGS AND ENVS
##########################################
ARG ZEPPELIN_VERSION=0.7.2
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_DATA=${ZEPPELIN_HOME}/data
ENV ZEPPELIN_CONF_DIR=${ZEPPELIN_HOME}/conf
ENV ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_HOME}/notebook
ENV ZEPPELIN_PORT=8888
ENV ZEPPELIN_VERSION=${ZEPPELIN_VERSION}
LABEL name="ZEPPELIN" version=${ZEPPELIN_VERSION}

###########################################
#### DIRECTORIES
###########################################
RUN mkdir -p ${ZEPPELIN_HOME} && \
    mkdir -p ${ZEPPELIN_HOME}/logs && \
    mkdir -p ${ZEPPELIN_HOME}/run && \
    mkdir -p ${ZEPPELIN_DATA} && \
    mkdir -p ${ZEPPELIN_CONF_DIR}

###########################################
#### INSTALL ZEPPELIN
###########################################
RUN echo '{ "allow_root": true }' > /root/.bowerrc && \
    wget http://mirror.netcologne.de/apache.org/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz && \
    tar -xvf zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz -C ${ZEPPELIN_HOME} --strip=1 && \
    rm -rf zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz  && \
    chown -R ${ZEPPELIN_USER}:${ZEPPELIN_GROUP} ${ZEPPELIN_HOME} && \
    chown -R ${ZEPPELIN_USER}:${ZEPPELIN_GROUP} ${ZEPPELIN_NOTEBOOK_DIR} && \
    chown -R ${ZEPPELIN_USER}:${ZEPPELIN_GROUP} ${ZEPPELIN_DATA}

##########################################
### VOLUMES
##########################################
VOLUME ${ZEPPELIN_NOTEBOOK_DIR}
VOLUME ${ZEPPELIN_DATA}

##########################################
### CONFIGURATIONS
##########################################
ENV ZEPPELIN_MEM="-Xmx3096m"
ENV ZEPPELIN_INTERPRETER_GROUP_ORDER="spark,md,sh,file,python,jdbc"
ENV ZEPPELIN_INTERPRETERS="org.apache.zeppelin.spark.SparkInterpreter, \
    org.apache.zeppelin.spark.PySparkInterpreter, \
    org.apache.zeppelin.spark.SparkSqlInterpreter, \
    org.apache.zeppelin.markdown.Markdown, \
    org.apache.zeppelin.angular.AngularInterpreter, \
    org.apache.zeppelin.shell.ShellInterpreter, \
    org.apache.zeppelin.file.HDFSFileInterpreter, \
    org.apache.zeppelin.python.PythonInterpreter, \
    org.apache.zeppelin.python.PythonInterpreterPandasSql, \
    org.apache.zeppelin.python.PythonCondaInterpreter, \
    org.apache.zeppelin.python.PythonDockerInterpreter, \
    org.apache.zeppelin.cassandra.CassandraInterpreter, \
    org.apache.zeppelin.postgresql.PostgreSqlInterpreter, \
    org.apache.zeppelin.jdbc.JDBCInterpreter, \
    org.apache.zeppelin.elasticsearch.ElasticsearchInterpreter, \
    org.apache.zeppelin.hbase.HbaseInterpreter"

##########################################
### PORTS
##########################################
EXPOSE ${ZEPPELIN_PORT}

##########################################
### ENTRYPOINT
##########################################
USER ${ZEPPELIN_USER}
WORKDIR ${ZEPPELIN_HOME}
CMD ${ZEPPELIN_HOME}/bin/zeppelin.sh