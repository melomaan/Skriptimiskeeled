# -*- coding: utf-8 -*-
"""Script for performing synchronous uploads to one of many
ZippyShare.com upload domains. Takes user's input for file
location (absolute path) and returns the download link.

Author: Üllar Seerme
"""

import sys
import random
import re
try:
    import chilkat
except ImportError:
    print("Error importing chilkat. Install module from "
          "http://www.chilkatsoft.com/python.asp")


class Uploader():
    http = chilkat.CkHttp()
    req = chilkat.CkHttpRequest()
    req.UseUpload()

    def __init__(self):
        """Define the default upload URL of the main domain in use."""
        self.req.put_Path("/upload")
        self.domain = ""
        loc = input("Enter the location of what you want to upload: ")
        add = self.req.AddFileForUpload("file1", loc)

        if add is not True:
            print(self.req.lastErrorText())
            sys.exit()

        self.unlock_chilkat()
        self.rand_domain()
        self.upload()

    def unlock_chilkat(self):
        """Call once at the beginning to unlock the commercially licensed
        chilkat module. Any string will do as argument.
        """
        unlock = self.http.UnlockComponent("Unlock")

        if unlock is not True:
            print(self.http.lastErrorText())
            sys.exit()

    def rand_domain(self):
        """Choose a random upload domain from range 1 to 78. This is
        specific to ZippyShare.
        """
        prefix = "www"
        arr = []
        for i in range(1, 79):
            domain_prefix = prefix + str(i)
            arr.append(domain_prefix)
        rand = random.choice(arr)
        self.domain = "%s.zippyshare.com" % rand

    def upload(self):
        """Begin synchronous upload and use re module (regex) to find the
        resource locator in the body of the response.
        """
        port = 80
        ssl = False
        resp = self.http.SynchronousRequest(self.domain, port, ssl, self.req)

        if resp is None:
            print(self.http.lastErrorText())
        else:
            matcher = re.search(self.domain + "/v/.*html", resp.bodyStr())
            if matcher:
                print("Link:", matcher.group(0))
            else:
                print("No match was found in the body of the source.")


def main():
    Uploader()

if __name__ == "__main__":
    main()