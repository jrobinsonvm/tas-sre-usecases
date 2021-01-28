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

# Let's determine if a route is accessible from one app to another app or service.   

If no other apps are available for testing you can deploy a test app to test connectivity to our spring-music app

1. First, let's clone our test-app repo. 
    ```
    git clone https://github.com/jrobinsonvm/test-app.git
    ```
2. Now let's deploy our test app.  Change directories to the test-app 
    ```
    cd test-app 
    ```
3. Change the name of your app to your team name. (Edit the manifest.yml file) 
    ```
    vi manifest.yml
    ```
4. Run "cf push" to deploy the app
    ```
    cf push
    ```
5. Run cf apps to view your newly deployed app.   
    ```
    cf apps
    ```
6. Let's get the GUID of our spring-music app.  Save this for later 
    ```
    cf app spring-music-<team name> --guid
    ```
7. Let's get the index number of the instance of spring-music app we would like to debug. Also take note of the route assigned to the app.  Save this detail for later
    ```
    cf app spring-music-<team name> 
    ```
8. In the command below replace the variables with your spring-music app's route, guid and isntance index number.  
    ```
    curl <app.vmware.com>  -H "X-Cf-App-Instance":"YOUR-APP-GUID:YOUR-INSTANCE-INDEX"
    ```
9. Let's ssh into our test app 
    ```
    cf ssh test-app-<team name>
    ```
10. Now run the curl command we created earlier to send a request to the app.   
    You should see the html content of your web app endpoint now.   
    This proves that other apps should be able to successfully reach your spring-music app.   
