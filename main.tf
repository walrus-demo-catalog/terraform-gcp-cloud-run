locals {
  project_name     = coalesce(try(var.context["project"]["name"], null), "default")
  project_id       = coalesce(try(var.context["project"]["id"], null), "default_id")
  environment_name = coalesce(try(var.context["environment"]["name"], null), "test")
  environment_id   = coalesce(try(var.context["environment"]["id"], null), "test_id")
  resource_name    = coalesce(try(var.context["resource"]["name"], null), "example")
  resource_id      = coalesce(try(var.context["resource"]["id"], null), "example_id")

  namespace = coalesce(try(var.infrastructure.namespace, ""), join("-", [
    local.project_name, local.environment_name
  ]))
  gpu_vendor    = coalesce(try(var.infrastructure.gpu_vendor, ""), "nvdia.com")
  domain_suffix = coalesce(var.infrastructure.domain_suffix, "cluster.local")

  annotations = {
    "walrus.seal.io/project-id"     = local.project_id
    "walrus.seal.io/environment-id" = local.environment_id
    "walrus.seal.io/resource-id"    = local.resource_id
  }
  labels = {
    "walrus.seal.io/catalog-name"     = "terraform-gcp-cloud-run"
    "walrus.seal.io/project-name"     = local.project_name
    "walrus.seal.io/environment-name" = local.environment_name
    "walrus.seal.io/resource-name"    = local.resource_name
  }
}
locals {
  wellknown_port_protocols = ["TCP", "UDP"]

  internal_port_container_index_map = {
    for ip, cis in merge(flatten([
      for i, c in var.containers : [{
        for p in try(c.ports != null ? c.ports : [], []) : p.internal => i...
        if p != null
      }]
    ])...) : ip => cis[0]
  }

  containers = [
    for i, c in var.containers : merge(c, {
      name = format("%s-%d-%s", coalesce(c.profile, "run"), i, basename(split(":", c.image)[0]))
      envs = [
        for xe in [
          for e in(c.envs != null ? c.envs : []) : e
          if e != null && try(!(e.value != null && e.value_refer != null) && !(e.value == null && e.value_refer == null), false)
        ] : xe
      ]
      ports = [
        for xp in [
          for _, ps in {
            for p in(c.ports != null ? c.ports : []) : p.internal => {
              internal = p.internal
              external = p.external
              protocol = p.protocol == null ? "TCP" : upper(p.protocol)
              schema   = p.schema == null ? (contains([80, 8080], p.internal) ? "http" : (contains([443, 8443], p.internal) ? "https" : null)) : lower(p.schema)
            }...
            if p != null
          } : ps[length(ps) - 1]
          if local.internal_port_container_index_map[ps[length(ps) - 1].internal] == i
        ] : xp
        if try(contains(local.wellknown_port_protocols, xp.protocol), true)
      ]
      checks = [
        for ck in(c.checks != null ? c.checks : []) : ck
        if try(lookup(ck, ck.type, null) != null, false)
      ]
    })
    if c != null
  ]
}

locals {
  container_ephemeral_envs_map = {
    for c in local.containers : c.name => [
      for e in c.envs : e
      if try(e.value_refer == null, false)
    ]
    if c != null
  }

  container_internal_ports_map = {
    for c in local.containers : c.name => [
      for p in c.ports : merge(p, {
        name = lower(format("%s-%d", p.protocol, p.internal))
      })
      if p != null
    ]
    if c != null
  }

  run_containers = [
    for c in local.containers : c
    if c != null && try(c.profile == "" || c.profile == "run", true)
  ]
}

#
# Deployment
#

resource "google_cloud_run_v2_service" "cloudrun" {
  name     = format("%s-", local.resource_name)
  location = "us-central1"
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = var.deployment.replicas
      max_instance_count = var.deployment.replicas + 1
    }

    dynamic "containers" {
      for_each = try(nonsensitive(local.run_containers), local.run_containers)
      content {
        name  = containers.value.name
        image = containers.value.image

        dynamic "resources" {
          for_each = containers.value.resources != null ? try(
            [nonsensitive(containers.value.resources)],
            [containers.value.resources]
          ) : []
          content {
            limits = {
              for k, v in resources.value : "%{if k == "gpu"}${local.gpu_vendor}/%{endif}${k}" => "%{if k == "memory"}${v}Mi%{else}${v}%{endif}"
              if try(v != null && v > 0, false) && k != "cpu"
            }
            cpu_idle = true
          }
        }

        dynamic "env" {
          for_each = local.container_ephemeral_envs_map[containers.value.name] != null ? try(
            nonsensitive(local.container_ephemeral_envs_map[containers.value.name]),
            local.container_ephemeral_envs_map[containers.value.name]
          ) : []
          content {
            name  = env.value.name
            value = env.value.value
          }
        }

        dynamic "ports" {
          for_each = local.container_internal_ports_map[containers.value.name] != null ? try(
            nonsensitive(local.container_internal_ports_map[containers.value.name]),
            local.container_internal_ports_map[containers.value.name]
          ) : []
          content {
            container_port = ports.value.internal
          }
        }
      }
    }

    max_instance_request_concurrency = 1
  }
}