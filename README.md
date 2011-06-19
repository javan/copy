# Copy is a simple, Sinatra-based CMS (Copy Management System).

`$ gem install copy` and then generate a new site `$ copy -n mynewsite`

    mynewsite/
    ├── Gemfile              <- Uncomment the gems you need for storage.
    ├── config.ru            <- Configure storage, user, and password here.
    ├── public               <- The public root of your new site.
    │   ├── favicon.ico      <- A blank favicon, replace with your own.
    │   ├── images
    │   ├── javascripts
    │   │   └── main.js      <- A good place for your basic scripts.
    │   ├── robots.txt       <- Read file for details.
    │   └── stylesheets
    │       └── main.css     <- Toss some CSS styles in here.
    └── views                <- Your views, layouts, and partials live here.
        ├── index.html.erb
        └── layout.html.erb  <- Optional global layout file.
        
Copy automatically maps URLs to files in your `views` directory.

* `/` &rarr; `index.html.erb`
* `/about` &rarr; `about.html.erb` or `about/index.html.erb`
* `/about/us` &rarr; `about/us.html.erb`

Copy lets you define blocks of editable text in your views.

    <% copy :contact do %>
      1 _Infinite_ Loop
      Cupertino, CA 95014
      408.996.1010
    <% end %>

The text provided in the block will be saved and can then be edited live on the site. All content is formatted with Markdown. [See demo](http://copy-demo.heroku.com) for a live example or [view the source](https://github.com/javan/copy-demo).

Single line blocks will be edited in a text field as opposed to a textarea. Perfect for headlines.

    <h1><% copy :title do %>Like a boss!<% end %></h1>

**Partials** can be rendered from any view with the `partial` helper. Their filenames are always prefixed with an underscore.

* `<%= partial 'nav' %>` renders `_nav.html.erb`
* `<%= partial 'shared/details' %>` renders `shared/_details.html.erb`

----

### Storage

Copy supports multiple backends for storage: redis, mongodb, mysql, postgres, and sqlite.

Choosing and configuring your storage option is done in one line in your `config.ru` file by providing a connection URI.

Examples:

* `set :storage, 'mongodb://user:pass@host:port/database'`
* `set :storage, 'postgres://user:pass@host/database'`

----

### Editing copy on your live site

Browse to `/_copy` and drag the "Edit Copy" link to your bookmarks bar. Return to your site, click the bookmark (you'll be prompted for your username and password) and then click on the highlighted text to edit it. That's it!

----

[![Build Status](http://travis-ci.org/javan/copy.png)](http://travis-ci.org/javan/copy) &mdash; &copy; 2011 Javan Makhmali