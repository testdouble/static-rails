# static-rails-example

This example uses the static-rails gem. To see how this is all configured, check
out [config/initializers/static.rb](config/initializers/static.rb).

## Development mode

See it in action in local development

1. Install Ruby & [hugo](https://gohugo.io/getting-started/installing/)
2. `cd static/docs && bundle` to set up the Jekyll app
3. `cd static/blog-docs && npm install` to set up the Eleventy app
4. Add  this line to your system's `/etc/hosts` file: `127.0.0.1         blog.localhost`
5. In this project's root directory run `bundle && bin/rails s`
6. Visit any of the static sites within:
    * A Jekyll site at [http://localhost:3000/docs](localhost:3000/docs)
    * A Hugo site at [http://blog.localhost:3000](blog.localhost:3000)
    * An Eleventy site at [http://blog.localhost:3000/docs](blog.localhost:3000/docs)
    * A Hugo site at [http://localhost:3000](localhost:3000/marketing)

## Production mode

See how things would look in production:

1. Run `bin/rake assets:precompile`
2. Inspect the built assets in
    * `static/docs/_site`
    * `static/blog/public`
    * `static/blog-docs/_site`
    * `static/marketing/public`
3. Run `RAILS_ENV=production bin/rails s` and verify the above URLs serve the
   production assets without running any dev servers

## Running tests

This app also includes a Cypress test (via our
[cypress-rails](https://github.com/testdouble/cypress-rails) gem).

Run it with:

```
$ ./script/test
```

You can check out the [CI build
output](https://circleci.com/gh/testdouble/static-rails), too.
