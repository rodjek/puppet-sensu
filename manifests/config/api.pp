define sensu::config::api($key, $value) {
  include sensu::augeas

  Augeas {
    lens    => 'Sensu.lns',
    incl    => '/etc/sensu/config.json',
    context => '/files/etc/sensu/config.json/dict/entry[.="api"]',
    require => File['/usr/share/augeas/lenses/sensu.aug'],
  }

  if $key == 'port' {
    $config_type = 'number'
  } else {
    $config_type = 'string'
  }

  augeas {
    "${name}-api - create and set to '${value}'":
      changes => [
        "set dict/entry[last()+1] ${key}",
        "set dict/entry[last()]/${config_type} ${value}",
      ],
      onlyif  => "match dict/entry[.='${key}'] size == 0";
    "${name}-api - set to '${value}'":
      changes => "set dict/entry[.='${key}']/${config_type} ${value}",
      require => Augeas["${name}-api - create and set to '${value}'"];
  }
}
