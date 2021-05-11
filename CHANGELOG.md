## 0.1.0

* Add support for Rails 6.1 when CSRF is enabled
* Increase required Ruby to 2.5

## 0.0.14

* HTML & XML won't be cached by default in production
  [#20](https://github.com/testdouble/static-rails/pull/20)

## 0.0.13

* 404 pages served in production via a site's `compile_404_file_path` setting
  will now also send the HTTP status code of 404 instead of 200

## 0.0.12

* Fix an issue in which enabling force_ssl would result in redirects to the
  obfuscated `/_static_rails/` path. Resolved this by placing the static-rails
  middleware after `ActionDispatch::SSL`. Note that this will break if you
  remove `Rack::SendFile` from your app's middleware stack

## 0.0.11

* Inline the `ActionDispatch::FileHandler` from Rails master so that we can
  target a single stable version of its API and control what MIME types it
  considers to be compressible (bonus is that it effectively backports brotli
  compression to pre-6.1 rails apps)

## 0.0.10

* Change default `cache-control` header for static assets being served from disk
  from `no-cache` to `"public; max-age=31536000"`

## 0.0.9

* When using CSRF protection, the artificial path info will now be
  "__static_rails__" instead of a random string, to make logs appear cleaner
* Attempt to guard against future internal changes to Rails' request forgery
  protection by adding `method_missing` that calls through

## 0.0.8

* Add support for the [CSRF
  changes](https://github.com/rails/rails/commit/358ff18975f26e820ea355ec113ffc5228e59af8) in Rails 6.0.3.1

## 0.0.7

* Ensure that CSRF tokens are valid, at the cost of some performance and
  reliance on additional Rails internals. As a result CSRF cookie setting is now
  disabled by default [#6](https://github.com/testdouble/static-rails/pull/6)

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
