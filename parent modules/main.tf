module "resource_group" {
  source                  = "../modules/azurerm_resource_group"
  resource_group_name     = "rg-jeet"
  resource_group_location = "centralindia"
}

module "resource_group" {
  source                  = "../modules/azurerm_resource_group"
  resource_group_name     = "rg-jeet-PR test kerna ha wapis se kiya ha wapis se"
  resource_group_location = "centralindia"
}

module "virtual_network" {
  depends_on               = [module.resource_group]
  source                   = "../modules/azurerm_virtual_network"
  virtual_network_name     = "vnet-todoapp"
  virtual_network_location = "centralindia"
  resource_group_name      = "rg-jeet"
  address_space            = ["10.0.0.0/16"]
}

module "frontend_subnet" {
  depends_on           = [module.virtual_network]
  source               = "../modules/azurerm_subnet"
  resource_group_name  = "rg-jeet"
  virtual_network_name = "vnet-todoapp"
  subnet_name          = "frontend-subnet"
  address_prefixes     = ["10.0.1.0/24"]
}

module "public_ip_frontend" {
  source              = "../modules/azurerm_public_ip"
  public_ip_name      = "pip-todoapp-frontend"
  resource_group_name = "rg-jeet"
  location            = "centralindia"
  allocation_method   = "Static"
}

module "key_vault" {
  source              = "../modules/azurerm_key_vault"
  key_vault_name      = "jeetkitihori"
  location            = "centralindia"
  resource_group_name = "rg-jeet"
}

module "vm_username" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "jeetkitihori"
  resource_group_name = "rg-jeet"
  secret_name         = "vm-username"
  secret_value        = "devopsadmin"
}

module "vm_password" {
  source              = "../modules/azurerm_key_vault_secret"
  depends_on          = [module.key_vault]
  key_vault_name      = "jeetkitihori"
  resource_group_name = "rg-jeet"
  secret_name         = "vm-password"
  secret_value        = "P@ssw01rd@123"
}

module "frontend_vm" {
  depends_on = [module.frontend_subnet, module.key_vault, module.vm_username, module.vm_password, module.public_ip_frontend]
  source     = "../modules/azurerm_virtual_machine"

  resource_group_name  = "rg-jeet"
  location             = "centralindia"
  vm_name              = "vm-frontend"
  vm_size              = "Standard_B1s"
  image_publisher      = "Canonical"
  image_offer          = "0001-com-ubuntu-server-focal"
  image_sku            = "20_04-lts"
  image_version        = "latest"
  nic_name             = "nic-vm-frontend"
  frontend_ip_name     = "pip-todoapp-frontend"
  vnet_name            = "vnet-todoapp"
  frontend_subnet_name = "frontend-subnet"
  key_vault_name       = "jeetkitihori"
  username_secret_name = "vm-username"
  password_secret_name = "vm-password"
}


module "sql_server" {
  source                       = "../modules/azurerm_sql_server"
  sql_server_name              = "todosqlserver008"
  resource_group_name          = "rg-jeet"
  location                     = "centralindia"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
}


module "sql_database" {
  depends_on          = [module.sql_server]
  source              = "../modules/azurerm_sql_database"
  sql_server_name     = "todosqlserver008"
  resource_group_name = "rg-jeet"
  sql_database_name   = "tododb"
}



