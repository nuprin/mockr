var mockr = function(){
    var mockView;	     //mock display panel
	var threadView;      //threads panel
    
    // highlight    : creates a highlighted section by clicking and draging
    // .initalize() : binds user highlight to the page (start,size,stop)
    // .create()    : create a new highlighted section
    // .clear()     : removes all highlighted sections
    // .selected()  : returns the area highlighted by the user
    var highlight = function(){
        var area;  //area highlighted by user
        var dom;   //userlight dom element
        var x ;    //vertical mouse data
        var y;     //horizontal mouse data
        
        function initalize(){
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
            $(mockView).html('');
            area = null;
            dom = null;
        }
        function create(o){
            if (dom) $(dom).remove();
            dom = $('<div class="highlight"></div>').css({
                left     : o.x,
                top      : o.y,
                opacity  : 0.4,
                width    : o.w,
                height   : o.h
            }).appendTo(mockView)[0];
        }
        
        function start(){
            x.start = user.mouse.left();
            y.start = user.mouse.top();
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
            x.drag = user.mouse.left();
            y.drag = user.mouse.top();
            $(dom).css({
                left   : x.start < x.drag ? x.start : x.drag,
                top    : y.start < y.drag ? y.start : y.drag,
                width  : Math.abs( x.start - x.drag ),
                height : Math.abs( y.start - y.drag )
            });
        }
        function stop(){
            x = {};
            y = {};
            var o = {
                x : x.start < x.drag ? x.start : x.drag,
                y : y.start < y.drag ? y.start : y.drag,
                w : $(dom).width(),
                h : $(dom).height()
            }
            if (o.w < 10 || o.h < 10) {
                clear();
                dom = null;
            }
            else {
                area = o;
            }
        }
        
        return {
            initalize : initalize,
            create    : create,
            clear     : clear,
            area      : getArea
        };
    }();
    
    function initalize(){
        mockView = document.getElementById("mock");
        threadView = document.getElementById("comments_list");
        
        highlight.initalize();
    }

    return {
        initalize: initalize,
        highlight: highlight
    }
}();

$(document).ready(mockr.initalize);
