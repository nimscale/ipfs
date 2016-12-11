# IPFS Command Line Tool

* Command line tool implemented in `nim` that's purpose is to hash and add
files to IPFS return sequence of the file's hashes

* `pyipfs.nim` is a wrapper around the `ipfs.nim` and return string of hashes separated by `&`
    * To generate `.so` file that can be imported use [pymod](https://github.com/jboy/nim-pymod)
    ```
    python path/to/pmgen.py pyipfs.nim
    ```

## Usage
    * Using nim module:
    ```
    nim c -r ipfs.nim /path/to/file
    ```
    * Using python
    ```python
    import ipfs

    ipfs.pyUpload("/path/to/file")
    ```