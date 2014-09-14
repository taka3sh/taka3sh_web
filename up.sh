#!/bin/sh
. ./params.cfg

virsh -c $CONNECT pool-refresh $POOL
virsh -c $CONNECT vol-delete $NAME.qcow2 --pool $POOL
virsh -c $CONNECT destroy $NAME
virsh -c $CONNECT undefine $NAME

virsh -c qemu:///system vol-create-as $POOL $NAME.qcow2 10G \
	--allocation 0 \
	--format qcow2 \
	--backing-vol $NAME.base.qcow2 \
	--backing-vol-format qcow2

virt-install \
	--name $NAME \
	--ram 512 \
	--vcpus 1 \
	--import \
	--os-variant debianwheezy \
	--disk vol=$POOL/$NAME.qcow2 \
	--network network=$NETWORK,model=virtio,mac=$MAC \
	--hvm \
	--virt-type kvm \
	--connect $CONNECT \
	--noreboot
