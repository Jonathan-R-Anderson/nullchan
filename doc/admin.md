Administering a Nullchan instance
=================================

This document is meant to be a reference on how to administer a Nullchan instance;
if you want a guide on how to deploy Nullchan, see `deploying.md` for more on that.
This is also not a reference on how to moderate a Nullchan deployment, either; for
that, look at `moderate.md`.


Changing a board's properties
-----------------------------

Navigate to the catalog of the board whose name you want to change and click on the
Admin link in the menu bar. You can then enter a new name for the board, change the
maximum number of allowed threads, as well as change the rules specific to the board.


Updating to a new version of Nullchan
-------------------------------------

For Docker-based deployments, after downloading the new container, run the `update`
command on the Nullchan container, which could either be something like `docker-compose run nullchan update`
if you're using a `docker-compose`-based deployment, or `docker run dangerontheranger/nullchan update` otherwise.
If your deployment does not use Docker, run `update.py` after downloading the latest version of Nullchan.
