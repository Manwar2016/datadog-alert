#!/bin/bash
# Create Remaining Disk Monitor for Diego Cells
# Developer: Arunava Basu (arunava.basu@nbcuni.com)
#
### Variable list:
# 1. api_key -> From Datadog SaaS UI
# 2. app_key -> From Datadog SaaS UI
# 3. datadog_metric_prefix -> From Ops manager UI -> datadog ECS tile -> Settings -> Datadog Properties -> Metric Prefix
# 4. instance_ip -> From Ops manager UI -> ERT Tile -> Status -> Diego Cells -> IPS
# 5. environment_name -> User Given. Please use  the current naming convention. For example, DevASZ or ProdAOA or LabASH.
#
## Usage:
# ./create_diego_remaining_disk_monitor.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -i 172.28.98.35 -e ProdASZ
#
if [ $# -ne 10 ]
  then
    echo "Usage: ./create_diego_remaining_disk_monitor.sh -a <API_KEY> -p <APP_KEY> -m <DATADOG_METRIC_PREFIX> -i <INSTANCE_IP> -e <ENVIRONMENT_NAME>"
    echo "For Example, ./create_diego_remaining_disk_monitor.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -i 172.28.98.35 -e ProdASZ"
    echo "Please provide API_KEY, APP_KEY, DATADOG_METRIC_PREFIX, INSTANCE_IP and ENVIRONMENT_NAME. You will get all the data from Ops manager UI except API_KEY, APP_KEY & ENVIRONMENT_NAME."
    exit 0
fi
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -a|--api_key)
    api_key="$2"
    shift
    ;;
    -p|--app_key)
    app_key="$2"
    shift
    ;;
    -m|--datadog_metric_prefix)
    datadog_metric_prefix="$2"
    shift
    ;;
    -i|--instance_ip)
    instance_ip="$2"
    shift
    ;;
    -e|--environment_name)
    environment_name="$2"
    shift
    ;;
    *)
    echo "Usage: ./create_diego_remaining_disk_monitor.sh -a <API_KEY> -p <APP_KEY> -m <DATADOG_METRIC_PREFIX> -i <INSTANCE_IP> -e <ENVIRONMENT_NAME>"
    echo "For Example, ./create_diego_remaining_disk_monitor.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -i 172.28.98.35 -e ProdASZ"
    echo "Please provide API_KEY, APP_KEY, DATADOG_METRIC_PREFIX, INSTANCE_IP and ENVIRONMENT_NAME. You will get all the data from Ops manager UI except API_KEY, APP_KEY & ENVIRONMENT_NAME."
    exit 0
    ;;
esac
shift
done

# check diego_remaining_disk.json exists?
if [ ! -f ./diego_remaining_disk.json ]; then
    echo "Error: diego_remaining_disk.json not found!!"
    echo "Error: Please add diego_remaining_disk.json file!!"
    exit 0
fi

logfile="./monitor_automation_output.log"
rm -rf ./diego_remaining_disk_tmp.json
cp -p diego_remaining_disk.json diego_remaining_disk_tmp.json
sed -i "s/datadog_metric_prefix/$datadog_metric_prefix/g" diego_remaining_disk_tmp.json
sed -i "s/instance_ip/$instance_ip/g" diego_remaining_disk_tmp.json
sed -i "s/environment_name/$environment_name/g" diego_remaining_disk_tmp.json
    
# Create Monitor REST API call
create_monitor_api_response=$(curl -s -X POST -H "Content-type: application/json" -d @diego_remaining_disk_tmp.json "https://app.datadoghq.com/api/v1/monitor?api_key=${api_key}&application_key=${app_key}")
  
# Returning Monitor ID
new_monitor_id=$(echo $create_monitor_api_response | jq -r .id)
new_monitor_name=$(echo $create_monitor_api_response | jq -r .name)
echo "Info: New Diego Remaining Disk Monitor Details:  ID: $new_monitor_id -> Name: \"$new_monitor_name\""
echo "Info: New Diego Remaining Disk Monitor Details:  ID: $new_monitor_id -> Name: \"$new_monitor_name\"" >> $logfile
