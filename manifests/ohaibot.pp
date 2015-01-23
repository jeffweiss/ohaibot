include ::apt

apt::source { 'erlang-solutions':
  location   => 'http://packages.erlang-solutions.com/ubuntu',
  repos      => 'contrib',
  key        => 'D208507CA14F4FCA',
  key_server => 'pgp.mit.edu',
}

package { 'erlang':
  ensure => latest,
  require => Apt::Source['erlang-solutions'],
}

package { 'elixir':
  ensure => latest,
  require => Apt::Source['erlang-solutions'],
}

package {'git':
  ensure => latest,
}

#$ohaibot_dir = '/var/src/ohaibot'

#file {"$ohaibot_dir":
#ensure => directory,
#}

#vcsrepo {"$ohaibot_dir":
#ensure   => present,
#provider => git,
#source   => 'https://github.com/jeffweiss/ohaibot.git',
#require  => [Package['git'],File["$ohaibot_dir"]],
#}
