/**********************************************
 * General stuff
 **********************************************/
variable "environment" {
  description = "development, production, etc."
  type        = "string"
  default     = "development"
}

variable "tags" {
  type        = "map"
  description = "mandatory tags to prevent Krampus from our killing services"
  default     = {}
}

/**********************************************
 * Go Lambda specific stuff
 **********************************************/
variable "function_name" {
  type        = "string"
  description = "name of the lambda function to deploy"
}

variable "filepath" {
  type        = "string"
  description = "filepath of the zipfile for the lambda function to deploy"
}

variable "executable_name" {
  type        = "string"
  default     = "main"
  description = "filename of the executable file for the lambda function to deploy"
}

variable "timeout" {
  default     = 3
  description = "how long you want the lambda to run before it times out"
}

variable "memory_size" {
  default     = 128
  description = "the amount of memory (in MB) to allocate to each running lambda. Worth noting that this is also the only way to allocate more CPU to the lambda"
}

variable "env_vars" {
  type        = "map"
  description = "a map of the environment variables you want your lambda to have access to at runtime"
}

/**********************************************
 * Tracing config
 **********************************************/
variable "enable_xray" {
  default     = false
  description = "set to true if you want the lambda to operate in the Active tracing mode"
}

variable "tracing_mode" {
  type        = "string"
  default     = "PassThrough"
  description = "the tracing mode to use with X-Ray. Either PassThrough or Active. Note that the Lambda will require X-Ray write permissions separately if set to Active"
}

/**********************************************
 * Additional Access Policies, optional
 **********************************************/
variable "attach_policies" {
  default     = []
  description = "a list of any additional policy ARNs that you'd like the lambda to have access to"
}
