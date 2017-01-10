// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

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
    var submit_data = {}; //generic data object to package ajax request submissions

    $( ".table-responsive" ).on( "change", ".request-options", function(event) {
      event.stopPropagation();
      var this_td = $( this ).closest( "td" )
      if($(this)[0].selectedOptions[0].value === 'recall'){
        // enable checkbox?
        $('.alert').hide();
        var recall_pickup_select = this_td.find( ".recall-pickup" );
        var item_inputs = $( this ).closest( "tr" ).find( "input" );
        var bib_inputs =  $('input[name^="bib["]');
        var user_inputs = $('input[name^="request["]');
        // var pickup_pref = $( this ).closest( "td" ).find( "select" );
        // var mfhd_inputs = $('input[name^="mfhd[]["]');

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
             //console.log(opts[i]['@code'] + " : " + opts[i]['$']);
             recall_pickup_select.append($("<option></option>").attr("value",opts[i]['@code']).text(opts[i]['$']));
            }

            recall_pickup_select.show();
            // data['requestable[][type]'] = "recall";
            // data[pickup_pref[0].name] = pickup_pref[0].selectedOptions[0].value;
          } else {
            this_td.append($("<div class='alert alert-danger'></div>").text("Cannot be recalled because: " + msg.response.recall.note['$']));
          }
          //data = {}; // clear data for submission step
        });
      } else {
        $('.alert').hide();
        if(recall_pickup_select){
          recall_pickup_select.hide();
        }
        if($(this)[0].selectedOptions[0].value === 'bd'){
          // uncheck and disable checkbox?
          var item_title = $('#bib_title').val();
          this_td.append($("<div class='alert alert-warning'></div>").html("Due to the nature of this service, you must use the <a href='http://libserv51.princeton.edu/bd.link/link.to.bd.php?ti=" + item_title + "' target='_blank'>the BorrowDirect system interface</a> to request this item."));
        }
        if($(this)[0].selectedOptions[0].value === 'ill'){
          // uncheck and disable checkbox?
          this_td.append($("<div class='alert alert-warning'></div>").html("Due to the nature of this service, you must use the <a href='https://library.princeton.edu/services/interlibrary-services' target='_blank'>the InterLibrary Loan system interface</a> to request this item."));
        }
      }
    });


});
