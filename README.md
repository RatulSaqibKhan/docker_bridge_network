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
2. Create 2 virtual ethernet cables:
    ```
    sudo ip link add rveth type veth peer name rbrveth
    sudo ip link add gveth type veth peer name gbrveth
    ```
3. Attach the Veth Cables to Their Respective Namespaces:
    ```
    sudo ip link set rveth netns red
    sudo ip link set gveth netns green
    ```
4. Assign IP Addresses to Each Namespace
    ```
    sudo ip netns exec red ip address add 192.168.0.2/32 dev rveth
    sudo ip netns exec green ip address add 192.168.0.3/32 dev gveth
    ```
5. Now let's <b>up</b> the network interfaces in the namespaces above:
    ```
    sudo ip netns exec red ip link set lo up
    sudo ip netns exec red ip link set rveth up
    sudo ip netns exec green ip link set lo up
    sudo ip netns exec green ip link set gveth up
    ```
6. Now we need to add the default gateway for each of the end of the veth; that is we need to add the ip to the route table of each namespaces:
    ```
    sudo ip netns exec red ip route add default via 192.168.0.2 dev rveth
    sudo ip netns exec green ip route add default via 192.168.0.3 dev gveth
    ```
7. Now create a bridge:
    ```
    sudo ip link add br0 type bridge
    ```
8. Now <b>up</b> the bridge interface:
    ```
    sudo ip link set br0 up
    ```
9. Now we set the ip of the bridge:
    ```
    sudo ip addr add 192.168.0.1/16 dev br0
    ```
10. With the bridge device set, it’s time to connect the bridge side of the veth cable to the bridge.
    ```
    sudo ip link set rbrveth up
    sudo ip link set gbrveth up
    ```

11. We can add the bridge veth interfaces to the bridge by setting the bridge device as their master:
    ```
    sudo ip link set rbrveth master br0
    sudo ip link set gbrveth master br0
    ```
11. Now we use ping command to communicate between the two network namespaces:
    ```
    sudo ip netns exec red ping 192.168.0.3
    sudo ip netns exec green ping 192.168.0.2
    ```