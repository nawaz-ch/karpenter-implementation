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


