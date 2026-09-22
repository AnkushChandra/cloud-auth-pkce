variable "aws_region" {
  description = "Region where the homework stack is deployed."
  type        = string
  default     = "ap-south-1"
}

variable "stage_name" {
  description = "API Gateway stage name. The UI redirect URI is this stage path."
  type        = string
  default     = "prod"
}

variable "student_name" {
  description = "Name stored on the student employee record."
  type        = string
  default     = "Ankush Chandrashekar"
}

variable "student_iam_user" {
  description = "IAM user name used to build the student AWS user ARN."
  type        = string
  default     = "ankushc"
}

variable "student_employee_id" {
  description = "Partition key of the student employee record."
  type        = string
  default     = "1005"
}

variable "cognito_domain_prefix" {
  description = "Existing Cognito managed-login domain prefix."
  type        = string
  default     = "ap-south-1sxyac8kr4"
}
