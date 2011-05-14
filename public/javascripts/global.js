/* Site Globals  */
var scrolling = false;
var controlView = false;
var controlNoticeView = false;
var controlActionView = false;

function toggleControls(action,content,callback) {
    if(controlActionView.is(':visible') && controlActionView.attr('data-action')==action) {
        controlActionView.slideUp(700,function(){
            controlActionView.attr('data-action','');
            controlView.hide();
            if (typeof callback == "function") callback()
        });
    } else if(controlActionView.is(':visible') && controlActionView.attr('data-action')!=action) {
        controlActionView.slideUp(700,function(){
            renderControl(action,content);
            if (typeof callback == "function") callback()
        });
    } else {
        renderControl(action,content);
        if (typeof callback == "function") callback()
    }
    $('#next-url').val(location.pathname);
}

function renderControl(action,content) {
	$('html, body').animate({scrollTop:0}, 1000);
    controlView.show();
    controlActionView.html(content);
    initForms();
    controlActionView.find('.cancel').click(function(){
      toggleControls($(this).parents('.actions').attr('data-action'),"")
      return false;
    })
    controlActionView.attr('data-action',action);
    controlActionView.slideDown(700);
}

function initForms() {
  
    $('input[data-max-chars]').each(function(){
      count = $(this).val().length;
      limit = $(this).attr('data-max-chars');
      $(this).parent().append('<p class="character-count">Characters remaining: '+(limit-count)+'</p>')
      limitCount = $(this).parent().find('.character-count');
      $(this).bind('keyup',function(){
        count = $(this).val().length;
        if (count > limit) {
        		$(this).val($(this).val().substring(0, limit));
        	} else {
        		limitCount.text('Characters remaining: '+(limit-count));
        	}
      });
    });
  
    $('label.text').each(function(){
        $(this).addClass('compact');
        
        label = $(this).find('span');
        label.bind('click',function() { $(this).parent().find('input, textarea').focus();});
        
        input = $(this).find('input, textarea');
        if(input.length!=0) {
            if(input.val().length!=0) {
                $(this).addClass('active');
            }
            input.bind('focus',function(){
                $(this).parents('label').addClass('active');
            });
            input.bind('blur',function(){
                if($(this).val().length==0) {
                    $(this).parents('label').removeClass('active');
                } 
            });
        }
    });
    
}

function foldArticles() {
	$('.idea').each(function(){
		
		if($(this).hasClass('list') && $(this).find('article').length>0) {
			$(this).addClass('folded');
			$(this).find('article').hide();
			$(this).click(function(e){
			  if (!$(e.target).is('a')) {
			  	if($(this).find('article').is(':visible')) {
  					$(this).find('article').slideUp();
  				} else { 
  					$(this).find('article').slideDown();
  				}
			  }
			});
		}
	
		$(this).find('.control').hide();
		$(this).bind('mouseover',function(){ $(this).find('.control').show(); });
		$(this).bind('mouseout',function(){ $(this).find('.control').hide(); });

	});
	
  $('.owned:not(.inactive)').each(function(){
    $(this).bind('mouseover',function(){ $(this).css({opacity: 0.9}) });
    $(this).bind('mouseout',function(){ $(this).attr({style:''}) });
  });
  
}

$(document).ready(function(){	

    /* Init control area */
    controlView = $('#controls').hide();
    controlNoticeView = controlView.find('.notices').hide();
    controlActionView = controlView.find('.actions').hide();

    /* User account */
    $('#userControls').hide();
    $('header aside p.control').css({cursor:'pointer'})
    $('header aside p.control').click(function(){
      content = $('#userControls').clone();
      content.show();
      toggleControls("userControls",content);
    });

    /* Some form interactions */
    initForms();
	        
    /* Lazy loading */
    pageBottom = $(document).height()-$(window).height()-$('footer:last').outerHeight()-20;
    $(window).scroll(function(){
        if($(document).scrollTop() > pageBottom && !loading && $('#load_more').length!=0) {
            scrolling = true;
            $('#load_more').trigger('click');
        }
    });

  /* Fold articles */
  foldArticles();

  /* Init filters */
  $('#home #content .container').prepend('<section id="filters"><ul class="toggler availability"><li><a data-type="available" href="/">Available ideas</a></li><li><a data-type="all" href="/">All ideas</a></li></ul></section>');
  $('#home .owned').not('.current-work').not('.single').hide();
  $('.availability a[data-type="available"]').parent().addClass('active');
  $('.availability a').click(function(e){
    $(this).parent().siblings().removeClass('active');
    $(this).parent().addClass('active');
    if($(this).attr('data-type')=='available') {
      $('.owned').not('.current-work').hide();
    } else if($(this).attr('data-type')=='all') {
      $('.owned').not('.current-work').show();
    }
    return false;
  });


});

$(window).load(function(){  
    
	/* Flash any errors/alerts/notices on page load */
	if(controlNoticeView.length!=0) {
	    controlView.show();
	    controlNoticeView.slideDown(700);
	    controlNoticeView.delay(2000).slideUp(700,function(){
	        if(!controlActionView.is(':visible')) controlView.hide();    
	    });
    }
    
});