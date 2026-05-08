# Karpenter Installation on AWS EKS
**Overview**
---
 configure Karpenter a Kubernetes cluster autoscaler designed for AWS EKS. Karpenter automatically provisions and manages EC2 instances based on pod scheduling requirements, offering faster scaling, better bin-packing, and cost optimization compared to traditional Cluster Autoscaler.

 # What is Karpenter?
  Karpenter is an open-source, flexible, high-performance Kubernetes cluster autoscaler that:
- Provisions nodes in seconds, not minutes
- Automatically selects optimal instance types based on pod requirements
- Supports Spot instances with graceful interruption handling
- Consolidates nodes to reduce costs when capacity is underutilized
- Eliminates the need for managing Auto Scaling Groups (ASGs)

## karpenter architecture
![alt](https://github.com/nawaz-ch/karpenter-implementation/blob/ec7635d2cfa29de87c640bee74a23f89b6916220/karpenter-architecture.png)

## karpenter install diagram
![alt](https://github.com/nawaz-ch/karpenter-implementation/blob/ec7635d2cfa29de87c640bee74a23f89b6916220/karpenter-install.png)


# Architecture Overview 
```bash
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                           │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                    VPC (10.0.0.0/16)                 │  │
│  │                                                      │  │
│  │  ┌────────────────────────────────────────────┐     │  │
│  │  │         EKS Cluster (retail-dev)           │     │  │
│  │  │                                            │     │  │
│  │  │  ┌──────────────────────────────────────┐ │     │  │
│  │  │  │    Karpenter Controller (Pods)       │ │     │  │
│  │  │  │  - Watches for unschedulable pods    │ │     │  │
│  │  │  │  - Provisions EC2 instances          │ │     │  │
│  │  │  │  - Handles spot interruptions        │ │     │  │
│  │  │  └──────────────────────────────────────┘ │     │  │
│  │  │                                            │     │  │
│  │  │  ┌──────────────────────────────────────┐ │     │  │
│  │  │  │    Managed Node Group (baseline)     │ │     │  │
│  │  │  │  - Hosts system pods                 │ │     │  │
│  │  │  │  - CoreDNS, kube-proxy, etc.         │ │     │  │
│  │  │  └──────────────────────────────────────┘ │     │  │
│  │  │                                            │     │  │
│  │  │  ┌──────────────────────────────────────┐ │     │  │
│  │  │  │    Karpenter Nodes (dynamic)         │ │     │  │
│  │  │  │  - On-Demand instances               │ │     │  │
│  │  │  │  - Spot instances                    │ │     │  │
│  │  │  │  - Auto-scaled based on demand       │ │     │  │
│  │  │  └──────────────────────────────────────┘ │     │  │
│  │  └────────────────────────────────────────────┘     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │              Supporting Resources                    │  │
│  │                                                      │  │
│  │  - SQS Queue (spot interruption events)             │  │
│  │  - EventBridge Rules (AWS events → SQS)             │  │
│  │  - IAM Roles (controller + node permissions)        │  │
│  │  - Pod Identity (IRSA alternative)                  │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘

```

## Karpenter project files

```bash
├── 03_KARPENTER_terraform-manifests/    # Layer 3: Karpenter Infrastructure
│   ├── c1_versions.tf                   # Terraform versions & S3 backend
│   ├── c2_variables.tf                  # Karpenter variables
│   ├── c3_01_vpc_remote_state.tf        # VPC remote state reference
│   ├── c3_02_eks_remote_state.tf        # EKS remote state reference
│   ├── c4_datasources_and_locals.tf     # AWS account/region/cluster name
│   ├── c5_helm_and_kubernetes_providers.tf  # K8s provider configs
│   ├── c6_01_karpenter_controller_iam_role.tf       # Controller IAM role
│   ├── c6_02_karpenter_controller_iam_policy.tf     # Controller permissions
│   ├── c6_03_karpenter_pod_identity_association.tf  # Pod Identity mapping
│   ├── c6_04_karpenter_node_iam_role.tf             # Node IAM role
│   ├── c6_05_karpenter_access_entry.tf              # Node cluster access
│   ├── c6_06_karpenter_helm_install.tf              # Karpenter Helm chart
│   ├── c6_07_karpenter_sqs_queue.tf                 # Interruption queue
│   ├── c6_08_karpenter_eventbridge_rules.tf         # Spot event rules
│   └── terraform.tfvars                 # Karpenter variable values
│
├── 04_KARPENTER_k8s-manifests/          # Layer 4: Karpenter Configuration
   ├── 01_ec2nodeclass.yaml             # Node template (AMI, SG, subnets)
   ├── 02_nodepool_ondemand.yaml        # On-Demand node pool
   └── 03_nodepool_spot.yaml            # Spot instance node pool

```

> 📝 **Note:** Make sure your eks cluster is up and running and add the eks pod identity agent add on.

## deployment steps

```bash
# Step 1: Deploy Karpenter Infrastructure
cd ../03_KARPENTER_terraform-manifests
terraform init
terraform apply -auto-approve

# Step 2: Configure kubectl
aws eks update-kubeconfig --name retail-dev-eksdemo1 --region us-east-1

# Step 3: Verify Karpenter is running
kubectl get pods -n kube-system -l app.kubernetes.io/name=karpenter

# Step 4: Apply Karpenter Configuration
cd ../04_KARPENTER_k8s-manifests
kubectl apply -f 01_ec2nodeclass.yaml
kubectl apply -f 02_nodepool_ondemand.yaml
kubectl apply -f 03_nodepool_spot.yaml

# Step 5: Verify NodePools and EC2Nodeclass
kubectl get nodepools
kubectl get ec2nodeclass

```
> ⚠️ Critical Configuration:
```bash
#  REQUIRED for Karpenter-add this for eks cluster
resource "aws_ec2_tag" "eks_subnet_tag_private_cluster" {
  value = "owned"  # Must be "owned", not "shared"
}
```

## Why "owned" matters:
- `shared`: EKS control plane can use, but Karpenter CANNOT launch nodes
- `owned`: Full access for Karpenter, Managed Node Groups, and control plane

# Key Component: Karpenter Configuration
**Purpose: Define how Karpenter provisions nodes**
## EC2NodeClass (Node Template)
```bash
# 01_ec2nodeclass.yaml
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default-ec2nodeclass
spec:
  # Recommended for EKS-managed Amazon Linux 2023 AMIs
  amiFamily: AL2023

  amiSelectorTerms:
    - alias: al2023@latest

  # Node IAM role created in Terraform
  role: "arn:aws:iam::180789647333:role/retail-dev-karpenter-node-role"

  # Auto-discover subnets (your cluster tags)
  subnetSelectorTerms:
    - tags:
        kubernetes.io/cluster/retail-dev-eksdemo1: owned
        kubernetes.io/role/internal-elb: "1"

  # Auto-discover security groups
  securityGroupSelectorTerms:
    - tags:
        kubernetes.io/cluster/retail-dev-eksdemo1: owned

  # Required for Karpenter auto-discovery of resources
  tags:
    karpenter.sh/discovery: retail-dev-eksdemo1

  # Recommended EBS configuration
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 20Gi
        volumeType: gp3
        encrypted: true
        deleteOnTermination: true

  # Recommended IMDS Metadata options
  metadataOptions:
    httpTokens: required
    httpPutResponseHopLimit: 2


  # -------------------------------------------------------------------
  # NOTE ABOUT SUBNET SELECTION:
  #
  # By default, Karpenter discovers *all* subnets that contain the
  # cluster tag:
  #
  #   kubernetes.io/cluster/<cluster-name> = owned
  #
  # Since this tag exists on BOTH public and private subnets, Karpenter
  # may accidentally provision worker nodes in PUBLIC subnets, which
  # gives EC2 instances public IP addresses (NOT secure).
  #
  # To enforce a private-only Kubernetes data plane, we add an extra
  # filter:
  #
  #   kubernetes.io/role/internal-elb = "1"
  #
  # This tag exists ONLY on private subnets (created for internal load
  # balancers), so Karpenter will launch nodes **exclusively in private
  # subnets**, with NO public IPs — matching enterprise security
  # standards.
  # Use this filter ALWAYS in production clusters for node provisioning.
  # -------------------------------------------------------------------
```

**On-Demand NodePool**
```bash
# 02_nodepool_ondemand.yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ondemand-nodepool
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default-ec2nodeclass

      # No taints for now (you can add later)
      taints: []
      startupTaints: []

      # Node selection logic
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]

        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        
        # Cheaper, smaller instance families
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["t3", "t3a"]  # All burstable, budget-friendly

        # Limit to smaller sizes only
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["micro", "small", "medium"]  # Caps at t3.medium (2 vCPU, 4GB RAM)

        # Must match the AZs where your EKS cluster has subnets configured
        # Karpenter can only launch nodes in AZs with configured VPC subnets
        - key: topology.kubernetes.io/zone
          operator: In
          values: ["us-east-1a", "us-east-1b", "us-east-1c"]  

  # Cluster-wide max scaling limit
  limits:
    cpu: "50"

  # Recommended disruption settings
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s  # How long to wait before consolidating
```

## spot Nodepool
```bash
# 03_nodepool_spot.yaml
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: spot-nodepool
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default-ec2nodeclass

      taints: []
      startupTaints: []

      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]

        - key: kubernetes.io/os
          operator: In
          values: ["linux"]

        # Spot capacity (50-90% cheaper than on-demand)
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]

        # Multiple instance families for better spot availability
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: ["t3", "t3a", "t2", "c5a", "c6a"]

        # Allow micro to large - flexibility helps find available spot capacity
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["micro", "small", "medium", "large"]

        # Must match the AZs where your EKS cluster has subnets configured
        # Karpenter can only launch nodes in AZs with configured VPC subnets
        - key: topology.kubernetes.io/zone
          operator: In
          values: ["us-east-1a", "us-east-1b", "us-east-1c"]

  limits:
    cpu: "50"

  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 30s
```

## Deploy and Verify Nodepools
```bash

# Change Directory
04_KARPENTER_k8s-manifests

# Deploy Nodepools
kubectl apply -f 02_nodepool_ondemand.yaml
kubectl apply -f 03_nodepool_spot.yaml

# List Nodepools
kubectl get nodepools

# Expected:
# NAME                READY   AGE
# ondemand-nodepool   True    5m
# spot-nodepool       True    5m


# Describe Nodepools
kubectl describe nodepool ondemand-nodepool
kubectl describe nodepool spot-nodepool

```
