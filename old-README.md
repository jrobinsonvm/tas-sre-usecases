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


# Lets check for expired certificates using the CredHub CLI 
1. First SSH to the Bosh Director VM 
    ```
    ssh boshvm
    ```
2.  Set your credhub target to point to the Bosh Director  
    ```
    credhub api https://<Bosh-Endpoint>:8844 --ca-cert=/var/tempest/workspaces/default/root_ca_certificate
    ```
3.  Next authenticate to CredHub using your bosh credentials 
    ```
    credhub login \
      --client-name=<BoshClient> \
      --client-secret=<BoshSecret>
    ```
4.  Run the following credhub command to view any expired certificates. 
    ```
    credhub get -n /services/tls_ca -j | jq -r .value.ca  | openssl x509 -text -noout | grep -A 2 "Validity"
    ```
    The output should show 2 dates.  The first date from the output lists when your certificate became valid. 
    The second date will list when your certificate expires.    
    Alternatively you could run this command without grep to get more details.  
    ```
    credhub get -n /services/tls_ca -j | jq -r .value.ca  | openssl x509 -text -noout
    ```
    If your certificate has already expired please follow the knowledge base article below. 
    https://community.pivotal.io/s/article/How-to-rotate-and-already-expired-services-tls-ca-certificate?language=en_US


# You can also use the CredHub CLI to rotate your certicates for you. 
# Part 1 of Cert Rotation 
  Since this is a very disruptive process we will NOT implement these steps during the workshop.   
  The following steps will show you how to rotate your Services TLS Certificate.  
1. Check if CredHub has a new temporary certificate from a previous rotation attempt.
    ```
    credhub get -n /services/new_ca
    ```
2. If any older temporary certificate exists, delete it before proceeding. 
    ```
    credhub delete -n /services/new_ca
    ```
3. You have the option to bring your own certificate or use a self signed certificate. 
    If you select to use a self signed certificate, please see the following command to create the self signed certificate.  
    ```
        credhub generate \
        --name="/services/new_ca" \
        --type="certificate" \
        --no-overwrite \
        --is-ca \
        --duration=1825 \
        --common-name="opsmgr-services-tls-ca"
    ```
    This will create a self signed certificate called opsmgr-services-tls-ca which expires in 5 years.
    Default duration is 1 year if no input is given.   
4. Now retrieve the current TLS CA Certificate 
    ```
    credhub get --name=/services/tls_ca -k ca
    ```
5. Retrieve the new certificate from a pre-existing file or from your new CredHub location
    ```
    credhub get --name=/services/new_ca -k ca
    ```
6. From the Ops Manager tile, paste both certificates into the Bosh Director > Security > Trusted Certificates field and click save.  
7. From the Tas for VMs tile, paste both certificates into the Networking > Certificate Authorities trusted by the Gorouter and Certificate Authorities trusted by the HAProxy fields and click save.  
8. From Ops Manager, click Review Pending Changes. 
9. Before applying any changes, identify which service tiles are using the Services TLS CA certificate
    ```
    credhub curl -p /api/v1/certificates?name=%2Fservices%2Ftls_ca
    ```
    The output from the above command should give you a list of services which are depenedent on the Services TLS CA Certificate.  
10. Now for each service tile listed in the previous output 
    Expand the errands view and enable the errand to upgrade all service instances.        
11. Now from Ops manager, select Review Pending Changes and click Apply.   

# Part 2 of Cert Rotation 
12. After changes have been successfully applied we will need to set the new Services TLS Certificate. 
    If you are using an exisiting certificate use the following command. 
    ```
        credhub set \
        --name="/services/tls_ca" \
        --type="certificate" \
        --certificate=<PEM-PATH/root.pem> \
        --private=<CERT-KEY>
    ```
    If you are using a self signed certificate use the following command.  
    ```
        credhub get -n /services/new_ca -k ca > new_ca.ca
        credhub get -n /services/new_ca -k certificate > new_ca.certificate
        credhub get -n /services/new_ca -k private_key > new_ca.private_key
        credhub set -n /services/tls_ca \
        --type=certificate \
        --root=new_ca.ca \
        --certificate=new_ca.certificate \
        --private=new_ca.private_key
    ```
13. Now navigate back to the Ops Manager and select Review Changes.  
14. As a precautionary step before applying any changes, identify which service tiles are using the Services TLS CA certificate
    ```
    credhub curl -p /api/v1/certificates?name=%2Fservices%2Ftls_ca
    ```
15. Now for each service tile listed in the previous output 
    Expand the errands view and enable the errand to upgrade all service instances.        
16. Now from Ops manager, select Review Pending Changes and click Apply.   

# Part 3 of Cert Rotation 
Now we will need to remove the old services TLS Certificate 
17. From Ops Manager select the Bosh Director tile.  
18. Click Security and delete the old CA Certificate from the Trusted Certificates field and click save.  
19. From Ops Manager select the TAS for VMs tile
20. Click Networking and delete the old CA Certificate in the Certificate Authorities trueted by Gorouter and Certificate Authorities trusted by HAProxy fields and click save.  
21. Finally Navigae back to Ops Manager dashboard and click Review Pending Changes.   
22. Ensure that errands have been enabled to upgrade all service instances.   
23. Click Apply Changes.   





# To be continued --> 


Determine why a Diego Cell under heavy load 
    1. Inspect the app via SSH 
    Command: cf ssh <app name>
        1. If SSH via CLI is not an option
            --> https://docs.cloudfoundry.org/devguide/deploy-apps/ssh-apps.html#ssh-command
Resource limitations on the system
    1. How and why to expand
    
Routing Conflicts / Scaling - Multiple apps using same route. 
    1. https://docs.cloudfoundry.org/devguide/deploy-apps/troubleshoot-app-health.html#routing-conflict
