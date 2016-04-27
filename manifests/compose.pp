# == Class: docker::compose
#
# Class to install Docker Compose using the recommended curl command.
#
# === Parameters
#
# [*ensure*]
#   Whether to install or remove Docker Compose
#   Valid values are absent present
#   Defaults to present
#
# [*version*]
#   The version of Docker Compose to install.
#   Defaults to the value set in $docker::params::compose_version
#
# [*install_url*]
#   The URL to use to install docker-compose.
#   Defaults to the URL recommended by https://docs.docker.com/compose/install/
#
class docker::compose(
  $ensure = 'present',
  $version = $docker::params::compose_version,
  $install_url = "https://github.com/docker/compose/releases/download/${version}/docker-compose-${::kernel}-x86_64"
) inherits docker::params {
  validate_string($version)
  validate_re($ensure, '^(present|absent)$')
  validate_re($install_url, '^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$')

  if $ensure == 'present' {
    exec { "Install Docker Compose ${version}":
      path    => '/usr/bin/',
      cwd     => '/tmp',
      command => "curl -s -L ${install_url} > /usr/local/bin/docker-compose-${version}",
      creates => "/usr/local/bin/docker-compose-${version}"
    } ->
    file { "/usr/local/bin/docker-compose-${version}":
      owner => 'root',
      mode  => '0755'
    } ->
    file { '/usr/local/bin/docker-compose':
      ensure => 'link',
      target => "/usr/local/bin/docker-compose-${version}",
    }
  } else {
    file { [
      "/usr/local/bin/docker-compose-${version}",
      '/usr/local/bin/docker-compose'
    ]:
      ensure => absent,
    }
  }
}
