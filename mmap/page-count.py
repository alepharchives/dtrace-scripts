#!/usr/bin/env python

import sys, re

if __name__ == "__main__":

	n = 0
	
	for line in sys.stdin:

		# __LINKEDIT, __symtab = 2 pages, 5016 pages in

		m = re.search('=\s+(\d+)\s+pages', line)
		
		if m:
			n += int(m.group(1))

	print '%d pages read' % n