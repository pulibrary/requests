require 'borrow_direct'

BorrowDirect::Defaults.html_base_url = 'https://pulsearch.princeton.edu/borrow-direct'
# IN OL this is current set as 'https://borrow-direct.relaisd2d.com/service-proxy/?command=mkauth'
# https://pulsearch.princeton.edu/borrow-direct
# Set a default BD LibrarySymbol for your library
BorrowDirect::Defaults.library_symbol = 'PRINCETON'
BorrowDirect::Defaults.api_base = BorrowDirect::Defaults::PRODUCTION_API_BASE
BorrowDirect::Defaults.api_key = ENV['BD_AUTH_KEY']
BorrowDirect::Defaults.find_item_patron_barcode = ENV['BD_FIND_BARCODE']