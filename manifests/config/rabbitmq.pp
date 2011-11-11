define sensu::config::rabbitmq($key, $value) {
  include sensu::augeas

  Augeas {
    lens    => 'Sensu.lns',
    incl    => '/etc/sensu/config.json',
    context => '/files/etc/sensu/config.json/dict/entry[.="rabbitmq"]',
    require => File['/usr/share/augeas/lenses/sensu.aug'],
  }

  augeas {
    "${name}-rabbitmq - create and set to '${value}'":
      changes => [
        "set dict/entry[last()+1] ${key}",
        "set dict/entry[last()]/string ${value}",
      ],
      onlyif  => "match dict/entry[.='${key}'] size == 0";
    "${name}-rabbitmq - set to '${value}'":
      changes => "set dict/entry[.='${key}']/string ${value}",
      require => Augeas["${name}-rabbitmq - create and set to '${value}'"];
  }
}
