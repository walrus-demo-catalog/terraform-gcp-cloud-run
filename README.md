<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.51.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.51.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_v2_service.cloudrun](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_v2_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_containers"></a> [containers](#input\_containers) | Specify the container items to deploy.<br><br>Examples:<pre>containers:<br>- profile: init/run<br>  image: string<br>  execute:<br>    working_dir: string, optional<br>    command: list(string), optional<br>    args: list(string), optional<br>    readonly_rootfs: bool, optional<br>    as_user: number, optional<br>    as_group: number, optional<br>    privileged: bool, optional<br>  resources:<br>    cpu: number, optional               # in oneCPU, i.e. 0.25, 0.5, 1, 2, 4<br>    memory: number, optional            # in megabyte<br>    gpu: number, optional               # in oneGPU, i.e. 1, 2, 4<br>  envs:<br>  - name: string<br>    value: string, optional<br>    value_refer:<br>      schema: string<br>      params: map(any)<br>  files:<br>  - path: string<br>    mode: string, optional<br>    accept_changed: bool, optional      # accpet changed<br>    content: string, optional<br>    content_refer:<br>      schema: string<br>      params: map(any)<br>  mounts:<br>  - path: string<br>    readonly: bool, optional<br>    subpath: string, optional<br>    volume: string, optional            # shared between containers if named, otherwise exclusively by this container<br>    volume_refer:<br>      schema: string<br>      params: map(any)<br>  ports:<br>  - internal: number<br>    external: number, optional<br>    protocol: tcp/udp<br>    schema: string, optional<br>  checks:<br>  - type: execute/tcp/http/https<br>    delay: number, optional<br>    interval: number, optional<br>    timeout: number, optional<br>    retries: number, optional<br>    teardown: bool, optional<br>    execute:<br>      command: list(string)<br>    tcp:<br>      port: number<br>    http:<br>      port: number<br>      headers: map(string), optional<br>      path: string, optional<br>    https:<br>      port: number<br>      headers: map(string), optional<br>      path: string, optional</pre> | <pre>list(object({<br>    profile = optional(string, "run")<br>    image   = string<br>    execute = optional(object({<br>      working_dir     = optional(string)<br>      command         = optional(list(string))<br>      args            = optional(list(string))<br>      readonly_rootfs = optional(bool, false)<br>      as_user         = optional(number)<br>      as_group        = optional(number)<br>      privileged      = optional(bool, false)<br>    }))<br>    resources = optional(object({<br>      cpu    = optional(number, 0.25)<br>      memory = optional(number, 256)<br>      gpu    = optional(number, 0)<br>    }))<br>    envs = optional(list(object({<br>      name  = string<br>      value = optional(string)<br>      value_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    files = optional(list(object({<br>      path           = string<br>      mode           = optional(string, "0644")<br>      accept_changed = optional(bool, false)<br>      content        = optional(string)<br>      content_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    mounts = optional(list(object({<br>      path     = string<br>      readonly = optional(bool, false)<br>      subpath  = optional(string)<br>      volume   = optional(string)<br>      volume_refer = optional(object({<br>        schema = string<br>        params = map(any)<br>      }))<br>    })))<br>    ports = optional(list(object({<br>      internal = number<br>      external = optional(number)<br>      protocol = optional(string, "tcp")<br>      schema   = optional(string)<br>    })))<br>    checks = optional(list(object({<br>      type     = string<br>      delay    = optional(number, 0)<br>      interval = optional(number, 10)<br>      timeout  = optional(number, 1)<br>      retries  = optional(number, 1)<br>      teardown = optional(bool, false)<br>      execute = optional(object({<br>        command = list(string)<br>      }))<br>      tcp = optional(object({<br>        port = number<br>      }))<br>      http = optional(object({<br>        port    = number<br>        headers = optional(map(string))<br>        path    = optional(string, "/")<br>      }))<br>      https = optional(object({<br>        port    = number<br>        headers = optional(map(string))<br>        path    = optional(string, "/")<br>      }))<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Receive contextual information. When Walrus deploys, Walrus will inject specific contextual information into this field.<br><br>Examples:<pre>context:<br>  project:<br>    name: string<br>    id: string<br>  environment:<br>    name: string<br>    id: string<br>  resource:<br>    name: string<br>    id: string</pre> | `map(any)` | `{}` | no |
| <a name="input_deployment"></a> [deployment](#input\_deployment) | Specify the deployment action, like scaling, scheduling, security and so on.<br><br>Examples:<pre>deployment:<br>  timeout: number, optional<br>  replicas: number, optional<br>  rolling: <br>    max_surge: number, optional          # in fraction, i.e. 0.25, 0.5, 1<br>    max_unavailable: number, optional    # in fraction, i.e. 0.25, 0.5, 1<br>  fs_group: number, optional<br>  sysctls:<br>  - name: string<br>    value: string</pre> | <pre>object({<br>    timeout  = optional(number, 300)<br>    replicas = optional(number, 1)<br>    rolling = optional(object({<br>      max_surge       = optional(number, 0.25)<br>      max_unavailable = optional(number, 0.25)<br>    }))<br>    fs_group = optional(number)<br>    sysctls = optional(list(object({<br>      name  = string<br>      value = string<br>    })))<br>  })</pre> | <pre>{<br>  "replicas": 1,<br>  "rolling": {<br>    "max_surge": 0.25,<br>    "max_unavailable": 0.25<br>  },<br>  "timeout": 300<br>}</pre> | no |
| <a name="input_infrastructure"></a> [infrastructure](#input\_infrastructure) | Specify the infrastructure information for deploying.<br><br>Examples:<pre>infrastructure:<br>  namespace: string, optional<br>  gpu_vendor: string, optional<br>  domain_suffix: string, optional<br>  service_type: string, optional</pre> | <pre>object({<br>    namespace     = optional(string)<br>    gpu_vendor    = optional(string, "nvidia.com")<br>    domain_suffix = optional(string, "cluster.local")<br>    service_type  = optional(string, "NodePort")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection"></a> [connection](#output\_connection) | The connection, the main URI in which this Service is serving traffic. |
| <a name="output_context"></a> [context](#output\_context) | The input context, a map, which is used for orchestration. |
<!-- END_TF_DOCS -->