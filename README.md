Run fallout as a daemon:

    daemon --name=fallout --chdir=/var/lib/jenkins/tmp/fallout --output=/var/lib/jenkins/tmp/fallout/log/fallout.log --pidfile=/var/lib/jenkins/tmp/fallout/tmp/pids/fallout.pid -- bin/fallout