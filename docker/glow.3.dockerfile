# ===== For the runtime environment for this image we need the databricks azure setup ============== 
FROM databricksruntime/genomics-azure:8.x

# ===== Install python dependencies for Glow =======================================================
ENV GLOW_VERSION=1.1.0
# we want specify that the earliest version is 1.1.0

RUN /databricks/conda/envs/dcs-minimal/bin/pip install glow.py==$GLOW_VERSION

# ===== Set up scala dependencies for Glow =========================================================
ENV GLOW_VERSION=1.1.0
ENV HADOOP_BAM_VERSION=7.9.1

RUN mkdir /databricks/jars
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/io/projectglow/glow-spark3_2.12/${GLOW_VERSION}/glow-spark3_2.12-${GLOW_VERSION}.jar 
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/org/seqdoop/hadoop-bam/${HADOOP_BAM_VERSION}/hadoop-bam-${HADOOP_BAM_VERSION}.jar

ENV JAVA_OPTS="-Dspark.executor.extraClassPath=/databricks/jars/glow-spark3_2.12-${GLOW_VERSION}.jar,/databricks/jars/hadoop-bam-${HADOOP_BAM_VERSION}.jar \
               -Dspark.driver.extraClassPath=/databricks/jars/glow-spark3_2.12-${GLOW_VERSION}.jar,/databricks/jars/hadoop-bam-${HADOOP_BAM_VERSION}.jar \
               -Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
               -Dspark.hadoop.io.compression.codecs=io.projectglow.sql.util.BGZFCodec,org.seqdoop.hadoop_bam.util.BGZFEnhancedGzipCodec"

RUN cd /root/