variable "aws_mskconnect_worker_configuration" {
    type = any
    description = "a list of the worker configuration"
    default = {}
}


variable "aws_mskconnect_custom_plugin" {
    type = any
    description = "a list of msk connect cusotm plugin"
    default = {}
}

variable "aws_mskconnect_connector" {
    type = any
    default = {}
}

variable "kafkaconnect_version" {
    type = string 
    default = "2.7.1"
}

 variable  "mcu_count" {
    type = number
    default = 1
 }   


 variable "min_worker_count" {
    type = number
    default = 1
 }    
      

 variable "max_worker_count" {
    type = number
    default = 2
 }  

variable "scale_in_cpu_utilization_percentage" {
    type =  number
    default = 20
}
      
variable "scale_out_cpu_utilization_percentage" {
    type =  number
    default = 80
}


variable "authentication_type" {
    type = string 
    default = "NONE"

}


variable "encryption_type" {
    type = string
    default = "TLS"
}

variable "log_group" {
    type =  string 
    default = "/aws/msk-connect/debezium/logs"
}