# lineDUBbed

DUB package testing platform

## Controller

## Runner

Abbreviated as LDR.

### System requirements

| Resource | Minimum | Recommended |
| :-- | :-- | :-- |
| Machine | Virtual Machine | dedicated (“bare-metal”) |
| Operating System | Debian 12 | Debian 12 |
| CPU | dual-core | quad-core |
| RAM | 2 GB | 8 GB |

Runners are supposed to be treated like an appliance.
Install the runner on a newly installed machine
dedicated to running LDR.

A bare-metal installation isn’t necessary;
virtual machines are fine, but might yield less accurate test results.

Container virtualized installations (like LXC, LXD) are not supported.
As LDR uses application containers itself, such setups would be subject to the
complexity of nested containers. Assumptions and requirements of container
engines usually aren’t met in those environments (without further tweaking).

To reduce complexity and provide a more streamlined user experience,
each release of the runner supports only a single operating system.
There are no plans to add support for non-Debian systems or Debian derivatives.
(With a few patches to the installation,
you should be able to get it up and running on unsupported systems, too.)

### Setup

```sh
apt-get update && apt-get -y install curl
curl -sSLo ldr-setup.sh https://github.com/analogjupiter/linedubbed/blob/main/runner/setup.sh?raw=true
chmod +x ldr-setup.sh
./ldr-setup.sh
```
