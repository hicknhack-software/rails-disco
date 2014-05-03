$(function () {
    var event_source = $('.event-source[data-href]');
    if (event_source.length==1 && typeof(EventSource)!=='undefined') {
        var source = new EventSource(event_source.data('href'));
        source.addEventListener('projected', function (e) {
            window.location.reload();
        });
        source.addEventListener('exception', function (e) {
            var d = $.parseJSON(e.data);
            $('body').prepend(
                $('<div class="alert alert-projection">').append(
                    $('<div class="message">').text(d['error']),
                    $('<div class="backtrace">').text(d['backtrace'].join('\n'))
                )
            );
            source.close();
        });
    }
});
