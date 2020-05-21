## 0.0.6

* Fix an issue where `ActionDispatch::FileHandler` won't be loaded in the event
  that static-rails is serving compiled assets but Rails is not

## 0.0.5

* Add a site option `compile_404_file_path` to specify a file to be used as a
  404 page when serving compiled assets and no file is found

## 0.0.4

* Add a cookie named `_csrf_token` by default to all static site requests, so
  that your static sites can make CSRF-protected requests of your server
  ([#4](https://github.com/testdouble/static-rails/pull/4))

## 0.0.3

* Add `url_skip_paths_starting_with` array of strings option to site
  configuration. Will fall through to the next matching site or all the way to
  the Rails app.

## 0.0.2

* Add `env` hash option to site configuration

## 0.0.1

* Initial release
