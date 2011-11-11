define sensu::handler($command, $ensure='present') {
  include sensu::augeas

  Augeas {
    lens    => 'Sensu.lns',
    incl    => '/etc/sensu/config.json',
    context => '/files/etc/sensu/config.json/dict',
    require => File['/usr/share/augeas/lenses/sensu.aug'],
  }

  case $ensure {
    'present': {
      augeas {
        "create handler dict and ${name} handler":
          changes => [
            'set entry[last()+1] handlers',
            "set entry[.='handlers']/dict/entry ${name}",
            "set entry[.='handlers']/dict/entry/string '${command}'",
          ],
          onlyif  => 'match entry[.="handlers"] size == 0';
        "create handler ${name}":
          changes => [
            "set entry[.='handlers']/dict/entry[last()+1] ${name}",
            "set entry[.='handlers']/dict/entry[last()]/string '${command}'",
          ],
          onlyif  => "match entry[.='handlers']/dict/entry[.='${name}'] size == 0",
          require => Augeas["create handler dict and ${name} handler"];
        "set handler ${name} to '${command}'":
          changes => "set entry[.='handlers']/dict/entry[.='${name}']/string '${command}'",
          require => Augeas["create handler ${name}"];
      }
    }
    'absent': {
      augeas { "remove handler ${name}":
        changes => "rm entry[.='handlers']/dict/entry[.='${name}']",
      }
    }
    default: {
      fail("Sensu::Handler[${name}] passed invalid `ensure` parameter '${ensure}'")
    }
  }
}
