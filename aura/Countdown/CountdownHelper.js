({
    setupCountdown: function(c,countDownDate){
        var x = setInterval(function() {
            var now = new Date().getTime();
            var distance = countDownDate - now;
            var days = Math.floor(distance / (1000 * 60 * 60 * 24));
            var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            var seconds = Math.floor((distance % (1000 * 60)) / 1000);
            if(document.getElementById("days"))
                document.getElementById("days").innerHTML = days;
            if(document.getElementById("hours"))
                document.getElementById("hours").innerHTML = hours;
            if(document.getElementById("minutes"))
                document.getElementById("minutes").innerHTML = minutes;
            if(document.getElementById("seconds"))
                document.getElementById("seconds").innerHTML = seconds;
            if (distance < 0) {
                clearInterval(x);
                document.getElementById("days").innerHTML = 0;
                document.getElementById("hours").innerHTML = 0;
                document.getElementById("minutes").innerHTML = 0;
                document.getElementById("seconds").innerHTML = 0;
            }
        }, 1000);
        c.set('v.intervalVar',x);
    }
})