#!/bin/bash -x
. ./params.cfg

virsh -c $CONNECT destroy $NAME.base
virsh -c $CONNECT undefine $NAME.base
virsh -c $CONNECT vol-delete $NAME.base.img --pool default

virt-install \
	--name $NAME.base \
	--ram 2048 \
	--vcpus 2 \
	--location $LOCATION \
	--extra-args "console=ttyS0 priority=critical" \
	--initrd-inject preseed.cfg \
	--os-variant debianwheezy \
	--disk size=10,bus=virtio,format=raw \
	--network network=$NETWORK,model=virtio \
	--hvm \
	--virt-type kvm \
	--connect $CONNECT \
	--noreboot

baseimg=`virsh -c $CONNECT vol-path $NAME.base.img --pool $POOL`
destimg=${baseimg%.img}.qcow2
virt-sparsify --compress --convert qcow2 --tmp /data/tmp $baseimg $destimg
chown root:root $destimg
chmod 400 $destimg
virsh -c $CONNECT vol-delete $NAME.base.img --pool default
virsh -c $CONNECT pool-refresh default
