_ = require 'underscore-plus'
ResizePaneMouseView = require './resize-pane-mouse-view'

console.log ('yo')

module.exports =
  resizePanel: null

  activate: () ->
    @createMouseView()

  createMouseView: ->
    @resizePaneMouseViews = []

    console.log ('init')

    @paneSubscription = atom.workspace.observePanes (pane) =>
      resizePaneMouseView = new ResizePaneMouseView(pane)

      paneElement = atom.views.getView(pane)
      paneElement.insertBefore(resizePaneMouseView.element, paneElement.lastChild)

      @resizePaneMouseViews.push(resizePaneMouseView)
      pane.onDidDestroy => _.remove(@resizePaneMouseViews, resizePaneMouseView)

  deactivate: ->
    @paneSubscription.dispose()
    resizePaneMouseView.remove() for resizePaneMouseView in @resizePaneMouseViews
