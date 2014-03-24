import sys
import random
import re
import chilkat


class Uploader():
    http = chilkat.CkHttp()
    req = chilkat.CkHttpRequest()
    req.UseUpload()

    def __init__(self):
        # Default upload URL of the main domain
        self.req.put_Path("/upload")
        self.domain = ""
        loc = input("Enter the location of what you want to upload: ")

        add = self.req.AddFileForUpload("file1", loc)
        if add is not True:
            print(self.req.lastErrorText())
            sys.exit()

        self.unlock_chilkat()
        self.get_prefix()
        self.upload()

    def unlock_chilkat(self):
        # The following unlocks the Chilkat module, which is necessary because
        # it is commercially licensed. This should be called once at the
        # beginning of the program
        unlock = self.http.UnlockComponent("Unlock")
        if unlock is not True:
            print(self.http.lastErrorText())
            sys.exit()

    def get_prefix(self):
        # ZippyShare has multiple upload domains ranging from www1 to www78,
        # so each upload gets a random domain for uploading
        prefix = "www"
        arr = []
        for i in range(1, 79):
            domain_prefix = prefix + str(i)
            arr.append(domain_prefix)
        rand = random.choice(arr)
        self.domain = "%s.zippyshare.com" % rand

    def upload(self):
        port = 80
        ssl = False
        resp = self.http.SynchronousRequest(self.domain, port, ssl, self.req)
        if resp is None:
            print(self.http.lastErrorText())
        else:
            resp.put_Utf8(True)
            matcher = re.search(self.domain + "/v/.*html", resp.bodyStr())
            if matcher:
                print(repr(matcher.group(0)))
            else:
                print("No match was found in the body of the source.")


def main():
    ifh = Uploader()

if __name__ == "__main__":
    main()