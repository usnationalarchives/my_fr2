$(document).ready(function () {
    var commentButton = $('#start_comment.how_to_comment');
    if (commentButton.length > 0) {
      if($('#addresses').length === 0) {
        if ($('#further-info').length === 0) {
          commentButton.remove();
        } else {
          commentButton.attr('href', '#further-info');
        }
      }
    }

    $('div.article[data-internal-id]').each(function () {
        var id = $(this).attr('data-internal-id');
        $.ajax({
            url: '/articles/views',
            type: 'POST',
            data: {
                'id': id,
                'referer': document.referrer
            }
        });
    });

   function PrintViewManager() {
      var screen_sheets = $("head link[media=screen]");
      var print_sheets = $("head link[media=print]");
      this.enter = function(){
        screen_sheets.attr("media", "none");
        print_sheets.attr("media", "all");
        $("body").addClass("print_view");
      };
      this.exit = function(){
        if( $("body").hasClass("print_view") ){
          screen_sheets.attr("media", "screen");
          print_sheets.attr("media", "print");
          $("body").removeClass("print_view");
        }
      };
    }
    var print_view_manager = new PrintViewManager();

    if( $("#entries").length > 0 ){
      $(window).bind('hashchange', function(){
        if (location.hash === "#print_view") {
          print_view_manager.enter();
        } else {
          print_view_manager.exit();
        }
      }).trigger('hashchange');
    }

    var citation_modal_template;
    if ( $("#select-cfr-citation-template").length > 0 ) {
      citation_modal_template = Handlebars.compile($("#select-cfr-citation-template").html());
    }

    function display_cfr_modal(title, html) {
      if ($('#cfr_citation_modal').length === 0) {
          $('body').append('<div id="cfr_citation_modal"/>');
      }
      $('#cfr_citation_modal').html(
        [
        '<a href="#" class="jqmClose">Close</a>',
        '<h3 class="title_bar">' + title + '</h3>',
        html
        ].join("\n")
      );
      $('#cfr_citation_modal').jqm({
          modal: true,
          onShow: function(hash) {
                    closeOnEscape(hash);
                    hash.w.show();
                  }
      });
      $('#cfr_citation_modal').jqmShow().centerScreen();
    }


    // cfr citation modal
    $('a.cfr.external').bind('click', function(event) {
      var link = $(this);
      var cfr_url = link.attr('href');

      if( cfr_url.match(/^\//) ) {
        event.preventDefault();

        $.ajax({
          url: cfr_url,
          dataType: 'json',
          success: function(response) {
            var cfr_html = citation_modal_template(response);
            display_cfr_modal('External CFR Selection', cfr_html);
          }
        });
      }
    });
});
