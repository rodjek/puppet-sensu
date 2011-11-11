define sensu::api(
                      $rabbitmq_password,
                      $rabbitmq_host='localhost',
                      $rabbitmq_user='sensu',
                      $rabbitmq_vhost='/',
                      $redis_host='localhost',
                      $redis_port='6379',
                      $listen_address=$ipaddress,
                      $listen_port='4567'
                    ) {
  include sensu::user
  include sensu::package

  sensu::config::rabbitmq {
    'sensu::api password':
      key   => 'password',
      value => $rabbitmq_password;
    'sensu::api host':
      key   => 'host',
      value => $rabbitmq_host;
    'sensu::api user':
      key   => 'user',
      value => $rabbitmq_user;
    'sensu::api vhost':
      key   => 'vhost',
      value => $rabbitmq_vhost;
  }

  sensu::config::redis {
    'sensu::api host':
      key   => 'host',
      value => $redis_host;
    'sensu::api port':
      key   => 'port',
      value => $redis_port;
  }

  sensu::config::api {
    'sensu::api host':
      key   => 'host',
      value => $listen_address;
    'sensu::api port':
      key   => 'port',
      value => $listen_port;
  }
}
