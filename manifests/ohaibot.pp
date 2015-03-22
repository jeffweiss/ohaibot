include ::apt

apt::source { 'erlang-solutions':
  location    => 'http://packages.erlang-solutions.com/ubuntu',
  repos       => 'contrib',
  key         => 'D208507CA14F4FCA',
  key_server  => 'pgp.mit.edu',
  include_src => false,
}

package { 'erlang':
  ensure => latest,
  require => Apt::Source['erlang-solutions'],
}

package { 'elixir':
  ensure => latest,
  require => Apt::Source['erlang-solutions'],
}

# This is required for any mix dependencies on github
package { 'git':
  ensure => "1:1.9.1-1",
}

notify {"$::ipaddress_eth0":}
notify {"$::ipaddress_eth1":}
