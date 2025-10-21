config.load_autoconfig()
config.source('theme.py')

c.qt.highdpi = True

## Scrolling
c.scrolling.smooth = True

## Content ##
c.content.pdfjs = True
c.content.autoplay = False

## Downloads ##
c.downloads.position = "bottom"
c.downloads.remove_finished = 300000

## Hints ##
c.hints.leave_on_load = False

## Tabs ##
c.tabs.position = "left"
c.tabs.last_close = "close"
c.tabs.show = "multiple"
c.tabs.max_width = 250

## URLs ##
c.url.default_page = "qute://start"
c.url.searchengines = {
  "DEFAULT": "https://duckduckgo.com?q={}",
  "yt":      "https://www.youtube.com/results?search_query={}"
}

## Misc ##
c.confirm_quit = ["downloads"]
c.auto_save.session = True

config.bind('<Ctrl-o>', 'prompt-open-download', mode='prompt')
config.bind('<Ctrl+e>', 'cmd-edit', mode='command')
config.bind('<Ctrl-w>', 'tab-close')
