class apache_c2c::security {

  case $::osfamily {

    'RedHat': {
      package { 'apache-mod_security':
        ensure => present,
        name   => 'mod_security',
      }

      file { '/etc/httpd/conf.d/mod_security.conf':
        ensure  => file,
        content => '# file managed by puppet

<IfModule mod_security2.c>
  Include modsecurity.d/modsecurity_localrules.conf
</IfModule>
',
        require => Package['apache-mod_security'],
        notify  => Exec['apache-graceful'],
      }
    }

    'Debian': {
      package { 'apache-mod_security':
        ensure => present,
        name   => 'libapache-mod-security',
      }
    }

    default: {
      fail ("Operating system not supported: '${::osfamily}'")
    }
  }

  apache_c2c::module { ['unique_id', 'security']:
    ensure  => present,
    require => Package['apache-mod_security'],
  }

}
