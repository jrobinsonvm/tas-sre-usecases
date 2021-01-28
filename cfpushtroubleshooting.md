# Troubleshooting Use Cases:

:  
        <!-- 
        https://docs.cloudfoundry.org/devguide/deploy-apps/large-app-deploy.html
        https://docs.cloudfoundry.org/devguide/deploy-apps/troubleshoot-app-health.html#time  
        https://docs.cloudfoundry.org/adminguide/troubleshooting_slow_requests.html 
        https://docs.cloudfoundry.org/adminguide/troubleshooting_slow_requests.html#app_logs
        https://docs.cloudfoundry.org/devguide/deploy-apps/troubleshoot-app-health.html#time
        https://docs.pivotal.io/ops-manager/2-10/security/pcf-infrastructure/check-expiration.html#check-ui
        https://docs.cloudfoundry.org/concepts/http-routing.html#app-instance-routing
        https://docs.cloudfoundry.org/adminguide/troubleshooting_slow_requests.html#duplicate-latency
        -->

# TAS 101 Workshop - SRE Focus 

# Application fails to start after issuing cf push command.  
1. Clone the broken-spring-music git repo. 
    ```
    git clone https://github.com/jrobinsonvm/broken-spring-music.git
    ```
2. CD into broken-spring-music directory  
    ```
    cd broken-spring-music
    ```
3. Change the name of your app to your team name. (Edit the manifest.yml file) 
    ```
    vi manifest.yml
    ```
4. Run "cf push" to deploy the app
    ```
    cf push
    ```
    It looks like our app didn't start.  Let's see what could be the issue.   
    Typically the first thing to check are the logs.  This can be done with the following command.  
    ```
    cf logs spring-music-<team name> --recent
    ```
    From the output you can easily identify the issue.  
    ```
    [APP/PROC/WEB/0] ERR Cannot calculate JVM memory configuration: There is insufficient memory remaining for heap. Memory available for allocation 512M is less than allocated memory 680680K
    ```
    The memory limit which we set within the manifest yaml file was not sufficent to run our app.  

    In another scanario where our logs are not as straight forward we could use other methods to investigate the issue.   

    If a command fails or produces unexpected results, re-run it with HTTP tracing enabled to view requests and responses between the cf CLI and the Cloud Controller REST API.
    To do this simply rerun cf push with -v for verbose output.  
    ```
    cf push -v 
    ```
    Please try running the cf events command to get a list of key events with their corresponding timestamps.   
    ```
    cf events spring-music-<team name>
    ```
    Use the cf env command to view the environment variables that you have set using the cf set-env command and the variables in the container environment:
    ```
    cf env
    ```
    Know your app's estimated startup time (timeout issue)
    By default, applications must start within 60 seconds.  
    This timeout can be extended to a max of 180 seconds  
    You configure the CLI staging, startup, and timeout settings to override settings in the manifest, as necessary. 
    ```
    CF_STAGING_TIMEOUT: Controls the maximum time that the cf CLI waits for an app to stage after it successfully uploads and packages the app. Value set in minutes.
    CF_STARTUP_TIMEOUT: Controls the maximum time that the cf CLI waits for an app to start. Value set in minutes.
    cf push -t TIMEOUT: Controls the maximum time that Cloud Foundry allows to elapse between starting an app and the first healthy response from the app. When you use this flag, the cf CLI ignores any app start timeout value set in the manifest. Value set in seconds.
    ```

5. To increase the memory limit edit the mainifest.yaml file and replace 0.5G with 1G.  
    ```
    vi manifest.yml 
    ```
6.  Now redeploy the application 
    ```
    cf push 
    ```
