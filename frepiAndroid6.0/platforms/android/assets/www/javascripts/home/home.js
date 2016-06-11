(function() {
  var $images, currentElem, imgsMaxIndex, initSlider, restartAnimation, setInfiniteSliding, setMenuVisibility, setNextImg, setPrevImg;

  $images = $('#slider .images > li');

  imgsMaxIndex = $images.length - 1;

  currentElem = 0;

  setInfiniteSliding = setInterval((function() {
    return setNextImg();
  }), 7000);

  initSlider = function() {
    return $images.hide().first().show();
  };

  setNextImg = function() {
    $images.eq(currentElem).fadeOut(300);
    currentElem = currentElem === imgsMaxIndex ? 0 : currentElem += 1;
    return $images.eq(currentElem).fadeIn(300);
  };

  setPrevImg = function() {};

  restartAnimation = function() {
    var $elemsToAnimate;
    $elemsToAnimate = $('#slider .inner-images > li');
    return $.each($elemsToAnimate, function(i, elem) {
      var $elem;
      $elem = $(elem);
      return $elem.before($elem.clone(true)).remove();
    });
  };

  setMenuVisibility = function() {
    if ($(window).outerWidth() < 480) {
      $('nav .right.menu').addClass('hidden');
    } else {
      $('nav .right.menu').removeClass('hidden');
    }
    return $(window).resize(function() {
      if ($(window).outerWidth() < 480) {
        return $('nav .right.menu').addClass('hidden');
      } else {
        return $('nav .right.menu').removeClass('hidden');
      }
    });
  };

  setMenuVisibility();

  initSlider();

}).call(this);
