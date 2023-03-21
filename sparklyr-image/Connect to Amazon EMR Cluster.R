library(sparklyr)
library(dplyr)

cluster_id <- system(paste("aws emr list-clusters",
                           "--active",
                           "--query 'Clusters[0].Id'",
                           "--output text"), intern = TRUE)
private_dns_name <- system(paste("aws emr list-instances",
                                 "--cluster-id", cluster_id,
                                 "--instance-group-type MASTER",
                                 "--query 'Instances[0].PrivateDnsName'",
                                 "--output text"), intern = TRUE)
master_node <- paste0(private_dns_name, ":8998")
sc <- spark_connect(master = master_node, 
                    method = "livy", 
                    version = "3.3.0", 
                    config = livy_config(jars = "/user/hadoop/sparklyr-master-2.12.jar"))
