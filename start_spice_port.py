#!/usr/bin/env python

import libvirt
import xml.dom.minidom as minidom
import sys,os


if len(sys.argv) != 2:
    print "Usage: %s <vm_name>" % sys.argv[0]
    exit(1)

conn=libvirt.open("qemu:///system")

for id in conn.listDomainsID():
   dom = conn.lookupByID(id)
   if dom.name() == sys.argv[1]:
       xmldesc = dom.XMLDesc(0)
       break

midom = minidom.parseString(xmldesc)
root = midom.documentElement
childs = root.childNodes
for child in childs:
    if child.nodeName == 'devices':
        for subchild in child.childNodes:
            if subchild.nodeName == 'graphics':
                port = subchild.getAttribute('port')
                port_offset = str(int(port) + 30000) 
                cmd = "ps axu | grep -v 'grep' | grep 'websock' | egrep %s |awk '{system(\"kill -9 \"$2)}'" % port
                os.system(cmd)
                cmd = "websockify %s 0:%s -D" % (port_offset, port)
                os.system(cmd)
                break
        break

