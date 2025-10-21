config.load_autoconfig()
config.source('theme.py')

c.fonts.default_family = 'Hack Nerd Font Mono'
c.fonts.default_size   = '11pt'
c.qt.highdpi = True

c.scrolling.smooth = True

c.colors.webpage.preferred_color_scheme = 'dark'
c.auto_save.session = True
c.confirm_quit = ["downloads"]

c.spellcheck.languages = ['en-US']


config.bind('<Ctrl-o>', 'prompt-open-download', mode='prompt')
config.bind('<Ctrl+e>', 'cmd-edit', mode='command')

# Binds for moving through completion items
# config.bind('<Ctrl-n>', 'completion-item-focus next', mode='command')
# config.bind('<Ctrl-p>', 'completion-item-focus prev', mode='command')

config.bind('<Ctrl-w>', 'tab-close')


## Content ##
c.content.pdfjs = True
c.content.autoplay = False

## Downloads ##
c.downloads.position = "bottom"
c.downloads.remove_finished = 300000

## Hints ##
c.hints.leave_on_load = False

## Tabs ##
c.tabs.last_close = "close"
c.tabs.show = "multiple"
c.tabs.max_width = 250


c.url.default_page = "qute://start"
c.url.searchengines = {
  "DEFAULT": "https://duckduckgo.com?q={}",
  "yt":      "https://www.youtube.com/results?search_query={}"
}
