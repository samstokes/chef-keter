name        'keter'
maintainer  'Sam Stokes'
maintainer  'me@samstokes.co.uk'
description 'Sets up Keter on an Ubuntu server'
version     '0.0.1'

recipe      'keter', 'Sets up Keter to run on startup'

attribute   'keter/root',
              display_name: 'Keter Root',
              description: 'Root directory for Keter (will contain incoming/)',
              type: 'string',
              default: '/var/keter'

supports 'ubuntu'
