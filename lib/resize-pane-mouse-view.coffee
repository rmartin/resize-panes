path = require 'path'
shell = require 'shell'

{BufferedProcess, CompositeDisposable} = require 'atom'
{$, View} = require 'atom-space-pen-views'
_ = require 'underscore-plus'

toggleConfig = (keyPath) ->
  atom.config.set(keyPath, not atom.config.get(keyPath))


module.exports =
class resizePaneMouseView extends View
  panel: null
  initialPageX = 0


  @content: ->
    @div class: 'resize-panel-handle'

  initialize: (state) ->
    initialPageX = 0
    @handleEvents()

  handleEvents: ->
    $(this).on('mousedown', (e) => @resizeStarted(e));

  resizeStarted: ({pageX, which}) =>
    initialPageX = pageX
    $(document).on('mousemove', @resizePaneMouseView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizePaneMouseView)
    $(document).off('mouseup', @resizeStopped)

  resizePaneMouseView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1
    flex = @getFlex()
    # TODO: calculate the correct offset based on mouse position
    # see: http://codepen.io/pprice/pen/splkc/
    if (pageX > initialPageX)
      flex.grow *= 1.01
      flex.shrink *= 1.01
    else
      flex.grow /= 1.01
      flex.shrink /= 1.01
    @setFlex flex
    initialPageX = pageX


  getFlex: ->
    [grow,shrink,basis] = $('.pane.active').css('-webkit-flex').split ' '
    return {grow,shrink,basis}

  setFlex: ({grow,shrink,basis}) ->
    flex = [grow,shrink,basis].join ' '
    $('.pane.active').css('-webkit-flex', flex)
