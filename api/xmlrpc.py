#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# TODO: Simplest RPC server (to use as an API server), https, basic auth
# @author: hajime
#
import logging
import os
try:
    from xmlrpc.server import SimpleXMLRPCServer
except ImportError:
    from SimpleXMLRPCServer import SimpleXMLRPCServer

logging.basicConfig(level=logging.INFO)

server = SimpleXMLRPCServer(('localhost', 9000), logRequests=True)


def list_contents(dir_name):
    logging.debug('list_contents(%s)', dir_name)
    return os.listdir(dir_name)


server.register_function(list_contents)

try:
    print('Use Control-C to exit')
    server.serve_forever()
except KeyboardInterrupt:
    print('Exiting')
