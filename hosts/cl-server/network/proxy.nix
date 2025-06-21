{
  pkgs,
  lib,
  config,
  ...
}:
{
  system.preserve.directories = [ "/var/lib/sing-box" ];
  systemd.network.networks."10-proxy" = {
    matchConfig = {
      Name = "lo";
    };
    linkConfig = {
      RequiredForOnline = true;
    };
    networkConfig = {
      KeepConfiguration = true;
    };
    routes = [
      {
        Gateway = "0.0.0.0";
        Type = "local";
        Table = 7890;
      }
      {
        Gateway = "::";
        Type = "local";
        Table = 7890;
      }
    ];
    routingPolicyRules = [
      {
        FirewallMark = 7890;
        Table = 7890;
      }
    ];
  };
  networking.nftables.tables = {
    proxy = {
      name = "proxy";
      family = "inet";
      content = ''
        define EXCLUDES_PROXY_V4 = { 127.0.0.0/8, 192.168.0.0/16, 10.0.0.0/8, 172.16.0.0/12, 255.255.255.255/32 };
        define EXCLUDES_PROXY_V6 = { fe80::/10, fc00::/7, ::1 };
        chain divert {
          type filter hook prerouting priority mangle; policy accept;
          ip daddr $EXCLUDES_PROXY_V4 accept
          ip6 daddr $EXCLUDES_PROXY_V6 accept
          iifname { lan, wg } ip protocol {tcp, udp} tproxy ip to 127.0.0.1:1234 meta mark set 7890 counter accept
          iifname { lan, wg } ip6 nexthdr {tcp, udp} tproxy ip6 to [::1]:1234 meta mark set 7890 counter accept
        }
      '';
    };
  };
  services.sing-box = {
    enable = true;
    package = pkgs.sing-box.overrideAttrs (final: prev: {
      tags = prev.tags ++ ["with_grpc" "with_v2ray_api"];
    });
    settings = {
      log = {
        level = "warn";
        timestamp = false;
      };
      route = {
        rules = [
          {
            port = [53];
            ip_cidr = ["127.0.0.1"];
            action = "hijack-dns";
          }
          {
            ip_is_private = true;
            outbound = "direct";
          }
          {
            action = "sniff";
          }
          {
            protocol = "dns";
            action = "hijack-dns";
          }
          {
            rule_set = [
              "site-direct"
              "steam-cn"
            ];
            outbound = "direct";
          }
          {
            rule_set = "site-proxy";
            outbound = "proxy";
          }
          {
            action = "resolve";
            strategy = "prefer_ipv4";
          }
          {
            ip_is_private = true;
            outbound = "direct";
          }
          {
            rule_set = "geoip-cn";
            outbound = "direct";
          }
        ];
        rule_set = [
          {
            type = "remote";
            tag = "geoip-cn";
            format = "binary";
            url = "https://raw.githubusercontent.com/Loyalsoldier/geoip/release/srs/cn.srs";
            download_detour = "proxy";
          }
          {
            tag = "site-direct";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/direct.srs";
            download_detour = "proxy";
          }
          {
            tag = "site-proxy";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/proxy.srs";
            download_detour = "proxy";
          }
          {
            tag = "steam-cn";
            type = "remote";
            format = "binary";
            url = "https://raw.githubusercontent.com/DDCHlsq/sing-ruleset/ruleset/steamcn.srs";
            download_detour = "proxy";
          }
        ];
        final = "proxy";
      };
      inbounds = [
        {
          type = "tproxy";
          tag = "tproxy-in-v4";
          listen = "127.0.0.1";
          listen_port = 1234;
        }
        {
          type = "tproxy";
          tag = "tproxy-in-v6";
          listen = "::1";
          listen_port = 1234;
        }
        {
          type = "mixed";
          tag = "proxy-in";
          listen = "0.0.0.0";
          listen_port = 7890;
        }
        {
          type = "direct";
          tag = "dns-udp-in";
          listen = "192.168.0.1";
          listen_port = 53;
          network = "udp";
          override_address = "127.0.0.1";
          override_port = 53;
        }
        {
          type = "direct";
          tag = "dns-tcp-in";
          listen = "192.168.0.1";
          listen_port = 53;
          network = "tcp";
          override_address = "127.0.0.1";
          override_port = 53;
        }
      ];
      outbounds = [
        {
          type = "direct";
          tag = "direct";
        }
        {
          type = "direct";
          tag = "proxy";
          routing_mark = 1234;
        }
      ];
      experimental = {
        cache_file = {
          enabled = true;
        };
        clash_api = {
          external_controller = "0.0.0.0:9090";
          external_ui = "${pkgs.metacubexd}";
        };
        v2ray_api = {
          listen = "127.0.0.1:9091";
          stats = {
            enabled = true;
            inbounds = lib.map (value: value.tag) config.services.sing-box.settings.inbounds;
            outbounds = lib.map (value: value.tag) config.services.sing-box.settings.outbounds;
          };
        };
      };
      dns = {
        strategy = "prefer_ipv4";
        reverse_mapping = true;
        cache_capacity = 32768;
        servers = [
          {
            tag = "proxy-dns";
            address = "https://1.1.1.1/dns-query";
            address_resolver = "resolver-dns";
            detour = "proxy";
          }
          {
            tag = "direct-dns";
            address = "https://dns.alidns.com/dns-query";
            address_resolver = "resolver-dns";
            detour = "direct";
          }
          {
            tag = "resolver-dns";
            address = "223.5.5.5";
            detour = "direct";
          }
          {
            tag = "mdns";
            address = "local";
          }
          {
            tag = "hosts";
            address = "local";
          }
        ];
        rules = [
          {
            domain = lib.flatten (builtins.attrValues config.networking.hosts);
            server = "hosts";
          }
          {
            domain_suffix = [
              ".local"
            ];
            server = "mdns";
          }
          {
            rule_set = [
              "site-proxy"
            ];
            server = "proxy-dns";
          }
          {
            rule_set = [
              "site-direct"
              "steam-cn"
            ];
            server = "direct-dns";
          }
        ];
        final = "direct-dns";
      };
    };
  };
  systemd.services.sing-box.serviceConfig.Slice = config.systemd.slices.system-network.name;
}
