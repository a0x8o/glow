FROM databricksruntime/genomics-azure:8.x AS builder

# ===== Set up Hail ================================================================================

ENV HAIL_VERSION=0.2.74
# maybe we can specify that the earliest version is 0.2.65

RUN apt-get update && apt-get install -y \
    openjdk-8-jre-headless \
    g++ \
    libopenblas-base liblapack3 \
    liblz4-1 liblz4-dev liblz4-tool \
    rsync 

RUN /databricks/conda/envs/dcs-minimal/bin/pip install hail==$HAIL_VERSION
RUN hail_jar_path=$(find /databricks/conda/envs/dcs-minimal/lib -name 'hail-all-spark.jar')
## NOTE: Jar is in /databricks/conda/envs/dcs-minimal/lib/python3.7/site-packages/hail/backend/hail-all-spark.jar
RUN mkdir /databricks/jars
RUN cp /databricks/conda/envs/dcs-minimal/lib/python3.7/site-packages/hail/backend/hail-all-spark.jar /databricks/jars

RUN HAIL_HOME=$(/databricks/conda/envs/dcs-minimal/bin/pip show hail | grep Location | awk -F' ' '{print $2 "/hail"}')

RUN mkdir -p /databricks/driver/conf
RUN echo -e '\
[driver] {\n\
  "spark.kryo.registrator" = "is.hail.kryo.HailKryoRegistrator"\n\
  "spark.hadoop.fs.s3a.connection.maximum" = 5000\n\
  "spark.serializer" = "org.apache.spark.serializer.KryoSerializer"\n\
}\n\
' > /databricks/driver/conf/00-hail.conf




