locals {
  names = {
    api-management              = lower("APIM-${var.env}-${var.application}-${var.location_map[var.location]}")
    application-gateway         = {
      name                          = lower("AGW-${var.env}-${var.location_map[var.location]}-${var.application}")
      gateway_ip_configuration_name = lower("gw-ip-${var.env}-${var.location_map[var.location]}-${var.application}")
      unused = { # these items are needed to build a minimal Application Gateway resource
        probe_name                 = lower("unused-backend-probe-${var.env}-${var.location_map[var.location]}-${var.application}")
        frontend_port_name         = lower("unused-feport-${var.env}-${var.location_map[var.location]}-${var.application}")
        backend_address_pool_name  = lower("unused-beap-${var.env}-${var.location_map[var.location]}-${var.application}")
        backend_http_settings_name = lower("unused-htst-${var.env}-${var.location_map[var.location]}-${var.application}")
        http_listener_name         = lower("unused-listener-${var.env}-${var.location_map[var.location]}-${var.application}")
        rule_name                  = lower("unused-rule-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      common_public = {
        frontend_port_name              = lower("feport-${var.env}-${var.location_map[var.location]}-${var.application}")
        frontend_ip_configuration_name  = lower("feip-${var.env}-${var.location_map[var.location]}-${var.application}")
        backend_address_pool_name       = lower("beap-${var.env}-${var.location_map[var.location]}-${var.application}")
        backend_http_settings_name      = lower("htst-${var.env}-${var.location_map[var.location]}-${var.application}")
        ssl_certificate_name            = "dtos-lets-encrypt"
      }
      common_private = {
        frontend_port_name             = lower("feport-private-${var.env}-${var.location_map[var.location]}-${var.application}")
        frontend_ip_configuration_name = lower("feip-private-${var.env}-${var.location_map[var.location]}-${var.application}")
        ssl_certificate_name           = "dtos-lets-encrypt-private"
      }
    }
    app-insights                = upper("${var.env}-${var.location_map[var.location]}")
    app-service-plan            = lower("ASP-${var.application}-${var.env}-${var.location_map[var.location]}")
    app-service                 = lower("AS-${var.env}-${var.location_map[var.location]}-${var.application}")
    availability-set            = lower("AVS-${var.env}-${var.location_map[var.location]}-${var.application}")
    avd-dag                     = lower("AVDDAG-${var.env}-${var.location_map[var.location]}")
    avd-host                    = lower("AVDSH-${var.env}-${var.location_map[var.location]}")
    avd-host-pool               = lower("AVDHP-${var.env}-${var.location_map[var.location]}")
    avd-workspace               = lower("AVDWS-${var.env}-${var.location_map[var.location]}")
    azure-container-registry    = lower("ACR${var.location_map[var.location]}${var.application}${var.env}")
    connection                  = lower("CON-${var.env}-${var.location_map[var.location]}-${var.application}")
    custom-image                = lower("IMAGE-${var.env}-${var.location_map[var.location]}")
    dev-center                  = lower("DEVC-${var.env}-${var.location_map[var.location]}")
    dev-center-project          = lower("prj-${var.env}-${var.location_map[var.location]}")
    dns-zone                    = "${lower(var.application)}.${lower(var.env)}.net"
    docker-dtr                  = lower("DTR-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-manager              = lower("UCP-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker               = lower("LWK-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker-windows       = lower("WWK-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker-windows-nb    = lower("WWK${var.env}${var.location_map[var.location]}${var.application}")
    external-load-balancer      = lower("ELB-${var.env}-${var.location_map[var.location]}-${var.application}")
    event-grid-topic            = lower("EVGT-${var.env}-${var.location_map[var.location]}")
    firewall                    = lower("FW-${var.env}-${var.location_map[var.location]}-${var.application}")
    function-app                = lower("${var.env}-${var.location_map[var.location]}")
    internal-load-balancer      = lower("ILB-${var.env}-${var.location_map[var.location]}-${var.application}")
    key-vault                   = upper("KV-${var.application}-${var.env}-${var.location_map[var.location]}")
    kubernetes-service          = lower("AKS-${var.env}-${var.location_map[var.location]}-${var.application}")
    load-balancer               = lower("LB-${var.env}-${var.location_map[var.location]}-${var.application}")
    local-network-gateway       = lower("LNG-${var.env}-${var.location_map[var.location]}-${var.application}")
    log-analytics-workspace     = upper("${var.env}-${var.location_map[var.location]}")
    logic-app                   = lower("LA-${var.env}-${var.location_map[var.location]}-${var.application}")
    managed-devops-pool         = lower("private-pool-${var.env}-${var.location_map[var.location]}")
    network-interface           = upper("${var.env}-${var.location_map[var.location]}-${var.application}")
    network-security-group      = upper("NSG-${var.env}-${var.location_map[var.location]}-${var.application}")
    private-ssh-key             = lower("ssh-pri-${var.env}${var.location_map[var.location]}${var.application}")
    public-ip-address           = lower("PIP-${var.env}-${var.location_map[var.location]}-${var.application}")
    public-ip-dns               = lower("${var.env}${var.location_map[var.location]}${var.application}")
    public-ssh-key              = lower("ssh-pub-${var.env}${var.location_map[var.location]}${var.application}")
    redis-cache                 = lower("RC-${var.location_map[var.location]}-${var.env}-${var.application}")
    resource-group              = lower("RG-${var.application}-${var.env}-${var.location_map[var.location]}")
    resource-application        = lower("${var.env}-${var.location_map[var.location]}-${var.application}")
    route-table                 = lower("RT-${var.env}-${var.location_map[var.location]}-${var.application}")
    service-bus                 = lower("SB-${var.location_map[var.location]}-${var.env}-${var.application}")
    service-principal           = upper("SP-${var.env}-${var.application}")
    sql-server                  = lower("SQLSVR-${var.application}-${var.env}-${var.location_map[var.location]}")
    sql-server-db               = lower("SQLDB-${var.application}-${var.env}-${var.location_map[var.location]}")
    sql-server-managed-instance = lower("SQLMI-${var.env}-${var.location_map[var.location]}-${var.application}")
    stack-dns-suffix            = "${lower(var.env)}${lower(var.application)}"
    storage-account             = substr(lower("ST${var.application}${var.env}${var.location_map[var.location]}"), 0, 24)
    storage-alerts              = lower("STALERT${var.env}${var.location_map[var.location]}${var.application}")
    storage-boot-diags          = lower("STDIAG${var.env}${var.location_map[var.location]}${var.application}")
    storage-flow-logs           = lower("STFLOW${var.env}${var.location_map[var.location]}${var.application}")
    storage-shared-state        = lower("STSTATE${var.env}${var.location_map[var.location]}${var.application}")
    subnet                      = upper("SN-${var.env}-${var.location_map[var.location]}-${var.application}")
    virtual-machine             = lower("${var.env}-${var.application}")
    win-virtual-machine         = lower("${var.env}-${var.application}")
    virtual-network             = upper("VNET-${var.env}-${var.location_map[var.location]}-${var.application}")
    vnet-gateway                = lower("GWY-${var.env}-${var.location_map[var.location]}-${var.application}")
  }
}

output "names" {
  description = "Return list of calculated standard names for the deployment."
  value       = local.names
}
