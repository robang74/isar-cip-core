#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import subprocess
import requests
import os
import sys
import time
from urllib.parse import urljoin

cdate=time.strftime("%Y%m%d")
api="https://api.kernelci.org/upload"
token=os.getenv("KERNELCI_TOKEN")

release=sys.argv[1]
target=sys.argv[2]
extension=sys.argv[3]

rootfs_filename="cip-core-image-kernelci-cip-core-"+release+"-"+target+".tar.gz"
initrd_filename="cip-core-image-kernelci-cip-core-"+release+"-"+target+"-initrd.img"
initrd_gz_filename="cip-core-image-kernelci-cip-core-"+release+"-"+target+"-initrd.img.gz"

input_dir="build/tmp/deploy/images/"+target
upload_path="/images/rootfs/cip/"+cdate+"/"+target+"/"
upload_path_latest="/images/rootfs/cip/latest/"+target+"/"
rootfs=input_dir+"/"+rootfs_filename
initrd=input_dir+"/"+initrd_filename

def upload_file(api, token, path, input_file, input_filename):
    headers = {
        'Authorization': token,
    }
    data = {
        'path': path,
    }
    files = {
        'file': (input_filename, open(input_file, 'rb').read()),
    }
    url = urljoin(api, 'upload')
    resp = requests.post(url, headers=headers, data=data, files=files)
    resp.raise_for_status()

if os.path.exists(rootfs) and os.path.exists(initrd):
    print("uploading rootfs to KernelCI")
    upload_file(api, token, upload_path, rootfs, rootfs_filename)
    print("uploading initrd to KernelCI")
    upload_file(api, token, upload_path, initrd, initrd_gz_filename)
    print("uploaded to: https://storage.kernelci.org"+upload_path)

    # Upload latest
    print("uploading rootfs to KernelCI CIP latest")
    upload_file(api, token, upload_path_latest, rootfs, rootfs_filename)
    print("uploading initrd to KernelCI CIP latest")
    upload_file(api, token, upload_path_latest, initrd, initrd_gz_filename)
    print("uploaded to: https://storage.kernelci.org"+upload_path_latest)
