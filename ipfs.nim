import snappy
import md5
import os
import osproc
import strutils
import tables
import httpclient, json
import typetraits
import pymod


proc upload*(filename: string, msgpack:bool) : string {.exportpy.} =
    var
        hashamap = ""
        hashbmap = ""
    let client = newHttpClient()
    const blockSize: int = 1024 * 1024
    var
        c1: MD5Context
        d1: MD5Digest
        c2: MD5Context
        d2: MD5Digest
        f: File
        bytesRead: int = 0
        buffer: array[blockSize, char]
        byteTotal: int = 0

    # read chunk of file, calling update until all bytes have been read
    try:
        f = open(filename)

        md5Init(c1)
        bytesRead = f.readBuffer(buffer.addr, blockSize)

        while bytesRead > 0:
            md5Init(c2)
            byteTotal += bytesRead
            md5Update(c1, buffer, bytesRead)
            md5Update(c2, buffer, bytesRead)
            md5Final(c2, d2)
            var hash = compress($d2)
            var data = newMultipartData()
            data["path"] = (hash, "text/html", hash)
            var output = client.postContent("http://127.0.0.1:5001/api/v0/add", multipart=data)
            var hashb = parseJson(output)["Hash"]
            bytesRead = f.readBuffer(buffer.addr, blockSize)
            if hashamap == "":
                hashamap = hashamap & $d2
                hashbmap = hashbmap & $hashb
            else:
                hashamap = hashamap & "," & $d2
                hashbmap = hashbmap & "," & $hashb
        md5Final(c1, d1)
    except IOError:
        echo("File not found.")
    finally:
        if f != nil:
            f.close()
    let hashes = "$#&$#&$#" % [hashamap, hashbmap, $d1]
    return hashes

# if paramCount() > 0:
#     let arguments = commandLineParams()
#     echo("MD5: ", calculateMD5Incremental(arguments[0]))
# else:
#     echo("Must pass filename.")
#     quit(-1)

initPyModule("encrypt", calculateMD5Incremental)
