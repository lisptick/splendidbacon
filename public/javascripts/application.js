function ClearForm() {
  document.new_invitation.invitation_email.value= "";
}


jQuery(function() {

	var organization = $("#organization_nav h1 a").text();
	$("#organization_nav").hover(function() {
		$(this).find("a:first").text("Edit");
	}, function() {
		$(this).find("a:first").text(organization);
	});


  var scroll = 448;
  var maxScroll = $("#months").width() - $("#timeline").width() - 870;
  var currentScroll = 0;

  $("a[href='#next']").click(function() {
    if (currentScroll < maxScroll) {
      $("#timeline .project, .month, #today_bar").animate({ left: "-=" + scroll + "px" });
      currentScroll += scroll;
    }
    return false;
  });

  $("a[href='#prev']").click(function() {
    if (currentScroll >= scroll) {
      $("#timeline .project, .month, #today_bar").animate({ left: "+=" + scroll + "px" });
      currentScroll -= scroll;
    }
    return false;
  });

  $(document).keydown(function(e) {
    if (e.keyCode == 37) {
      $("a[href='#prev']").click();
      return false;
    }
    if (e.keyCode == 39) {
      $("a[href='#next']").click();
      return false;
    }
  });


  if ($("#inner_timeline").length == 1) {
    var top = $("#inner_timeline").height() / 2 - $("#outer_timeline a.nav img").height() / 2
    $("#outer_timeline a.nav").css({ top: top + "px" });
  }
  
  // Project form
  $(".relatize").relatizeDate();
  
  $(".datepicker").datepicker({ dateFormat: 'd MM yy' });
  
  $(".project_state label.collection_radio").click(function() {
    $(this).addClass("selected").siblings().removeClass("selected");
  });

  $(".project_state input.radio").hide().filter(":checked").each(function() {
    $("label[for=" + this.id + "]").click();
  });
  
  $("input.person:checked").each(function(){
    $("label[for=" + $(this).attr("id") + "]").addClass("selected");
  });

  $("input.person").hide();
  
  $(".person label.collection_check_boxes").click(function() {
    if ($("#" + $(this).attr("for")).attr("checked") == true)
    {
      $(this).removeClass("selected");
    }
    else
    {
      $(this).addClass("selected");
    }
  });
  
  $("#post-receive").click(function() {
    $(this).focus().select();
  });

  $(".projectcontent, #timeline .project").click(function() {
    window.location = $(this).find("a").attr("href");
    return false;
  });
  

  $("#onav").hide(); 

  $("#organization_nav #control").click(function () {
    $(this).next("#onav").slideToggle("fast");
  });
 
  $("body").click(function () {
    $("#onav").hide();
  });

  $("#organization_nav #control").click(function(e) {
    e.stopPropagation();
  });


  $("#timeline .project").hover(function() {
    $(this).css({ overflow: "visible" });
  }, function() {
    $(this).css({ overflow: "hidden" });
  });
  
  if ($.browser.webkit) {
      $('input').attr('autocomplete', 'off');
  }
  
  if ( $('meta[name="broadcast-title"]').length ) {
    $.jGrowl($('meta[name="broadcast-text"]').attr("content"), {
      sticky: true, 
      header: $('meta[name="broadcast-title"]').attr("content"),
      close: function() {
        $.ajax({
          url: $('meta[name="broadcast-url"]').attr("content"),
          type: 'POST'
        });
      }
    })
  }
});
