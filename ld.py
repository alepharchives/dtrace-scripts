#!/usr/bin/env python

f = open('/tmp/ld.log', 'wa')
f.write(' '.join(sys.argv))
f.close()
sys.execv('/usr/bin/ld', argv)
