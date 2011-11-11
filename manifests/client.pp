define sensu::client(
                      $rabbitmq_password,
                      $rabbitmq_host='localhost',
                      $rabbitmq_user='sensu',
                      $rabbitmq_vhost='/'
                    ) {
  include sensu::user
  include sensu::package

  sensu::config::rabbitmq {
    'sensu::client password':
      key   => 'password',
      value => $rabbitmq_password;
    'sensu::client host':
      key   => 'host',
      value => $rabbitmq_host;
    'sensu::client user':
      key   => 'user',
      value => $rabbitmq_user;
    'sensu::client vhost':
      key   => 'vhost',
      value => $rabbitmq_vhost;
  }
}
