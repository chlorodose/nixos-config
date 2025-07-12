{
  config,
  lib,
  outputs,
  ...
}:
{
  sops.secrets."matrix/homeserver_key" = {
    sopsFile = outputs.lib.getSecret "services.yaml";
    mode = "0440";
    owner = "root";
    group = "matrix-synapse";
  };
  systemd.slices.system-chat.sliceConfig = {
    CPUWeight = 100;
    MemoryHigh = "32G";
    IOWeight = 100;
  };
  services.matrix-synapse = {
    enable = true;
    withJemalloc = true;
    enableRegistrationScript = false;
    extras = [
      "systemd"
      "postgres"
      "url-preview"
      "user-search"
      "cache-memory"
      "sentry"
      "jwt"
    ];
    settings = {
      signing_key_path = config.sops.secrets."matrix/homeserver_key".path;

      server_name = "matrix.chlorodose.me";
      public_baseurl = "https://matrix.chlorodose.me/";
      serve_server_wellknown = true;

      listeners = [
        {
          type = "http";
          resources = [
            {
              names = [
                "client"
                "federation"
                "keys"
                "media"
                "health"
                "static"
                # "consent"
              ];
            }
          ];
          x_forwarded = true;
          path = "/run/matrix-synapse/matrix.sock";
          mode = "0660";
        }
      ];

      database = {
        name = "psycopg2";
        allow_unsafe_locale = true; # C.UTF-8 is better!
        args = {
          host = "/run/postgresql";
          database = "matrix";
          user = "matrix-synapse";
        };
      };

      presence.enabled = true;

      allow_public_rooms_without_auth = true;
      allow_public_rooms_over_federation = true;

      federation_metrics_domains = [
        "matrix.org"
      ];
      federation_whitelist_endpoint_enabled = true;
      allow_device_name_lookup_over_federation = false;
      max_event_delay_duration = "7d";
      redaction_retention_period = null;
      forgotten_room_retention_period = "1d";
      user_ips_max_age = null;

      caches = {
        global_factor = 1;
        cache_entry_ttl = "1h";
        sync_response_cache_duration = "5m";
        cache_autotuning = {
          max_cache_memory_usage = "32G";
          target_cache_memory_usage = "8G";
          min_cache_ttl = "1m";
        };
      };

      filter_timeline_limit = 1024;
      rc_message = {
        per_second = 1024;
        burst_count = 4096;
      };
      rc_presence = {
        per_user = {
          per_second = 1024;
          burst_count = 4096;
        };
      };
      rc_joins = {
        local = {
          per_second = 1024;
          burst_count = 4096;
        };
        remote = {
          per_second = 1024;
          burst_count = 4096;
        };
      };
      rc_joins_per_room = {
        per_second = 1024;
        burst_count = 4096;
      };
      rc_invites = {
        per_room = {
          per_second = 1024;
          burst_count = 4096;
        };
        per_user = {
          per_second = 1024;
          burst_count = 4096;
        };
        per_issuer = {
          per_second = 1024;
          burst_count = 4096;
        };
      };
      rc_media_create = {
        per_second = 1024;
        burst_count = 4096;
      };
      rc_federation = {
        window_size = 2500;
        sleep_limit = 50;
        sleep_delay = 500;
        reject_limit = 250;
        concurrent = 10;
      };
      rc_delayed_event_mgmt = {
        per_second = 1024;
        burst_count = 4096;
      };
      rc_reports = {
        per_second = 1024;
        burst_count = 4096;
      };
      federation_rr_transactions_per_room_per_second = 25;

      enable_registration = false;

      refreshable_access_token_lifetime = "10m";
      refresh_token_lifetime = "30m";

      enable_metrics = true;

      user_directory = {
        enabled = true;
        search_all_users = true;
        prefer_local_users = true;
        max_search_results = 1000;
      };

      trusted_key_servers = [
        {
          server_name = "matrix.org";
        }
      ];
      suppress_key_server_warning = true;

      # user_consent = {
      #   template_dir = pkgs.writeTextFile {
      #     name = "policy-templates";
      #     text = ''

      #     '';
      #   };
      # };

      server_notices = {
        system_mxid_localpart = "server-notifications";
        system_mxid_display_name = "Server Notifications";
        room_name = "Server Notifications";
        room_topic = "Server Notifications";
        auto_join = true;
      };

      room_list_publication_rules = [
        {
          user_id = "@chlorodose:matrix.chlorodose.me";
          action = "allow";
        }
        { action = "deny"; }
      ];

      max_upload_size = "16G";
      max_image_pixels = "64M";
      dynamic_thumbnails = true;
    };
  };
  users.users.nginx.extraGroups = [ "matrix-synapse" ];
  systemd.services.matrix-synapse = {
    environment = {
      "HTTP_PROXY" = "http://127.0.0.1:7890";
      "HTTPS_PROXY" = "http://127.0.0.1:7890";
      "NO_PROXY" = "localhost";
    };
    serviceConfig = {
      Slice = config.systemd.slices.system-chat.name;
    };
  };
  system.preserve.directories = [
    config.services.matrix-synapse.dataDir
  ];
  services.nginx.upstreams.synapse = {
    servers = {
      "unix:/run/matrix-synapse/matrix.sock" = { };
    };
  };
}
