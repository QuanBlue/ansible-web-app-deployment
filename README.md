<h1 align="center">
  <img src="./assets/ansible.png" alt="icon" width="200"></img>
  <br>
  <b>Ansible Web application Deployment</b>
</h1>

<p align="center">Auto deploy web application with Ansible in multi base: EC2, VMachine, Container,..</p>

<!-- Badges -->
<p align="center">
  <a href="https://github.com/QuanBlue/ansible-web-app-deployment/graphs/contributors">
    <img src="https://img.shields.io/github/contributors/QuanBlue/ansible-web-app-deployment" alt="contributors" />
  </a>
  <a href="">
    <img src="https://img.shields.io/github/last-commit/QuanBlue/ansible-web-app-deployment" alt="last update" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-web-app-deployment/network/members">
    <img src="https://img.shields.io/github/forks/QuanBlue/ansible-web-app-deployment" alt="forks" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-web-app-deployment/stargazers">
    <img src="https://img.shields.io/github/stars/QuanBlue/ansible-web-app-deployment" alt="stars" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-web-app-deployment/issues/">
    <img src="https://img.shields.io/github/issues/QuanBlue/ansible-web-app-deployment" alt="open issues" />
  </a>
  <a href="https://github.com/QuanBlue/ansible-web-app-deployment/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/QuanBlue/ansible-web-app-deployment.svg" alt="license" />
  </a>
</p>

<p align="center">
  <b>
    <a href="https://github.com/QuanBlue/ansible-web-app-deployment">Documentation</a> •
    <a href="https://github.com/QuanBlue/ansible-web-app-deployment/issues/">Report Bug</a> •
    <a href="https://github.com/QuanBlue/ansible-web-app-deployment/issues/">Request Feature</a>
  </b>
</p>
<br/>
<details open>
<summary><b>Table of Contents</b></summary>

- [Getting Started](#toolbox-getting-started)
  - [Prerequisites](#prerequisites)
  - [Environment Variables](#environment-variables)
- [Usage](#rocket-usage)
- [Roadmap](#world_map-roadmap)
- [Contributors](#busts_in_silhouette-contributors)
- [FAQ](#white_question_mark-faq)
- [Credits](#sparkles-credits)
- [License](#scroll-license)
</details>

# :toolbox: Getting Started

## Prerequisites

Before proceeding with the installation and usage of this project, ensure that you have the following prerequisites in place:

- **Network Connectivity:** Docker requires network connectivity to download images, communicate with containers, and access external resources.
- Each machine base have its own require
  - **Container base:**
    - _Docker Engine_, Install [here](https://www.docker.com/get-started/).
  - **Virtual machine base:**
    - _Virtualbox version:_ `>= 7.0.6`, Install [here](https://www.virtualbox.org/wiki/Downloads).
    - _Vagrant version:_ `>= 2.3.7`, Install [here](https://www.vagrantup.com/downloads).
    - _Vagrant plugin:_
      - vagrant-scp:
        ```
        vagrant plugin install vagrant-scp`
        ```

## Environment Variables

# :rocket: Usage

To deploy this project, with each base, follow these steps:

**Container base:**

```sh
bash ./container_deploy.sh
```

**Virtual machine base:**

```sh
bash ./vmachine_deploy.sh
```

# :world_map: Roadmap

- [x] Deploy
  - [x] Application
  - [x] Deploy monitoring and logging components
- [ ] Deploy Application on
  - [x] Docker - Container
  - [x] Vagrant - VMachine
  - [ ] AWS - EC2

# :busts_in_silhouette: Contributors

<a href="https://github.com/QuanBlue/Linux-Bootstrap/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=QuanBlue/Linux-Bootstrap" />
</a>

Contributions are always welcome!

# :white_question_mark: FAQ

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
- [Vagrant](https://www.vagrantup.com/)
- [Virtualbox](https://www.virtualbox.org/)
- [Ansible](https://www.ansible.com/)
- Emojis are taken from [here](https://github.com/arvida/emoji-cheat-sheet.com)

# :scroll: License

Distributed under the MIT License. See <a href="../LICENSE">`LICENSE`</a> for more information.

---

> Bento [@quanblue](https://bento.me/quanblue) &nbsp;&middot;&nbsp;
> GitHub [@QuanBlue](https://github.com/QuanBlue) &nbsp;&middot;&nbsp; Gmail quannguyenthanh558@gmail.com
