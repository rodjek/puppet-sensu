class sensu::user {
  group { 'sensu':
    ensure => present,
  }

  user { 'sensu':
    ensure     => present,
    gid        => 'sensu',
    shell      => '/sbin/nologin',
    home       => '/var/lib/sensu',
    managehome => true,
    password   => '!!',
    require    => Group['sensu'],
  }
}
