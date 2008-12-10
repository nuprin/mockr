var mockr = function() {
    var mockView;
    var sidebar;
    
    // highlight    : creates a highlighted section by clicking and draging
    // .initialize() : binds user highlight to the page (start,size,stop)
    // .create()    : create a new highlighted section
    // .clear()     : removes all highlighted sections
    // .selected()  : returns the area highlighted by the user
    var highlight = function(){
        var area;  // area highlighted by user
        var dom;   // userlight dom element
        var x ;    // vertical mouse data
        var y;     // horizontal mouse data

        function initialize(){
            x = {};
            y = {};
            mockView.mousedown(function(event){
                event.preventDefault();
                start();
            });
            mockView.mousemove(size);
            mockView.mouseup(stop);
        }
        function getArea(){
            return area;
        }
        function clear(){
            $('#mock div.highlight').animate({opacity:0},500,null,function(){
                $(this).remove();
            });
            $('#area').remove();
            $('#add_feedback_form').parents("div.module").
              removeClass("commenting");
            area = null;
            dom = null;
        }
        function create(o){
            return $('<div class="highlight"></div>').css({
                left     : o.x || 0,
                top      : o.y || 0,
                opacity  : 0.4,
                width    : o.width,
                height   : o.height
            }).attr({
                id:o.id
            }).appendTo(mockView)[0];
        }

        function start(){
            x.start = getX();
            y.start = getY();
            clear();
            dom = $('<div id="area" class="highlight"></div>')[0];
            mockView.append(dom);
            $(dom).css({
                left     : x.start,
                top      : y.start,
                opacity  : 0.4,
                width    : 2,
                height   : 2
            });
        }
        function getX() {
          return user.mouse.left() - mockView.offset().left +
                  $('#mock').scrollLeft();
        }
        function getY() {
          return user.mouse.top() - mockView.offset().top + 
                  $('#mock').scrollTop();
        }
        function size(){
            if (!y.start && !x.start) return false;
            x.drag = getX();
            y.drag = getY();
            $(dom).css({
                left   : x.start < x.drag ? x.start : x.drag,
                top    : y.start < y.drag ? y.start : y.drag,
                width  : Math.abs( x.start - x.drag ),
                height : Math.abs( y.start - y.drag )
            });
        }
        function stop(){
            showSidebar();
            startCommenting();
            var o = {
                x : x.start < x.drag ? x.start : x.drag,
                y : y.start < y.drag ? y.start : y.drag,
                width : $(dom).width(),
                height : $(dom).height()
            };
            x = {};
            y = {};
            if (o.width < 10 || o.height < 10) {
                clear();
                dom = null;
            }
            else {
                area = o;
                $('#comment_x').val(o.x||0);
                $('#comment_y').val(o.y||0);
                $('#comment_width').val(o.width||0);
                $('#comment_height').val(o.height||0);
            }
        }
        
        return {
            initialize : initialize,
            create    : create,
            clear     : clear,
            area      : getArea,
        };
    }();

    this.startCommenting = function(){
      $('#add_feedback_form').parents("div.module").addClass("commenting");
      $('#comment_text').focus();
    }

    function toggleSidebar() {
      if ($(document.body).hasClass('fullscreen')) {
        showSidebar();
      } else {
        hideSidebar();
      }
    }

    function showSidebar() {
      if ($(document.body).hasClass('fullscreen')) {
        sidebar.animate({left: '0'}, 'fast');
        mockView.animate({left: '0', width: '-=400px'}, 'fast');
        $(document.body).toggleClass('fullscreen');
      }
    }

    function hideSidebar() {
      if (!$(document.body).hasClass('fullscreen')) {
        sidebar.animate({left: '-400px'}, 'fast');
        mockView.animate({left: '-400px', width: '+=400px'}, 'fast');
        $(document.body).toggleClass('fullscreen');
      }
    }

    function initializeFeatureList(){
      $("#feature_list").change(function(event) {
        if (event.target.value != "") {
          location.href = "/" + event.target.value;
        }
      });     
    }

    function initializeFeedbackFilter() {
      $("#feedback_filter").change(function(event) {
        location.href = "?feedback_filter=" + event.target.value
      })
    }

    function initializeTextareas() {
      $("textarea").keydown(function(event) {
        if (user.keyboard.character() == "enter") {
          $(this).height($(this).height() + 24);
        }
      });   
    }
    
    function initializeChildComments() {
      $("#comments_list .replylink").click(function (){
        $(this).parents("li.comment_node").
          toggleClass("replying").find('textarea').focus();
      });
    }

    function initializeComments() {
      $("#comments_list >li").click(function(){
          $("#comments_list >li").removeClass('highlighted');
          $(this).addClass('highlighted');
          highlight.clear();
          if ($(this).attr('box')) {
              var box = $(this).attr('box').split('_');
              var id = $(this).attr('id');
              var high = highlight.create({
                  x: box[0],
                  y: box[1],
                  width: box[2],
                  height: box[3],
                  id: id
              });
              scrollToElem(high);
          }
      });
    }

    function adjustHeights() {
      height = user.browser.height() - $('#comments_list').offset().top
      $("#comments_list").height(height)
      $("#mock").height(user.browser.height())
    }
    
    function scrollToElem(elem) {
      boxTop = parseInt(elem.style.top);
      mockTop = parseInt($('#mock').height() / 2);
      boxLeft = parseInt(elem.style.left);
      mockLeft = parseInt($('#mock').width() / 2);
      position = {
        top:  Math.max(boxTop - mockTop, 0), 
        left: Math.max(boxLeft - mockLeft, 0)        
      }
      $(elem).css({opacity: 0});
      // TODO: Find a built in bounds function.
      if (position.top < $('#mock').scrollTop() ||
          position.top > $('#mock').scrollTop() + $('#mock').height()) {
        pause = 400;
      } else {
        pause = 0;
      }
      $('#mock').scrollTo(position, pause, {axis: 'xy', onAfter: function() {
        $(elem).animate({opacity: 0.7}, 200).animate({opacity: 0.4}, 200);
      }});
    }

    function initialize() {
        mockView = $("#mock");
        sidebar = $('#sidebar');
        
        highlight.initialize();
        
        initializeFeatureList();
        initializeFeedbackFilter();
        initializeTextareas();
        initializeComments();
        initializeChildComments();
        adjustHeights();
    }

    return {
        initialize:      initialize,
        highlight:       highlight,
        startCommenting: startCommenting,
        adjustHeights:   adjustHeights,
        hideSidebar:     hideSidebar,
        showSidebar:     showSidebar
    };
}();

$(document).ready(mockr.initialize);
$(window).resize(mockr.adjustHeights);
