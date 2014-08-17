$ ->
  updateForm = ->
    if $('#supporter_is_custom').prop('checked')
      $('.custom_form').show()
      $('.supporter_email label').text('* Your email')
      $('.submit').val('Create a custom Code of Conduct')
    else
      $('.custom_form').hide()
      $('.supporter_email label').text('* Your email (won\'t be published)')
      $('.submit').val('Sign the Code of Conduct')


  $('#supporter_is_custom').bind 'change', ->
    updateForm()

  updateForm()
