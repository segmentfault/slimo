// Generated by CoffeeScript 2.1.0
(function() {
  var Opt, ZJ, argv, options, parseAddress, server, source, target;

  ZJ = require('zongji');

  Opt = require('optimist');

  argv = Opt.usage('Usage: $0 [ -s localhost ] [ -t 192.168.1.2 ]').demand(['s', 't', 'source_user', 'target_user', 'binlog_name', 'binlog_pos']).boolean('h').alias('i', 'id').alias('s', 'source').alias('t', 'target').alias('h', 'help').alias('n', 'binlog_name').alias('p', 'binlog_pos').default('i', 10).default('source_password', null).default('target_password', null).argv;

  if (argv.h) {
    Opt.showHelp();
    process.exit(0);
  }

  parseAddress = function(address) {
    var host, parts;
    host = [null, 3306];
    parts = address.split(':');
    host[0] = parts[0];
    if (parts.length > 1) {
      host[1] = parseInt(parts[1]);
    }
    return host;
  };

  source = parseAddress(argv.s);

  target = parseAddress(argv.t);

  options = {
    includeEvents: ['unknown', 'query', 'tablemap', 'writerows', 'updaterows', 'deleterows'],
    serverId: parseInt(argv.i)
  };

  if (argv.binlog_name != null) {
    options.binlogName = argv.binlog_name;
  }

  if (argv.binlog_pos != null) {
    options.binlogNextPos = argv.binlog_pos;
  }

  server = new ZJ({
    host: source[0],
    port: source[1],
    user: argv.source_user,
    password: argv.source_password + ''
  });

  server.on('binlog', function(e) {
    return e.dump();
  });

  server.start(options);

}).call(this);
