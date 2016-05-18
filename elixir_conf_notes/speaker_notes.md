# Chat Bot: A Practical Walkthrough of the Powerful Features of Erlang/Elixir/OTP

I know what you're thinking, "OMG, that is the longest. title. ever. I'm already
bored."

# Beware: Live Demos
Don't worry. I have live demos ahead, and those *never* go wrong.

# Why did I do this?
I'm a beginner with Erlang and Elixir. 
I understood the mechanics of how to use various aspects, did not have the 
visceral understanding of when to migrate from one to another, which pain it's
alleviating.
I needed a non-trival project that as it expanded would necessitate redesign
and refactoring, incorporating the things I had learned, but not internalized.
So I made a thing. A thing I knew would be bad, well, sub-optimal, at first.
Almost no books and tutorials follow this path.
Only after I had started down this path (and submitted the conf proposal) did
I start Sasa's Elixir in Action. So if you like my talk, read Sasa's book, he
does it far better.
Oh, also, at work we use a fork of Hubot. Regardless of whatever my feelings of
Node, whenever there's a problem with additional functionality, the entire bot
dies a fiery death rather than just the bit of new functionality. It's a
situation just begging for the concurrency and isolation of Erlang.

# 
When I think about idiomatic Erlang or Elixir, a few things come to mind as
strategic advantages.
 1) Supervision
 2) Live Code Update
 3) Clustering

# Supervision 
It's not a "real" app unless it has a supervision tree. So this was the first
one that OhaiBot had.

```
<insert graphic here>
```

It worked ok. If I had a problem with a bot and it crashed, bot restarted.
Storing state (like for karma) separate from logic, so it persists if a logic
problem exists.
  
Where it breaks down: errors from the underlying IRC library

I could not have done this project without Paul Schoenfelder (bitwalker on
github)'s exirc library, but I noticed that when I run on a flaky connection,
like my laptop, opening/closing, moving from wireless AP to wired connection,
etc, the exirc doesn't handle it very well, and I basically have to restart
the client connection in the library to get it to reconnect.

The exirc client has a reference to each one of the bots (exirc calls them
handlers). The handlers/bots call the exirc client via a registered process, so
that at least handles restarts/failures fairly gracefully, but the new exirc
client will require each handler to reregister itself with the new client 
process.

A few options:
 1) stop running an irc bot from laptop (done) 
 2) fix reconnect logic in exirc
 3) restructure supervision trees, exirc client death fixes itself (done)

You can't have multiple restart strategies in a single supervisor, so my
resulting supervision tree now looks like this.

```
<insert graphic here
```

I also am now using something other than `one_for_one`, because whenever the
client restarts, I need to restart all the bots so that they'll automatically
reregister themselves with the new client process as handlers. (There's
probably a more elegant / better way to do this, but this was, for me, the path
of least resistence.) So, I'm using `one_for_all` for this portion of the
subtree, for the individual bots though, I'm back to `one_for_one`.


