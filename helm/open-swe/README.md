# Open SWE Helm Chart

This Helm chart deploys the Open SWE application stack, which consists of a LangGraph agent and a Next.js web interface.

## Overview

Open SWE is a monorepo containing two main applications:
- **LangGraph Agent** (`open-swe`): Node.js 20 application running on port 2024 with webhook endpoints
- **Web Interface** (`web`): Next.js 15 application running on port 3000 that proxies requests to the agent

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- Container registry access for pulling images

## Installation

### Quick Start

```bash
# Install with default values
helm install open-swe ./helm/open-swe

# Install with custom values file
helm install open-swe ./helm/open-swe -f my-values.yaml

# Install in a specific namespace
helm install open-swe ./helm/open-swe --namespace open-swe --create-namespace
```

### Required Configuration

Before installing, you **must** configure the following required secrets:

```yaml
secrets:
  # Required: Encryption key for secure data storage
  secretsEncryptionKey: "your-32-character-encryption-key"
  
  # Required: At least one LLM provider API key
  anthropicApiKey: "your-anthropic-api-key"
  # OR
  openaiApiKey: "your-openai-api-key"
  
  # Required for GitHub integration
  githubAppId: "your-github-app-id"
  githubAppPrivateKey: "your-github-app-private-key"
  githubWebhookSecret: "your-webhook-secret"
```

### Example Installation with Required Values

Create a `values.yaml` file:

```yaml
# Required secrets
secrets:
  secretsEncryptionKey: "abcdef1234567890abcdef1234567890"
  anthropicApiKey: "sk-ant-api03-..."
  githubAppId: "123456"
  githubAppPrivateKey: |
    -----BEGIN RSA PRIVATE KEY-----
    ...your private key...
    -----END RSA PRIVATE KEY-----
  githubWebhookSecret: "your-webhook-secret"

# Optional: Custom image configuration
openSwe:
  image:
    repository: "your-registry/open-swe-agent"
    tag: "latest"

web:
  image:
    repository: "your-registry/open-swe-web"
    tag: "latest"

# Optional: Enable ingress
ingress:
  enabled: true
  hosts:
    - host: open-swe.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
          service: web
        - path: /api
          pathType: Prefix
          service: openSwe
        - path: /webhooks
          pathType: Prefix
          service: openSwe
```

Then install:

```bash
helm install open-swe ./helm/open-swe -f values.yaml
```

## Configuration

### Global Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `""` |
| `nameOverride` | Override the chart name | `""` |
| `fullnameOverride` | Override the full resource names | `""` |

### Open SWE Agent Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `openSwe.enabled` | Enable the LangGraph agent deployment | `true` |
| `openSwe.image.repository` | Agent image repository | `open-swe/agent` |
| `openSwe.image.tag` | Agent image tag | `""` (uses appVersion) |
| `openSwe.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `openSwe.replicaCount` | Number of agent replicas | `1` |
| `openSwe.service.type` | Service type | `ClusterIP` |
| `openSwe.service.port` | Service port | `2024` |
| `openSwe.resources.limits.cpu` | CPU limit | `2` |
| `openSwe.resources.limits.memory` | Memory limit | `4Gi` |
| `openSwe.resources.requests.cpu` | CPU request | `500m` |
| `openSwe.resources.requests.memory` | Memory request | `1Gi` |

### Web Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `web.enabled` | Enable the web application deployment | `true` |
| `web.image.repository` | Web image repository | `open-swe/web` |
| `web.image.tag` | Web image tag | `""` (uses appVersion) |
| `web.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `web.replicaCount` | Number of web replicas | `1` |
| `web.service.type` | Service type | `ClusterIP` |
| `web.service.port` | Service port | `3000` |
| `web.resources.limits.cpu` | CPU limit | `1` |
| `web.resources.limits.memory` | Memory limit | `2Gi` |
| `web.resources.requests.cpu` | CPU request | `250m` |
| `web.resources.requests.memory` | Memory request | `512Mi` |

### Configuration Values (ConfigMap)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.langgraphApiUrl` | LangGraph API URL | `http://open-swe-agent:2024` |
| `config.nextPublicApiUrl` | Public API URL for web app | `http://localhost:2024` |
| `config.openSweAppUrl` | Open SWE application URL | `http://localhost:3000` |
| `config.port` | Agent application port | `"2024"` |
| `config.skipCiUntilLastCommit` | Skip CI until last commit | `"true"` |
| `config.langchainProject` | LangSmith project name | `""` |
| `config.langchainTracingV2` | Enable LangSmith tracing | `""` |
| `config.langchainTestTracking` | Enable LangSmith test tracking | `""` |
| `config.githubAppName` | GitHub App name | `""` |
| `config.githubAppRedirectUri` | GitHub App redirect URI | `""` |

### Secrets Configuration

| Parameter | Description | Required |
|-----------|-------------|----------|
| `secrets.secretsEncryptionKey` | 32-character encryption key | **Yes** |
| `secrets.anthropicApiKey` | Anthropic API key | **Yes*** |
| `secrets.openaiApiKey` | OpenAI API key | **Yes*** |
| `secrets.googleApiKey` | Google API key | No |
| `secrets.langchainApiKey` | LangSmith API key | No |
| `secrets.daytonaApiKey` | Daytona API key | No |
| `secrets.firecrawlApiKey` | Firecrawl API key | No |
| `secrets.githubAppId` | GitHub App ID | **Yes** |
| `secrets.githubAppPrivateKey` | GitHub App private key | **Yes** |
| `secrets.githubAppClientSecret` | GitHub App client secret | No |
| `secrets.githubWebhookSecret` | GitHub webhook secret | **Yes** |

*At least one LLM provider API key (Anthropic or OpenAI) is required.

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

#### Example Ingress Configuration

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: open-swe.example.com
      paths:
        - path: /
          pathType: Prefix
          service: web
        - path: /api
          pathType: Prefix
          service: openSwe
        - path: /webhooks
          pathType: Prefix
          service: openSwe
  tls:
    - secretName: open-swe-tls
      hosts:
        - open-swe.example.com
```

## Health Checks

Both applications include health check endpoints:
- **Agent**: `GET /health` on port 2024
- **Web**: `GET /` on port 3000

## Security

### Security Contexts

Both applications run with non-root security contexts:
- **Agent**: Runs as user `agent` (UID 1001)
- **Web**: Runs as user `nextjs` (UID 1001)

### Secrets Management

All sensitive data is stored in Kubernetes Secrets with base64 encoding. Never commit secrets to version control.

## Troubleshooting

### Common Issues

1. **Pod fails to start with "missing required secrets"**
   - Ensure all required secrets are configured in your values.yaml
   - Verify the secrets are properly base64 encoded

2. **Agent cannot connect to external APIs**
   - Check that API keys are correctly configured
   - Verify network policies allow outbound connections

3. **Web app cannot reach agent**
   - Verify the `config.langgraphApiUrl` points to the correct service
   - Check that both services are in the same namespace

### Debugging Commands

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=open-swe

# View pod logs
kubectl logs -l app.kubernetes.io/name=open-swe -c agent
kubectl logs -l app.kubernetes.io/name=open-swe -c web

# Check service endpoints
kubectl get endpoints

# Describe ingress
kubectl describe ingress open-swe
```

## Upgrading

```bash
# Upgrade to a new version
helm upgrade open-swe ./helm/open-swe -f values.yaml

# Rollback to previous version
helm rollback open-swe 1
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall open-swe

# Remove persistent data (if any)
kubectl delete pvc -l app.kubernetes.io/name=open-swe
```

## Development

### Building Custom Images

```bash
# Build agent image
docker build -t your-registry/open-swe-agent:latest ./apps/open-swe

# Build web image
docker build -t your-registry/open-swe-web:latest ./apps/web

# Push images
docker push your-registry/open-swe-agent:latest
docker push your-registry/open-swe-web:latest
```

### Local Development with Helm

```bash
# Install with local images
helm install open-swe ./helm/open-swe \
  --set openSwe.image.repository=your-registry/open-swe-agent \
  --set openSwe.image.tag=latest \
  --set web.image.repository=your-registry/open-swe-web \
  --set web.image.tag=latest \
  -f values.yaml
```

## Support

For issues and questions:
- Check the [troubleshooting section](#troubleshooting)
- Review pod logs for error messages
- Ensure all required configuration values are set
- Verify network connectivity between components

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.
