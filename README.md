# A quest in the clouds

### Q. What is this quest?

It is a fun way to assess your cloud skills. It is also a good representative sample of the work we do at Rearc. Quest is a webapp made with node.js and golang.

### Q. So what skills should I have?
- Public cloud: AWS, GCP, Azure.
  - More than one cloud is a "good to have" but one is a "must have".
- General cloud concepts, especially networking.
- Containerization, such as: Docker, containerd, kubernetes
- IaC (Infrastructure as code). At least some Terraform preferred.
- Linux (or other POSIX OS).
- VCS (Version Control System). Git is highly preferred. 
- TLS is a plus.

### Q. What do I have to do?
You may do all or some of the following tasks. Please read over the complete list before starting.

1. If you know how to use git, start a git repository (local-only is acceptable) and commit all of your work to it.
1. Use Infrastructure as Code (IaC) to the deploy the code as specified below.
   - Terraform is ideal, but use whatever you know, e.g. CloudFormation, CDK, Deployment Manager, etc.
1. Deploy the app in a container in any public cloud using the services you think best solve this problem.
   - Use `node` as the base image. Version `node:10` or later should work.
1. Navigate to the index page to obtain the SECRET_WORD.
1. Inject an environment variable (`SECRET_WORD`) in the Docker container using the value on the index page.
1. Deploy a load balancer in front of the app.
1. Add TLS (https). You may use locally-generated certs.

### Q. How do I know I have solved these stages?
Each stage can be tested as follows (where `<ip_or_host>` is the location where the app is deployed):

1. Public cloud & index page (contains the secret word) - `http(s)://<ip_or_host>[:port]/`
1. Docker check - `http(s)://<ip_or_host>[:port]/docker`
1. Secret Word check - `http(s)://<ip_or_host>[:port]/secret_word`
1. Load Balancer check  - `http(s)://<ip_or_host>[:port]/loadbalanced`
1. TLS check - `http(s)://<ip_or_host>[:port]/tls`

### Q. Do I have to do all these?
You may do whichever, and however many, of the tasks above as you'd like. We suspect that once you start, you won't be able to stop. It's addictive. Extra credit if you are able to submit working entries for more than one cloud provider.

### Q. What do I have to submit?
1. Your work assets, as one or both of the following:
   - A link to a hosted git repository.
   - A compressed file containing your project directory (zip, tgz, etc). Include the `.git` sub-directory if you used git.
1. Proof of completion, as one or both of the following:
   - Link(s) to hosted public cloud deployment(s).
   - One or more screenshots showing, at least, the index page of the final deployment in one or more public cloud(s) you have chosen.
1. An answer to the prompt: "Given more time, I would improve..."
   - Discuss any shortcomings/immaturities in your solution and the reasons behind them (lack of time is a perfectly fine reason!)
   - **This may carry as much weight as the code itself**

Your work assets should include:

- IaC files, if you completed that task.
- One or more Dockerfiles, if you completed that task.
- A sensible README or other file(s) that contain instructions, notes, or other written documentation to help us review and assess your submission.
  - **Note** - the more this looks like a finished solution to deliver to a customer, the better.

### Q. How long do I need to host my submission on public cloud(s)?
You don't have to at all if you don't want to. You can run it in public cloud(s), grab a screenshot, then tear it all down to avoid costs.

If you _want_ to host it longer for us to view it, we recommend taking a screenshot anyway and sending that along with the link. Then you can tear down the quest whenever you want and we'll still have the screenshot. We recommend waiting no longer than one week after sending us the link before tearing it down.

### Q. What if I successfully complete all the challenges?
We have many more for you to solve as a member of the Rearc team!

### Q. What if I find a bug?
Awesome! Tell us you found a bug along with your submission and we'll talk more!

### Q. What if I fail?
There is no fail. Complete whatever you can and then submit your work. Doing _everything_ in the quest is not a guarantee that you will "pass" the quest, just like not doing something is not a guarantee you will "fail" the quest.

### Q. Can I share this quest with others?
No. After interviewing, please change any solutions shared publicly to be private.

### Q. Do I have to spend money out of my own pocket to complete the quest?
No. There are many possible solutions to this quest that would be zero cost to you when using [AWS](https://aws.amazon.com/free), [GCP](https://cloud.google.com/free), or [Azure](https://azure.microsoft.com/en-us/pricing/free-services).

### Updates
I went through the Quest App, I really enjoyed the App deployment & learnt a lot and Thanks for recommending this.
I used Infrastructure as Code (IaC) in a public cloud AWS. Below are detailed steps to deploy and test the app on AWS using Terraform and Docker.

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
        
    3. Endpoint created in app.js

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


**Step 3: Deployment with Terraform**

    1. Initialize Terraform:
        terraform init
    
    2. Create main.tf with EC2 instances and necessary inbound, outbnound rules
        Here are the following will be added:
        - Create app_server --> Inject SECRET_WORD here in docker run as parameter
        - Create app loadbalncers
        - Create load balancer App listener
        - Create App Target Group
        - Create App Target Group Attachment
        - Create Load Balancer Security Group

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

**Given more time, I would improve...**

    1. Automated CI/CD Pipeline:
        - Implement a CI/CD pipeline using tools like GitHub Actions, Jenkins, or GitLab CI/CD to automate the deployment process.
        - This would ensure faster and more reliable deployments.

    2. Multi-Cloud Support:
        - Extend the Terraform configuration to support multiple cloud providers (AWS, GCP, Azure) for better flexibility and redundancy.

    3. Kubernetes Integration:
        - Deploy the app on Kubernetes (EKS, GKE, or AKS) instead of a single Docker container.
        - This would improve scalability, resilience, and ease of management.

    4. Enhanced Security:
        - Use HTTPS instead of HTTP by configuring TLS certificates for the load balancer.
        - Implement security best practices such as network segmentation, IAM roles, and secrets management.

    5. Monitoring and Logging:
        - Integrate monitoring tools like Prometheus and Grafana to track app performance.
        - Set up centralized logging using tools like ELK Stack or CloudWatch Logs.

    6. Infrastructure Testing:
        - Use tools like Terratest to write automated tests for the Terraform configuration.
        - This would ensure the infrastructure is deployed correctly and meets requirements.

    7. High Availability:
        - Deploy the app across multiple availability zones to ensure high availability.
        - Use auto-scaling groups to handle traffic spikes.
    Offcourse if I had more time I would like to add another approach where I can included automated way using 
    k8s and AWS Fargate service

**Shortcomings/Immaturities in the Solution**

    1. Single Cloud Provider:
        - The solution is currently limited to AWS. Supporting multiple cloud providers would make it more robust and versatile.

    2. Manual Deployment:
        - The deployment process is manual and lacks automation. A CI/CD pipeline would streamline the process.

    3. Basic Security:
        - The solution does not include advanced security measures like HTTPS, IAM roles, or secrets management.

    4. Lack of Scalability:
        - The app is deployed as a single container without auto-scaling or Kubernetes orchestration, limiting its scalability.

    5. No Monitoring or Logging:
        - There is no monitoring or logging setup, making it difficult to troubleshoot issues or track performance.

    6. Limited Testing:
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

**Bonus**

    CI/CD pipeline is enablement:
    GitHub Secrets Setup
    Before running the workflow, store these secrets in GitHub Settings → Secrets:

    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY
    - AWS_EC2_IP → Public IP of your EC2 instance
    - DOCKER_USERNAME
    - DOCKER_PASSWORD
