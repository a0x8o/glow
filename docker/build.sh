#!/bin/bash
docker build - < ./genomics.azure.dockerfile -t projectglow/genomics-azure:8.x --no-cache;
docker tag projectglow/genomics-axure:8.x a0x8o/genomics-databricks-azure:8.x;
docker push a0x8o/genomics-databricks-azure:8.x;
docker build - < ./glow.2.dockerfile -t projectglow/glow:1.0.1 --no-cache;
docker tag projectglow/glow:1.0.1 a0x8o/glow-databricks:1.0.1;
docker push a0x8o/glow-databricks:1.0.1;
