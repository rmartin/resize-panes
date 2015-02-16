_ = require 'underscore-plus'
ResizePaneView = require './resize-pane-view'
{$, View} = require 'atom-space-pen-views'
# include event-kit as a dependency if you want to use this
{CompositeDisposable} = require 'event-kit'

module.exports =
  isFirstLoad: true
  resizePaneViews: []

  activate: () ->
    @subscriptions = new CompositeDisposable

    # TODO: refactor this to use non-depreciated view
    @subscriptions.add atom.workspaceView.eachPaneView (pane) =>
      if @isFirstLoad then return
      @insertResizePanes()

    @subscriptions.add atom.workspace.observePanes (pane) =>

      # TODO: refactor this to prevent forcing the view to be removed (pane-axis job)
      pane.onDidDestroy =>

        debugger

        view = atom.views.getView(pane)
        view.remove()
        @removeResizePanes()
        @insertResizePanes()

    @isFirstLoad = false

  getEditorPanes: ->
    return $('.pane')

  # Determine if the pane already has a resize pane
  hasResizePane: (paneElement) ->
    paneElement? and paneElement.nextElementSibling? and paneElement.nextElementSibling.attributes.class.value is 'resize-pane-handle'

  # Insert resize pane for current view. Excluded when only one pane or last pane(s) on the right
  insertResizePane: (paneElement) ->
    editorPanes = @getEditorPanes()

    # Return if resize pane already exists
    if @hasResizePane(paneElement)
      return

    # console.log editorPanes
    # If there is only one pane, nothing to do
    # if editorPanes.length <= 1
      # return

    resizePaneView = new ResizePaneView(paneElement)
    $(resizePaneView).insertAfter(paneElement)
    @resizePaneViews.push(resizePaneView)

  # Insert resize panes for all views. Excluded when only one pane or last pane(s) on the right
  insertResizePanes: ->
    editorPanes = @getEditorPanes()
    # Loop through all panes and add a resize container (except last pane column).
    # Keep track of all panes in array to avoid search for them for removal
    editorPanes.each (i,pane) =>
      @insertResizePane(pane)

  # Remove all resize panes present in the view
  removeResizePanes: ->
    editorPanes = @getEditorPanes()
    editorPanes.each (i,elm) =>
      $(elm).attr('style','')

    _.each @resizePaneViews, (resizePaneView) ->
      resizePaneView.destroy();
    @resizePaneViews = []

  # Clean-up when destorying views
  deactivate: ->
    @removeResizePanes()
    # @didDestoryPaneSub.dispose()
    # @willDestorySub.dispose()
    @subscriptions.dispose()
    # @didDestoryPaneSub.dispose()
