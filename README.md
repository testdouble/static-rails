# static-rails

A gem to support integrating one or more static sites with your Rails
application.

## Install

Add this to your Gemfile:

```
gem "static-rails"
```

And run this to generate an initializer in which to configure your static sites:

```
$ rails g static_rails:initializer
```


## Configuring your static site generator

### Using Jekyll

If you have a Jekyll app that you plan on serving from a non-root path (say,
`/docs`), then you'll need to set the `baseurl` in `_config.yml`:

```yml
baseurl: "/docs"
```

(Note that this means running the Jekyll application directly using `bundle exec
jekyll serve` will also start serving at `http://127.0.0.1:4000/docs/`)

### Using Hugo

Hugo can be a little tricky, because by the `.Permalink` value will always
include a fully qualified protocol, host, and port, even for development mode.
That means if you're forwarding `http://blog.localhost:3000` to a Hugo server
running on `http://localhost:1313`, it's very likely the static files (e.g. all
the links on the page) will have references to `http://localhost:1313`, which
may result in accidentally navigating away from your Rails development server
unexpectedly.

One way to mitigate this is to favor `.RelPermalink` in your templates over
`.Permalink` where possible.

