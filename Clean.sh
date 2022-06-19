;R="[1;31m";G="[1;32m";Y="[1;33m";C="[1;36m";B="[1;m";O="[m";[ "$(id -u)" = 0 ]||{ echo "$Y- 正在获取root权限$O";su -c "\"$0\" \"$@\"";exit;};runtime(){ RUNTIME="/data/adb/TimeRainStarSky/Runtime";export PATH="/data/adb/magisk:$PATH";[ -d "$RUNTIME" ]&&[ -f "$RUNTIME/verify" ]&&[ "$(ls "$RUNTIME")" = "$(cat "$RUNTIME/verify")" ]||{ echo "$Y- 正在配置运行环境$O";abort(){ rm -rf "$RUNTIME";echo "$R! $@$O";exit 1;};rm -rf "$RUNTIME";mkdir -p "$RUNTIME";setcmd(){ CMDPATH="$(command -v "$1")"&&cp "$CMDPATH" "$RUNTIME"&&"$RUNTIME/$@"|tr " " "\n"|while read i;do [ -z "$i" ]&&continue;ln -sf "$1" "$RUNTIME/$i";done||abort "找不到$1，请安装运行环境后重试";};setcmd busybox --list;setcmd toybox;ls "$RUNTIME">"$RUNTIME/verify";};export PATH="$DIR:$RUNTIME:$PATH";export LD_LIBRARY_PATH="$DIR:$RUNTIME:$LD_LIBRARY_PATH";};DIR="$(dirname "$(realpath "$0")")";runtime;abort(){ echo "
$R! $@$O";exit 1;};mktmp(){ TMP="$(dirname "$(realpath "$0")")/tmp"&&rm -rf "$TMP"&&mkdir -p "$TMP"||abort "创建缓存文件夹失败";};echo "$B—————————————————————————
$R Boot$Y Clean$O &$G Pack$C Tools$O
—————————————————————————
    ${G}作者：${C}时雨🌌星空$O

$Y- 正在设置环境$O";TMP="$(dirname "$(realpath "$0")")/tmp";[ -f "$1" ]&&FILE="$(realpath "$1")"||abort "输入文件不存在";DIR="$(dirname "$FILE")";FILE="$(basename "$FILE")"
mktmp;cd "$TMP"||abort "切换到缓存目录失败"
echo "
$Y- 正在解包$FILE$O
"
magiskboot unpack "$DIR/$FILE"||abort "$FILE解包失败"
echo "
$Y- 正在重建Ramdisk$O"
mkdir cpio;cd cpio;cpio -i < ../ramdisk.cpio 2>/dev/null
if [ -f ramdisk-files.txt ];then
  [ -f ramdisk-files.sha256sum ]&&{ sha256sum -c ramdisk-files.sha256sum >/dev/null||echo "
$R! Ramdisk校验错误$O";}
  cpio -oH newc < ramdisk-files.txt > ../ramdisk.cpio||abort "Ramdisk打包失败"
else
  echo "
$R! 找不到Ramdisk清单文件，无法重建，直接打包$O"
fi
cd ..||abort "切换到缓存目录失败"
ls|grep -v ramdisk.cpio|xargs rm -rf||abort "删除缓存文件失败"
echo "
$Y- 正在打包${FILE%.*}-cleaned.img$O
"
magiskboot repack "$DIR/$FILE" "$DIR/${FILE%.*}-cleaned.img"||abort "Boot打包失败"
rm -rf "$TMP"
echo "
$G- ${FILE%.*}-cleaned.img打包完成$O"