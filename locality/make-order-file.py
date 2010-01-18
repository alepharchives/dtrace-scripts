#!/usr/bin/env python

#
# Time order symbols file suitable for ld
# Usage: make-order-file.py dtrace.log all.syms code.syms

import sys, re

def write_syms(out, sym, mods):
	for mod in mods:
		out.write('%s: %s\n' % (mod, sym))

logfile, allfile, codefile = sys.argv[1:4]

syms = open(logfile + '.order', 'w')
missing = open(logfile + '.missing', 'w')

# Load output from 'nm -njls __TEXT __text' on firefox-bin.

shortsyms = {}
fullsyms = {}

for line in open(codefile):		
	sym = line.rstrip()
	short = sym[:127]
	if len(sym) > 127 and short in shortsyms:
		print '%s is longer than 127 characters and has a duplicate' % sym
	shortsyms[short] = 1
	fullsyms[short] = sym
	
print 'code symbols loaded: %d' % len(fullsyms)

# Output from 'nm -onm' on 'ld -whatsloaded'.
# We are only interested in __TEXT,__text 
# which we check against shortsyms.

# nsBrowserApp.o: 0000000000000000 (__TEXT,__text) non-external __ZL6OutputPKcz
# nsBrowserApp.o:                  (undefined) external __ZN13nsCOMPtr_base16begin_assignmentEv
# nsBrowserApp.o: 000000000000cf38 (__TEXT,__cstring) non-external LC0

whatsloaded = {}

re = re.compile('[^:]+:?([^:]+):\s+[0-9a-f]+\s+\(__\w+,__\w+\)\s[^\[\]]+\s(.+)$')

for line in open(allfile):	
	m = re.match(line.rstrip())
	if m:
		mod, sym = m.group(1, 2)
		if sym[:127] not in shortsyms:
			continue
		if sym not in whatsloaded:
			whatsloaded[sym] = [mod]
		else:
			whatsloaded[sym].append(mod)
		
n = len(whatsloaded)
print 'code symbols matched: %d' % n

# output from dtrace, cut off at 127 characters
#		_GLOBAL__I_gArgc
#		 stub helpers
#		__ZL8CheckArgPKciPS0_i

seen = {}

for line in open(logfile):	
	sym = line.rstrip()
	if sym in seen:
		continue
	seen[sym] = 1
	found = 0
	if sym in shortsyms:
		found = 1
	if not found:
		sym1 = '_' + sym
		if sym1 in shortsyms:
			found = 1
			sym = sym1
	if found:
		sym = fullsyms[sym] # non-truncated
		write_syms(syms, sym, whatsloaded[sym])
		whatsloaded.pop(sym)
	else:
		missing.write(('%s\n' % sym))

# dump the rest of the symbols

# print '%d symbols ordered' % (n - len(whatsloaded))

# for sym in whatsloaded:
# 		write_syms(syms, sym, whatsloaded[sym])
	