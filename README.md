# lineDUBbed

DUB package testing platform

## Controller

## Runner

### System requirements

| Resource | Minimum | Recommended |
| :-- | :-- | :-- |
| Operating System | Debian 12 | Debian 12 |
| CPU | dual-core | quad-core |
| RAM | 2 GB | 8 GB |

Runners are supposed to be treated like an appliance.
Install the runner on a newly installed machine
that runs only for this single specific purpose.

Virtual machines or containers are fine,
but will yield less accurate results.

To reduce complexity and provide a more streamlined user experience,
each release of the runner supports only a single operating system.
There are no plans to add support for non-Debian systems or Debian derivatives.

### Setup

```sh
apt-get update && apt-get -y install curl
curl -sSLo ldr-setup.sh https://github.com/analogjupiter/linedubbed/blob/stable/runner/setup.sh?raw=true
chmod +x ldr-setup.sh
./ldr-setup.sh
```
