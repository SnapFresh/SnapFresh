// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

$(function() {
  $("#retailers th a, #retailers .pagination a").live("click", function() {
    $.getScript(this.href);
    return false;
  });
  $("#retailers_search input").keyup(function() {
    $.get($("#retailers_search").attr("action"), $("#retailers_search").serialize(), null, "script");
    return false;
  });
});

