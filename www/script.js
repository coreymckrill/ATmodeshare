// Make the whole FAQ box header clickable for expanding/collapsing the box
shinyjs.init = function() {
    $('#shiny-tab-faq').on('click', '.box-info', function(event) {
        event.stopPropagation();
        $(event.currentTarget).find('.box-body, .box-footer').toggle();
    })
}
