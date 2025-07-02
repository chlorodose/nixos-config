{
  config,
  outputs,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."website/key.pem" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "website/key.pem";
    mode = "0440";
    owner = "nginx";
    group = "nginx";
  };
  sops.secrets."website/api.auth" = {
    format = "binary";
    sopsFile = outputs.lib.getSecret "website/api.auth";
    mode = "0440";
    owner = "nginx";
    group = "nginx";
  };

  systemd.slices.system-web.sliceConfig = { };
  services.nginx =
    let
      configs = {
        general = ''
          sendfile on;
          tcp_nopush on;
          tcp_nodelay on;

          keepalive_timeout 60;
          keepalive_requests 10000;
          client_header_timeout 3s;
          client_body_timeout 30s;

          client_max_body_size 64M;
          client_body_buffer_size 128k;
          client_header_buffer_size 4k;

          open_file_cache max=10000 inactive=30s;
          open_file_cache_errors on;
          open_file_cache_min_uses 2;
          open_file_cache_valid 10s;
        '';
        tls = ''
          ssl_conf_command Options KTLS;

          ssl_stapling on;
          ssl_stapling_verify on;

          ssl_session_cache shared:TLS:512M;
          ssl_session_timeout 1h;
          ssl_session_tickets off;

          ssl_protocols TLSv1.3;
          ssl_ecdh_curve X25519:prime256v1:secp384r1;
          ssl_prefer_server_ciphers off;
        '';
        misc = ''
          http2 on;

          resolver 127.0.0.1;
          resolver_timeout 5s;

          server_tokens off;
        '';
        headers = ''
          add_header Strict-Transport-Security "max-age=15778800; includeSubDomains; preload" always;
          add_header X-Content-Type-Options    "nosniff" always;
          add_header Referrer-Policy           "strict-origin-when-cross-origin" always;
        '';
        proxy = ''
          proxy_http_version 1.1;

          proxy_connect_timeout 60s;
          proxy_send_timeout 600s;
          proxy_read_timeout 600s;

          proxy_cache_bypass $http_upgrade;

          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Real-IP $remote_addr;

          map $http_upgrade $connection_upgrade {
            default upgrade;
            ""      "";
          }
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $connection_upgrade;
        '';
        rewrites = ''
          server {
            listen 0.0.0.0:80;
            listen [::0]:80;
            server_name www.chlorodose.me;
            server_name internal.chlorodose.me;
            location / {
              return 301 https://$host$request_uri;
            }
          }
        '';
        real_ip = ''
          set_real_ip_from 192.168.100.1;
          real_ip_header X-Forwarded-For;
        '';
      };
      robots = ''
        User-agent: *
        Allow: /
      '';
    in
    {
      enable = true;

      additionalModules = with pkgs.nginxModules; [ ];

      httpConfig = ''
        log_format user_default '[$time_local] |$host| ($remote_user) $remote_addr -> ($request_length) "$request" -> ($bytes_sent) $status | with "$http_user_agent" from "$http_referer" as $http_cf_ray';
        access_log /var/log/nginx/access.log user_default buffer=512k flush=30s;

        server {
          listen 0.0.0.0:443 ssl;
        	listen [::0]:443 ssl;

          ssl_certificate_key ${config.sops.secrets."website/key.pem".path};
          ssl_certificate ${./server-cert-cloudflare.pem};

          server_name www.chlorodose.me;

          location = /robots.txt {
            alias ${pkgs.writeText "robots-txt" robots};
          }
        }

        server {
          listen 0.0.0.0:443 ssl;
        	listen [::0]:443 ssl;

          ssl_certificate_key ${config.sops.secrets."website/key.pem".path};
          ssl_certificate ${./server-cert.pem};

          server_name internal.chlorodose.me;
          
          if ($realip_remote_addr = "192.168.100.1") {
            return 403;
          }

          location /prometheus {
            proxy_pass http://prometheus;
          }
          location /grafana {
            proxy_pass http://grafana;
          }
        }

        server {
          listen 0.0.0.0:80;

          server_name 127.0.0.1;

          location = /nginx_status {
            stub_status on;
          }
        }

        ${builtins.toString (
          lib.flip lib.mapAttrsToList config.services.nginx.upstreams (
            name: upstream: ''
              upstream ${name} {
                ${builtins.toString (
                  lib.flip lib.mapAttrsToList upstream.servers (
                    name: server: ''
                      server ${name} ${
                lib.concatStringsSep " " (
                  lib.mapAttrsToList (
                    key: value:
                    if builtins.isBool value then lib.optionalString value key else "${key}=${toString value}"
                  ) server
                )
                      };
                    ''
                  )
                )}
                ${upstream.extraConfig}
              }
            ''
          )
        )}

        ${lib.concatStringsSep "\n" (
          lib.mapAttrsToList (_: value: "include ${value};") (lib.mapAttrs pkgs.writeText configs)
        )}
      '';

      appendConfig = ''
        worker_processes auto;
        worker_rlimit_nofile 65535;
      '';

      eventsConfig = ''
        worker_connections 4096;
        multi_accept on;
      '';
    };
  networking.hosts."192.168.0.1" = ["internal.chlorodose.me"];
  systemd.services = lib.listToAttrs (
    lib.map
      (value: {
        name = value;
        value = {
          serviceConfig.Slice = config.systemd.slices.system-web.name;
        };
      })
      [
        "nginx"
      ]
  );
}
