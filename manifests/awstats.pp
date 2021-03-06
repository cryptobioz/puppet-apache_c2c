class apache_c2c::awstats {

  package { 'awstats':
    ensure => installed,
  }

  # ensure non-managed files are purged from directory
  file {'/etc/awstats':
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    recurse => true,
    force   => true,
    require => Package['awstats'],
  }

  case $::osfamily {

    'Debian': {
      cron { 'update all awstats virtual hosts':
        command => '/usr/share/doc/awstats/examples/awstats_updateall.pl -awstatsprog=/usr/lib/cgi-bin/awstats.pl -confdir=/etc/awstats now > /dev/null',
        user    => 'root',
        minute  => [0,10,20,30,40,50],
        require => Package[awstats],
      }

      file { '/etc/cron.d/awstats':
        ensure => absent,
      }
    }

    'RedHat': {

      # awstats RPM installs its own cron in /etc/cron.hourly/awstats

      case $::operatingsystemmajrelease {
        '5': {
          file { '/usr/share/awstats/wwwroot/cgi-bin/':
            seltype => 'httpd_sys_script_exec_t',
            mode    => '0755',
            recurse => true,
            require => Package['awstats'],
          }

          file { '/var/lib/awstats/':
            seltype => 'httpd_sys_script_ro_t',
            seluser => 'user_u',
            recurse => true,
            require => Package['awstats'],
          }
        }
        '6': {
          file { '/usr/share/awstats/wwwroot/cgi-bin/':
            mode    => '0755',
            recurse => true,
            require => Package['awstats'],
          }
        }
        default: { fail "Module 'apache_c2c' not compatible with this distro, use 'puppetlabs-apache' instead" }
      }

      file { '/etc/httpd/conf.d/awstats.conf':
        ensure  => absent,
        require => Package['awstats'],
        notify  => Exec['apache-graceful'],
      }
    }

    default: { fail "Unsupported osfamily ${::osfamily}" }
  }

}
