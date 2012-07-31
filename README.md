# Demo of Live Streaming in Rails 4

This repo is the result of following [Aaron Patterson's tutorial](http://tenderlovemaking.com/2012/07/30/is-it-live.html) for playing with Live Streaming in Rails 4 (edge).

Every aspect of Rails is frozen in vendor/cache, so this demo should always work even if Rails 4 changes.

## Usage

In one terminal, start the Rails app in development mode:

```
puma
```

Go to [http://localhost:9292/users](http://localhost:9292/users) to see the application.

Change any file under `app/assets` or `app/views`, a message should be sent to the browser, and the browser will refresh the page.

