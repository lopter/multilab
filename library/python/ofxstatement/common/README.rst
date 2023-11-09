ofxstatement-common
===================

This package host some utility functions that I have found useful while writing
a few ofxstatement_ plugins:

- ofxstatement-us-hsbc_;
- ofxstatement-us-schwab_;
- ofxstatement-us-capitalone_.

.. _ofxstatement: https://github.com/kedder/ofxstatement
.. _ofxstatement-us-hsbc:
.. _ofxstatement-us-schwab:
.. _ofxstatement-us-capitalone:

Function index
--------------

Everything is under the ``x.ofxstatement.plugins.common`` namespace:

- ``spawn_debugger_on_exception``: this context manager will automatically
  start ``pdb`` if an unhandled exception is raised;
- ``locale.validate``: raises an exception if its argument doesn't look like a
  locale in the format ``lang.encoding``;
- ``locale.parse_amount``: parses a monetary amount according to the given
  locale and returns a ``Decimal``.

.. vim: set ft=rst spelllang=en spell tw=80 expandtab:
