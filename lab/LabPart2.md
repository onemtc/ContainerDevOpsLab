# DevOps Lab Part 2 - Container Security

*This lab leverages [Trivy, from Azua](https://github.com/aquasecurity/trivy) as a simple container scanning tool.  AzDo integration tips come from [Pixel Robots Blog](https://pixelrobots.co.uk/2020/02/use-trivy-and-azure-devops-to-scan-container-images-for-vulnerabilities/)*


## Lab Goals: Scan a container for security vinerabilities as part of the build process


## Exercise 1 - Edit Build Pipeline to include Trivy task
In this exercise, we will add a task to our pipeline to scan the container for security vunerabilities.  Because there is no built-in task, we will call Trivy from the command line.


From your Azure DevOps project:
1. Select `Pipelines` from the left-pane menu and then select `Pipelines`.  Click on your build pipeline then select `Edit`.
2. Select `+` next to your Docker agent on the left-pane
3. Search for 'Command Line', then press `Add`
4. Select `Command Line Script`, then change the Display name to 'Trivy Scan'
5. Within the `Script` section, paste in the following text:
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy --exit-code 0 --severity MEDIUM,HIGH --ignore-unfixed $(containerRegistry)/$(imageRepository):$(Build.BuildId)

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy --exit-code 1 --severity CRITICAL --ignore-unfixed $(containerRegistry)/$(imageRepository):$(Build.BuildId)
```
6. Drag the `Trivy Scan` task so that it comes between the `Build Services` task and the `Push Services` task.
7. From the top menu, select `Variables`
8. Click `+ Add`, and add the following variables:
   
    - **<u>NAME:</u>** containerRegistry    **<u>VALUE:</u>** YOUR_ACR.azurecr.io    (obtain your_acr.azurecr.io from the container registry you created)
    - **<u>NAME:</u>** imageRepository    **<u>VALUE:</u>** myhealth.web    
    
9. From the top menu, select the dropdown for `Save & queue` and choose `Save`


## Exercise 2 - Test the build process with container scanning

1. Select `Pipelines` from the left-pane menu and then select `Pipelines`.  Click on your build pipeline then select `Run Pipeline` from the drop-down menu.  Click on `Run` to run the pipeline
2. Click on the `Docker` job to watch the pipeline
3. Once the `Trivy Scan` task runs, click on it to review the log output.

## Exercise 3 - Review Trivy output

So what does the Trivy scan do?
```
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy --exit-code 0 --severity MEDIUM,HIGH --ignore-unfixed $(containerRegistry)/$(imageRepository):$(Build.BuildId)

docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/Library/Caches:/root/.cache/ aquasec/trivy --exit-code 1 --severity CRITICAL --ignore-unfixed $(containerRegistry)/$(imageRepository):$(Build.BuildId)
```
The first Trivy line uses Docker to run a Trivy container which scans for any **medium** or **high** vunerabilities.  If any are found, it returns an exit code of **0**, meaning the pipeline will continue.  

The second Trivy line is similar, except it only scans for **critical** vunerabiltiies, and if any are found, an exit code of **1** is returned, which will halt the pipeline.

It is left as a [exercise to the reader](https://github.com/aquasecurity/trivy#save-the-results-as-json) to save the results (eg, as a build artifact, or to a storage account) so that they can be analyzed outside of the build pipeline.

