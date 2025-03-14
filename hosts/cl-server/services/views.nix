{ config, ... }:
let
  exportersAddr = "127.0.0.99";
in
{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "node_exporter";
      static_configs = [
        {
          targets = [
            "${config.services.prometheus.exporters.node.listenAddress}:${toString config.services.prometheus.exporters.node.port}"
          ];
          labels.type = "node";
        }
      ];
    }
  ];
  services.grafana.provision.dashboards.settings.providers = [ ];
  services.prometheus.exporters = {
    node = {
      enable = true;
      port = 9901;
      listenAddress = exportersAddr;
      user = "root";
      enabledCollectors = [
        "buddyinfo"
        "cgroups"
        "cpu_vulnerabilities"
        "ethtool"
        "interrupts"
        "ksmd"
        "lnstat"
        "logind"
        "processes"
        "qdisc"
        "slabinfo"
        "softirqs"
        "sysctl"
        "systemd"
        "tcpstat"
        "perf"
      ];
    };
  };

  boot.kernel.sysctl."kernel.perf_event_paranoid" = 0;
}
