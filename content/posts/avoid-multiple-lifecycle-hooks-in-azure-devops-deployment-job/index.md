---
title: "Avoid Multiple Lifecycle Hooks in Azure Devops Deployment Job"
summary: Optimizing Azure DevOps pipelines by minimizing lifecycle hooks improves variable consistency across deployment stages.
date: 2024-05-08T08:53:47-05:00
lastmod: 2024-05-15T09:00:00-05:00
draft: false
categories: ["Dev"]
tags: ["obs", "cicd", "azure-devops", "azure"]
thumbnail: posts/avoid-multiple-lifecycle-hooks-in-azure-devops-deployment-job/feature.jpg
---

In Azure DevOps, it's recommended to manage CI/CD processes with an Infrastructure-as-Code strategy, which requires defining one or multiple YAML pipelines. When using such a pipeline, usually a multi-staged pipeline, in CD processes, we don't even need the "Release" option in the UI anymore. All actions are consolidated under Pipelines > Pipelines in Azure DevOps.

For the CD process, we usually define a Deployment Job to control the release process. However, there is a strange situation where the pipeline fails to read the variables defined or generated in the previous stages.

## Background

- I have a multi-stage pipeline.
- The stage contains a deployment job.
- Deployment job has `preDeploy`, `deploy` , and other stages.
- There is a task in `preDeploy` to output a variable in the first stage.

A task in the stage before the deployment job is used to read a variable from an external variable group and save it as `myStepVariable`:

```yaml
- bash: |
    echo "##vso[task.setvariable variable=myStepVariable;isOutput=true]$(vgroup-var1)"
  name: step_gen_myStepVariable
```

In deployment job stage, a variable is defined using an expression to recall the variable created in the previous stage:

```yaml
- stage: stage_deployMyApp
  dependsOn: stage_prepareVariable
  variables:
    myDeployVariable: $[ stageDependencies.stage_prepareVariable.job_saveVariable.outputs['job_saveVariable.step_gen_myStepVariable.myStepVariable'] ]
```

There is a deployment job in same stage to print out the variable:

```yaml
- bash: |
    echo $(myPreReleaseVariable)
	name: printSharedVariable
```

### Observation

It is expected that the task will echo the value defined in the variable. However, it prints nothing.

### Example of a complete Pipeline

This is a minimal yet complete example of the pipeline:

```yaml
trigger:
- master
 
resources:
- repo: self
 
pool:
  vmImage: 'ubuntu-16.04'
 
variables:
- group: vgroup # vgroup-var1 is defined in this group
 
stages:
  - stage: stage_prepareVariable
  
    jobs:
    - job: job_saveVariable
      steps:
        # create a variable named myStepVariable in the pipeline
        - bash: |
            echo "##vso[task.setvariable variable=myStepVariable;isOutput=true]$(vgroup-var1)"
            name: step_gen_myStepVariable

  - stage: stage_deployMyApp
    dependsOn: stage_prepareVariable
    variables:
        # pull the variable form previous stage
      myDeployVariable: $[ stageDependencies.stage_prepareVariable.job_saveVariable.outputs['job_saveVariable.step_gen_myStepVariable.myStepVariable'] ]
    
    jobs:
    - deployment: deploy_staging
      strategy:                  
        runOnce:
          preDeploy:
            steps:
            - script: echo preDeploy stage... 
            # myDeployVariable become empty here
            - bash: |
                echo $(myDeployVariable)
              name: step_printVariable_preDeploy
          deploy:
            steps:
            - script: echo deploy stage... 
            # myDeployVariable become empty here
            - bash: |
                echo $(myDeployVariable)
              name: step_printVariable_deploy
```

## Actual vs. Expected Result

Run the Azure Pipeline. As long as the previous stage has directives like `preDeploy` and `deploy`, the variable will become `Null`

However, if the previous stage has **only one** directive i.e. `deploy`, the variable will be set.

It is supposed to have the value of `vgroup-var1`, which is defined in an Azure DevOps variable group.

## Thoughts and Temporary Solution
Defining multiple stages in a deployment job is useful to identify the deployment lifecycle events. However, under some rare cases like the one described above, the variable injected does not pass the value to the downstream stages and tasks.

In the end, I stopped using the directives and grouped all the tasks under one stage, i.e., deploy only. The pipeline works, and I am still able to carry forward the variables and make successful deployments.

## Reference

[Define variables - Azure Pipelines | Microsoft Learn](https://learn.microsoft.com/en-us/azure/devops/pipelines/process/variables?view=azure-devops&tabs=yaml%2Cbatch#use-outputs-in-a-different-stage)

[Set a multi-job output variable does not work for deployments · Issue #4946 · MicrosoftDocs/azure-devops-docs · GitHub](https://github.com/MicrosoftDocs/azure-devops-docs/issues/4946)

[Variables across stages : r/azuredevops (reddit.com)](https://www.reddit.com/r/azuredevops/comments/gvo3ml/variables_across_stages/)

https://stackoverflow.com/questions/61216069/sharing-variables-between-deployment-job-lifecycle-hooks-in-azure-devops-pipelin

[Share Variables between Stages, Deployment : r/azuredevops (reddit.com)](https://www.reddit.com/r/azuredevops/comments/ma7j7h/share_variables_between_stages_deployment/)

_(cover image generated by [ChatGPT](https://chat.openai.com).)_