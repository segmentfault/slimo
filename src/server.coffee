ZJ = require 'zongji'
Opt = require 'optimist'

argv = Opt
    .usage 'Usage: $0 [ -s localhost ] [ -t 192.168.1.2 ]'
    .demand ['s', 't', 'source_user', 'target_user']
    .boolean 'h'
    .alias 'i', 'id'
    .alias 's', 'source'
    .alias 't', 'target'
    .alias 'h', 'help'
    .default 'i', 10
    .default 'source_password', null
    .default 'target_password', null
    .argv

if argv.h
    Opt.showHelp()
    process.exit 0

parseAddress = (address) ->
    host = [null, 3306]
    parts = address.split ':'

    host[0] = parts[0]
    host[1] = parseInt parts[1] if parts.length > 1

    host

source = parseAddress argv.s
target = parseAddress argv.t

server = new ZJ
    host: source[0]
    port: source[1]
    user: argv.source_user
    password: argv.source_password + ''
    serverId: parseInt argv.i

server.on 'binlog', (e) ->
    e.dump()

server.start includeEvents: ['unknown', 'query', 'tablemap', 'writerows', 'updaterows', 'deleterows']

