var mockr = function(){
    var mockView;        //mock display panel
    var threadView;      //threads panel

    // highlight    : creates a highlighted section by clicking and draging
    // .initialize() : binds user highlight to the page (start,size,stop)
    // .create()    : create a new highlighted section
    // .clear()     : removes all highlighted sections
    // .selected()  : returns the area highlighted by the user
    var highlight = function(){
        var area;  //area highlighted by user
        var dom;   //userlight dom element
        var x ;    //vertical mouse data
        var y;     //horizontal mouse data

        function initialize(){
            x = {};
            y = {};
            mockView.onmousedown = start;
            mockView.onmousemove = size;
            mockView.onmouseup = stop;
        }
        function getArea(){
            return area;
        }
        function clear(){
            $('#mock div.highlight').animate({opacity:0},500,null,function(){
                $(this).remove();
            });
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
            x.start = user.mouse.left() - $(mockView).offset().left;
            y.start = user.mouse.top() - $(mockView).offset().top;
            clear();
            dom = $('<div id="area" class="highlight"></div>').css({
                left     : x.start,
                top      : y.start,
                opacity  : 0.4,
                width    : 2,
                height   : 2
            }).appendTo(mockView)[0];
        }
        function size(){
            if (!y.start && !x.start) return false;
            x.drag = user.mouse.left() - $(mockView).offset().left;
            y.drag = user.mouse.top() - $(mockView).offset().top;
            $(dom).css({
                left   : x.start < x.drag ? x.start : x.drag,
                top    : y.start < y.drag ? y.start : y.drag,
                width  : Math.abs( x.start - x.drag ),
                height : Math.abs( y.start - y.drag )
            });
        }
        function stop(){
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
            area      : getArea
        };
    }();

    this.startCommenting = function(){
      $('#add_feedback_form').parents("div.module").addClass("commenting");
      $('#comment_text').focus();
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
      $("#comments_list .replylink").click(function () {
        $(this).parents("li.comment_node").toggleClass("replying");
      });
    }

    function initialize(){
        mockView = document.getElementById("mock");
        threadView = document.getElementById("comments_list");
        highlight.initialize();
        
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
                $(high).css({opacity:0}).animate({opacity:0.7},200).animate({opacity:0.4},200);
            }
        });
        initializeFeatureList();
        initializeFeedbackFilter();
        initializeTextareas();
        initializeChildComments();
    }

    return {
        initialize: initialize,
        highlight: highlight,
        startCommenting: startCommenting,
    };
}();

$(document).ready(mockr.initialize);
