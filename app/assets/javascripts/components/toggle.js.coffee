$(document).ready ->
  _.each $('.toggle'), (el)->
    link = $(el)
    trigger = link.data('toggle-trigger') || 'click'

    link.on trigger, (e)->
      e.preventDefault()

      linkTarget = $( link.data 'toggle-target' )
      linkTarget.toggle()

      textTarget = $( link.data 'toggle-text-node') || link
      if linkTarget.css('display') == 'none'
        textTarget.text link.data('toggle-show-text') || 'show'
      else
        textTarget.text link.data('toggle-hide-text') || 'hide'
