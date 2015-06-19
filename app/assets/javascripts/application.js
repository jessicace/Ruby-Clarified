// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  $('.getBenchmark').click(function(e) {
    var url = $(this).attr('href');
    console.log(url)
    $.get(url, function(data) {
      $('#output').html(data);
    });
    e.preventDefault();
  });

  $('.method-heading').click(function(e) {
    console.log(e);
    var target = e.target;
    var codeSections = $(target).parents('.method-detail').find('.method-source-code');

    console.log(target);
    $(target).parents('.method-detail').find('.method-source-code').slideToggle();
  });

});

