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

    var data = {}; //generic data object to package ajax pickup locations request

    $( ".table-responsive" ).on( "change", ".request-options", function(event) {
      event.stopPropagation();
      var this_td = $( this ).closest( "td" );
      var recall_pickup_select = this_td.find( ".recall-pickup" );
      var bd_pickup_select = this_td.find( ".bd-pickup" );
      var chbx =  $( this ).closest( "tr" ).find( "input:checkbox" );

      if($(this)[0].selectedOptions[0].value === 'recall'){

        chbx.prop("disabled", false);
        $('.submit--request').prop("disabled", false);
        $('.alert').hide();
        recall_pickup_select.show();
        bd_pickup_select.hide();

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
              recall_pickup_select.empty();
              for ( i=0; i < length; i++) {
               recall_pickup_select.append($("<option></option>").attr("value",opts[i]['@code'] + '|' + opts[i]['$']).text(opts[i]['$']));
              }

            } else {
              recall_pickup_select.hide();
              this_td.append($("<div class='alert alert-danger'></div>").text("Cannot be recalled because: " + msg.response.recall.note['$']));
            }
          });

      } else {
        $('.alert').hide();
        if(recall_pickup_select.is(':visible')){
          recall_pickup_select.hide();
        }
        if(bd_pickup_select.is(':visible')){
          bd_pickup_select.hide();
        }
        if($(this)[0].selectedOptions[0].value === 'bd'){
          var bd_link = $( "body" ).data( "bd" ).link
          if(typeof bd_link !== "undefined"){
            bd_pickup_select = $( "body" ).data( "bd_pickups" ).pickup_select
            if(typeof bd_pickup_select !== "undefined"){
              bd_pickup_select.show();
            }else{
              chbx.prop("disabled", true);
              chbx.prop("checked", false);
              $('.submit--request').prop("disabled", true);
              this_td.append($("<div class='alert alert-warning'></div>").html("Your <strong>best bet</strong> is Borrow Direct. See if a version of this item is available via <a href='" + bd_link + "' target='_blank'>the BorrowDirect site</a>."));
            }
          }else{
            this_td.append($("<div class='alert alert-warning'></div>").html("Sorry, an error occurred with the Borrow Direct service."));
          }
          $('.alert-warning a').focus();
        }
        if($(this)[0].selectedOptions[0].value === 'ill'){
          chbx.prop("disabled", true);
          chbx.prop("checked", false);
          $('.submit--request').prop("disabled", true);
          var ctx = this_td.find('.ill-data').attr('data-ill-url')
          this_td.append($("<div class='alert alert-warning'></div>").html("Due to the nature of this service, you must use the <a href='"+ ctx +"' target='_blank'>the InterLibrary Loan system interface</a> to request this item."));
          $('.alert-warning a').focus();
        }
      }
    });


});
