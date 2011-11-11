define sensu::config::redis($key, $value) {
  include sensu::augeas

  Augeas {
    lens    => 'Sensu.lns',
    incl    => '/etc/sensu/config.json',
    context => '/files/etc/sensu/config.json/dict/entry[.="redis"]',
    require => File['/usr/share/augeas/lenses/sensu.aug'],
  }

  if $key == 'port' {
    $config_type = 'number'
  } else {
    $config_type = 'string'
  }

  augeas {
    "${name}-redis - create and set to '${value}'":
      changes => [
        "set dict/entry[last()+1] ${key}",
        "set dict/entry[last()]/${config_type} ${value}",
      ],
      onlyif  => "match dict/entry[.='${key}'] size == 0";
    "${name}-redis - set to '${value}'":
      changes => "set dict/entry[.='${key}']/${config_type} ${value}",
      require => Augeas["${name}-redis - create and set to '${value}'"];
  }
}
