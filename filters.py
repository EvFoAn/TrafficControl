import math

def formatBytes(bytes):
    if bytes == 0:
        return '0 Bytes'
    k = 1024
    sizes = ['Bytes', 'KB', 'MB', 'GB']
    i = int(math.floor(math.log(bytes) / math.log(k)))

    return f"{float(bytes / math.pow(k, i)):.2f} {sizes[i]}"
