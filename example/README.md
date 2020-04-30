# static-rails-example

This example uses the static-rails gem to host static content sites in dev/test,
build them for production along with your other assets during
`assets:precompile` and, when necessary, route traffic to those assets using
`Rack::Static`

See it in action in local development & test:

1. Install Ruby & [hugo](https://gohugo.io/getting-started/installing/)
2. `cd static/docs && bundle` to install and build the Jekyll app
3. Add  this line to your system's `/etc/hosts` file: `127.0.0.1
   blog.localhost`
4. In this project's root directory run `bundle && bin/rails s` and then visit
   [http://localhost:3000/docs](localhost:3000/docs) to see the Jekyll app
   forwarded and [http://blog.localhost:3000](blog.localhost:3000) to see
   requests forward to Rails

To see how this is configured, check out
[config/initializers/static.rb](config/initializers/static.rb).

See how things would look in production:

1. Run `bin/rake assets:precompile`
2. Inspect the built assets in `static/docs/_site` and `static/blog/public`
3. Run `RAILS_ENV=production bin/rails s` and note that assets are served out of
   [http://localhost:3000/docs](localhost:3000/docs) and
   [http://blog.localhost:3000](blog.localhost:3000), just like they are in
   development (but with this time, from static files, not via those tool's
   development servers)

