# A quest in the clouds


### Q. What do I have to do?

1. If you know how to use git, start a git repository (local-only is acceptable) and commit all of your work to it.
1. Use Infrastructure as Code (IaC) to the deploy the code as specified below.
   - Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.
1. Deploy the app in a container in any public cloud using the services you think best solve this problem.
   - Use `node` as the base image. Version `node:10` or later should work.
1. Navigate to the index page to obtain the SECRET_WORD.
1. Inject an environment variable (`SECRET_WORD`) in the Docker container using the value on the index page.
1. Deploy a load balancer in front of the app.
1. Add TLS (https). You may use locally-generated certs.


### Local testing
1. Public cloud & index page (contains the secret word) - `http(s)://<ip_or_host>[:port]/`
1. Docker check - `http(s)://<ip_or_host>[:port]/docker`
1. Secret Word check - `http(s)://<ip_or_host>[:port]/secret_word`
1. Load Balancer check  - `http(s)://<ip_or_host>[:port]/loadbalanced`
1. TLS check - `http(s)://<ip_or_host>[:port]/tls`

## Infra Setup

**Step 1: Set Up Your Environment**

    1. Install Prerequisites:
        - Install Terraform.
        - Install AWS CLI and configure it with your credentials (aws configure).
        - Install Docker.
        - Install Git.

    2. Create a Git Repository:
        - Initialize a Git repository locally:
        mkdir quest
        cd quest
        git init
        
    3. Endpoint created in app.js or you can use legacy src/000.js which uses unix bin files

**Step 2: Build and Push Docker Image**
    
    1. Dockerfile has been added

    2. Build and tag the Docker image and exposed Port in 80:
        docker build -t quest-app .

    3. Run the image locally:
        docker run -d -p 3000:3000 quest-app

        Retrieve the SECRET_WORD from index page
        Goto the http://localhost:3000
        You should get: Welcome to the Cloud Quest! The SECRET_WORD is: CLOUDY

    3. Pushed the image to a dockerhub registry
        docker tag quest-app prajshet/quest-app
        docker push prajshet/quest-app
    You can view the image under prajshet/quest-app


**Step 3: Deployment with Terraform via EC2 and LB**
    
    Navigate to terraform_ec2/main.tf

    1. Initialize Terraform:
        terraform init
    
    2. In main.tf with EC2 instances and necessary inbound, outbnound rules
        Here are the following will be added:
        - Create aws_vpc
        - Create aws_internet_gateway
        - Create two aws_subnet
        - Create aws_route_table associates aws_internet_gateway
        - Create aws_route_table_association links aws_route_table
        - Create aws_security_group through aws_vpc ingress, egress for instance
        - Create app_server --> Inject SECRET_WORD here in docker run as parameter
        - Create app loadbalncers through aws security group & aws_subnet
        - Create load balancer App listener through aws_lb arn
        - Create App Target Group through aws_vpc
        - Create App Target Group Attachment through aws_lb_target_group arn
        - Create Load Balancer Security Group through aws_vpc, ingress & egress to accept traffic

    2. Check the configuration
        terraform plan

    3. Apply the Terraform configuration:
        terraform apply -auto-approve
        
    4. Check in Deployed EC2 instance
        ssh -i "quest-key.pem" ec2-user@ec2-52-54-218-125.compute-1.amazonaws.com
        
       Now check App is responding in EC2 instance locally:
        [ec2-user@ip-172-31-85-143 ~]$ curl http://localhost:80/
            Welcome to the Cloud Quest! The SECRET_WORD is: CLOUDY

**Step 4: Check the outcome in Load Balancer DNS**

    Here is how I verified that solved these stages
    Each stage can be tested with LB DNS, http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com 

    1. Public cloud & index page (contains the secret word) - $ curl http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com
        Welcome to the Cloud Quest! The SECRET_WORD is: CLOUDY

    2. Docker check - $ curl http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com/docker
        This app is running inside a Docker container!

    3. Secret Word check - $ curl http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com/secret_word
        The injected SECRET_WORD is: CLOUDY

    4. Load Balancer check - $ curl http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com/loadbalanced
        This request was load balanced!

    5. TLS check - $ curl http://cloud-quest-lb-918987794.us-east-1.elb.amazonaws.com/tls
        This request was served over HTTP (no TLS).

**Step 4: Clean Up**

    After completing the quest, destroy the infrastructure to avoid unnecessary charges:

    terraform destroy

**Improvements Done**
    
    1. Deployment with Terraform via EKS & Fargate
        Navigate to terraform/eks.tf

        1) Initialize Terraform:
            terraform init
        2) In eks.tf with k8s cluster, ELB and ec2 instances and necessary inbound, outbnound rules
            - Add aws_iam_role_policy_attachment for below policies:
                a. eks_worker_node_policy
                b. eks_cni_policy
                c. eks_ecr_readonly_policy
                d. eks_cluster_policy
                e. eks_vpc_resource_controller
                f. eks_fargate_policy
            - Add aws_iam_role for below:
                a. eks
                b. eks_node
                c. eks_fargate
            - Add aws_vpc
            - Add public aws_subnet through aws_vpc
            - Add aws_internet_gateway
            - Add public aws_route_table through aws_internet_gateway
            - Add aws_route_table_association through aws_route_table
            - Add aws_security_group with ingress & egress rules
            - Add aws_eks_cluster with aws_iam_role, aws_subnet and aws_security_group
            - Add aws_eks_node_group with aws_eks_cluster, aws_iam_role, aws_subnet along with scaling config and aws_iam_role_policy_attachment
            - Add private aws_subnet
            - Add profile for AWS Fargate through aws_eks_cluster, aws_iam_role eks arn and private aws_subnet
        3) Check the configuration
            terraform plan
        4) Apply the Terraform configuration:
            terraform apply -auto-approve
        5) switch to deployements
            Application Scaling

            update kubectl to use your new EKS cluster:
            aws eks update-kubeconfig --name cloud-quest-cluster
        
            Once EKS cluster is ready deploy the App using k8s:
            - This deploy your app to EKS with 3 replicas for scaling
            kubectl apply -f deployment.yaml
        
            - This will create a LoadBalancer in AWS to expose your app.
            kubectl apply -f service.yaml
        
            - This automatically scales your app when CPU usage goes above 50%.
            kubectl apply -f hpa.yaml
        
            - Verify the deployment:
            kubectl get pods
            kubectl get services
            kubectl get hpa
        
    2. Automated CI/CD Pipeline:
        - Implement a CI/CD pipeline using tools like GitHub Actions, Jenkins, or GitLab CI/CD to automate the deployment process.
        - This would ensure faster and more reliable deployments.

**Given more time, I would improve...**

    1. Multi-Cloud Support:
        - Extend the Terraform configuration to support multiple cloud providers (AWS, GCP, Azure) for better flexibility and redundancy.

    2. Better Kubernetes Integration:
        - Deploy the app on Kubernetes (EKS, GKE, or AKS) cluster of small instance nodes.
        - This would improve scalability, resilience, and ease of management.

    3. Enhanced Security:
        - Use HTTPS instead of HTTP by configuring TLS certificates for the load balancer.
        - Implement security best practices such as network segmentation, IAM roles, and secrets management.

    4. Monitoring and Logging:
        - Integrate monitoring tools like Prometheus and Grafana to track app performance.
        - Set up centralized logging using tools like ELK Stack or CloudWatch Logs.

    5. Infrastructure Testing:
        - Use tools like Terratest to write automated tests for the Terraform configuration.
        - This would ensure the infrastructure is deployed correctly and meets requirements.

    6. High Availability:
        - Deploy the app across multiple availability zones to ensure high availability.
        - Use auto-scaling groups to handle traffic spikes.
    Since I had more time I added another approach where I included automated way using 
    k8s and AWS Fargate service

**Shortcomings/Immaturities in the Solution**

    1. Single Cloud Provider:
        - The solution is currently limited to AWS. Supporting multiple cloud providers would make it more robust and versatile.

    2. Basic Security:
        - The solution does not include advanced security measures like restricted ingress & egress, HTTPS, IAM roles, or secrets management.

    3. No Monitoring or Logging:
        - There is no monitoring or logging setup, making it difficult to troubleshoot issues or track performance.

    4. Limited Testing:
        - The infrastructure and app are not thoroughly tested, which could lead to undetected issues in production.

**Conclusion**

    This solution provides a basic deployment of the app in a public cloud using Terraform and Docker. While it 
    meets the core requirements, there are several areas for improvement, particularly in automation, security, 
    scalability, and multi-cloud support. Given more time, I would focus on implementing these enhancements to 
    create a more robust and production-ready solution.

**Snippets**:

Local testing to retrive SECRET_WORD

![Local testing](/Users/prajwalshetty/Desktop/Screenshot 2025-02-23 at 1.38.40 PM.png)

Load Balancer setup

![Load Balancer setup](../../Desktop/Screenshot%202025-02-23%20at%201.38.40%E2%80%AFPM.png)

DNS routing

![DNS routing](../../Desktop/Screenshot%202025-02-23%20at%2010.08.10%E2%80%AFPM.png)

Endpoints

![SECRET_WORD](../../Desktop/Screenshot%202025-02-23%20at%2010.08.44%E2%80%AFPM.png)

![docker](../../Desktop/Screenshot%202025-02-23%20at%2010.08.59%E2%80%AFPM.png)

![Injected_secret](../../Desktop/Screenshot%202025-02-23%20at%2010.09.08%E2%80%AFPM.png)

![LoadBalancer](../../Desktop/Screenshot%202025-02-23%20at%2010.09.17%E2%80%AFPM.png)

![tls](../../Desktop/Screenshot%202025-02-23%20at%2010.09.32%E2%80%AFPM.png)

**Bonus: Add these details in GitHub secrets**

    CI/CD pipeline is enablement:
    Before running the workflow, store these secrets in GitHub Settings → Secrets:

    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - AWS_EC2_IP → Public IP of your EC2 instance
    - DOCKER_USERNAME
    - DOCKER_PASSWORD

**Argo CD: deployment**

    This is optional but helps organize multiple applications under one project.
    $ kubectl apply -f argo-project.yaml

    This instructs ArgoCD to watch the Git repo, fetch the Helm chart, and deploy it.
    $ kubectl apply -f argo-app.yaml

    Verify the ArgoCD Application
    $ argocd app list
    $ argocd app sync cloud-quest-app

    Check the Service & Get LoadBalancer IP
    $ kubectl get svc -n cloud-quest

    ArgoCD UI & CLI
    Access via http://<ARGOCD-LOADBALANCER-IP>
    Default admin password:
    $ kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d








    
