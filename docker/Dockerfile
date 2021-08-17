FROM databricksruntime/genomics-azure:8.x AS builder

# ===== Set up Hail ================================================================================

ENV HAIL_VERSION=0.2.74
ENV SCALA_VERSION=2.12
ENV SPARK_VERSION=3.1.2
# maybe we can specify that the earliest version is 0.2.65

RUN apt-get update && apt-get install -y \
    openjdk-8-jre-headless \
    g++ \
    libopenblas-base liblapack3 \
    liblz4-1 liblz4-dev liblz4-tool \
    rsync python-setuptools

# RUN cd / && git clone https://github.com/hail-is/hail.git && cd hail
RUN cd / && git clone --depth 1 --branch ${HAIL_VERSION} https://github.com/hail-is/hail.git && cd hail
# RUN git fetch -a
# RUN git checkout tags/$HAIL_VERSION 
# docker doesn't work with tag checkouts
# error: pathspec 'tags/0.2.74' did not match any file(s) known to git. :-(
# RUN /databricks/conda/envs/dcs-minimal/bin/pip install -U setuptools
ENV PATH=/databricks/conda/envs/dcs-minimal/bin/:$PATH
RUN cd /hail/hail && make install-on-cluster HAIL_COMPILE_NATIVES=1 SCALA_VERSION=$SCALA_VERSION SPARK_VERSION=$SPARK_VERSION

RUN /databricks/conda/envs/dcs-minimal/bin/pip install hail==$HAIL_VERSION
# RUN /databricks/conda/envs/dcs-minimal/bin/pip install /hail/hail/build/deploy/dist/hail-${HAIL_VERSION}-py3-none-any.whl
RUN mkdir /databricks/jars
RUN cp /hail/hail/python/hail/backend/hail-all-spark.jar /databricks/jars

RUN HAIL_HOME=$(/databricks/conda/envs/dcs-minimal/bin/pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')

ENV JAVA_OPTS="-Dspark.executor.extraClassPath=/databricks/jars/hail-all-spark.jar \
               -Dspark.driver.extraClassPath=/databricks/jars/hail-all-spark.jar \
               -Dspark.kryo.registrator=is.hail.kryo.HailKryoRegistrator \
               -Dspark.hadoop.fs.s3a.connection.maximum=5000 \
               -Dspark.serializer=org.apache.spark.serializer.KryoSerializer"

RUN echo ${JAVA_OPTS} > /root/java_opts

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1

SHELL ["/bin/bash", "-c"]

RUN mkdir -p /databricks/driver/conf
# RUN echo -e '\
#   [driver] {\n\
#     "spark.kryo.registrator" = "is.hail.kryo.HailKryoRegistrator"\n\
#     "spark.hadoop.fs.s3a.connection.maximum" = 5000\n\
#     "spark.serializer" = "org.apache.spark.serializer.KryoSerializer"\n\
#   }\n\
#   ' > /databricks/driver/conf/00-hail-spark-driver-defaults.conf

RUN mkdir -p /databricks/scripts/
# RUN echo -e '\
#   #!/bin/bash\n\
#   cat << EOF > /databricks/driver/conf/00-hail-spark-driver-defaults.conf\n\
#   [driver] {\n\
#     "spark.kryo.registrator" = "is.hail.kryo.HailKryoRegistrator"\n\
#     "spark.hadoop.fs.s3a.connection.maximum" = 5000\n\
#     "spark.serializer = "org.apache.spark.serializer.KryoSerializer"\n\
#   }\n\
#   EOF\n\
#   ' > /databricks/scripts/genomics_spark_setup.sh
ADD ./setup_hail.sh /databricks/scripts/setup_hail.sh

RUN JAVA_OPTS=$(cat /root/java_opts)

RUN cd /root/


