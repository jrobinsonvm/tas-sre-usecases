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
