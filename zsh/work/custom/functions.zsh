gns3_add_host_tap_iface() { 
  IFNAME=tap.gns3 
  IP_ADDR=172.31.1.254/24
  echo "Creating tap interface $IFNAME"
  sudo ip tuntap add name $IFNAME mode tap
  echo "Setting IP address to $IP_ADDR"
  sudo ip addr add $IP_ADDR dev $IFNAME
  echo "Bringing interface up" 
  sudo ip link set dev $IFNAME up
}

setcap_weos_make_run() {
  echo "Set capabilities for 'qemu-system-arm'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/bin/qemu-system-arm
  echo "Set capabilities for 'qemu-system-ppc'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/bin/qemu-system-ppc
  echo "Set capabilities for 'qemu-system-x86_64'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/bin/qemu-system-x86_64
  echo "Set capabilities for 'qemu-bridge-helper'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/lib/qemu/qemu-bridge-helper
  echo "Set capabilities for 'brctl'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/sbin/brctl
  echo "Set capabilities for 'ip'"
  sudo /sbin/setcap cap_net_raw,cap_net_admin+ep /usr/bin/ip
}

# Example `fawlty_console qser1`
fawlty_console() {
  dev="qser1"

  if [ $# -lt 1 ]
  then
    echo "No device name provided. Assuming $dev"
  else
    dev=$1
  fi

  cd ~/Repos/fawlty/src/
  ../scripts/towers_container.sh exec console $dev
}

towers_console() {
  if [ $# -lt 1 ]
  then
    docker exec -it towers-ragwi bash
    return 0
  fi

  cd ~/Repos/fawlty/src/
  ../scripts/towers_container.sh exec console $1
}
 
towers_latest() {
  cd ~/Repos/fawlty/src
  UNSHARED=true ../scripts/towers_container.sh -t ../cfg/topology/dean.yml /tftpboot/WeOS-zero-9.99.x.bin
}

towers_master() {
  cd ~/Repos/fawlty/src
  UNSHARED=true ../scripts/towers_container.sh -t ../cfg/topology/dean.yml /tftpboot/WeOS-zero-master.bin
}

towers_start() {
  if [ $# -lt 1 ]
  then
    echo "Must provide a build path..."
    return 1
  fi

  cd ~/Repos/fawlty/src
  UNSHARED=true ../scripts/towers_container.sh -t ../cfg/topology/dean.yml $1
}

fawlty_start() {
  if [ $# -lt 1 ]
  then
    echo "Must provide a test..."
    return 1
  fi

  cd ~/Repos/fawlty/src/
  UNSHARED=true ../scripts/fawlty_container.sh -t ../cfg/topology/dean.yml -s "$@"
}

fawlty_debug() {
  if [ $# -lt 1 ]
  then
    echo "Must provide a test..."
    return 1
  fi

  cd ~/Repos/fawlty/src/
  UNSHARED=true ../scripts/fawlty_container.sh -t ../cfg/topology/dean.yml --debug -s "$@"
}

fawlty_suite() {
  if [ $# -lt 1 ]
  then
    echo "Must provide a suitefile..."
    return 1
  fi

  cd ~/Repos/fawlty/src/
  UNSHARED=true ../scripts/fawlty_container.sh -t ../cfg/topology/dean.yml --debug -S $1
}

towers_route_to_dut() {
  dut_ip="198.19.10.0"

  if [ $# -lt 1 ]
  then
    echo "No IP specified. Assuming DUT address is $dut_ip."
  else
    dut_ip=$1
  fi

  cmd="ip route add $dut_ip/24 via 172.18.0.2"
  echo "Running '$cmd'"
  sudo ip route add $dut_ip/24 via 172.18.0.2
}

restart_docker_radius() {
  docker stop freeradius-ver-3-0-26
  docker stop freeradius-ver-3-2-5
  docker rm freeradius-ver-3-0-26
  docker rm freeradius-ver-3-2-5
  echo "Removed radius containers"

  prev_pwd=$PWD

  echo "Starting radius containers"
  cd ~/Repos/fawlty/src/
  ../scripts/radius_side_cars.sh up --isolated
  cd ${prev_pwd}
}

