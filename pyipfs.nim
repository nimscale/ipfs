import ipfs
import strutils
import pymod

proc seqHashToChain(hashSeq: seq) : string =
  var hashTmp: string
  for hash in hashSeq:
    if hashTmp == nil:
      hashTmp = hash
    else:
      hashTmp = hashTmp & "," & hash
  return hashTmp

proc pyUpload*(filename: string): string {.exportpy.} =
  var hashSeq = ipfs.upload(filename)
  return "$#&$#&$#" % [seqHashToChain(hashSeq[0]), seqHashToChain(hashSeq[1]), hashSeq[2]]

initPyModule("ipfs", pyUpload)
