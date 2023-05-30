// Parameters
@description('The name of the AKS Cluster to configure the alerts on.')
param aksClusterName string

@description('Specifies the resource tags.')
param tags object

@description('Select the frequency on how often the alert rule should be run. Selecting frequency smaller than granularity of datapoints grouping will result in sliding window evaluation')
@allowed([
  'PT1M'
  'PT15M'
])
param evalFrequency string = 'PT1M'

@description('Specifies whether metric alerts as either enabled or disabled.')
param metricAlertsEnabled bool = true

@description('Defines the interval over which datapoints are grouped using the aggregation type function')
@allowed([
  'PT5M'
  'PT1H'
])
param windowSize string = 'PT5M'

@allowed([
  'Critical'
  'Error'
  'Warning'
  'Informational'
  'Verbose'
])
param alertSeverity string = 'Informational'

var alertServerityLookup = {
  Critical: 0
  Error: 1
  Warning: 2
  Informational: 3
  Verbose: 4
}
var alertSeverityNumber = alertServerityLookup[alertSeverity]

var AksResourceId = resourceId('Microsoft.ContainerService/managedClusters', aksClusterName)

resource nodeCpuUtilizationHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Node CPU utilization high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'host'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'cpuUsagePercentage'
          metricNamespace: 'Insights.Container/nodes'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'Node CPU utilization across the cluster.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource nodeWorkingSetMemoryUtilizationHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Node working set memory utilization high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'host'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'memoryWorkingSetPercentage'
          metricNamespace: 'Insights.Container/nodes'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'Node working set memory utilization across the cluster.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource jobsCompletedMoreThanSixHoursAgoForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Jobs completed more than 6 hours ago'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'completedJobsCount'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors completed jobs (more than 6 hours ago).'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource containerCpuUsageHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Container CPU usage high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'cpuExceededPercentage'
          metricNamespace: 'Insights.Container/containers'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 90
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors container CPU utilization.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource containerWorkingSetMemoryUsageHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Container working set memory usage high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'memoryWorkingSetExceededPercentage'
          metricNamespace: 'Insights.Container/containers'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 90
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors container working set memory utilization.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource podsInFailedStateForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Pods in failed state'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'phase'
              operator: 'Include'
              values: [
                'Failed'
              ]
            }
          ]
          metricName: 'podCount'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'Pod status monitoring.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource diskUsageHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Disk usage high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'host'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'device'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'DiskUsedPercentage'
          metricNamespace: 'Insights.Container/nodes'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors disk usage for all nodes and storage devices.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource nodesInNotReadyStateForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Nodes in not ready state'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'status'
              operator: 'Include'
              values: [
                'NotReady'
              ]
            }
          ]
          metricName: 'nodesCount'
          metricNamespace: 'Insights.Container/nodes'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'Node status monitoring.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource containersGettingOomKilledForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Containers getting OOM killed'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'oomKilledContainerCount'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors number of containers killed due to out of memory (OOM) error.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource persistentVolumeUsageHighForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Persistent volume usage high'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'podName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetesNamespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'pvUsageExceededPercentage'
          metricNamespace: 'Insights.Container/persistentvolumes'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 80
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors persistent volume utilization.'
    enabled: false
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource podsNotInReadyStateForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Pods not in ready state'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'PodReadyPercentage'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'LessThan'
          threshold: 80
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors for excessive pods not in the ready state.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'microsoft.containerservice/managedclusters'
    windowSize: windowSize
  }
}

resource restartingContainerCountForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Restarting container count'
  location: 'global'
  tags: tags
  properties: {
    criteria: {
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          dimensions: [
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          metricName: 'restartingContainerCount'
          metricNamespace: 'Insights.Container/pods'
          name: 'Metric1'
          operator: 'GreaterThan'
          threshold: 0
          timeAggregation: 'Average'
          skipMetricValidation: true
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    description: 'This alert monitors number of containers restarting across the cluster.'
    enabled: metricAlertsEnabled
    evaluationFrequency: evalFrequency
    scopes: [
      AksResourceId
    ]
    severity: alertSeverityNumber
    targetResourceType: 'Microsoft.ContainerService/managedClusters'
    windowSize: windowSize
  }
}

resource containerCpuUsageViolatesTheConfiguredThresholdForAksCluster 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Container CPU usage violates the configured threshold'
  location: 'global'
  tags: tags
  properties: {
    description: 'This alert monitors container CPU usage. It uses the threshold defined in the config map.'
    severity: alertSeverityNumber
    enabled: true
    scopes: [
      AksResourceId
    ]
    evaluationFrequency: evalFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          threshold: 0
          name: 'Metric1'
          metricNamespace: 'Insights.Container/containers'
          metricName: 'cpuThresholdViolated'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: true
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
  }
}

resource containerWorkingSetMemoryUsageViolatesTheConfiguredThresholdForAksCluster 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Container working set memory usage violates the configured threshold'
  location: 'global'
  tags: tags
  properties: {
    description: 'This alert monitors container working set memory usage. It uses the threshold defined in the config map.'
    severity: alertSeverityNumber
    enabled: metricAlertsEnabled
    scopes: [
      AksResourceId
    ]
    evaluationFrequency: evalFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          threshold: 0
          name: 'Metric1'
          metricNamespace: 'Insights.Container/containers'
          metricName: 'memoryWorkingSetThresholdViolated'
          dimensions: [
            {
              name: 'controllerName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetes namespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: true
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
  }
}


resource pvUsageViolatesTheConfiguredThresholdForAksCluster 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${aksClusterName} | Persistent Volume usage violates the configured threshold'
  location: 'global'
  tags: tags
  properties: {
    description: 'This alert monitors Persistent Volume usage. It uses the threshold defined in the config map.'
    severity: alertSeverityNumber
    enabled: metricAlertsEnabled
    scopes: [
      AksResourceId
    ]
    evaluationFrequency: evalFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
          threshold: 0
          name: 'Metric1'
          metricNamespace: 'Insights.Container/persistentvolumes'
          metricName: 'pvUsageThresholdViolated'
          dimensions: [
            {
              name: 'podName'
              operator: 'Include'
              values: [
                '*'
              ]
            }
            {
              name: 'kubernetesNamespace'
              operator: 'Include'
              values: [
                '*'
              ]
            }
          ]
          operator: 'GreaterThan'
          timeAggregation: 'Average'
          skipMetricValidation: true
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
  }
}
