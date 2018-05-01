ZJ = require 'zongji'
Opt = require 'optimist'
Mysql = require 'mysql2'

argv = Opt
    .usage 'Usage: $0 [ -s localhost ] [ -t 192.168.1.2 ]'
    .demand ['s', 't', 'd', 'source_user', 'target_user', 'binlog_name', 'binlog_pos']
    .boolean 'h'
    .alias 'i', 'id'
    .alias 's', 'source'
    .alias 't', 'target'
    .alias 'h', 'help'
    .alias 'n', 'binlog_name'
    .alias 'p', 'binlog_pos'
    .alias 'c', 'charset'
    .alias 'd', 'database'
    .default 'i', 10
    .default 'c', 'utf8mb4'
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
options =
    includeEvents: ['unknown', 'query', 'tablemap', 'writerows', 'updaterows', 'deleterows', 'rotate']
    serverId: parseInt argv.i

options.binlogName = argv.binlog_name if argv.binlog_name?
options.binlogNextPos = argv.binlog_pos if argv.binlog_pos?

mysql = Mysql.createConnection
    host: target[0]
    port: target[1]
    user: argv.target_user
    password: argv.target_password + ''
    database: argv.d + ''
    charset: argv.c

mysql.query 'SET sql_mode = ""'

server = new ZJ
    host: source[0]
    port: source[1]
    user: argv.source_user
    password: argv.source_password + ''
    charset: argv.c

server.on 'binlog', (e) ->
    console.log server.binlogName + ':' + e.nextPosition

    if e.getEventName() is 'query' and !e.query.match /^(BEGIN|COMMIT)\s*$/i
        #console.log e.query
        mysql.query e.query, (err, result) ->
            console.log err if err?


server.on 'error', (e) ->
    console.log e

server.start options

