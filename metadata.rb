name        'keter'
maintainer  'Sam Stokes'
maintainer  'me@samstokes.co.uk'
description <<-DESC
Sets up Keter on an Ubuntu server.

For SSL, requires an encrypted data bag keter/ssl_ENV.json where ENV is the
Chef environment name.
DESC
version     '0.0.1'

recipe      'keter', 'Sets up Keter to run on startup'

attribute   'keter/version',
              :display_name => 'Keter version',
              :description => 'Version of Keter to install',
              :type => 'string',
              :required => 'optional'
attribute   'keter/root',
              :display_name => 'Keter Root',
              :description => 'Root directory for Keter (will contain incoming/)',
              :type => 'string',
              :default => '/var/keter'

supports 'ubuntu'
