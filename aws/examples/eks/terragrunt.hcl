terraform {
  source = "${get_parent_terragrunt_dir()}/../module//eks"
}


include root {
  path = find_in_parent_folders()
  expose = true
}

dependency "default-tags"{
    config_path  = "../default-tags"
    mock_outputs = {
      tags = {
        school = "bus2"
        project = "bus2"
        subproject = "null"
        envir = "demo"
        contact = "contact"
      }
    }
}

locals {
  ## if you need a specific ami
  eks_node_ami_id = "ami-xxxxxxxxxxxxxxxxx"
}

inputs = {

  eks_clusters = {

    ## cluster 1
    test-sg-demo = {
      cluster_name = "test-sg-demo"
      
      ## default_tags for the EKS Cluster
      default_tags = dependency.default-tags.outputs.tags
      ## diable public access by default
      #cluster_endpoint_public_access = true

      subnet_ids = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx"
      ]
      vpc_id = "vpc-xxxxxxxxxxxxxxxxx"
      
      eks_managed_node_groups = {
        gateway = {
          min_size     = 1
          max_size     = 1
          desired_size = 1

          capacity_type = "ON_DEMAND"
          ## ssh key pair
          key_name = "eks-test"
          instance_types = ["t3.micro"]
          update_config = {
            max_unavailable_percentage = 25
          }

          labels = {
            apptier     = "gateway"
          }
          ## you must provide the EC2 tags for node group, otherwise it will be rejected by AWS SCP policies
          tags = dependency.default-tags.outputs.tags
        }
      }
    }
  }

}