Meetup3
=======

Here is an example project that you can start experimenting with if you don't happen to have any projects of your own you'd like to work on with others.

What I've done to get to this point.

  1. I created a new project like this: `mix new meetup3`
  2. I copied a file under `priv` directory called `top-1m.csv`. This file contains top 1 million hosts on the Internet in CSV format.
  3. I implemented a function `Meetup3.path_to_file/0` that you can use to get the path from which you can read the file.

Idea is that you could start learning Elixir by doing something cool with the data in the CSV file. It is intentionally rather large so you might actually have to think about parallelizing your implementation.

Few ideas what you might do with the data:

  1. Implement a `Mix.Task` or just a function that reads given number of lines from the file and prints them out.
  2. Perform HTTP HEAD request on some/all of the hosts and collect stats on used webservers from the HTTP `Server` header.
  3. Make an HTTP request to the host and track how long it takes for it to respond. Print out results on which host is the fastest.
  4. Figure out some cool idea of your own. ;)

Remember that performing 1 million HTTP requests is rather big task for any system so maybe start with implementing the idea number 1 and work from there.

Here are some useful modules you might want to check out:
  * http://elixir-lang.org/docs/stable/elixir/File.html
  * http://elixir-lang.org/docs/stable/elixir/Stream.html
  * http://elixir-lang.org/docs/stable/elixir/String.html
  * http://elixir-lang.org/docs/stable/elixir/Task.html

For HTTP client I'd suggest you to try out these:
  * https://github.com/edgurgel/httpoison
  * https://github.com/benoitc/hackney

`HTTPoison` is a wapper around great Erlang HTTP library called `hackney`. You can use whichever you please.

Have fun!
