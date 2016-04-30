![](https://raw.githubusercontent.com/ivanilves/CloudPort/master/public/images/cloudport.png)

With CloudPort you can set up anonymous and secure reverse tunnels.
Use it to expose services inside your LAN to the Internet in an **easy ad-hoc manner**.
CloudPort is available both as a hosted solution at **[cloudport.xyz](http://cloudport.xyz)** or as an on-premise service, which you can install inside your own infrastructure. You can also play with CloudPort inside **Vagrant**, it is as easy as doing `vagrant up` and then reaching the service out by address `172.16.172.16`.

## What's inside?
* **[Ruby on Rails](http://rubyonrails.org/)** with **[Puma](http://puma.io/)** application server and **[Sidekiq](http://sidekiq.org/)** scheduler.
* **[p.t.u.](https://github.com/ivanilves/ptu)** as a client-side worker (for Linux, MacOSX and Windows).
* **[Netzke](http://netzke.org/)** framework to power up management interface.
* **[Ansible](https://www.ansible.com/)** for server provisioning and software deployment.
* **[Docker](https://www.docker.com/)** engine to ensure proper isolation of the processes.
* **[MariaDB](https://mariadb.org/)** as an SQL database and **[Redis](http://redis.io/)** as a NoSQL one.
* **[NginX](http://nginx.org/)** web server to do reverse proxying and serve static assets.

## Install
Install CloudPort on any **Ubuntu 14.04** (virtual) server by executing these simple commands:
```
git clone https://github.com/ivanilves/CloudPort.git
cd CloudPort
./script/provision local
```
* Change CloudPort hostname by editing `/deploy/hostname` and running `sudo restart cloudport` then.
* Access management UI by entering `/manage` URL with username `cloudport` and default password `portcloud`.

That's all! Really simple, righ? :wink:

## NB!
* CloudPort supports only **Ubuntu**, **14.04** and later versions, for now.
* CloudPort uses **[p.t.u.](https://github.com/ivanilves/ptu)** as a client-side worker,
getting familiar with **p.t.u.** is not strictly required, but may help a lot.
* Apart from setting up system on some server locally, you could also use **Ansible** to provision remote CloudPort instances, though it would require you to have a working **Ansible** setup and some basic **Ansible** skills.

## Questions and issues
As long as we are still on the very early stage, please be cooperative and send me your feedback!
You are welcome to open **[Pull Requests](https://github.com/ivanilves/CloudPort/pulls)** and **[Issues](https://github.com/ivanilves/CloudPort/issues)** on GitHub, also you could help a lot by just running **CloudPort** inside your infrastructure or actively using its cloud version at **[cloudport.xyz](http://cloudport.xyz)**.

## Thank you!
You are awesome! :+1:
