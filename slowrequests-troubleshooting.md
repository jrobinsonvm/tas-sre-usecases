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

# Troubleshooting slow requests in TAS 

Let's imagine our spring-music app is experiencing latency.  
1. To better understand the issue lets measure the total round-trip of my app 
    ```
    time curl -v <your-app-spring-music.vmware.com>
    ```
    Examine the output and take note of the "real" time.  
2. View the request time in your app's logs 
    From one terminal enter the following command
    ```
    cf logs spring-music-<team name>
    ```
    From another terminal send a request to the app using the same curl command from earlier.   
    ```
    curl -v <your-app-spring-music.vmware.com>
    ```
    You should now see the requst in your terminal with the logs.   
    Type ctrl+c to exit the streaming logs.   
3. Duplicate latency on another endpoint
    We will now use our test-app to measure the latency we are seeing in our spring-music app.   
    First SSH into our test-app 
    ```
    cf ssh test-app-<team name>
    ```
    Now run the following curl command to measure the round trip back from our spring-music app.   
    ```
    time curl -v <your-app-spring-music.vmware.com>  
    ```
    If this experiment shows that something in your app is causing latency, use the following questions to start troubleshooting your app:
    * Did you recently push any changes?
    * Does your app make database calls?
        * If so, have your database queries changed?
    * Does your app make requests to other microservices?
        * If so, is there a problem in a downstream app?
    * Does your app log where it spends time? 
4. Remove the load balancer from the request path 
    First obtain the deployment id and router guid using bosh 
    List the vms within your bosh environment 
    ```
    bosh vms 
    ```
    Select one of your router vms and record its GUID and deployment ID.   
    Now run the following command to ssh into the router.  
    Replace the variables with your reouter GUID and deployment ID.  
    ```
    bosh ssh -d <deploymentID> router/<GUID>
    ```
    Run the same curl command from before.   
    ```
    time curl -v <your-app-spring-music.vmware.com> 
    ```
5. Remove Gorouter from the request path 
    Retrieve the IP Address and Port number of the Diego Cell where your app is running 
    ```
    cf ssh spring-music-<team name> -c "env |grep CF_INSTANCE_ADDR"
    ```
    The output should provide you with an IP address 
    Now we will use bosh to ssh back into our router VM
    ```
    bosh ssh -d <deploymentID> router/<GUID>
    ```
    Now determine the amount of time a request takes when it skips Gorouter.  
    Run the following command. Replacing the variable with the IP Address we obtained earlier. 
    ```
    time curl <IPaddressOfDiegoCellforSpringMusicApp>
    ```