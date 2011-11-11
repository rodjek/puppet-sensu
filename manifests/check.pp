define sensu::check($command, $subscribers, $interval, $ensure='present') {
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
        "create checks and ${name} check":
          changes => [
            'set entry[last()+1] checks',
            "set entry[.='checks']/dict/entry ${name}",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[1] command",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[1]/string ${command}",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[2] interval",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[2]/number ${interval}",
          ],
          onlyif  => 'match entry[.="checks"] size == 0';
        "create ${name} check":
          changes => [
            "set entry[.='checks']/dict/entry[last()+1] ${name}",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[1] command",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[1]/string ${command}",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[2] interval",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[2]/number ${interval}",
          ],
          onlyif  => "match entry[.='checks']/dict/entry[.='${name}'] size == 0",
          require => Augeas["create checks and ${name} check"];
        "update ${name} check":
          changes => [
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[.='command']/string ${command}",
            "set entry[.='checks']/dict/entry[.='${name}']/dict/entry[.='interval']/number ${interval}",
          ],
          require => Augeas["create ${name} check"];
      }
      sensu_check_subscribers { $name:
        subscribers => $subscribers,
        require     => Augeas["update ${name} check"],
      }
    }
    'absent': {
      augeas { "delete check ${name}":
        changes => "rm entry[.='checks']/dict/entry[.='${name}']",
      }
    }
    default: {
      fail("Sensu::Check[${name}] passed an invalid `ensure` parameter '${ensure}'")
    }
  }
}
