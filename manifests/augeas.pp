class sensu::augeas {
  file { '/usr/share/augeas/lenses/sensu.aug':
    source => 'puppet:///modules/sensu/usr/share/augeas/lenses/sensu.aug',
    owner  => 'root',
    group  => 'root',
    mode   => '0444',
  }
}
