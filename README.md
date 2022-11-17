# Docker Bridge Network Hands on Practice
We will build docker bridge network from scratch using linux network namespace and the concept of bridge. So let's get our hands dirty. 🤟🤟

## Our Mission
![Mission Plan](./Bridge%20Network%20Diagram.png)
- Our mission is to create two network namespaces,two virtual ethernet cables and a bridge and connect them according to the diagram given above. Finally we will communicate between the network namespaces using ping command.
## Procedure
1. Create 2 namespaces using following command:
    ```
    sudo ip netns add red
    sudo ip netns add green
    ```
2. Now create a bridge:
    ```
    sudo ip link add br0 type bridge
    ```
3. Create 2 virtual ethernet cables:
    ```
    sudo ip link add rveth type veth peer name rbrveth
    sudo ip link add gveth type veth peer name gbrveth
    ```
4. Attach the Veth Cables to Their Respective Namespaces:
    ```
    sudo ip link set rveth netns red
    sudo ip link set gveth netns green
    ```
5. Now <b>up</b> the bridge interface:
    ```
    sudo ip link set br0 up
    ```
4. Now let's <b>up</b> the network interfaces in the namespaces above:
    ```
    sudo ip netns exec red ip link set lo up
    sudo ip netns exec red ip link set rveth up
    sudo ip netns exec green ip link set lo up
    sudo ip netns exec green ip link set gveth up
    ```
5. Assign IP Addresses to Each Namespace
    ```
    sudo ip netns exec red ip address add 10.0.1.2/24 dev rveth
    sudo ip netns exec green ip address add 10.0.1.3/24 dev gveth
    ```
8. Now we set the ip of the bridge:
    ```
    sudo ip addr add 10.0.1.1/16 dev br0
    ```
9. We can add the bridge veth interfaces to the bridge by setting the bridge device as their master:
    ```
    sudo ip link set rbrveth master br0
    sudo ip link set gbrveth master br0
    ```
10. With the bridge device set, it’s time to connect the bridge side of the veth cable to the bridge.
    ```
    sudo ip link set rbrveth up
    sudo ip link set gbrveth up
    ```
11. Now we use ping command to communicate between the two network namespaces:
    ```
    sudo ip netns exec red ping 10.0.1.3
    sudo ip netns exec green ping 10.0.1.2
    ```
12. To delete the namespaces use the following commands:
    ```
    sudo ip netns del red
    sudo ip netns del green
    ```
13. To delete bridge use following:
    ```
    sudo ip link delete br0 type bridge
    ```
14. To delete unattached veth interfaces:
    ```
    sudo ip link delete <interface_name>
    ```

## Using Dockerfile to test
1. Run the following commands to build and run the container:
    ```
    docker build -t docker_bridge_test .
    docker run --privileged docker_bridge_test:latest
    ```
2. After runing the container check the container id using:
    ```
    docker ps
    ```
3. Now get inside the container using:
    ```
    docker exec -it <container_id> bash
    ```
4. After getting inside docker container use above mentioned commands sequentially without using the <b>sudo</b> keyword

## Additional Mission:
 - Let's try to connect internet from the container.
 - We will try to ping the dns of google 8.8.8.8 from the network namespaces
 ![Mission Plan](./Bridge%20Network%20Diagram%20Extended.jpeg)

## Procedure
  1. First, we need to define default gateway from each network namespaces; because the network doesn’t know what to do with the packets it receives.
      ```
      sudo ip netns exec red ip route add default via 10.0.1.1
      sudo ip netns exec green ip route add default via 10.0.1.1
      ```
  2. We can now connect to the internet, but can’t send or receive packets. To receive packets, configure Network Address Translation (NAT) with Masquerade. Masquerading allows machines to invisibly access the Internet via the Masquerade gateway, whereas a NAT can hide private addresses from the internet.

  3. Lets add a new `iptables` rule in the POSTROUTING chain of the NAT table to receive packets
      ```
      sudo iptables -t nat -A POSTROUTING -s 10.0.1.1/16 -j MASQUERADE
      ```
  
  4. Here is a breakdown of the above flag:
      - -t marks the table commands should be directed to
      - -A specifies that we’re appending a rule to the chain
      - -s specifies the source address
      - -j is the action being performed
  
  5. Now enable packet forwarding with IPv4 ip forwarding:
      ```
      sudo sysctl -w net.ipv4.ip_forward=1
      ```

  6. Now we try to reach the internet from one of the namespaces:
      ```
      sudo ip netns exec red ping 8.8.8.8
      ```