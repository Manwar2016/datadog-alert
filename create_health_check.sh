#!/bin/bash
# Create Health-Check Monitor
# Developer: Arunava Basu (arunava.basu@nbcuni.com)
#
### Variable list:
# 1. api_key -> From Datadog SaaS UI
# 2. app_key -> From Datadog SaaS UI
# 3. datadog_metric_prefix -> From Ops manager UI -> datadog ECS tile -> Settings -> Datadog Properties -> Metric Prefix
# 4. deployment_name -> From Ops manager UI or `bosh deployments` command
# 5. job_name -> From `bosh deployments` or from Ops manager UI -> ERT Tile -> Status -> Hover the mouse over the Logs section -> below left you can see the job name
# 6. index_no -> From Ops manager UI -> ERT Tile -> Status -> Index
# 7. instance_ip -> From Ops manager UI -> ERT Tile -> Status -> IPS
# 8. environment_name -> User Given. Please use  the current naming convention. For example, DevASZ or ProdAOA or LabASH.
#
## Usage:
# ./create_health_check.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -d cf-3aa13ea6f84746c30cdd -j cloud_controller -n 0 -i 172.28.98.35 -e ProdASZ
#
if [ $# -ne 16 ]
  then
    echo "Usage: ./create_health_check.sh -a <API_KEY> -p <APP_KEY> -m <DATADOG_METRIC_PREFIX> -d <DEPLOYMENT_NAME> -j <JOB_NAME> -n <INDEX_NUMBER> -i <INSTANCE_IP> -e <ENVIRONMENT_NAME>"
    echo "For Example, ./create_health_check.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -d cf-3aa13ea6f84746c30cdd -j cloud_controller -n 0 -i 172.28.98.35 -e ProdASZ"
    echo "Please provide API_KEY, APP_KEY, DATADOG_METRIC_PREFIX, DEPLOYMENT_NAME, JOB_NAME, INDEX_NUMBER, INSTANCE_IP and ENVIRONMENT_NAME. You will get all the data from Ops manager UI except API_KEY, APP_KEY & ENVIRONMENT_NAME."
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
    -d|--deployment_name)
    deployment_name="$2"
    shift
    ;;
    -j|--job_name)
    job_name="$2"
    shift
    ;;
    -n|--index_number)
    index_no="$2"
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
    echo "Usage: ./create_health_check.sh -a <API_KEY> -p <APP_KEY> -m <DATADOG_METRIC_PREFIX> -d <DEPLOYMENT_NAME> -j <JOB_NAME> -n <INDEX_NUMBER> -i <INSTANCE_IP> -e <ENVIRONMENT_NAME>"
    echo "For Example, ./create_health_check.sh -a 27af6********* -p 39ab6******* -m sysasz.datadog.nozzle. -d cf-3aa13ea6f84746c30cdd -j cloud_controller -n 0 -i 172.28.98.35 -e ProdASZ"
    echo "Please provide API_KEY, APP_KEY, DATADOG_METRIC_PREFIX, DEPLOYMENT_NAME, JOB_NAME, INDEX_NUMBER, INSTANCE_IP and ENVIRONMENT_NAME. You will get all the data from Ops manager UI except API_KEY, APP_KEY & ENVIRONMENT_NAME."
    exit 0
    ;;
esac
shift
done

# check health_check.json exists?
if [ ! -f ./health_check.json ]; then
    echo "Error: health_check.json not found!!"
    echo "Error: Please add health_check.json file!!"
    exit 0
fi

logfile="./monitor_automation_output.log"
rm -rf ./health_check_tmp.json
cp -p health_check.json health_check_tmp.json
sed -i "s/datadog_metric_prefix/$datadog_metric_prefix/g" health_check_tmp.json
sed -i "s/deployment_name/$deployment_name/g" health_check_tmp.json
sed -i "s/job_name/$job_name/g" health_check_tmp.json
sed -i "s/index_no/$index_no/g" health_check_tmp.json
sed -i "s/instance_ip/$instance_ip/g" health_check_tmp.json
sed -i "s/environment_name/$environment_name/g" health_check_tmp.json
    
# Create Monitor REST API call
create_monitor_api_response=$(curl -s -X POST -H "Content-type: application/json" -d @health_check_tmp.json "https://app.datadoghq.com/api/v1/monitor?api_key=${api_key}&application_key=${app_key}")
  
# Returning Monitor ID
new_monitor_id=$(echo $create_monitor_api_response | jq -r .id)
new_monitor_name=$(echo $create_monitor_api_response | jq -r .name)
echo "Info: New Health Check Monitor Details:  ID: $new_monitor_id -> Name: \"$new_monitor_name\""
echo "Info: New Health Check Monitor Details:  ID: $new_monitor_id -> Name: \"$new_monitor_name\"" >> $logfile
