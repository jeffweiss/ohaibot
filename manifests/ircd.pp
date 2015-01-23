class charybdis::vagrant inherits charybdis {
  include charybdis::admin
  include charybdis::cluster
  include charybdis::log

  include charybdis::default::alias
  include charybdis::default::auth
  # for vagrant environs we don't need the blacklist
  # because we're only running in a small dev env
  # include charybdis::default::blacklist
  include charybdis::default::class
  include charybdis::default::channel
  include charybdis::default::general
  include charybdis::default::listen
  include charybdis::default::loadmodule
  include charybdis::default::modules
  include charybdis::default::operator
  include charybdis::default::privset
  include charybdis::default::serverhide
  include charybdis::default::serverinfo

  charybdis::exempt { 'default': }
  charybdis::shared { 'default': }
}

include charybdis::vagrant
