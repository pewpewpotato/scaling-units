# How to package and publish an OpenTofu module to an OCI-compliant registry

This guide shows how to turn a local OpenTofu module into an OCI artifact and publish it to an OCI-compliant registry using ORAS, then consume it via the `oci://` module source. Steps are based on the official OpenTofu documentation.

References:
- OCI Registry integrations: https://opentofu.org/docs/cli/oci_registries/
- Module packages in OCI registries: https://opentofu.org/docs/cli/oci_registries/module-package/
- OCI registry credentials: https://opentofu.org/docs/cli/oci_registries/credentials/
- Module source addresses (OCI): https://opentofu.org/docs/language/modules/sources/#oci-distribution-repository

## Prerequisites
- OpenTofu v1.10+ installed.
- ORAS CLI installed (macOS):
  - Homebrew: `brew install oras`
- An OCI-compliant registry that implements OCI Distribution v1.1.0 (for example, many modern registries do; check your vendor’s docs).
- Credentials to push to your target registry. You can authenticate with one of:
  - `oras login <registry>`
  - `docker login <registry>` (OpenTofu can read Docker auth files)
  - Explicit OpenTofu CLI config (`oci_credentials` blocks) when needed

Note on credentials discovery (macOS): OpenTofu will look in locations like `$HOME/.docker/config.json` and `$HOME/.config/containers/auth.json`, and can also use explicit `oci_credentials` blocks in the OpenTofu CLI config.

## 1) Prepare your module directory
Place your module’s `.tf`/`.tofu` files in a clean folder. Optional submodules can live under subdirectories (e.g., `modules/vpc`).

Recommended contents (minimum):
- `main.tf`
- `variables.tf` (optional)
- `outputs.tf` (optional)
- `README.md` (recommended)

## 2) Create a ZIP archive for the module
From inside your module’s root directory, create a single zip file that represents the module package. The root of the archive becomes the module’s root.

Example (macOS/zsh):
- Basic, as per OpenTofu docs:
  - `zip -r ../module-package.zip .`
- Optional (exclude common VCS noise):
  - `zip -r ../module-package.zip . -x "*.git*" -x "*/.terraform/*" -x "../module-package.zip"`

Keep the archive one directory up to avoid zipping the zip into itself if you re-run.

## 3) Log in to your registry
Authenticate so you can push. Either works:
- `oras login <registry>`
- or `docker login <registry>`

OpenTofu will also discover credentials in Docker/containers auth files; see the credentials docs if you need explicit config (for example, `~/.tofurc` with `oci_credentials`).

## 4) Push the module as an OCI artifact with ORAS
Push the zip to your repository with the exact artifact type and layer media type expected by OpenTofu.

- Required artifactType: `application/vnd.opentofu.modulepkg`
- Required layer mediaType: `archive/zip`

Example push:
- `oras push \
    --artifact-type application/vnd.opentofu.modulepkg \
    <registry>/<repo>:<tag> \
    ../module-package.zip:archive/zip`

Notes:
- `<registry>/<repo>` is your target repo path (e.g., `ghcr.io/my-org/tofu-modules/network` or `example.com/repository-name`).
- `<tag>` can be a semantic version (e.g., `1.0.0`) or any valid tag; OpenTofu defaults to `latest` when no tag is requested during install.
- Use immutable digests when you need strict pinning (see Step 6 and 7).

## 5) Consume the module using the `oci://` source
In a configuration that uses your module:

- Use a tag (default is `latest`):
  - `source = "oci://<registry>/<repo>?tag=1.0.0"`
  - If you used `latest` when publishing, `source = "oci://<registry>/<repo>"` suffices.
- Use a digest (immutable):
  - `source = "oci://<registry>/<repo>?digest=sha256:<manifest-digest>"`
- Target a submodule within the package using double-slash:
  - `source = "oci://<registry>/<repo>//modules/vpc?tag=1.0.0"`

Minimal example:

```hcl
module "network" {
  source = "oci://example.com/my-team/network?tag=1.0.0"
}
```

Then run `tofu init` to fetch the module.

## 6) Versioning and tagging guidelines
- Prefer semantic version tags (e.g., `1.2.3`); OpenTofu doesn’t impose a scheme beyond OCI tag rules, but SemVer makes upgrades predictable.
- Use `latest` for a moving pointer if desired; use digests for immutable pins in production.
- When publishing a new version, push a new tag (e.g., `1.1.0`) and optionally update `latest`.

## 7) Verifying your artifact
- With OpenTofu: reference it and run `tofu init`. If download succeeds, your artifact structure is valid.
- With ORAS:
  - List tags: `oras repo tags <registry>/<repo>`
  - Fetch manifest: `oras manifest fetch <registry>/<repo>:<tag>` (verify `artifactType` is `application/vnd.opentofu.modulepkg` and the single layer has `mediaType` `archive/zip`).

## 8) Credential configuration options (quick reference)
OpenTofu looks for OCI credentials in several places and can be configured explicitly:
- Ambient (Docker/containers auth files): e.g., `$HOME/.docker/config.json`, `$HOME/.config/containers/auth.json`.
- CLI config (explicit): add to your OpenTofu CLI config file:

```hcl
oci_credentials "example.com" {
  username = "<user>"
  password = "<pass>"
}

# Or, use a Docker credential helper globally
oci_default_credentials {
  docker_credentials_helper = "osxkeychain"
}
```

Protect any files that contain secrets. See full credentials documentation for all options and precedence rules.

## 9) Troubleshooting
- 401/403 when pushing: verify you are logged in and your token has push/package permissions for your registry; try `oras login`.
- OpenTofu fails to install: check that your artifact’s manifest `artifactType` is exactly `application/vnd.opentofu.modulepkg` and that there’s exactly one layer with media type `archive/zip`.
- Tag not found: ensure you pushed the expected `<tag>`; when omitting `tag=...`, OpenTofu tries `latest`.
- Registry rejects manifest: ensure your registry supports OCI Distribution v1.1.0 and allows non-container-image artifacts.
- Subdirectory module not found: verify your package actually includes the `modules/<name>` path and use the `//modules/<name>` suffix in the source string.

## Example end-to-end (copy/paste friendly)
Assume you’re in the module directory and want to publish to `example.com/tofu/network` with tag `1.0.0`:

- `zip -r ../module-package.zip .`
- `oras login example.com`
- `oras push \
    --artifact-type application/vnd.opentofu.modulepkg \
    example.com/tofu/network:1.0.0 \
    ../module-package.zip:archive/zip`
- In a consuming config:

```hcl
module "network" {
  source = "oci://example.com/tofu/network?tag=1.0.0"
}
```

Run `tofu init` in the consumer to verify retrieval.

---

If you need to mirror providers in OCI registries (separate from modules), refer to: https://opentofu.org/docs/cli/oci_registries/provider-mirror/
