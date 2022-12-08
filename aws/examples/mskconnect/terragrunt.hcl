terraform {
  source = "../..//module/mskconnect"

}

include root {
  path = find_in_parent_folders()
  expose =true
}


inputs = {


  #### create mskconnect_custom_plugin
  ##  key == value.mskconnect_custom_plugin_name  :  keep them same 

  aws_mskconnect_custom_plugin = {
    "debezium-connector-postgres-1-9-0-kafka-config-provider-aws-0-1-1" = {
      mskconnect_custom_plugin_name = "debezium-connector-postgres-1-9-0-kafka-config-provider-aws-0-1-1"
      description = "debezium-connector-postgres-1-9-0-kafka-config-provider-aws-0-1-1"
      s3_bucket_arn = "arn:aws:s3:::bus2-cdc-plugins-bucket"
      s3_file_key = "debezium-connector-postgres-1.9.0-kafka-config-provider-aws-0.1.1.zip"
    }

    "confluentinc-kafka-connect-elasticsearch-11-1-10-kafka-config-provider-aws-0-1-1" = {
      mskconnect_custom_plugin_name = "confluentinc-kafka-connect-elasticsearch-11-1-10-kafka-config-provider-aws-0-1-1"
      description = "confluentinc-kafka-connect-elasticsearch-11.1.10-kafka-config-provider-aws-0.1.1"
      s3_bucket_arn = "arn:aws:s3:::bus2-cdc-plugins-bucket"
      s3_file_key = "confluentinc-kafka-connect-elasticsearch-11.1.10-kafka-config-provider-aws-0.1.1.zip"
    }

  }

### create mskconnect_connector
  aws_mskconnect_connector = {
    aceup-cdc-debezium-pft = {
      name = "aceup-cdc-debezium-pft"
      connector_configuration = {
        "connector.class"="io.debezium.connector.postgresql.PostgresConnector"
        "transforms.unwrap.delete.handling.mode"="rewrite"
        "max.queue.size"="102400"
        "slot.name"="enterprise_tag_pt_slot_20220621"
        "tasks.max"="1"
        "publication.name"="enterprise_tag_pt_pub_20220621"
        "retriable.restart.connector.wait.ms"="60000"
        "transforms"="unwrap"
        "schema.include.list"="public"
        "slot.max.retries"="9999"
        "slot.retry.delay.ms"="10000"
        "heartbeat.action.query"="insert into public.debezium_heartbeat_enterprise_tag_pt_pub_20220621(create_date) select now()"
        "decimal.handling.mode"="string"
        "transforms.unwrap.drop.tombstones"="false"
        "poll.interval.ms"="100"
        "transforms.unwrap.type"="io.debezium.transforms.ExtractNewRecordState"
        "value.converter"="org.apache.kafka.connect.json.JsonConverter"
        "snapshot.fetch.size"="51200"
        "key.converter"="org.apache.kafka.connect.json.JsonConverter"
        "database.tcpKeepAlive"="true"
        "publication.autocreate.mode"="all_tables"
        "database.user"="logicalrepluser"
        "database.dbname"="enterprise_tag_pt"
        "slot.drop.on.stop"="false"
        "+status.update.interval.ms"="10000"
        "xmin.fetch.interval.ms"="10000"
        "database.server.name"="enterprise_tag_pt"
        "heartbeat.interval.ms"="30000"
        "database.port"="5432"
        "plugin.name"="pgoutput"
        "schema.ignore"="true"
        "database.hostname"="bus2-aceup-rdsdb.cluster-cizbs0pn8xxx.ap-southeast-1.rds.amazonaws.com"
        "database.password"="xxxxxxxxxxxxxxxx"
        "value.converter.schemas.enable"="false"
        "transforms.unwrap.add.fields"="op,db,table,schema,lsn,source.ts_ms"
        "table.include.list"="public.debezium_heartbeat_enterprise_tag_pt_pub_20220621,public.scheme_uid"
        "max.batch.size"="51200"
        "snapshot.mode"="initial"
      }
      bootstrap_servers = "b-3.bus2cdcpft.pinshv.c5.kafka.ap-southeast-1.amazonaws.com:9098,b-2.bus2cdcpft.pinshv.c5.kafka.ap-southeast-1.amazonaws.com:9098,b-1.bus2cdcpft.pinshv.c5.kafka.ap-southeast-1.amazonaws.com:9098"
      security_groups = ["sg-xxxxxxxxxxxx"]
      subnets = ["subnet-xxxxxxxxxxxxx","subnet-xxxxxxxxxxxxx","subnet-xxxxxxxxxxxxx"]
      authentication_type = "IAM"
      mskconnect_custom_plugin_name = "debezium-connector-postgres-1-9-0-kafka-config-provider-aws-0-1-1"
      service_execution_role_arn = "arn:aws:iam::123456789012:role/msk-connect-role"  
    }


    aceup-es-confluent-pft = {
      name = "aceup-es-confluent-pft"
      connector_configuration = {
        "connector.class"="io.confluent.connect.elasticsearch.ElasticsearchSinkConnector"
        "type.name"="_doc"
        "connection.password"="Msk-xxxxxxxxxx"
        "tasks.max"="2"
        "topics"="enterprise_tag_pt.public.scheme_uid"
        "connection.username"="msk-devops"
        "transforms"="unwrap,key"
        "key.ignore"="true"
        "schema.ignore"="true"
        "key.converter.schemas.enable"="false"
        "transforms.key.field"="id"
        "transforms.key.type"="org.apache.kafka.connect.transforms.ExtractField$Key"
        "name"="aceup-es-confluent-pft" 
        "value.converter.schemas.enable"="false"
        "transforms.unwrap.add.fields"="op,lsn,source.ts_ms"
        "transforms.unwrap.type"="io.debezium.transforms.ExtractNewRecordState"
        "value.converter"="org.apache.kafka.connect.json.JsonConverter"
        "connection.url"="https://vpc-cdc-es-pft-xxxxxxxxxxxxxxxx.ap-southeast-1.es.amazonaws.com"
        "key.converter"="org.apache.kafka.connect.json.JsonConverter"

   
      }
      bootstrap_servers = "b-1.bus2cdcpft.xxxxxx.c5.kafka.ap-southeast-1.amazonaws.com:9098,b-3.bus2cdcpft.pinshv.c5.kafka.ap-southeast-1.amazonaws.com:9098,b-2.bus2cdcpft.pinshv.c5.kafka.ap-southeast-1.amazonaws.com:9098"
      security_groups = ["sg-xxxxxxxxxxxxxx"]
      subnets = ["subnet-xxxxxxxxxxx","subnet-xxxxxxxxxxx","subnet-xxxxxxxxxxx"]
      authentication_type = "IAM"
      mskconnect_custom_plugin_name = "confluentinc-kafka-connect-elasticsearch-11-1-10-kafka-config-provider-aws-0-1-1"
      service_execution_role_arn = "arn:aws:iam::123456789012:role/msk-connect-role"  
      log_group = "/aws/msk-connect/confluent/logs"
    }
  }

}
