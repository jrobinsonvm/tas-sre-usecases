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