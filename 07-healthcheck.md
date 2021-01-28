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

# Implement health checks for your applications.  

- An app health check is a monitoring process that continually checks the status of a running app.

- Developers can configure a health check for an app using the Cloud Foundry Command Line Interface (cf CLI) or by specifying the health-check-http-endpoint and health-check-type fields in an app manifest.

- App health checks function as part of the app lifecycle managed by Diego architecture. For more information, see Diego Components and Architecture here -> https://docs.pivotal.io/application-service/2-10/concepts/diego/diego-architecture.html

## In this lab we will understand how to implement health checks when deploying new applications and for existing applications.   

- First we will configure a health check for our test-app application that's already deployed.   

1.  
    ```
    git clone https://github.com/jrobinsonvm/broken-spring-music.git
    ```
2. CD into broken-spring-music directory  
    ```
    cd broken-spring-music
    ```
