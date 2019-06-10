module "label" {
  source              = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.11.1"
  attributes          = ["${var.attributes}"]
  namespace           = "${var.namespace}"
  environment         = "${var.environment}"
  stage               = "${var.stage}"
  delimiter           = "${var.delimiter}"
  name                = "${var.name}"
  tags                = "${var.tags}"
  additional_tag_map  = "${var.additional_tag_map}"
  regex_replace_chars = "${var.regex_replace_chars}"
  label_order         = "${var.label_order}"
  context             = "${var.context}"
}

variable "additional_tag_map" {
  type        = "map"
  default     = {}
  description = "Additional tags for appending to each tag map"
}

variable "label_order" {
  type        = "list"
  default     = []
  description = "The naming order of the id output and Name tag"
}

variable "regex_replace_chars" {
  type        = "string"
  default     = "/[^a-zA-Z0-9-]/"
  description = "Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed"
}

variable "tags" {
  description = "Additional tags to apply to all resources that use this label module"
  type        = "map"
  default     = {}
}

variable "namespace" {
  type        = "string"
  default     = ""
  description = "Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  default     = ""
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = "string"
  default     = ""
  description = "Solution name, e.g. 'app' or 'jenkins'"
}

variable "environment" {
  description = "The environment name if not using stage"
  default     = ""
}

variable "attributes" {
  type        = "list"
  description = "Any extra attributes for naming these resources"
  default     = []
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "context" {
  type        = "map"
  description = "The context output from an external label module to pass to the label modules within this module"
  default     = {}
}
