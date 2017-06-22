#!/bin/bash
start=$(date +%s)
logfile="./monitor_automation_output.log"
> $logfile

yaml_file="environment_details_for_monitor_creation.yml"

# sudo yum install python-yaml jq
python -c 'import sys, yaml, json; json.dump(yaml.load(sys.stdin), sys.stdout, indent=2)' < $yaml_file > ./tmp_monitors.json
monitor_json_data=$(cat ./tmp_monitors.json)

environment_name=$(echo $monitor_json_data | jq -r '.environment_name')
datadog_api_key=$(echo $monitor_json_data | jq -r '.datadog_api_key')
datadog_app_key=$(echo $monitor_json_data | jq -r '.datadog_app_key')
datadog_metric_prefix=$(echo $monitor_json_data | jq -r '.datadog_metric_prefix')
cf_deployment=$(echo $monitor_json_data | jq -r '.cf_deployment')
rabbit_deployment=$(echo $monitor_json_data | jq -r '.rabbit_deployment')
redis_deployment=$(echo $monitor_json_data | jq -r '.redis_deployment')
mysql_deployment=$(echo $monitor_json_data | jq -r '.mysql_deployment')

# To check the values===
#echo $environment_name
#echo $datadog_api_key
#echo $datadog_app_key
#echo $datadog_metric_prefix
#echo $cf_deployment
#echo $rabbit_deployment
#echo $redis_deployment
#echo $mysql_deployment

ert_json=$(echo $monitor_json_data | jq -r '.ert')
rabbitmq_json=$(echo $monitor_json_data | jq -r '.rabbitmq')
redis_json=$(echo $monitor_json_data | jq -r '.redis')
mysql_json=$(echo $monitor_json_data | jq -r '.mysql')

# 1. ERT Health-Check
echo "...............Elastic Runtime.............."
ert_jobs_length=$(echo $ert_json | jq ".|keys|length")
for ((i=0; i<$ert_jobs_length; i++)); do 
  job_name=$(echo $ert_json | jq ".|keys[$i]") 
  #echo $job_name
  #job_data=$(echo $ert_json | jq -r ".["$job_name"]")
  #echo $job_data
  index_length=$(echo $ert_json | jq -r ".["$job_name"]|length")
  #echo $index_length
  #index_numbers=$(echo $ert_json | jq -r ".["$job_name"]|keys")
  #echo $index_numbers
  for ((j=0; j<$index_length; j++)); do 
    index_number=$(echo $ert_json | jq -c ".["$job_name"]|keys[$j]")
    ip_address=$(echo $ert_json | jq -c ".["$job_name"]" | jq ".[$index_number]")
    echo $job_name : $index_number : $ip_address
    #### Invoking Create Health-Check Monitor class
    ./create_health_check.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -d $cf_deployment -j $job_name -n $index_number -i $ip_address -e $environment_name
  done  
done

# 2. RabbitMQ Health-Check
echo "...............RabbitMQ.............."
rabbitmq_jobs_length=$(echo $rabbitmq_json | jq ".|keys|length")
for ((i=0; i<$rabbitmq_jobs_length; i++)); do 
  job_name=$(echo $rabbitmq_json | jq ".|keys[$i]") 
  #echo $job_name
  #job_data=$(echo $rabbitmq_json | jq -r ".["$job_name"]")
  #echo $job_data
  index_length=$(echo $rabbitmq_json | jq -r ".["$job_name"]|length")
  #echo $index_length
  #index_numbers=$(echo $rabbitmq_json | jq -r ".["$job_name"]|keys")
  #echo $index_numbers
  for ((j=0; j<$index_length; j++)); do 
    index_number=$(echo $rabbitmq_json | jq -c ".["$job_name"]|keys[$j]")
    ip_address=$(echo $rabbitmq_json | jq -c ".["$job_name"]" | jq ".[$index_number]")
    echo $job_name : $index_number : $ip_address
    #### Invoking Create Health-Check Monitor class
    ./create_health_check.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -d $rabbit_deployment -j $job_name -n $index_number -i $ip_address -e $environment_name
  done
done

# 3. Redis Health-Check
echo "...............Redis.............."
redis_jobs_length=$(echo $redis_json | jq ".|keys|length")
for ((i=0; i<$redis_jobs_length; i++)); do 
  job_name=$(echo $redis_json | jq ".|keys[$i]") 
  #echo $job_name
  #job_data=$(echo $redis_json | jq -r ".["$job_name"]")
  #echo $job_data
  index_length=$(echo $redis_json | jq -r ".["$job_name"]|length")
  #echo $index_length
  #index_numbers=$(echo $redis_json | jq -r ".["$job_name"]|keys")
  #echo $index_numbers
  for ((j=0; j<$index_length; j++)); do 
    index_number=$(echo $redis_json | jq -c ".["$job_name"]|keys[$j]")
    ip_address=$(echo $redis_json | jq -c ".["$job_name"]" | jq ".[$index_number]")
    echo $job_name : $index_number : $ip_address
    #### Invoking Create Health-Check Monitor class
    ./create_health_check.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -d $redis_deployment -j $job_name -n $index_number -i $ip_address -e $environment_name
  done
done

# 4. Mysql Health-Check
echo "...............MySQL.............."
mysql_jobs_length=$(echo $mysql_json | jq ".|keys|length")
for ((i=0; i<$mysql_jobs_length; i++)); do 
  job_name=$(echo $mysql_json | jq ".|keys[$i]") 
  #echo $job_name
  #job_data=$(echo $mysql_json | jq -r ".["$job_name"]")
  #echo $job_data
  index_length=$(echo $mysql_json | jq -r ".["$job_name"]|length")
  #echo $index_length
  #index_numbers=$(echo $mysql_json | jq -r ".["$job_name"]|keys")
  #echo $index_numbers
  for ((j=0; j<$index_length; j++)); do 
    index_number=$(echo $mysql_json | jq -c ".["$job_name"]|keys[$j]")
    ip_address=$(echo $mysql_json | jq -c ".["$job_name"]" | jq ".[$index_number]")
    echo $job_name : $index_number : $ip_address
    #### Invoking Create Health-Check Monitor class
    ./create_health_check.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -d $mysql_deployment -j $job_name -n $index_number -i $ip_address -e $environment_name
  done
done

# 5. Diego Cell remaining Disk and Memory
echo "...............Diego Remaining Disk & Memory.............."
diego_cell_length=$(echo $ert_json | jq -r '.diego_cell|length')
diego_cell_json=$(echo $ert_json | jq -r '.diego_cell')
for ((i=0; i<$diego_cell_length; i++)); do 
  job_name="diego_cell"
  index_number=$(echo $diego_cell_json | jq -c ".|keys[$i]")
  ip_address=$(echo $diego_cell_json | jq -c ".[$index_number]")
  echo $job_name : $index_number : $ip_address
  #### Invoking Create Diego Remaining Disk Monitor class
  ./create_diego_remaining_disk_monitor.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -i $ip_address -e $environment_name
  #### Invoking Create Diego Remaining Memory Monitor class
  ./create_diego_remaining_memory_monitor.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -i $ip_address -e $environment_name
done

# 6. RabbitMQ Server Heartbeat
echo "...............RabbitMQ Server Heartbeat.............."
rabbitmq_server_length=$(echo $rabbitmq_json | jq '.["rabbitmq-server"]|length')
rabbitmq_server_json=$(echo $rabbitmq_json | jq '.["rabbitmq-server"]')
for ((i=0; i<$rabbitmq_server_length; i++)); do 
  job_name="rabbitmq-server"
  index_number=$(echo $rabbitmq_server_json | jq -c ".|keys[$i]")
  ip_address=$(echo $rabbitmq_server_json | jq -c ".[$index_number]")
  echo $job_name : $index_number : $ip_address
  #### Invoking RabbitMQ Server Heartbeat Monitor class
  ./create_rabbitmq_server_heartbeat_monitor.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -i $ip_address -e $environment_name
done

# 7. RabbitMQ Broker Heartbeat
echo "...............RabbitMQ Broker Heartbeat.............."
rabbitmq_broker_length=$(echo $rabbitmq_json | jq '.["rabbitmq-broker"]|length')
rabbitmq_broker_json=$(echo $rabbitmq_json | jq '.["rabbitmq-broker"]')
for ((i=0; i<$rabbitmq_broker_length; i++)); do 
  job_name="rabbitmq-broker"
  index_number=$(echo $rabbitmq_broker_json | jq -c ".|keys[$i]")
  ip_address=$(echo $rabbitmq_broker_json | jq -c ".[$index_number]")
  echo $job_name : $index_number : $ip_address
  #### Invoking Create RabbitMQ Broker Heartbeat Monitor class
  ./create_rabbitmq_service_broker_heartbeat_monitor.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -i $ip_address -e $environment_name
done

# 8. RabbitMQ haproxy Heartbeat
echo "...............RabbitMQ haproxy Heartbeat.............."
rabbitmq_haproxy_length=$(echo $rabbitmq_json | jq '.["rabbitmq-haproxy"]|length')
rabbitmq_haproxy_json=$(echo $rabbitmq_json | jq '.["rabbitmq-haproxy"]')
for ((i=0; i<$rabbitmq_haproxy_length; i++)); do 
  job_name="rabbitmq-haproxy"
  index_number=$(echo $rabbitmq_haproxy_json | jq -c ".|keys[$i]")
  ip_address=$(echo $rabbitmq_haproxy_json | jq -c ".[$index_number]")
  echo $job_name : $index_number : $ip_address
  #### Invoking Create RabbitMQ haproxy Heartbeat Monitor class
  ./create_rabbitmq_haproxy_heartbeat_monitor.sh -a $datadog_api_key -p $datadog_app_key -m $datadog_metric_prefix -i $ip_address -e $environment_name
done

end=$(date +%s)    
runtime_sec=$(python -c "print(${end} - ${start})")
runtime_min=$(awk "BEGIN {print $runtime_sec/60}")

# Cleaning temporary files
rm -rf *tmp*

echo -e "Script Runtime: $runtime_min minutes" >> $logfile
echo -e "Script Runtime: $runtime_min minutes"
echo -e "Info: Please find the $logfile file for output"
