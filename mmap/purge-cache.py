#!/usr/bin/env python

import mmap

SIZE = 8589934592L # 8Gb

map = mmap.mmap(-1, SIZE)
map[::4096] = '\x01' * (SIZE // 4096)
