variable "region" { 
	type = string
	default = "us-east-1" 
	}

variable "bucket_name" { 
	type = string 
	default = "three-tier-bucket"
	}

variable "bucket_logs" { 
	type = string 
	default = "log-bucket-for-three-tier-app"
	}
