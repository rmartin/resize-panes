path = require 'path'
shell = require 'shell'
{BufferedProcess, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'

toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))


module.exports =
class resizePaneMouseView extends View
  panel: null
  treeViewWidth = 0
  editorPaneWidth = 0
  editorPaneOriginX = 0

  @content: ->
    @div class: 'resize-panel-handle'

  initialize: (panel) ->
    this.panel = panel
    @handleEvents()

  handleEvents: ->
    $(this).on('mousedown', (e) => @resizeStarted(e));

  resizeStarted: ({pageX, which}) =>
    treeViewWidth = $('.tree-view-scroller').outerWidth()
    editorPaneWidth = $(this.panel).width()
    editorPaneOriginX = pageX
    $(document).on('mousemove', @resizePaneMouseView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizePaneMouseView)
    $(document).off('mouseup', @resizeStopped)

  resizePaneMouseView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1
    flexResizePercentage = (editorPaneWidth + (pageX - editorPaneOriginX)).toString();
    $(this.panel).css('flex', '0 1 ' + flexResizePercentage + 'px')
