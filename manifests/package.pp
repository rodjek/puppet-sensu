class sensu::package {
  gem { 'sensu': }

  file { '/etc/sensu':
    ensure  => directory,
    mode    => '0755',
    owner   => 'sensu',
    group   => 'sensu',
    require => User['sensu'],
  }
}
