# static-rails

A gem to support integrating one or more static sites with your Rails
application.

## Install

Add this to the Gemfile of your Rails app:

```
gem "static-rails"
```

And run this to generate an initializer in which to configure your static sites:

```
$ rails g static_rails:initializer
```

This will create an documented configuration file in
`config/initializers/static.rb`

Once installed, any `config.sites` you specify will be handled by static-rails
in the following way, by default:

* In `development` and `test`, static-rails will start each site's
  `serve_command` and proxy any requests to the Rails server that match the
  `url_subdomain` and `url_root_path` to that server

* When running `rake assets:precompile` (typically performed during a deploy),
  static-rails will run the `compile_command` for each configured site

* In `production`, static-rails will use `Rack::Static` to map any requests to
  the Rails server that match the site's `url_subdomain` and `url_root_path`
  settings

For examples on how to configure your static site, read on!

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

If you are mounting your [Hugo](https://gohugo.io) app to anything but the root
path, you'll need to specify that path in the `baseURL` of your root
`config.toml` file, like so:

```toml
baseURL = "http://blog.example.com/docs"
```

Additionally, getting Hugo to play nicely when being proxied by your Rails
server in development and test can be a little tricky, because most themes will
render fully-qualified URLs into markup when running the `hugo server` command.
That means if you're forwarding `http://blog.localhost:3000/docs` to a Hugo
server running on `http://localhost:1313`, it's very likely the static files
(e.g. all the links on the page) will have references to
`http://localhost:1313`, which may result in accidentally navigating away from
your Rails development server unexpectedly.

To mitigate this, there are a few things you can do:

* Favor `.RelPermalink` in your templates over `.Permalink` where possible.
* In place of referring to `{{.Site.BaseURL}}` in your templates, generate a
  base path with `{{ "/" | relURL }}` (given the above `baseURL`, this will
  render `"/marketing/"`)

A static-rails config for a Hugo configuration in `sites` might look like:

```rb
  {
    name: "docs",
    url_root_path: "/docs",
    source_dir: "static/docs",
    server_command: "hugo server",
    server_port: 8080,
    compile_command: "hugo",
    compile_command: "npx @11ty/eleventy --pathprefix docs",
    compile_dir: "static/docs/public"
  }
```

### Using Eleventy

If you are mounting your [Eleventy](https://www.11ty.dev) app to anything but
the root path, you'll want to configure a path prefix in `.eleventy.js`

```js
module.exports = {
  pathPrefix: "/docs/"
}
```

Alternatively, you can specify this from the command line with `--pathprefix
docs`.

A static-rails config for an Eleventy configuration in `sites` might look like:

```rb
  {
    name: "docs",
    url_root_path: "/docs",
    source_dir: "static/docs",
    server_command: "npx @11ty/eleventy --serve --pathprefix docs",
    server_port: 8080,
    compile_command: "npx @11ty/eleventy --pathprefix docs",
    compile_dir: "static/docs/_site"
  }
```

### Using Gatsby

** ⚠️ Gatsby is unlikely to work in development mode, due to [this
issue](https://github.com/gatsbyjs/gatsby/issues/18143), wherein all the assets
are actually served over a socket.io WebSocket channel and not able to be
proxied effectively. ⚠️  **

If you're mounting a [Gatsby](https://www.gatsbyjs.org) site to a non-root path
(e.g. in static-rails, you've configured its `url_root_path` to, say,
`careers`), then you'll want to configure the same root path in Gatsby as well,
so that its development servers and built assets line up correctly.

To do this, first add the `pathPrefix` property to `gatsby-config.js`:

```js
module.exports = {
  pathPrefix: `/careers`,
  // …
}
```

Next, add the flag `--prefix-paths` to both the Gatsby site's `server_command`
and `compile_command`, or else the setting will be ignored.

A static-rails config for a Gatsby configuration in `sites` might look like:

```rb
  {
    name: "gatsby",
    url_root_path: "/docs",
    source_dir: "static/docs",
    server_command: "npx gatsby develop --prefix-paths",
    server_port: 8000,
    compile_command: "npx gatsby build --prefix-paths",
    compile_dir: "static/docs/public"
  },
```
