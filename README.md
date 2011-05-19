Copy is a Sinatra-based content management system.
##################################################

Copy automatically maps URLs to files.

`/` &rarr; `index.html.erb`
`/about` &rarr; `about.html.erb` or `about/index.html.erb`
`/about/us` &rarr; `about/us.html.erb`

Copy lets you define blocks of editable text.

```
<% copy :contact do %>
  1 Infinite Loop
  Cupertino, CA 95014
  408.996.1010
<% end %>
```

The text provided in the block will be saved and can then be edited live on the site. All content is formatted with Markdown. [See demo](http://copy-demo.heroku.com).

---

### Installation

`$ gem install copy` and then generate a new site `$ copy -n mynewsite`

----

### Storage

Copy supports multiple backends for storage: redis, mongodb, mysql, postgres, and sqlite.

Choosing and configuring your storage option is done in one line in your `config.ru` file by providing a connection URI.

Examples: `set :storage, 'mongodb://user:pass@host:port/database'`, `set :storage, 'postgres://user:pass@host/database'`

----

&copy; 2011 Javan Makhmali