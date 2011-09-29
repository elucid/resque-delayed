## 1.1.0 (2011-09-23)

* well, this is embarrasing. originally added `@queue` instance variable to
  `Resque::Delayed` metaclass by accident. relocated.

  note: this means if you were using version 1.0.0 of the gem then your
  Resque::Delayed queue is currently stored in the empty string key instead
  of the "Resque::Delayed:internal" key. you can run

  `$ bundle exec rake resque_delayed:migrate_queue_key`

  to fix this.

## 1.0.0 (2011-09-07)

* initial release.