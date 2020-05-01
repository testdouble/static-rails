# static-rails

[![CircleCI](https://circleci.com/gh/testdouble/static-rails.svg?style=svg)](https://circleci.com/gh/testdouble/static-rails)

## What is this thing?

**tl;dr** in development, static-rails runs your static site generators; in
production, it serves the assets they compile

Static site generators are hot right now. Maybe you're hip with "the
[Jamstack](https://jamstack.org)", or maybe your API documentation is generated
by [Hugo](https://gohugo.io), or maybe your marketing folks are all using
[Jekyll](https://jekyllrb.com) for the company blog.

Up until now, compiling static assets with any degree of sophistication beyond
dumping them in your app's `public/` directory represented a significant
deviation from the "Rails Way". But the alternative—keeping your static pages
entirely separate from your Rails app—raises myriad operational challenges, from
tracking multiple git repositories, to managing multiple server configurations,
and figuring out a way to share common JavaScript and CSS assets.

But we are no longer constrained by that old choice, because now we have the
static-rails gem! Finally, you can have our Rails app and static sites in one
place with a minimal amount of pain.

Here's what it does:

* In `development` and `test` environments, the gem will run launch each site's
  `serve_command` and proxy any requests to the Rails server that match the
  `url_subdomain` and `url_root_path` you want to mount it at

* When you run `rake assets:precompile` (typically performed during a deploy),
  it will run the `compile_command` you've configured for each site

* In `production`, the gem will host each of your sites' compiled assets at the
  same subdomain and path you've configured, using the same middleware that
  Rails uses to host your `public/` assets. (Putting a performant CDN in
  front of them remains an exercise to the reader.)

## Install

Add this to the Gemfile of your Rails app:

```
gem "static-rails"
```

Then run this generator to create a configuration file in
`config/initializers/static.rb`:

```
$ rails g static_rails:initializer
```

## Configuring the gem

Once installed, any `config.sites` you specify will be handled by static-rails
in the following way, by default:

## Configuring your static site generators

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

Also, because Hugo will serve `/livereload.js` from the root, it probably won't
work in development when running through the static-rails proxy in development.
You might consider disabling it with `--disableLiveReload`.

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

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.
