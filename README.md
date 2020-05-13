# static-rails

[![CircleCI](https://circleci.com/gh/testdouble/static-rails.svg?style=svg)](https://circleci.com/gh/testdouble/static-rails)

## Build and serve your static sites from your Rails app

**tl;dr in development, static-rails runs your static site generators &
proxies requests; in production, it compiles and serves the final assets**

Static site generators are hot right now. Maybe you're hip with "the
[Jamstack](https://jamstack.org)", or maybe your API documentation is generated
by [Hugo](https://gohugo.io), or maybe your marketing folks use
[Jekyll](https://jekyllrb.com) for the company blog.

Up until now, compiling static assets with any degree of sophistication beyond
dumping them in your app's `public/` directory represented a significant
deviation from the "Rails Way". But the alternative—keeping your static sites
wholly separate from your Rails app—raises myriad operational challenges, from
tracking multiple git repositories, to managing multiple server configurations,
to figuring out a way to share common JavaScript and CSS assets between them
all.

No longer! static-rails lets you use your static asset generators of choice
without forcing you to abandon your monolithic Rails architecture.

Here's what it does:

* In development, static-rails launches your sites' local servers and then
  proxies any requests to wherever you've mounted them in your Rails app so you
  can start a single server and transition work between your static sites and
  Rails app seamlessly

* When deploying, static-rails will compile all your static assets when `rake
  assets:precompile` is run, meaning your assets will be built automatically
  when pushed to a platform like Heroku

* In production, static-rails will serve your sites' compiled assets from disk
  with a similar features and performance to what you're familiar with if you've
  ever hosted files out of your `public/` directory

## Install

Add this to your Gemfile:

```
gem "static-rails"
```

Then run this generator to create a configuration file
`config/initializers/static.rb`:

```
$ rails g static_rails:initializer
```

You can check out the configuration options in the [generated file's
comments]().

Want an example of setting things up? You're in luck, there's an [example
app](/example) right in this repo!

## Configuring the gem

**(Want to dive right in? The generated initializer [enumerates every
option](/lib/generators/templates/static.rb) and the [example app's
config](https://github.com/testdouble/static-rails/blob/master/example/config/initializers/static.rb)
sets up 4 sites.)**

### Top-level configuration

So, what should you stick in your initializer's `StaticRails.config do |config|`
block? These options are set right off the `config` object and control the
overall behavior of the gem itself, across all your static sites:

* **config.proxy_requests** (Default: `!Rails.env.production?`) when true,
  the gem's middleware requests that match where you've mounted your static site
  and proxy them to the development server

* **config.serve_compiled_assets** (Default: `Rails.env.production?`) when true,
  the gem's middleware will find your static assets on disk and serve them using
  the same code that Rails uses to serve files out of `public/`

* **config.ping_server_timeout** (Default: `5`) the number of seconds that (when
  `proxy_requests` is true, that the gem will wait for a response from a static
  site's server on any given request before timing out and raising an error

* **config.set_csrf_token_cookie** (Default: `true`) when true, the gem's
  middleware will set a cookie named `_csrf_token` with each request of your
  static site. You can use this to set the `'x-csrf-token'` header on any
  requests from your site back to routes hosted by the Rails app that are
  [protected from CSRF
  forgery](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)
  (if you're not using Rails' cookie store for sessions, turn this off)

### Configuring your static sites themselves

To tell the gem about your static sites, assign an array of hashes as `sites`
(e.g. `config.sites = [{…}]`). Each of those hashes have the following options:

* **name** (Required) A unique name for the site (primarily used for
  logging)

* **source_dir** (Required) The file path (relative to the Rails app's root) to
  the static site's project directory

* **url_subdomain** (Default: `nil`) Constrains the static site's assets to only
  be served for requests to a given subdomain (e.g. for a Rails app hosting
  `example.com`, a Hugo site at `blog.example.com` would set this to `"blog"`)

* **url_root_path** (Default: `/`) The base URL path at which to mount the
  static site (e.g. if you want your Jekyll site hosted at `example.com/docs`,
  you'd set this to `/docs`). For most static site generators, you'll want to
  configure it to serve assets from the same path so links and other references
  are correct (see below for examples)

* **url_skip_paths_starting_with** (Default: `[]`) If you want to mount your
  static site to `/` but allow the Rails app to serve APIs from `/api`, you can
  set the path prefix `["/api"]` here to tell the gem's middleware not to try to
  proxy or serve the request from your static site, but rather let Rails handle
  it

* **start_server** (Default `!Rails.env.production?) When true, the gem will
  start the site's server (and if it ever exits, restart it) as your Rails app
  is booting up. All output from the server will be forwarded to STDOUT/STDERR

* **server_command** (Required if `start_server` is true) the command to run to
  start the site's server, from the working directory of `source_dir` (e.g.
  `hugo server`)

* **ping_server** (Default: true) if this and `start_server` are both true, then
  wait to proxy any requests until the server is accepting TCP connections

* **env** (Default: `{}`) any environment variables you need to pass to either
  the server or compile commands (e.g. `env: {"BUNDLE_PATH" =>
  "vendor/bundle"}`). Note that this configuration file is Ruby, so if you need
  to provide different env vars based on Rails environment, you have the power
  to do that!

* **server_host** (Default: `localhost`) the host your static site's server will
  run on

* **server_port** (Required if `proxy_requests` is true) the port your static
  site's server will accept requests on

* **server_path** (Default: `"/"`) the root URL path to which requests should be
  proxied

* **compile_comand** (Required) the command to be run by both the
  `static:compile` and `assets:precompile` Rake commands (e.g. `npm run build`),
  with working directory set to the site's `source_dir`

* **compile_dir** (Required when `serve_compiled_assets` is true) the root file
  path to which production assets are compiled, relative to the site's
  `source_dir`

## Configuring your static site generators

Assuming you won't be mounting your static site to your app's root `/` path,
you'll probably need to configure its base URL path somehow. Here are
some tips (and if your tool of choice isn't listed, we'd love a [pull
request](https://github.com/testdouble/static-rails/edit/master/README.md)!):

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

Also, because Hugo will serve `/livereload.js` from the root, live-reloading probably
won't work in development when running through the static-rails proxy.
You might consider disabling it with `--disableLiveReload` unless you're serving
Hugo from a root path ("`/`").

A static-rails config for a Hugo configuration in `sites` might look like:

```rb
  {
    name: "docs",
    url_root_path: "/docs",
    source_dir: "static/docs",
    server_command: "hugo server",
    server_port: 8080,
    compile_command: "hugo",
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
/docs`.

A static-rails config for an Eleventy configuration in `sites` might look like:

```rb
  {
    name: "docs",
    url_root_path: "/docs",
    source_dir: "static/docs",
    server_command: "npx @11ty/eleventy --serve --pathprefix /docs",
    server_port: 8080,
    compile_command: "npx @11ty/eleventy --pathprefix /docs",
    compile_dir: "static/docs/_site"
  }
```

### Using Gatsby

<strong> ⚠️ Gatsby is unlikely to work in development mode, due to [this
issue](https://github.com/gatsbyjs/gatsby/issues/18143), wherein all the assets
are actually served over a socket.io WebSocket channel and not able to be
proxied effectively. ⚠️  </strong>

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

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
