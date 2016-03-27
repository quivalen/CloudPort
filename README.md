## CloudPort

With CloudPort you can set up anonymous and secure reverse tunnels.
Use it to expose services inside your LAN to Internet in an easy ad-hoc manner.
CloudPort is available both as a hosted solution at **[cloudport.xyz](http://cloudport.xyz)** or as an on-premise service, which you can install inside your own infrastructure. You can also play with CloudPort inside Vagrant, it is as easy as doing `vagrant up` and then reaching the service out by address `172.16.172.16`.

CloudPort uses **[p.t.u.](https://github.com/ivanilves/ptu)** as a client-side worker,
so getting familiar with **p.t.u.** is not strictly required but will help you a lot.

Install CloudPort on any server after executing these simple commands:
```
git clone https://github.com/ivanilves/CloudPort.git
cd CloudPort
./script/provision local
```
That's all! Really simple, righ? :wink:

As long as we are still on the very early stage, please be cooperative and send me your feedback!

### Thank you!
