// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function() {

    function isEmail(email) {
      var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;
      return regex.test(email);
    }

    $( "form#logins" ).submit(function( event ) {
      if ( !isEmail($( "#request_email" ).val()) ) {
        event.preventDefault();
        $( "#request_email" ).css("background-color","#f2dede");
        $( "span.error-email").css("color", "red");
        $( "span.error-email").text("Please supply a valid email address.");
      } else {
        $( "#request_email" ).css("background-color","#ffffff");
        $( "span.error-email").text("");
      }
      if ($.trim($('#request_user_name').val()) == "")
      {
        event.preventDefault();
        $( "#request_user_name" ).css("background-color","#f2dede");
        $( "span.error-user_name").css("color", "red");
        $( "span.error-user_name").text("Please supply your full name.");
      } else {
        $( "#request_user_name" ).css("background-color","#ffffff");
        $( "span.error-user_name").text("");
      }
    });

    $( "#no_netid").click(function( event ) {
      event.preventDefault();
      $( "#no_netid").hide();
      $( "#other_user_account_info").show();
    });

    $('#no_netid').keydown(function (e) {
      var keyCode = e.keyCode || e.which;

      if (keyCode == 13) {
        $( "#no_netid" ).trigger( "click" );
        return false;
      }
    });

    $( "#go_back").click(function( event ) {
      event.preventDefault();
      $( "#no_netid").show();
      $( "#other_user_account_info").hide();
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

    var data = {}; //generic data object to package ajax pick-up locations request

    $( ".table-responsive-sm" ).on( "change", ".request-options", function(event) {
      event.stopPropagation();
      var this_select = event.target;
      var this_td = $( this_select ).closest( "td" );
      var recall_pick_up_select = this_td.find( ".recall-pick-up" );
      var recall_pick_up_single = this_td.find( ".single-pick-up" );
      var recall_pick_up_single_hidden = this_td.find( ".single-pick-up-hidden" );
      var bd_pick_up_select = this_td.find( ".bd-pick-up" );
      var chbx =  $( this_select ).closest( "tr" ).find( "input:checkbox" );

      if($(this_select)[0].options[this_select.selectedIndex].value === 'recall'){

        chbx.prop("disabled", false);
        $('.submit--request').prop("disabled", false);
        $('.alert').hide();
        bd_pick_up_select.attr( "name", "not_used" );
        bd_pick_up_select.attr( "id", "" );
        bd_pick_up_select.hide();
        recall_pick_up_select.attr( "name", "requestable[][pick_up]" );
        recall_pick_up_select.attr( "id", "requestable__pick_up" );
        recall_pick_up_single_hidden.attr( "name", "requestable[][pick_up]" );
        recall_pick_up_single_hidden.attr( "id", "requestable__pick_up" );

        // don't keep hitting the service if the pick-up locs are populated
        if(recall_pick_up_select.find('option').length == 0){
          recall_pick_up_single.show();
          recall_pick_up_single.attr( "id", "requestable__pick_up" );
        } else if(recall_pick_up_select.find('option').length == 1) {
          var item_inputs = $( this_select ).closest( "tr" ).find( "input" );
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
            console.log(msg);
            if(msg.response.recall['@allowed'] == 'Y'){
              var opts = msg.response.recall['pick-up-locations']['pick-up-location'];
              var length = opts.length;

              for ( i=0; i < length; i++) {
               recall_pick_up_select.append($("<option></option>").attr("value",opts[i]['@code'] + '|' + opts[i]['$']).text(opts[i]['$']));
              }
              recall_pick_up_select.show();
              recall_pick_up_select.attr( "id", "requestable__pick_up" );
              recall_pick_up_single.show();
              recall_pick_up_single.attr( "id", "requestable__pick_up" );
            } else {
              recall_pick_up_select.hide();
              recall_pick_up_select.attr( "id", "" );
              recall_pick_up_single.hide();
              recall_pick_up_single.attr( "id", "" );
              this_td.append($("<div class='alert alert-danger'></div>").text("Cannot be recalled because: " + msg.response.recall.note['$']));
            }
          });
        } else {
          recall_pick_up_select.show();
          recall_pick_up_select.attr( "id", "requestable__pick_up" );
          recall_pick_up_single.show();
          recall_pick_up_single.attr( "id", "requestable__pick_up" );
        }
      } else {
        $('.alert').hide();
        chbx.prop("disabled", true);
        chbx.prop("checked", false);
        $('.submit--request').prop("disabled", true);

        if(recall_pick_up_select.is(':visible') || recall_pick_up_single.is(':visible')){
          recall_pick_up_select.hide();
          recall_pick_up_select.attr( "id", "" );
          recall_pick_up_select.attr( "name", "not_used" );
          recall_pick_up_single.hide();
          recall_pick_up_single.attr( "id", "" );
          recall_pick_up_single_hidden.attr( "name", "not_used" );
          recall_pick_up_single_hidden.attr( "id", "" );
        }
        if(bd_pick_up_select.is(':visible')){
          bd_pick_up_select.hide();
          bd_pick_up_select.attr( "id", "" );
          bd_pick_up_select.attr( "name", "not_used" );
        }
        if($(this_select)[0].options[this_select.selectedIndex].value === 'bd'){
          if(bd_pick_up_select.find('option').length > 1){
            bd_pick_up_select.show();
            bd_pick_up_select.attr( "id", "requestable__pick-up" );
            bd_pick_up_select.attr( "name", "requestable[][pick_up]" );
            chbx.prop("disabled", false);
            chbx.prop("checked", true);
            $('.submit--request').prop("disabled", false);
          }else{
            var bd_link = $( "body" ).data( "bd" ).link
            if(typeof bd_link !== "undefined"){
              this_td.append($("<div class='alert alert-warning'></div>").html("Your <strong>best bet</strong> is Borrow Direct. See if a version of this item is available via <a href='" + bd_link + "' target='_blank'>the BorrowDirect site</a>."));
            }else{
              this_td.append($("<div class='alert alert-warning'></div>").html("Sorry, an error occurred with the Borrow Direct service."));
            }
            $('.alert-warning a').focus();
          }
        }
        if($(this_select)[0].options[this_select.selectedIndex].value === 'ill'){
          var ctx = this_td.find('.ill-data').attr('data-ill-url')
          this_td.append($("<div class='alert alert-warning'></div>").html("Due to the nature of this service, you must use the <a href='"+ ctx +"' target='_blank'>the InterLibrary Loan system interface</a> to request this item."));
          $('.alert-warning a').focus();
        }
      }
    });

    jQuery(function() {
      return $(".tablesorter").DataTable({
        language: {
          search: "Search by Enumeration"
        },
        ordering: false
      });
    });

    $('.table input[type=checkbox]').on('change', function() {
      $(this).closest('tr').toggleClass('selected', $(this).is(':checked'));
    });
  

});
