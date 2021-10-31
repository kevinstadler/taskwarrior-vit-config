theme = [
#Name of the display attribute, typically a string
#Foreground color and settings for 16-color (normal) mode
#Background color for normal mode
#Settings for monochrome mode (optional)
#Foreground color and settings for 88 and 256-color modes (optional, see next example)
#Background color for 88 and 256-color modes (optional)
# for terms check: http://urwid.org/manual/displayattributes.html#standard-foreground-colors
    ('list-header', '', '', '', '', ''),
    ('list-header-column', 'black', 'light gray', '', 'black,bold', 'light gray'),
    ('list-header-column-separator', 'black', 'light gray', '', 'black', 'light gray'),
    ('striped-table-row', 'white', 'dark gray', '', 'white', 'g27'),
    ('reveal focus', 'black', 'dark cyan', 'standout', 'white', 'g20'),
    ('message status', 'white', 'dark blue', 'standout', 'white', 'dark blue'),
    ('message error', 'white', 'dark red', 'standout', 'white', 'dark red'),
    ('status', 'dark magenta', 'black', '', 'g40', 'black'),
    ('flash off', 'black', 'black', 'standout', 'black', 'black'),
    ('flash on', 'white', 'black', 'standout', 'white', 'black'),
    ('pop_up', 'white', 'black', '', 'white', 'black'),
    ('button action', 'white', 'light red', '', 'white', 'light red'),
    ('button cancel', 'black', 'light gray', '', 'black', 'light gray'),
]
