$images = $('#slider .images > li')
imgsMaxIndex = $images.length - 1
currentElem = 0
setInfiniteSliding = setInterval((->
		setNextImg()
	), 7000)

initSlider = ->
	$images.hide().first().show()

setNextImg = ->
	$images.eq(currentElem).fadeOut(300)
	currentElem = if currentElem is imgsMaxIndex then 0 else currentElem+=1
	$images.eq(currentElem).fadeIn(300)

setPrevImg = ->

restartAnimation = ->
	$elemsToAnimate = $('#slider .inner-images > li')
	$.each($elemsToAnimate, (i, elem) ->
			$elem = $(elem)
			$elem.before( $elem.clone(true) ).remove()
		)

# $('.nav.button').click( ->
# 		$('nav .right.menu').toggleClass('hidden')
# )

setMenuVisibility = ->
	if $(window).outerWidth() < 480
		$('nav .right.menu').addClass('hidden')
	else
		$('nav .right.menu').removeClass('hidden')

	$(window).resize(->
		if $(window).outerWidth() < 480
			$('nav .right.menu').addClass('hidden')
		else
			$('nav .right.menu').removeClass('hidden')
	)

setMenuVisibility()
initSlider()
