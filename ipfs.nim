import snappy
import md5
import os
import osproc
import strutils
import tables
import httpclient, json
import typetraits


let client = newHttpClient()
var
  hashSeq: seq[string]
  hashaMap: seq[string]
  hashbMap: seq[string]

proc addToIpfs*(input: string) : string =
    var data = newMultipartData()
    data["path"] = (input, "text/html", input)
    var output = client.postContent("http://127.0.0.1:5001/api/v0/add", multipart=data)
    var hash = parseJson(output)["Hash"]
    return $hash

proc hash(chunk: cstring, len: int) : string =
    var
        d: MD5Digest
        c: MD5Context
    c.md5Init()
    c.md5Update(chunk, len)
    c.md5Final(d)
    return $d

proc buildHashChain(chain: string, hash: string) : string =
  return if chain == nil: hash else: chain & "," & hash

proc upload*(filename: string) : (seq[string], seq[string], string) =
  const blockSize: int = 1024 * 1024
  var
      c1: MD5Context
      d1: MD5Digest
      f: File
      bytesRead: int = 0
      buffer: array[blockSize, char]
      byteTotal: int = 0

  try:
    hashaMap = @[]
    hashbMap = @[]
    f = open(filename)
    md5Init(c1)  # Initialize context to hash whole file
    bytesRead = f.readBuffer(buffer.addr, blockSize)

    while bytesRead > 0:
      # Reading chunks, hash, addToIpfs
      byteTotal += bytesRead
      var hasha = hash(buffer, bytesRead)  # MD5 hash
      c1.md5Update(buffer, bytesRead)
      var hashb = addToIpfs(compress(hasha))  # IPFS hash to the compressed md5
      bytesRead = f.readBuffer(buffer.addr, blockSize)
      hashaMap.add($hasha)
      hashbMap.add($hashb)
    c1.md5Final(d1)  # Getting the hash of the whole file
  except IOError:
      echo("File not found.")
  finally:
      if f != nil:
          f.close()
  return (hashaMap, hashbMap, $d1)

if paramCount() > 0:
    let arguments = commandLineParams()
    echo upload(arguments[0])
else:
    echo("Must pass filename.")
    quit(-1)
