variable "resource_group_name" {}
variable "sql_server_name" {}
variable "sql_database_name" {
  description = "The name of the SQL database."
  type        = string
}