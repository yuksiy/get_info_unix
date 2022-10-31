#!/bin/sh

# ==============================================================================
#   機能
#     システム設定一覧を取得する
#   構文
#     USAGE 参照
#
#   Copyright (c) 2007-2022 Yukio Shiiya
#
#   This software is released under the MIT License.
#   https://opensource.org/licenses/MIT
# ==============================================================================

######################################################################
# 基本設定
######################################################################

######################################################################
# 変数定義
######################################################################
# ユーザ変数

# システム環境 依存変数
CHECK_SUPPORT_STATUS="`which check-support-status 2>/dev/null`"
DPKG="`which dpkg 2>/dev/null`"
RPM="`which rpm 2>/dev/null`"
YUM="`which yum 2>/dev/null`"
DNF="`which dnf 2>/dev/null`"
IPTABLES="`which iptables 2>/dev/null`"
IP6TABLES="`which ip6tables 2>/dev/null`"
EBTABLES="`which ebtables 2>/dev/null`"
BRCTL="`which brctl 2>/dev/null`"
IP="`which ip 2>/dev/null`"
SS="`which ss 2>/dev/null`"
EFIBOOTMGR="`which efibootmgr 2>/dev/null`"
SGDISK="`which sgdisk 2>/dev/null`"
SMARTCTL="`which smartctl 2>/dev/null`"
PVDISPLAY="`which pvdisplay 2>/dev/null`"
VGDISPLAY="`which vgdisplay 2>/dev/null`"
LVDISPLAY="`which lvdisplay 2>/dev/null`"
APCACCESS="`which apcaccess 2>/dev/null`"
SYSTEMCTL="`which systemctl 2>/dev/null`"
HOSTNAMECTL="`which hostnamectl 2>/dev/null`"
LOCALECTL="`which localectl 2>/dev/null`"
TIMEDATECTL="`which timedatectl 2>/dev/null`"

# プログラム内部変数

######################################################################
# 関数定義
######################################################################
USAGE() {
	cat <<- EOF 1>&2
		Usage:
		  get_config_list.sh DEST_DIR
	EOF
}

######################################################################
# メインルーチン
######################################################################

# 第1引数のチェック
if [ "$1" = "" ];then
	echo "-E Missing DEST_DIR argument" 1>&2
	USAGE;exit 1
else
	DEST_DIR="$1"
	# 宛先ディレクトリのチェック
	if [ ! -d "${DEST_DIR}" ];then
		echo "-E DEST_DIR not a directory -- \"${DEST_DIR}\"" 1>&2
		USAGE;exit 1
	fi
fi

# システム構成情報の取得
if [ -n "${CHECK_SUPPORT_STATUS}" ];then
	"${CHECK_SUPPORT_STATUS}"                          > "${DEST_DIR}/check-support-status.log"                2>&1
fi
if [ -n "${DPKG}" ];then
	"${DPKG}" -l                                       > "${DEST_DIR}/dpkg-l.log"                              2>&1
	"${DPKG}" --get-selections                         > "${DEST_DIR}/dpkg--get-selections.log"                2>&1
fi
if [ -n "${RPM}" ];then
	"${RPM}" -qa | sort                                > "${DEST_DIR}/rpm-qa.log"                              2>&1
fi
if [ \( -n "${YUM}" \) -a \( -z "${DNF}" \) ];then
	"${YUM}" list installed                            > "${DEST_DIR}/yum-list-installed.log"                  2>&1
	"${YUM}" group list ids hidden installed           > "${DEST_DIR}/yum-group-list-ids-hidden-installed.log" 2>&1
fi
if [ -n "${DNF}" ];then
	"${DNF}" list installed                            > "${DEST_DIR}/dnf-list-installed.log"                  2>&1
	"${DNF}" group list ids hidden installed           > "${DEST_DIR}/dnf-group-list-ids-hidden-installed.log" 2>&1
fi
lsmod                                                  > "${DEST_DIR}/lsmod.log"                               2>&1
lspci                                                  > "${DEST_DIR}/lspci.log"                               2>&1
lspci -n                                               > "${DEST_DIR}/lspci-n.log"                             2>&1
lspci -v                                               > "${DEST_DIR}/lspci-v.log"                             2>&1
lspci -v -n                                            > "${DEST_DIR}/lspci-v-n.log"                           2>&1
if [ -n "${IPTABLES}" ];then
	"${IPTABLES}"  -t filter   -L -n --line-numbers -v > "${DEST_DIR}/iptables-t-filter.log"                   2>&1
	"${IPTABLES}"  -t nat      -L -n --line-numbers -v > "${DEST_DIR}/iptables-t-nat.log"                      2>&1
	"${IPTABLES}"  -t mangle   -L -n --line-numbers -v > "${DEST_DIR}/iptables-t-mangle.log"                   2>&1
	"${IPTABLES}"  -t raw      -L -n --line-numbers -v > "${DEST_DIR}/iptables-t-raw.log"                      2>&1
	"${IPTABLES}"  -t security -L -n --line-numbers -v > "${DEST_DIR}/iptables-t-security.log"                 2>&1
fi
if [ -n "${IP6TABLES}" ];then
	"${IP6TABLES}" -t filter   -L -n --line-numbers -v > "${DEST_DIR}/ip6tables-t-filter.log"                  2>&1
	"${IP6TABLES}" -t mangle   -L -n --line-numbers -v > "${DEST_DIR}/ip6tables-t-mangle.log"                  2>&1
	"${IP6TABLES}" -t raw      -L -n --line-numbers -v > "${DEST_DIR}/ip6tables-t-raw.log"                     2>&1
	"${IP6TABLES}" -t security -L -n --line-numbers -v > "${DEST_DIR}/ip6tables-t-security.log"                2>&1
fi
if [ -n "${EBTABLES}" ];then
	"${EBTABLES}"  -t filter   -L --Ln                 > "${DEST_DIR}/ebtables-t-filter.log"                   2>&1
	"${EBTABLES}"  -t nat      -L --Ln                 > "${DEST_DIR}/ebtables-t-nat.log"                      2>&1
	"${EBTABLES}"  -t broute   -L --Ln                 > "${DEST_DIR}/ebtables-t-broute.log"                   2>&1
fi
#ifconfig -a                                            > "${DEST_DIR}/ifconfig-a.log"                          2>&1
#netstat -anp                                           > "${DEST_DIR}/netstat-anp.log"                         2>&1
#netstat -rn                                            > "${DEST_DIR}/netstat-rn.log"                          2>&1
if [ -n "${BRCTL}" ];then
	"${BRCTL}" show                                    > "${DEST_DIR}/brctl-show.log"                          2>&1
	for bridge_dir in `ls -a1d /sys/class/net/*/bridge 2>/dev/null` ; do
		bridge=$(basename $(dirname ${bridge_dir}))
		"${BRCTL}" showstp ${bridge}                   > "${DEST_DIR}/brctl-showstp-${bridge}.log"             2>&1
	done
fi
if [ -n "${IP}" ];then
	"${IP}" addr show                                  > "${DEST_DIR}/ip-addr-show.log"                        2>&1
	"${IP}" link show                                  > "${DEST_DIR}/ip-link-show.log"                        2>&1
	"${IP}" maddress show                              > "${DEST_DIR}/ip-maddress-show.log"                    2>&1
	"${IP}" rule show                                  > "${DEST_DIR}/ip-rule-show.log"                        2>&1
	for table in `"${IP}" rule show | awk '{print $5}'` ; do
		"${IP}" -4 route show table ${table}           > "${DEST_DIR}/ip-4-route-show-table-${table}.log"      2>&1
		"${IP}" -6 route show table ${table}           > "${DEST_DIR}/ip-6-route-show-table-${table}.log"      2>&1
	done
fi
if [ -n "${SS}" ];then
	"${SS}" -anptuw                                    > "${DEST_DIR}/ss-anptuw.log"                           2>&1
fi
ps -eflH                                               > "${DEST_DIR}/ps-eflH.log"                             2>&1
who -r                                                 > "${DEST_DIR}/who-r.log"                               2>&1
if [ -n "${EFIBOOTMGR}" ];then
	"${EFIBOOTMGR}"                                    > "${DEST_DIR}/efibootmgr.log"                          2>&1
	"${EFIBOOTMGR}" -v                                 > "${DEST_DIR}/efibootmgr-v.log"                        2>&1
fi
for disk in `ls /sys/block | grep -e "^hd" -e "^nvme" -e "^sd" -e "^vd" -e "^xvd"` ; do
	hdparm -i /dev/${disk}                             > "${DEST_DIR}/hdparm-i-${disk}.log"                    2>&1
	cfdisk -P r /dev/${disk}                           > "${DEST_DIR}/cfdisk-P_r-${disk}.log"                  2>&1
	cfdisk -P s /dev/${disk}                           > "${DEST_DIR}/cfdisk-P_s-${disk}.log"                  2>&1
	cfdisk -P t /dev/${disk}                           > "${DEST_DIR}/cfdisk-P_t-${disk}.log"                  2>&1
	fdisk -l /dev/${disk}                              > "${DEST_DIR}/fdisk-l-${disk}.log"                     2>&1
	sfdisk -d /dev/${disk}                             > "${DEST_DIR}/sfdisk-d-${disk}.log"                    2>&1
	sfdisk -l -uS /dev/${disk}                         > "${DEST_DIR}/sfdisk-l-uS-${disk}.log"                 2>&1
	if [ -n "${SGDISK}" ];then
		"${SGDISK}" /dev/${disk} -b                     "${DEST_DIR}/sgdisk-b-${disk}.bin" >/dev/null
		"${SGDISK}" -p /dev/${disk}                    > "${DEST_DIR}/sgdisk-p-${disk}.log"                    2>&1
		for partnum in `"${SGDISK}" -p /dev/${disk} | sed -n '/^Number/,$p' | sed '1d' | awk '{print $1}'` ; do
			"${SGDISK}" /dev/${disk} -i ${partnum}     > "${DEST_DIR}/sgdisk-${disk}-i-${partnum}.log"         2>&1
		done
	fi
	if [ -n "${SMARTCTL}" ];then
		"${SMARTCTL}" /dev/${disk} -a                  > "${DEST_DIR}/smartctl-a-${disk}.log"                  2>&1
	fi
done
for fs_dev in `cat /etc/fstab | grep -v "^#" | awk '$3~/ext[234]/ {print $1}'` ; do
	fs_dev_base=`basename ${fs_dev}`
	tune2fs -l ${fs_dev}                               > "${DEST_DIR}/tune2fs-l-${fs_dev_base}.log"            2>&1
done
df --sync -x iso9660 -Tl                               > "${DEST_DIR}/df--sync-x-iso9660-Tl.log"               2>&1
df --sync -x iso9660 -Tli                              > "${DEST_DIR}/df--sync-x-iso9660-Tli.log"              2>&1
mount -l                                               > "${DEST_DIR}/mount-l.log"                             2>&1
test -n "${PVDISPLAY}" && "${PVDISPLAY}"               > "${DEST_DIR}/pvdisplay.log"                           2>&1
test -n "${VGDISPLAY}" && "${VGDISPLAY}" -v            > "${DEST_DIR}/vgdisplay-v.log"                         2>&1
test -n "${LVDISPLAY}" && "${LVDISPLAY}" --maps        > "${DEST_DIR}/lvdisplay--maps.log"                     2>&1
if [ -n "${APCACCESS}" ];then
	"${APCACCESS}" status                              > "${DEST_DIR}/apcaccess-status.log"                    2>&1
	#"${APCACCESS}" eprom                               > "${DEST_DIR}/apcaccess-eprom.log"                     2>&1
fi
if [ -n "${SYSTEMCTL}" ];then
	"${SYSTEMCTL}" list-dependencies                   > "${DEST_DIR}/systemctl-list-dependencies.log"         2>&1
	"${SYSTEMCTL}" list-unit-files                     > "${DEST_DIR}/systemctl-list-unit-files.log"           2>&1
	"${SYSTEMCTL}" list-units                          > "${DEST_DIR}/systemctl-list-units.log"                2>&1
	"${SYSTEMCTL}" status                              > "${DEST_DIR}/systemctl-status.log"                    2>&1
fi
if [ -n "${HOSTNAMECTL}" ];then
	"${HOSTNAMECTL}" status                            > "${DEST_DIR}/hostnamectl-status.log"                  2>&1
fi
if [ -n "${LOCALECTL}" ];then
	"${LOCALECTL}" status                              > "${DEST_DIR}/localectl-status.log"                    2>&1
fi
if [ -n "${TIMEDATECTL}" ];then
	"${TIMEDATECTL}" status                            > "${DEST_DIR}/timedatectl-status.log"                  2>&1
fi

