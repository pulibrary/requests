// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    $( "#returnToRecordLink" ).click(function( event ) {
      event.preventDefault();
      location.href= document.referrer;
    });

    // Enhance the Bootstrap collapse utility to toggle hide/show for other options
    $('input[type=radio][name^="requestable[][delivery_mode"]').change(function() {
        // collapse others
        $("input[name='" + this.name + "']").each(function( index ) {
          var target = $(this).attr('data-target');
          $(target).collapse('hide');
        });
        // open target
        var target = $(this).attr('data-target');
        $(target).collapse('show');

    });

    var data = {}; //generic data object to package ajax pickup locations request

    $( ".table-responsive" ).on( "change", ".request-options", function(event) {
      event.stopPropagation();
      var this_td = $( this ).closest( "td" );
      var recall_pickup_select = this_td.find( ".recall-pickup" );
      var chbx =  $( this ).closest( "tr" ).find( "input:checkbox" );

      if($(this)[0].selectedOptions[0].value === 'recall'){

        chbx.prop("disabled", false);
        $('.submit--request').prop("disabled", false);
        $('.alert').hide();
        recall_pickup_select.show();

        // don't keep hitting the service if the pickup locs are populated
        if(recall_pickup_select.find('option').length == 1){
          var item_inputs = $( this ).closest( "tr" ).find( "input" );
          var bib_inputs =  $('input[name^="bib["]');
          var user_inputs = $('input[name^="request["]');

          var inputs = $.merge( $.merge( item_inputs, bib_inputs ), user_inputs );

          $.each( inputs, function( key ) {
            data[inputs[key].name] = inputs[key].value;
          });

          $.ajax({
            method: "POST",
            url: "/requests/recall_pickups",
            data: data
          })
          .done(function( msg ) {
            if(msg.response.recall['@allowed'] == 'Y'){
              var opts = msg.response.recall['pickup-locations']['pickup-location'];
              var length = opts.length;

              for ( i=0; i < length; i++) {
               recall_pickup_select.append($("<option></option>").attr("value",opts[i]['@code'] + '|' + opts[i]['$']).text(opts[i]['$']));
              }
            } else {
              recall_pickup_select.hide();
              this_td.append($("<div class='alert alert-danger'></div>").text("Cannot be recalled because: " + msg.response.recall.note['$']));
            }
          });
        }
      } else {
        $('.alert').hide();
        chbx.prop("disabled", true);
        chbx.prop("checked", false);
        $('.submit--request').prop("disabled", true);

        if(recall_pickup_select.is(':visible')){
          recall_pickup_select.hide();
        }
        if($(this)[0].selectedOptions[0].value === 'bd'){
          var item_title = $('#bib_title').val();
          this_td.append($("<div class='alert alert-warning'></div>").html("We could not automatically locate a direct match for this item in BorrowDirect, but you can <a href='http://libserv51.princeton.edu/bd.link/link.to.bd.php?ti=" + item_title + "' target='_blank'>manually check for other editions</a> that may be useful. Checkout period is 12 weeks, with no renewals."));
        }
        if($(this)[0].selectedOptions[0].value === 'ill'){
          var ctx = this_td.find('.ill-data').attr('data-ill-url')
          this_td.append($("<div class='alert alert-warning'></div>").html("Due to the nature of this service, you must use the <a href='"+ ctx +"' target='_blank'>the InterLibrary Loan system interface</a> to request this item."));
        }
      }
    });


});
