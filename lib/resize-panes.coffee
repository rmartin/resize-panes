path = require 'path'

module.exports =
  resizePanel: null

  activate: (@state) ->
    @createView()

  deactivate: ->
    @disposables.dispose()
    @resizePanel?.deactivate()
    @resizePanel = null

  serialize: ->
    if @resizePanel?
      @resizePanel.serialize()
    else
      @state

  createView: ->
    unless @resizePanel?
      ResizePanel = require './resize-panel'
      @resizePanel = new ResizePanel(@state)
    @resizePanel
