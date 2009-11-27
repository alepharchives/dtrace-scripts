#!/usr/bin/env python

#
# Time order symbols file suitable for ld
# Usage: make-order-file.py dtrace.log default.order.temp code.syms

import sys, re

def write_syms(out, sym, mods):
	for mod in mods:
		out.write('%s: %s\n' % (mod, sym))
		
syms = open(sys.argv[1] + '.order', 'w')
missing = open(sys.argv[1] + '.missing', 'w')

# output from 'ld -whatsloaded', massaged:
# 	nsUnicharUtils.o: __Z11ToLowerCaseRK18nsAString_internalRS_
# 	nsUnicharUtils.o: __Z11ToLowerCaset

whatsloaded = {}

for line in open(sys.argv[2]):		
	mod, sym = re.split(':\s', line)
	sym = sym.rstrip()
	if sym not in whatsloaded:
		whatsloaded[sym] = [mod]
	else:
		whatsloaded[sym].append(mod)

n = len(whatsloaded)
print "symbols in the default order file: %d" % n

# output from dtrace:
#		_GLOBAL__I_gArgc
#		 stub helpers
#		__ZL8CheckArgPKciPS0_i

seen = {}

for sym in open(sys.argv[1]):	
	sym = sym.rstrip()
	h = hash(sym)	
	if h in seen:
		continue
	seen[h] = 1
	if sym in whatsloaded:
		write_syms(syms, sym, whatsloaded[sym])
		whatsloaded.pop(sym)
	else:
		missing.write(('%s\n' % sym))

# dump the rest of the symbols

print '%d symbols ordered' % (n - len(whatsloaded))

for sym in whatsloaded:
		write_syms(syms, sym, whatsloaded[sym])
	