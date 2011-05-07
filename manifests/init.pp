class rabbitmq {
  $ver = $rabbitmqversion
  $plugins = ["mochiweb", "webmachine", "amqp_client", "rabbitmq-mochiweb", "rabbitmq-management-agent", "rabbitmq-management"]

  exec { "install-rabbitmq":
    command => template("rabbitmq/install.erb"),
    creates => "/usr/lib/rabbitmq/lib/rabbitmq_server-$ver",
    cwd => "/root",
    logoutput => on_failure
  }

  define installplugin($ver) {
    exec { "install-plugin-$name":
      command => "wget http://www.rabbitmq.com/releases/plugins/v$ver/$name-$ver.ez",
      notify => Service["rabbitmq-server"],
      creates => "/usr/lib/rabbitmq/lib/rabbitmq_server-$ver/plugins/$name-$ver.ez",
      cwd => "/usr/lib/rabbitmq/lib/rabbitmq_server-$ver/plugins"
    }
  }

  # install plugins
  installplugin{ $plugins: ver => $ver }

  service { "rabbitmq-server":
    ensure => running,
    require => Exec["install-rabbitmq"],
    hasstatus => true
  }
}

