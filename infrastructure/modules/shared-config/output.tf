locals {
  names = {
    # Return the three letter location code for the given location
    location_code = lower(var.location_map[var.location])

    api-management = lower("APIM-${var.env}-${var.application}-${var.location_map[var.location]}")

    application-gateway = {
      name                          = lower("AGW-${var.env}-${var.location_map[var.location]}-${var.application}")
      gateway_ip_configuration_name = lower("gw-ip-${var.env}-${var.location_map[var.location]}-${var.application}")
      managed_identity_name         = lower("MI-${var.application}-${var.env}-${var.location_map[var.location]}-agw")

      frontend_port_name = {
        https = lower("feport-https-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      frontend_ip_configuration_name = {
        private = lower("feip-priv-${var.env}-${var.location_map[var.location]}-${var.application}")
        public  = lower("feip-pub-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      probe_name = {
        apim_gateway   = lower("apim-gateway-probe-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_portal    = lower("apim-portal-probe-${var.env}-${var.location_map[var.location]}-${var.application}")
        migration_test = lower("migration-test-probe-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      backend_address_pool_name = {
        apim_gateway   = lower("apim-gateway-beap-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_portal    = lower("apim-portal-beap-${var.env}-${var.location_map[var.location]}-${var.application}")
        migration_test = lower("migration-test-beap-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      backend_http_settings_name = {
        apim_shared    = lower("apim-shared-htst-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_gateway   = lower("apim-gateway-htst-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_portal    = lower("apim-portal-htst-${var.env}-${var.location_map[var.location]}-${var.application}")
        migration_test = lower("migration-test-htst-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      http_listener_name = {
        apim_gateway_public   = lower("apim-gateway-pub-listener-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_gateway_private  = lower("apim-gateway-priv-listener-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_portal_private   = lower("apim-portal-priv-listener-${var.env}-${var.location_map[var.location]}-${var.application}")
        migration_test_public = lower("migration-test-pub-listener-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      rewrite_rule_set_name = {
        migration_test = lower("migration-test-rwrs-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
      rule_name = {
        apim_gateway_public   = lower("apim-gateway-pub-rule-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_gateway_private  = lower("apim-gateway-priv-rule-${var.env}-${var.location_map[var.location]}-${var.application}")
        apim_portal_private   = lower("apim-portal-priv-rule-${var.env}-${var.location_map[var.location]}-${var.application}")
        migration_test_public = lower("migration-test-pub-rule-${var.env}-${var.location_map[var.location]}-${var.application}")
      }
    }

    app-insights                        = lower("APPI-${var.env}-${var.location_map[var.location]}-${var.application}")
    app-service-plan                    = lower("ASP-${var.env}-${var.location_map[var.location]}-${var.application}")
    app-service                         = lower("AS-${var.env}-${var.location_map[var.location]}-${var.application}")
    availability-set                    = lower("AVS-${var.env}-${var.location_map[var.location]}-${var.application}")
    avd-dag                             = lower("AVDDAG-${var.env_type}-${var.location_map[var.location]}")
    avd-host                            = lower("AVDSH-${var.env_type}-${var.location_map[var.location]}")
    avd-host-pool                       = lower("AVDHP-${var.env_type}-${var.location_map[var.location]}")
    avd-scaling-plan                    = lower("AVDSP-${var.env_type}-${var.location_map[var.location]}")
    avd-workspace                       = lower("AVDWS-${var.env_type}-${var.location_map[var.location]}")
    azure-container-registry            = lower("ACR${var.location_map[var.location]}${var.application}${var.env}")
    container-app                       = lower("CA-${var.env}-${var.location_map[var.location]}-${var.application}")
    container-app-environment           = lower("CAE-${var.env}-${var.location_map[var.location]}-${var.application}")
    connection                          = lower("CON-${var.env}-${var.location_map[var.location]}-${var.application}")
    custom-image                        = lower("IMAGE-${var.env}-${var.location_map[var.location]}")
    dev-center                          = lower("DEVC-${var.env}-${var.location_map[var.location]}")
    dev-center-project                  = lower("prj-${var.env}-${var.location_map[var.location]}")
    dns-zone                            = lower("${var.application}.${var.env}.net")
    docker-dtr                          = lower("DTR-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-manager                      = lower("UCP-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker                       = lower("LWK-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker-windows               = lower("WWK-${var.env}-${var.location_map[var.location]}-${var.application}")
    docker-worker-windows-nb            = lower("WWK${var.env}${var.location_map[var.location]}${var.application}")
    external-load-balancer              = lower("ELB-${var.env}-${var.location_map[var.location]}-${var.application}")
    event-grid-topic                    = lower("EVGT-${var.env}-${var.location_map[var.location]}")
    event-hub-namespace                 = lower("EVHNS-${var.env}-${var.location_map[var.location]}-${var.application}")
    firewall                            = lower("FW-${var.env}-${var.location_map[var.location]}-${var.application}")
    front-door-profile                  = lower("AFD-${var.env_type}-${var.application}")
    function-app                        = lower("${var.env}-${var.location_map[var.location]}")
    linux-web-app                       = lower("${var.env}-${var.location_map[var.location]}")
    internal-load-balancer              = lower("ILB-${var.env}-${var.location_map[var.location]}-${var.application}")
    key-vault                           = upper("KV-${var.application}-${var.env}-${var.location_map[var.location]}")
    kubernetes-service                  = lower("AKS-${var.env}-${var.location_map[var.location]}-${var.application}")
    load-balancer                       = lower("LB-${var.env}-${var.location_map[var.location]}-${var.application}")
    local-network-gateway               = lower("LNG-${var.env}-${var.location_map[var.location]}-${var.application}")
    log-analytics-workspace             = lower("LAW-${var.env}-${var.location_map[var.location]}-${var.application}")
    logic-app                           = lower("LA-${var.env}-${var.location_map[var.location]}-${var.application}")
    managed-devops-pool                 = lower("private-pool-${var.env}-${var.location_map[var.location]}")
    managed-identity                    = lower("MI-${var.env}-${var.location_map[var.location]}-${var.application}")
    monitor-action-group                = lower("AG-${var.env}-${var.location_map[var.location]}-${var.application}")
    network-interface                   = upper("${var.env}-${var.location_map[var.location]}-${var.application}")
    network-security-group              = upper("NSG-${var.env}-${var.location_map[var.location]}-${var.application}")
    postgres-sql-server                 = lower("postgres-${var.application}-${var.env}-${var.location_map[var.location]}")
    private-ssh-key                     = lower("ssh-pri-${var.env}${var.location_map[var.location]}${var.application}")
    private-link-scope                  = lower("ampls-${var.env}${var.application}")
    private-link-scope-private-endpoint = lower("ampls-${var.env}${var.location_map[var.location]}${var.application}-private-endpoint")
    private-link-scoped-service         = lower("ampls-svc-${var.env}${var.location_map[var.location]}${var.application}")
    public-ip-address                   = lower("PIP-${var.env}-${var.location_map[var.location]}-${var.application}")
    public-ip-dns                       = lower("${var.env}${var.location_map[var.location]}${var.application}")
    public-ssh-key                      = lower("ssh-pub-${var.env}${var.location_map[var.location]}${var.application}")
    redis-cache                         = lower("RC-${var.location_map[var.location]}-${var.env}-${var.application}")
    resource-group                      = lower("RG-${var.application}-${var.env}-${var.location_map[var.location]}")
    resource-application                = lower("${var.env}-${var.location_map[var.location]}-${var.application}")
    route-table                         = lower("RT-${var.env}-${var.location_map[var.location]}-${var.application}")
    service-bus                         = lower("SB-${var.location_map[var.location]}-${var.env}-${var.application}")
    service-bus-namespace               = lower("SBN-${var.location_map[var.location]}-${var.env}-${var.application}")
    service-principal                   = upper("SP-${var.env}-${var.application}")
    sql-server                          = lower("SQLSVR-${var.application}-${var.env}-${var.location_map[var.location]}")
    sql-server-db                       = lower("SQLDB-${var.application}-${var.env}-${var.location_map[var.location]}")
    sql-server-managed-instance         = lower("SQLMI-${var.env}-${var.location_map[var.location]}-${var.application}")
    stack-dns-suffix                    = "${lower(var.env)}${lower(var.application)}"
    storage-account                     = substr(lower("ST${var.application}${var.env}${var.location_map[var.location]}"), 0, 24)
    storage-alerts                      = lower("STALERT${var.env}${var.location_map[var.location]}${var.application}")
    storage-boot-diags                  = lower("STDIAG${var.env}${var.location_map[var.location]}${var.application}")
    storage-flow-logs                   = lower("STFLOW${var.env}${var.location_map[var.location]}${var.application}")
    storage-shared-state                = lower("STSTATE${var.env}${var.location_map[var.location]}${var.application}")
    subnet                              = upper("SN-${var.env}-${var.location_map[var.location]}-${var.application}")
    virtual-machine                     = lower("${var.env}-${var.application}")
    win-virtual-machine                 = lower("${var.env}-${var.application}")
    virtual-network                     = upper("VNET-${var.env}-${var.location_map[var.location]}-${var.application}")
    virtual-network-lowercase           = lower("vnet-${var.env}-${var.location_map[var.location]}-${var.application}")
    vnet-gateway                        = lower("GWY-${var.env}-${var.location_map[var.location]}-${var.application}")
  }
}

output "names" {
  description = "Return list of calculated standard names for the deployment."
  value       = local.names
}
