require 'borrow_direct'

# For use by clients that want to generate valid BD URLs that pass through PUL Auth
BorrowDirect::Defaults.html_base_url = 'https://catalog.princeton.edu/borrow-direct'
# Set Relais base URL as a constant for internal use
RELAIS_BASE = 'https://borrow-direct.relaisd2d.com/service-proxy/?command=mkauth'.freeze
# PUL Code in Borrow Direct
BorrowDirect::Defaults.library_symbol = 'PRINCETON'
BorrowDirect::Defaults.api_base = 'https://bdtest.relais-host.com' # BorrowDirect::Defaults::TEST_API_BASE
BorrowDirect::Defaults.api_key = ENV['BD_AUTH_KEY']
BorrowDirect::Defaults.find_item_patron_barcode = ENV['BD_FIND_BARCODE']
