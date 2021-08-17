  #!/bin/bash

  set -ex 
  set -o pipefail

  cat << EOF > /databricks/driver/conf/00-hail-spark-driver-defaults.conf
  [driver] {
    "spark.kryo.registrator" = "is.hail.kryo.HailKryoRegistrator"
    "spark.hadoop.fs.s3a.connection.maximum" = 5000
    "spark.serializer = "org.apache.spark.serializer.KryoSerializer"
  }
  EOF
