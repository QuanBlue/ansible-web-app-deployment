<h1 align="center">
  <img src="./assets/ansible.png" alt="icon" width="200"></img>
  <br>
  <b>Ansible VPS Generator</b>
</h1>

<p align="center">Helping you auto create Ansible VPS and Ubuntu VPSs  in multi base: EC2, VW, Container.., connect them and auto generate Inventory file</p>

<!-- Badges -->
<p align="center">
  <a href="https://github.com/QuanBlue/ansible-vps-generator/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/QuanBlue/ansible-vps-generator" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/QuanBlue/ansible-vps-generator" alt="last update" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/network/members">
    <img src="https://img.shields.io/github/forks/QuanBlue/ansible-vps-generator" alt="forks" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/stargazers">
    <img src="https://img.shields.io/github/stars/QuanBlue/ansible-vps-generator" alt="stars" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">
    <img src="https://img.shields.io/github/issues/QuanBlue/ansible-vps-generator" alt="open issues" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-vps-generator/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/QuanBlue/ansible-vps-generator.svg" alt="license" />
  </a>
</p>

<p align="center">
  <b>
    <a href="https://github.com/QuanBlue/ansible-vps-generator">Documentation</a> •
    <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">Report Bug</a> •
    <a href="https://github.com/QuanBlue/ansible-vps-generator/issues/">Request Feature</a>
  </b>
</p>
<br/>
<details open>
<summary><b>Table of Contents</b></summary>

- [:toolbox: Getting Started](#toolbox-getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
- [:rocket: Usage](#rocket-usage)
- [:world_map: Roadmap](#world_map-roadmap)
- [:busts_in_silhouette: Contributors](#busts_in_silhouette-contributors)
- [FAQ](#faq)
- [:sparkles: Credits](#sparkles-credits)
- [:scroll: License](#scroll-license)
</details>

# :toolbox: Getting Started

## Prerequisites

Before proceeding with the installation and usage of this project, ensure that you have the following prerequisites in place:

- **Docker Engine:** Docker provides a consistent and portable environment for running applications in containers. Install [here](https://www.docker.com/get-started/).
- **Network Connectivity:** Docker requires network connectivity to download images, communicate with containers, and access external resources.

## Environment Variables

# :rocket: Usage

# :world_map: Roadmap

- [ ] Deploy
  - [ ] Application
  - [ ] Deploy monitoring and logging components
- [ ] Deploy Application on
  - [ ] Docker - Container
  - [ ] Vagrant - VWare
  - [ ] AWS - EC2

# :busts_in_silhouette: Contributors

<a href="https://github.com/QuanBlue/Linux-Bootstrap/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QuanBlue/Linux-Bootstrap" />
</a>

Contributions are always welcome!

# FAQ

- **Question 1:** In real life, do we deploy monitoring and logging components such as Prometheus and grafana in 1 or 2 machines?

  - Based on your specific requirements and preferences. There are multiple approaches you can consider:

    - **Separate Machines:** In this approach, you can deploy Prometheus and Grafana on separate machines. This separation allows for isolation and scalability. Prometheus collects and stores metrics on one machine, while Grafana is hosted on another machine for visualization and analysis.

    - **Combined Machine:** Alternatively, you can deploy Prometheus and Grafana on the same machine. This approach simplifies the setup and management since both tools are installed on a single instance. It can be a viable solution for smaller deployments or if resource limitations are a concern.

    ```txt
    In this Project, I using the first approach
    ```

- **Question 2:** where i should install `node_exporter`

  - `Node Exporter` is typically installed on each individual machine that you want to monitor. It should be installed on machines or servers you wish to monitor.

  - By installing `Node Exporter` on each machine, you allow `Prometheus` to collect and scrape metrics specific to that machine's performance and health for analysis and alerting.

  - This provides a more comprehensive view of your entire infrastructure and enables you to monitor the individual components that make up your application.

- **Question 3:** Summarizing the `advantages` and `disadvantages` of installing Node Exporter **on an independent machine** versus **combining it with the machines**:

|                                                  | Independent Machine                             | Combined with Backend Machines                |
| ------------------------------------------------ | ----------------------------------------------- | --------------------------------------------- |
| <span style="color:green">**Advantages**</span>  |                                                 |                                               |
| Centralized Monitoring                           | Enables centralized monitoring                  | Metrics collected directly from sources       |
| Resource Isolation                               | Separates monitoring from application servers   | Simplifies setup and maintenance              |
| Security                                         | Restricted network access to backend machines   | Direct access to backend machines for metrics |
| <span style="color:red">**Disadvantages**</span> |                                                 |                                               |
| Additional Resource                              | Requires dedicated machine for Node Exporter    | Resource utilization on backend machines      |
| Management Complexity                            | Adds complexity in managing multiple machines   | Simplifies setup and maintenance              |
| Network Overhead                                 | Requires network communication between machines | Local access for metrics collection           |

It's important to note that the decision should be based on your specific infrastructure and requirements. Assessing factors such as scale, resource availability, security considerations, and management preferences will help determine the most suitable approach for your monitoring setup.

# :sparkles: Credits

- [Docker](https://www.docker.com/)
- [Ansible](https://www.ansible.com/)
- Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

# :scroll: License

Distributed under the MIT License. See <a href="../LICENSE">`LICENSE`</a> for more information.

---

> Bento [@quanblue](https://bento.me/quanblue) &nbsp;&middot;&nbsp;
> GitHub [@QuanBlue](https://github.com/QuanBlue) &nbsp;&middot;&nbsp; Gmail quannguyenthanh558@gmail.com
