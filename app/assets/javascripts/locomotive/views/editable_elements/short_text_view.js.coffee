Locomotive.Views.EditableElements ||= {}

class Locomotive.Views.EditableElements.ShortTextView extends Backbone.View

  tagName: 'li'

  className: 'text input html'

  render: ->
    $(@el).html(ich.editable_text_input(@model.toJSON()))

    return @

  after_render: ->
    settings = _.extend {}, @tinymce_settings(),
      onchange_callback: (editor) =>
        console.log('content changed !!!! (' + @model.cid + '), ' + editor.getBody().innerHTML)
        console.log(@model)
        @model.set(content: editor.getBody().innerHTML)

    console.log('here ?')

    window.a = @$('textarea')
    window.b = settings

    @$('textarea').tinymce(settings)

  tinymce_settings: ->
    window.Locomotive.tinyMCE.minimalSettings

  refresh: ->
    # do nothing

  remove: ->
    @$('textarea').tinymce().destroy()
    super