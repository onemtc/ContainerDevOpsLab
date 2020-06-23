# DevOps Lab - Use Azure DevOps to manage build and deployment of your application

*Based on a lab from https://github.com/microsoft/MTC_2020AzureMigrateYourApps and application code from https://github.com/MSTecs/Azure-DevDay-lab4-demoProject*

## Lab Goals: Deploying a Docker based web application to Azure App Service
In this lab, you will use Azure DevOps to automate the build and deployment of your application to Azure

### Learning Objectives
    - Build Docker images using Azure DevOps 
    - Push and store the Docker images into Azure Container Registry
    - Deploy and run the images inside the Docker Containers

## Exercise 0:  Setup

In this exercise, we will scaffold out the infrastructure used with the following lab exercies.  While not a part of this lab, the example code could be used as the basis for an infrastructure as code approach to maintaining the infrastructure.

1. This exercise will use the **Azure Cloud Shell** as the environment to deploy the infrastructure.  From your browser, navigate to https://shell.azure.com
2. From inside the Azure Cloud Shell, run the following commands to configure git:
```
    git config --global user.name "<your name>"
    git config --global user.email <your email>
```
3. Using Git, pull down the lab materials into a new directory called lab1:
```
git clone https://github.com/onemtc/ContainerDevOpsLab.git lab1
```
4. From within the Azure Cloud Shell cd to the lab1/IaC folder which you just created.  ("`cd lab1/IaC`")
5. Load the configuration script into the **code** editor:  `code configscript.sh`
6. You will see the configuration script in the editor.  The first & second lines need to be customized appropriately.  Make these edits, then press `Cntrl-S` to save the file.
7. From the command line, run the script  `bash configscript.sh`


## Exercise 1 - Create a new project and clone the GitHub repo
1. Open the Azure DevOps portal [Azure DevOps](http://dev.azure.com) 
2. Use link `Sign in to Azure DevOps` and login using your assigned credentials
3. Select `+ New Project`
4. Set the **Project name** to a name of your choice
5. In the **Visibility** section, select `Private`
6. Select `Advanced`, in **Version control** select 'GIT' and in **Work item process** select 'Scrum' 
7. Select `Create` at the bottom right of the page. Once your project has been created, select `Repos` from left-pane menu
6. From the Repos page, select `Import` in the `or import a repository` section
7. `Source type` should be set to 'Git', and in `Clone URL` enter this URL and leave `Requires authorization` unchecked
    https://github.com/onemtc/ContainerDevOpsLab.git
8. Select `Import`
9. Select `Files` under `Repos` from the left-pane menu and you will see the cloned GitHub repo


## Exercise 2 - Configure Continuous Integration
### Task 1 - configure the DevOps Pipeline

From Your Azure DevOps project:
1. Select `Pipelines` from the left-pane menu and then select `Pipelines`.  Select `Create pipeline`
2. Select `Use the classic editor to create a pipeline without YAML` option at the bottom of the page       
9.  Select `Azure Repos Git` and select your project and repository, leave the branch on 'master' 
10. Select `Continue`
11. Select the `Empty job` option at the top of the page
12. Select `Agent job 1` and change `Display name` to 'Docker'
13. Set `Agent pool` to 'Azure pipelines'
14. Set `Agent Specification` to 'ubuntu-16.04' from the dropdown
15. Scroll down to the `Execution Plan` section, and 'Job cancel timeout' to 5
16. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 2 - create Run services


1. Select `+` next to your Docker agent on the left-pane
2. Search for 'docker compose' and then select `Add`
3. Select `Run a Docker Compose command` from the left-pane and set `Display name` to 'Run services' 
4. From `Azure subscription`, select the dropdown next to `Authorize` and select `Advanced options`
5. In the 'Add an Azure Resource Manager service connection' window, optionally limit the scope to your resource group, then select `OK` from the window to create a service connection
9. Select `Azure Container Registry` using the dropdown.  Choose the Azure Container Registry that was created during the setup exercise.
10. From `Docker Compose File`, select `...` and select the file 'code/docker-compose.ci.build.yml'
11. Scroll down to `Action` and select 'Run service images' from the dropdown
12. Uncheck `Run in Background`
14. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 3 - create Build services

1. From the left-pane menu, select `+` next to `docker` and search for 'docker compose' and select `Add`
2. Select `Run a Docker Compose command` from the left-pane
3. Set `Display name` to 'Build services'
4. From `Azure subscription`, select your previously created service connection 
5. Select the `Azure Container Registry` and choose the Azure Container Registry that was created during the setup exercise.
6. From `Docker Compose File`, select `...` and select the file 'code/docker-compose.yml'
7. Enter `DOCKER_BUILD_SOURCE=` in the `Environment Variables` dialogue  _FYI, this variable is an artifact from when the project was originally created in VS2017; we are setting it null to ignore it_
8. From `Action` select 'Build service images' from the dropdown
9. In `Additional Image Tags`, enter `$(BUILD.BUILDID)`
11. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 4 - Create Push Services
1. From the left-pane menu, select `+` next to `docker` and search for 'docker compose' and select `Add`
2. Select `Run a Docker Compose command` from the left-pane
3. Set `Display name` to 'Push services'
4. From `Azure subscription`, select your previously created service connection 
5. Select the `Azure Container Registry` and choose the Azure Container Registry that was created during the setup exercise.
6. From `Docker Compose File`, select `...` and select the file 'code/docker-compose.yml'
7. Enter `DOCKER_BUILD_SOURCE=` in the `Environment Variables` dialogue
8. From `Action` select 'Push service images' from the dropdown
9. In `Additional Image Tags`, enter `$(BUILD.BUILDID)`
11. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 5: create Publish Artifact
1. From the left-pane menu, select `+` next to `docker` and search for 'Publish build artifacts' and select `Add` 
2. Select `Publish Artifact: drop` from the left-pane
3. Set `Display name` to 'Publish artifacts'
4. Set `Path to publish` to `code/myhealthclinic.dacpac`
5. Set `Artifact name` to `dacpac`
7. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 6 - Set variables
1. Select `Variables` from top menu
2. Create these variables by selecting the `+ Add` button
    - Name: BuildConfiguration Value: Release  Check the `Settable at queue time` option
    - Name: BuildPlatform Value: Any CPU
3. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 7 - configure triggers for continuous integration
1. Select `Triggers` from top menu
2. Check `Enable continuous integration` 
3. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 8 - configure build options
1. Select `Options` from top menu
2. On the left-pane, set `Build number format` to _\$(date:yyyyMMdd)\$(rev:.r)_ 
3. On the right-pane, set `Build job timeout in minutes` to '0'
4. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 9 - Set the compute host
1. Select `Tasks` from top menu
2. Select `Pipeline` just below `Tasks`
3. Set `Agent Pool` to 'Azure Pipelines' from dropdown
4. Set `Agent Specification` to  'Ubuntu 16.04' from dropdown 
5. From the top menu, select the dropdown for `Save & queue` and choose `Save` using the default values

### Task 10 - Test the build process
1. Click the `Queue` button from the top menu, and then press `Run` to launch a build process
2. You will see a job labeled 'Docker'.  Click on this job to view the build
3. As each of the tasks in the job executes, a new line will be generated.  If you entered all the data correctly, this job should run to completion.
4. Switch browser tabs and go back to the Azure Portal.  Open up your Container Registry, and under `Services`, select `Repositories`.    You should see the `myhealth.web` repository, which was pushed to the registry by the pipeline.


## Exercise 3 - Configure Continuous Delivery

### Task 1 - create the release pipeline
1. Go back to Azure DevOps in yor browser, and from the left-pane menu, select `Pipelines` and then select `Releases` 
2. Select `New pipeline` and select `Empty job` from top of page on the right side
3. Set `Stage name` to 'Dev'
4. Select `+ Add` from left-pane `Artifacts` section
5. Select `Build` from `Source type`
6. Set `Project` to your DevOps project name - it should be auto-suggested
7. Select your build pipeline from the `Source (build pipeline)` dropdown
8. Set `Default version` to 'Latest'
9. Set `Source alias` to the suggested value - it will be created from your DevOps project name, and press `Save`
10. Select the `Continuous deployment trigger` icon located `Artifacts` (it resembles a lightning bolt) and on the right set `Continuous deployment trigger` to 'Enabled'
11. Select `Save` from top menu and save using the default values

### Task 2 - configure the SQL database deployment
1. From the top menu, select `Tasks` 
2. Select `Agent job`
3. Set `Display name` to 'DB Deployment'
4. Select the `+ Add` button next to 'Demands' and create the item
    - Name: sqlpackage, Condition: exists
5. Select `+` next to `DB Deployment` in left-pane and search for 'Azure SQL database deployment' and select `Add`
7. From the left-pane, select `Azure SQL Dacpac Task`
8. Set `Display name` to 'Execute Azure SQL : DacpacTask'
9. From `Azure subscription`, select your previously created service connection 
10. Set `Azure SQL Server` to `$(SQLserver)`
11. Set `Database` to `$(DatabaseName)`
12. Set `Login` to ' $(SQLadmin)' (with a blank space at the beginning but no quotes)
13. Set `Password` to `$(Password)` 
14. Scroll down to the section `Deployment Package`, and set `DACPAC File` to `$(System.DefaultWorkingDirectory)/**/*.dacpac`
16. Select `Save` from the top and save using the default values

### Task 3 - create and configure the Web App deployment agent
1. From the left-pane, select `...` next to `Dev` and select `Add an Agent Job`
2. Select the new `Agent job` 
3. Set `Display name` to 'Web App deployment'  
4. Set `Agent pool` to 'Azure Pipelines' from the dropdown
4. Set `Agent Specification` to 'ubuntu-16.04'  from the dropdown
5. Select `Save` from the top and save using the default values

### Task 4 - create and configure the app service deployment task
1. Select `+` next to `Web App deployment` in the left-pane and search for 'Azure App Service Deploy' and select `Add`
2. Select your new `Azure App Service Deploy:` from the left-pane
4. Set `Task version` to  '3.*'  from the dropdown
5. Set `Display name` to 'Azure App Service Deploy' 
6. From `Azure subscription`, select your previously created service connection 
7. Set `App type` to  'Linux Web App' from the dropdown
8. Set `App Service Name` to the name of your App Service.  (created during the setup phase)
9. Set `Registry or Namespace` to `$(ACR)`
10. Set `Image` to `myhealth.web`
11. Set `Tag` to `$(BUILD.BUILDID)`
13. Select `Save` from the top menu and save using the default values

### Task 5 - restart app service
_This step is not technically needed, but I have found it ensures that the container starts up correctly within the app service_
1. Select `+` next to `Web App deployment` in the left-pane and search for 'Azure App Service manage' and select `Add`
2. Select your new task from the left-pane , which will be labeled `Swap Slots`
3. Set `Display name` to 'App Service - Restart' 
4. Under  `Azure subscription`, select your previously created service connection 
5. Set  `Action` to 'Restart App Service'
6. Set `App Service Name` to the name of your App Service.  (created during the setup phase)
7. Select `Save` from the top menu and save using the default values


### Task 6 - configure variables
1. Select `Variables` from the top menu
2. Select `+ Add` and create the following variables

    - **<u>NAME:</u>** ACR    **<u>VALUE:</u>** YOUR_ACR.azurecr.io    **<u>SCOPE:</u>** Release
        (obtain your_acr.azurecr.io from the container registry you created)
    - **<u>NAME:</u>** DatabaseName    **<u>VALUE:</u>** mhcdb    **<u>SCOPE:</u>** Release
    - **<u>NAME:</u>** Password    **<u>VALUE:</u>** P2ssw0rd1234    **<u>SCOPE:</u>** Release
    - **<u>NAME:</u>** SQLadmin    **<u>VALUE:</u>** sqladmin    **<u>SCOPE:</u>** Release
    - **<u>NAME:</u>** SQLserver    **<u>VALUE:</u>**    YOUR_DBSERVER.database.windows.net    **<u>SCOPE:</u>** Release
        (the full name, FQDN, of your SQL database server)


3. Select `Save` from the top menu and save using the default values

### Task 7 - Test your release pipeline
1. From pipeline window, press `Create Release` to start the release pipeline.
2.  Click on the release job to watch the logs as the release executes
3.  If you entered everything correctly, the pipeline should finish sucessfully
4.  Switch tabs the the Azure Portal, and go to your App Service.  From the Overview page, you can find the url to your website.  Click it to open the website in a new tab
5.  If everthing worked ok, you should see your website.  If you see an error screen, it is possible that the credentials were not set up correctly between the App Server and the Azure Container registry.  To diagnose & remediate:
    1.  Go back to your webapp in the portal, and open up the `Container Settings` blade.
    2.  Ensure that the settings match the following:
           - `Azure Container Registry` is selected at the top
           - `Registry`  set to the name of your registry (just the short name, without _azurecr.io_)
           - `Image`  set to `myhealth.web`
           - `Tag`  set to `latest`
           - `Continuous Deployment` set to 'Off'
     3. Press `Save` 


## Exercise 4 - Initiate the Continuous Integration Build and Deployment

1. From the left-pane menu, select `Repos` and then `Files`.  Navigate to the (ProjectName)/code/src/MyHealth.Web/Views/Home folder and open Index.cshtml file for editing
    - Modify the text 'JOIN US' to 'CONTACT US' on line 28, and then select `Commit` button accepting its default values.  This action will initiate an automatic build 
2. Select `Pipelines` and then `Builds` from the left-pane menu then select the build name just committed from the right-pane
    - The Build will generate and push the docker image of the web application to the Azure Container Registry. Once the build is completed, the build summary will be displayed
    - You can watch each of the steps you created being executed in this build
    - Once the build is completed (all green check boxes), the build summary will be displayed.  The build may take a few minutes
3. From Azure Dev Ops portal, select `Pipelines` and then `Releases`. Select  the latest release and select on `Logs` to view the details of the release in progress
    - You can watch each of the steps you created being executed in this build
    - Once the build is completed (all green check boxes), the build summary will be displayed.  The build may take a few minutes
4. From the Azure Portal, select the 'Azure Container Registry' service and then select `Repositories` option to view the generated docker images.  You should see a repository named 'myhealth.web'

5. From the Azure Portal, select your app service and then `Overview` from the left-pane menu. Select the link next to the `URL` field to browse the application
6. Use the credentials Username: user and Password: P2ssw0rd@1 to login to the HealthClinic.Biz web application
    - If this is the first time using the application, you might have a delay as the services are initially hydrated


**Congratulations!  You have successfully built and deployed a functioning DevOps pipeline that includes continuous integration.**

You can now continue with **[Part 2](LabPart2.md)**
