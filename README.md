Sports Arbitrage Parser
=======================

This was a project I wrote many moons ago to look for the existence of arbitrage opportunities in the sports betting word.  I'm not sure of the legal status of gambling on sports where you live, but first and foremost, don't do illigal things.  This project should be viewed as a tool to learn from, not a tool to break laws.  I will say there are opportunities, at least when I ran it for long periods of time five years ago.  They don't appear to stay open very long.  I never exploited any of the opportunities.

I've periodically received requests to get this running again.  I'm going to attempt to summarize that process here.  This is old code.  I have no intention of upgrading it, although I'd be happy to offer advice if someone is interested.

Setup
-----
The easiest way to get this code running is to launch it through Virtualbox using Vagrant.  If you haven't used either of these tools, you can install Virtualbox from here: https://www.virtualbox.org/wiki/Downloads.  Vagrant can be installed from here: http://www.vagrantup.com/downloads.html.

You can launch the VM by navigating to the root of this project and running:

```bash
  vagrant up
```

This will provision an Ubuntu 14.04 server with Ruby 1.8.7 and MySQL installed as well as required gems.  MySQL is installed with a root password of 'root'.  The code for this project will be mounted in /home/vagrant/app. You can work outside the VM, using whatever editor you'd like, and run the code in the vm to test.

To log into the VM:

```bash
  vagrant ssh
```

then:
```bash
  cd app
```





