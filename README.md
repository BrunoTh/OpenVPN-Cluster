# OpenVPN-Cluster with Docker

## Intro
This Docker image is based on [Kyle Manna's openvpn image](https://github.com/kylemanna/docker-openvpn). 

## What it does
The idea was to create an openvpn server cluster without any load balancer. All servers are stated in the client configuration.
If one server goes down the client tries to connect to the next server in the list. All clients can 'see' each other no matter
to which they're connected. This is done by advertising the client's ip address to the cluster network (via broadcast). 
The entries for the routing table are added dynamically in each container.

## Requirements
* All containers have to be in the same subnet.
* The server configuration and pki stuff must be shared between the containers.

## How to
* Initialize the openvpn server (read [Kyle's guide](https://github.com/kylemanna/docker-openvpn/blob/master/README.md))
* Edit the openvpn server config:
  ```
  topology subnet
  script-security 2
  learn-address /app/learn-address.sh
  ```
  If you want to use the `ovpn_genconfig` script, modify `OVPN_EXTRA_SERVER_CONFIG` in `/etc/openvpn/ovpn_env.sh`:
  ```
  declare -x OVPN_EXTRA_SERVER_CONFIG=([0]="script-security 2" [1]="topology subnet" [2]="learn-address /app/learn-address.sh"
  ```
* Generate keys for clients and assign a static ip to them by adding a file for each client to `/etc/openvpn/ccd/`. The
  filename has to be identical to the client name used for the key generation.
  ```
  ifconfig-push <static ip> <subnet>
  ```
  The ip range and subnet are set in the server config.

## Test setup
For testing purpose I started three containers usign the docker-compose.yml where every container has the same volume 
mounted to `/etc/openvpn/`. So I had three identical servers. The containers are connected to the compose network via interface
eth0.

## TODO
* Figure out how to dynamically write the list of servers into the client config.
* Dynamic client ip address assigment.
