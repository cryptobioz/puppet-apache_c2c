define apache_c2c::auth::basic::file::webdav::user (
  $vhost,
  $ensure            = present,
  $authname          = false,
  $location          = "/${name}",
  $auth_user_file    = undef,
  $rw_users          = 'valid-user',
  $limits            = 'GET HEAD OPTIONS PROPFIND',
  # lint:ignore:empty_string_assignment
  $ro_users          = '',
  # lint:endignore
  $allow_anonymous   = false,
  $restricted_access = []) {

  validate_string($rw_users)
  validate_string($limits)
  validate_string($ro_users)
  validate_array($restricted_access)

  $fname = regsubst($name, '\s', '_', 'G')

  $wwwroot = $apache_c2c::root
  validate_absolute_path($wwwroot)

  if !defined(Apache_c2c::Module['authn_file']) {
    apache_c2c::module {'authn_file': }
  }

  if $auth_user_file {
    $_auth_user_file = $auth_user_file
  } else {
    $_auth_user_file = "${wwwroot}/${vhost}/private/htpasswd"
  }

  if $authname {
    $_authname = $authname
  } else {
    $_authname = $name
  }

  if $rw_users != 'valid-user' {
    $_users = "user ${rw_users}"
  } else {
    $_users = $rw_users
  }

  $seltype = $::osfamily ? {
    'RedHat' => 'httpd_config_t',
    default  => undef,
  }
  file { "${wwwroot}/${vhost}/conf/auth-basic-file-webdav-${fname}.conf":
    ensure  => $ensure,
    content => template('apache_c2c/auth-basic-file-webdav-user.erb'),
    seltype => $seltype,
    notify  => Exec['apache-graceful'],
  }

}
