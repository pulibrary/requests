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

    // Submit Recall requests independently of requests _form partial
    $( ".table-responsive" ).on( "click", ".recall-request", function() {

      var item_inputs = $( this ).closest( "tr" ).find( "input" );
      var bib_inputs =  $('input[name^="bib["]');
      var user_inputs = $('input[name^="request["]');
      var pickup_pref = $( this ).closest( "td" ).find( "select" );
      // var mfhd_inputs = $('input[name^="mfhd[]["]');

      var inputs = $.merge( $.merge( item_inputs, bib_inputs ), user_inputs );
      var data = {};

      $.each( inputs, function( key ) {
        data[inputs[key].name] = inputs[key].value;
      });
      data['requestable[][type]'] = "recall";
      data[pickup_pref[0].name] = pickup_pref[0].selectedOptions[0].value;

      $.ajax({
        method: "POST",
        url: "/requests/submit",
        data: data
      })
      .done(function( msg ) {
        console.log( "Done: " + msg );
      });

    });


});
