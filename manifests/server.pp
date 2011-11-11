define sensu::server(
                      $rabbitmq_password,
                      $rabbitmq_host='localhost',
                      $rabbitmq_user='sensu',
                      $rabbitmq_vhost='/',
                      $redis_host='localhost',
                      $redis_port='6379'
                    ) {
  include sensu::user
  include sensu::package

  sensu::config::rabbitmq {
    'sensu::server password':
      key   => 'password',
      value => $rabbitmq_password;
    'sensu::server host':
      key   => 'host',
      value => $rabbitmq_host;
    'sensu::server user':
      key   => 'user',
      value => $rabbitmq_user;
    'sensu::server vhost':
      key   => 'vhost',
      value => $rabbitmq_vhost;
  }

  sensu::config::redis {
    'sensu::server host':
      key   => 'host',
      value => $redis_host;
    'sensu::server port':
      key   => 'port',
      value => $redis_port;
  }
}
