# CDN cache policy (REQ-DIST-005). gsctl publish stores each object's
# Cache-Control (distribution.CacheControl: packages immutable 1 y, timestamp
# 300 s, other metadata 3600 s); the edge and clients respect it, so the
# policy has one source. Query strings never split the cache.
resource "cloudflare_ruleset" "cdn_cache" {
  zone_id     = var.cloudflare_zone_id
  name        = "dm-dist cache policy"
  description = "DESIGN.md §9.1 cache policy for ${var.cdn_hostname}"
  kind        = "zone"
  phase       = "http_request_cache_settings"

  rules = [
    {
      description = "Cache the distribution plane with the stored Cache-Control"
      expression  = "(http.host eq \"${var.cdn_hostname}\")"
      action      = "set_cache_settings"
      enabled     = true
      action_parameters = {
        cache = true
        edge_ttl = {
          mode = "respect_origin"
        }
        browser_ttl = {
          mode = "respect_origin"
        }
        cache_key = {
          custom_key = {
            query_string = {
              exclude = {
                all = true
              }
            }
          }
        }
      }
    }
  ]
}

# Only GET and HEAD reach the bucket host (it is read-only, §9.1).
resource "cloudflare_ruleset" "cdn_methods" {
  zone_id     = var.cloudflare_zone_id
  name        = "dm-dist read-only"
  description = "Block every method but GET and HEAD on ${var.cdn_hostname}"
  kind        = "zone"
  phase       = "http_request_firewall_custom"

  rules = [
    {
      description = "Read-only distribution host"
      expression  = "(http.host eq \"${var.cdn_hostname}\" and not http.request.method in {\"GET\" \"HEAD\"})"
      action      = "block"
      enabled     = true
    }
  ]
}

# Logs (REQ-DIST-006, ADR-017): no Logpush job is defined, so no request log
# with client IPs is exported or kept by this project; see §15 D85.
