resource "azurerm_route_table" "this" { #creates the route table
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_route" "this" { # creates routes only if we pass routes
  for_each = var.routes           #means: For every route in the var.routes map, create one azurerm_route.

  name                   = each.key
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.this.name
  address_prefix         = each.value.address_prefix
  next_hop_type          = each.value.next_hop_type
  next_hop_in_ip_address = try(each.value.next_hop_in_ip_address, null) #Some Azure route types need a next-hop IP address. Some do not.
}

resource "azurerm_subnet_route_table_association" "this" {
  # attaches route table to subnets
  for_each = var.subnet_ids

  subnet_id      = each.value
  route_table_id = azurerm_route_table.this.id
}