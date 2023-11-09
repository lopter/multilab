Schwab (USA) plugin for ofxstatement
====================================

This is a plugin for ofxstatement_. It will allow you to convert CSV exports
from the Charles Schwab website into OFX files that can be easily imported into
accounting tools such as GnuCash_.

Requirements
------------

- Python ≥ 3.6.

Configuration
-------------

Configure an account using this plugin with ``ofxstatement edit-config``::

   [us:schwab:checking]
   plugin = us-schwab
   # Please adjust locale for your operating system, see explanation below.
   locale = en_US.US-ASCII
   routing_number = 1234
   account_number = 4567
   account_type = CHECKING

You'll want to make sure that ``locale`` is appropriate for your operating
system, as far as I can tell, Charles Schwab produces ASCII files and numbers
area only positive like "$1234.56". Some good values:

- GNU/Linux: ``en_US.ansix341968``;
- mac OS: ``en_US.US-ASCII``.

.. vim: set ft=rst spelllang=en spell tw=80 expandtab:
