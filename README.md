# datadog-monitoring-automation
version 2.0.0

**Prerequisites**
```
$ yum install -y jq python-yaml
```

Input File: [environment_details_for_monitor_creation.yml](https://github.inbcu.com/206528261/datadog-monitoring-automation/blob/ecs-dd/environment_details_for_monitor_creation.yml)

### Input Variable list:

* 1. `api_key` -> From Datadog SaaS UI
* 2. `app_key` -> From Datadog SaaS UI
* 3. `datadog_metric_prefix` -> From Ops manager UI -> datadog ECS tile -> Settings -> Datadog Properties -> Metric Prefix
* 4. `job_name` -> From `bosh deployments` command or from Ops manager UI -> ERT Tile -> Status -> Hover the mouse over the Logs section -> below left you can see the job name. For example, `diego_cell`
* 5. `index_no` -> From Ops manager UI -> ERT Tile -> Status -> Index
* 6. `instance_ip` -> From Ops manager UI -> ERT Tile -> Status -> IPS
* 7. `environment_name` -> User Given. Please use  the current naming convention. For example, DevASZ or ProdAOA or LabASH.
* 8. `cf_deployment`:  From `bosh deployments`
* 9. `rabbit_deployment`:  From `bosh deployments`
* 10. `redis_deployment`:  From `bosh deployments`
* 11. `mysql_deployment`:  From `bosh deployments`

### Usage:
```
$ git clone git@github.inbcu.com:206528261/datadog-monitoring-automation.git
# You can download this repository as well from https://github.inbcu.com/206528261/datadog-monitoring-automation/archive/ecs-dd.zip
$ cd datadog-monitoring-automation
$ git checkout ecs-dd
$ chmod +x *.sh

# Update the environment_details_for_monitor_creation.yml file as per your environment data.
$ ./create_monitors.sh
```
