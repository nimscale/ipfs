import httpclient, json
import typetraits
import osproc
import strutils
import daemonize

# TODO: move redis and ipfs binaries and remove redis and ipfs directories and tars

const tmpdir = "/tmp/bin"

proc extractFromTarGz(path: string, dest: string = "."): string =
  result = execProcess("tar -zxf $# -C $#" % [path, dest])

proc installIpfs(path: string): string =
  const url = "http://dist.ipfs.io/go-ipfs/v0.4.4/go-ipfs_v0.4.4_linux-amd64.tar.g"
  downloadFile(url, "$#/go-ipfs.tar.gz" % path)
  echo extractFromTarGz("$#/go-ipfs.tar.gz" % path, tmpdir)

proc startIpfs(path: string = "$#/go-ipfs/" % tmpdir): Process =
  var process = startProcess("ipfs", path, ["daemon"])
  var f : File;
  discard f.open(outputHandle(process), fmRead)
  while(true):
    let line = f.readLine()
    if line == "Daemon is ready":
      break
  return process

proc installRedis(path: string): string =
  const url = "http://download.redis.io/redis-stable.tar.gz"
  downloadFile(url, "$#/redis.tar.gz" % path)
  echo extractFromTarGz("$#/redis.tar.gz" % path, tmpdir)
  result = execProcess("cd $#/redis-stable && make" % [path])

proc clean(p: Process) =
  p.close()

echo installIpfs(tmpdir)
echo installRedis(tmpdir)
var process = startIpfs()
echo execProcess("ipfs add $#/redis-stable/src/redis-server" % tmpdir)
clean(process)
