terraform {
  source = "${get_parent_terragrunt_dir()}/../module//midware-env"
}

include {
  path = find_in_parent_folders()
}

inputs = {

  db_subnet_groups = {
    # db-subnet-group-1 = {
    #   name  = "db-subnet-group-1"
    #   subnet_ids = [
    #     "subnet-xxxxxxxxx,
    #     "subnet-xxxxxxxxx",
    #     "subnet-xxxxxxxxx"
    #   ]
    # }
    db-subnet-group-2 = {
      name  = "db-subnet-group-2"
      subnet_ids = [
        "subnet-xxxxxxxxx",
        "subnet-xxxxxxxxx",
        "subnet-xxxxxxxxx"
      ]
    }
  },
    elasticache_subnet_groups = {
    redis-subnet-group-1 = {    
      name  = "redis-subnet-group-1"
      subnet_ids = [
        "subnet-xxxxxxxxx",
        "subnet-xxxxxxxxx",
        "subnet-xxxxxxxxx"
      ]
    }
  }
}
 