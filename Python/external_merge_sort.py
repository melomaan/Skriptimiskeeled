import tempfile
import heapq
import array
import pprint
from itertools import islice

iters = []
n = 10
chunk_size = 1024

def yield_ints(file_object):
    while True:
        a = array.array('i')
        a.fromstring(file_object.read())
        if not a:
            break
        for x in a:
            yield x


def chunk_sort(file_object, size):
    file = open(file_object)
    while True:
        chunk = [int(line.strip()) for line in list(islice(file, size))]
        if not chunk:
            break

        tmp = tempfile.TemporaryFile()
        array.array('i', sorted(chunk)).tofile(tmp)
        tmp.seek(0)
        iters.append(yield_ints(tmp))


chunk_sort('random.dat', chunk_size)

arr = array.array('i')

for x in heapq.merge(*iters):
    arr.append(x)

print(heapq.nlargest(n, arr))
