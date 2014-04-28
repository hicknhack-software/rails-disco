$(function () {
    var event_source = $('.event-source[data-href]');
    if (event_source.length==1 && typeof(EventSource)!=='undefined') {
        setTimeout(function () {
            var source = new EventSource(event_source.data('href'));
            source.addEventListener('projected', function (e) {
                window.location.reload();
            });
            source.addEventListener('exception', function (e) {
                $('body').append(
                    $('<div class="alert alert-projection">').append(
                        $('<div class="message">').text(e.data['error']),
                        $('<div class="backtrace">').text(e.data['backtrace'])
                    )
                );
            });
        }, 1);
    }
});
