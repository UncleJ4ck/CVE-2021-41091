# CVE-2021-41091

This exploit offers an in-depth look at the CVE-2021-41091 security vulnerability and provides a step-by-step guide on how to utilize the exploit script to achieve privilege escalation on a host.

## Vulnerability Summary

CVE-2021-41091 is a flaw in Moby (Docker Engine) that allows unprivileged Linux users to traverse and execute programs within the data directory (usually located at /var/lib/docker) due to improperly restricted permissions. This vulnerability is present when containers contain executable programs with extended permissions, such as setuid. Unprivileged Linux users can then discover and execute those programs, as well as modify files if the UID of the user on the host matches the file owner or group inside the container.

## Overlay 

The overlay filesystem is a critical component in exploiting this vulnerability. Docker's overlay filesystem enables the container's file system to be layered on top of the host's file system, thus allowing the host system to access and manipulate the files within the container. In the case of CVE-2021-41091, the overly permissive directory permissions in /var/lib/docker/overlay2 enable unprivileged users to access and execute programs within the containers, leading to a potential privilege escalation attack.
Exploitation Steps

1. Connect to the Docker container hosted on your machine and obtain root access.

2. Inside the container, set the setuid bit on /bin/bash with the following command: `chmod u+s /bin/bash`

3. On the host system, run the provided exploit script (poc.sh) by cloning the repository and executing the script as follows:

```
git clone https://github.com/UncleJ4ck/CVE-2021-41091
cd CVE-2021-41091
chmod +x ./poc.sh
./poc.sh
```

4. The script will prompt you to confirm if you correctly set the setuid bit on /bin/bash in the Docker container. If the answer is "yes," the script will check if the host is vulnerable and iterate over the available overlay2 filesystems. If the system is indeed vulnerable, the script will attempt to gain root access by spawning a shell in the vulnerable path (the filesystem of the Docker container where you executed the setuid command on /bin/bash).


<img src="https://i.imgur.com/gWUcKUX.png">

> Tested on docker engine version 20.10.5+dfsg1

# Mitigation

It is crucial to update Docker to version 20.10.9 or higher to address this vulnerability.


## TO-DO

- [ ] Add Many Cases for other privilige escalation scenarios
- [x] Fix Bugs


## Credit

> https://www.cyberark.com/resources/threat-research-blog/how-docker-made-me-more-capable-and-the-host-less-secure
