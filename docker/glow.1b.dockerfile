# ===== For the runtime environment for this image we need the databricks azure setup ============== 

FROM projectglow/genomics-azure:8.4

# ===== Install python dependencies for Glow =======================================================

# Upgrade to Glow 1.1.0 when available
# ENV GLOW_VERSION=1.1.0
# once available, we want specify that the earliest version is 1.1.0

ENV GLOW_VERSION=1.0.1
ENV PYARROW_VERSION=1.0.1
ENV NUMPY_VERSION=1.19.2

RUN /databricks/conda/envs/dcs-minimal/bin/pip install glow.py==$GLOW_VERSION
RUN /databricks/conda/envs/dcs-minimal/bin/pip install numpy==$NUMPY_VERSION
RUN /databricks/conda/envs/dcs-minimal/bin/pip install pyarrow==$PYARROW_VERSION

# ===== Set up scala dependencies for Glow =========================================================

ENV GLOW_VERSION=1.0.1
ENV HADOOP_BAM_VERSION=7.9.1
ENV HTSJDK_VERSION=2.21.2
ENV PICARD_VERSION=2.23.3
ENV JDBI_VERSION=2.78

RUN mkdir /databricks/jars
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/io/projectglow/glow-spark3_2.12/${GLOW_VERSION}/glow-spark3_2.12-${GLOW_VERSION}.jar
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/org/seqdoop/hadoop-bam/${HADOOP_BAM_VERSION}/hadoop-bam-${HADOOP_BAM_VERSION}.jar
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/com/github/samtools/htsjdk/${HTSJDK_VERSION}/htsjdk-${HTSJDK_VERSION}.jar
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/com/github/broadinstitute/picard/${PICARD_VERSION}/picard-${PICARD_VERSION}.jar
RUN cd /databricks/jars && curl -O \
https://repo1.maven.org/maven2/org/jdbi/jdbi/${JDBI_VERSION}/jdbi-${JDBI_VERSION}.jar

## liftOver test dependencies
RUN mkdir /opt/liftover
RUN curl https://raw.githubusercontent.com/broadinstitute/gatk/master/scripts/funcotator/data_sources/gnomAD/b37ToHg38.over.chain --output /opt/liftover/b37ToHg38.over.chain

ENV JAVA_OPTS="-Dspark.executor.extraClassPath=/databricks/jars/glow-spark3_2.12-${GLOW_VERSION}.jar,/databricks/jars/hadoop-bam-${HADOOP_BAM_VERSION}.jar,/databricks/jars/htsjdk-${HTSJDK_VERSION}.jar,/databricks/jars/picard-${PICARD_VERSION}.jar,/databricks/jars/jdbi-${JDBI_VERSION}.jar \
               -Dspark.driver.extraClassPath=/databricks/jars/glow-spark3_2.12-${GLOW_VERSION}.jar,/databricks/jars/hadoop-bam-${HADOOP_BAM_VERSION}.jar,/databricks/jars/htsjdk-${HTSJDK_VERSION}.jar,/databricks/jars/picard-${PICARD_VERSION}.jar,/databricks/jars/jdbi-${JDBI_VERSION}.jar \
               -Dspark.serializer=org.apache.spark.serializer.KryoSerializer \
               -Dspark.hadoop.io.compression.codecs=io.projectglow.sql.util.BGZFCodec,org.seqdoop.hadoop_bam.util.BGZFEnhancedGzipCodec"

# ===== Reset current directory ====================================================================

RUN cd /root/