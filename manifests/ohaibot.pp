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
