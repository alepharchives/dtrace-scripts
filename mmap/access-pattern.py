#!/usr/bin/env python

import sys, re
from bisect import bisect

if __name__ == "__main__":

	segments = open(sys.argv[1])
	pageins = open(sys.argv[2])

	offsets = []
	sections = []
	offset = size = vmaddr = 0
	
	# read in sections
	
	for line in segments:
		
		# Segment __TEXT: 19062784 (vmaddr 0x0 fileoff 0)

		m = re.match('Segment\s+([^:]+):\s+(\d+)\s+\(vmaddr\s+0x[a-f\d]+\s+fileoff\s+(\d+)\)', line)
		
		if m:
			segment = m.group(1)
			segsize, segoffs = map(int, m.group(2, 3))
			print "segment: %s, size: %d, offset: %d" % (segment, segsize, segoffs)
			
			# Segment __LINKEDIT: 19382272 (vmaddr 0x138a000 fileoff 20393984)
			
			if segment == '__LINKEDIT':
				offsets.append(segoffs)
				sections.append((segment, '__symtab', segoffs, segsize))
							
			continue 
			
		# Section __const: 1120204 (addr 0x1300 offset 4864)

		m = re.match('\s+Section\s+([^:]+):\s+(\d+)\s\(addr\s+(0x[a-f\d]+)\s+offset\s+(\d+)\)', line)
		
		if m:
			section = m.group(1)
			sz, offs = map(int, m.group(2, 4))
			addr = int(m.group(3), 16)
			
			# Section __bss: 61412 (addr 0x1372d40 offset 0)
			# Section __common: 29384 (addr 0x1381d40 offset 0)

			if offs == 0:
				offs = offset + addr - vmaddr

			offs1 = offset + addr - vmaddr 
			
			if offs1 != offs:
				print line
				print "offset: %d, offset1: %d, offset2: %d" % (offs, offset + size, offset + addr - vmaddr)
				
			offset = offs
			size = sz
			vmaddr = addr
			
			offsets.append(offset)
			sections.append((segment, section, offset, size))
			continue
	
	# read in page-ins
	
	for line in pageins:
		
		# vnode_pagein: XUL, offset: 20254720, size: 24576
		
		m = re.search('offset:\s+(\d+),\s+size:\s+(\d+)', line)
		
		if m:			
			start, size = map(int, m.group(1, 2))
			ix = bisect(offsets, start)
			if ix >= len(sections):
				print offsets
				print line
				print "start: %d, ix: %d" % (start, ix)
			sect = sections[ix]
			pages = size / 4096
			print "%s, %s = %d pages" % (sect[0], sect[1], pages)
		