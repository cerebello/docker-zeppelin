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
RUN groupadd --gid=${ZEPPELIN_GID} ${ZEPPELIN_GROUP}
RUN useradd --uid=${ZEPPELIN_UID} --gid=${ZEPPELIN_GID} --no-create-home ${ZEPPELIN_USER}
RUN usermod -a -G ${SPARK_GROUP} ${ZEPPELIN_USER}

##########################################
### ARGS AND ENVS
##########################################
ARG ZEPPELIN_VERSION=0.7.2
ENV ZEPPELIN_HOME=/opt/zeppelin
ENV ZEPPELIN_LOCAL_DATASETS=/opt/datasets
ENV ZEPPELIN_CONF_DIR=${ZEPPELIN_HOME}/conf
ENV ZEPPELIN_NOTEBOOK_DIR=${ZEPPELIN_HOME}/notebook
ENV ZEPPELIN_PORT=8888
ENV ZEPPELIN_VERSION=${ZEPPELIN_VERSION}
ENV ZEPPELIN_USER=${ZEPPELIN_USER}
ENV ZEPPELIN_GROUP=${ZEPPELIN_GROUP}
LABEL name="ZEPPELIN" version=${ZEPPELIN_VERSION}

###########################################
#### DIRECTORIES
###########################################
RUN mkdir -p ${ZEPPELIN_HOME} && \
    mkdir -p ${ZEPPELIN_HOME}/logs && \
    mkdir -p ${ZEPPELIN_HOME}/run && \
    mkdir -p ${ZEPPELIN_CONF_DIR}

###########################################
#### INSTALL PYTHON LIBS
###########################################
RUN pip install numpy \
                pandasql \
                geopandas \
                scikit-learn \
                scipy

###########################################
#### INSTALL ZEPPELIN
###########################################
RUN echo '{ "allow_root": true }' > /root/.bowerrc
RUN wget http://mirror.netcologne.de/apache.org/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz && \
   tar -xvf zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz -C ${ZEPPELIN_HOME} --strip=1 && \
   rm -rf zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz
RUN chown -R ${ZEPPELIN_USER}:${ZEPPELIN_GROUP} ${ZEPPELIN_HOME}
RUN chown -R ${ZEPPELIN_USER}:${ZEPPELIN_GROUP} ${ZEPPELIN_NOTEBOOK_DIR}

##########################################
### VOLUMES
##########################################
VOLUME ${ZEPPELIN_NOTEBOOK_DIR}
VOLUME ${ZEPPELIN_LOCAL_DATASETS}

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