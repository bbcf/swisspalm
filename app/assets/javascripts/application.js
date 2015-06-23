//= require jquery
//= require jquery_ujs

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

var browserName = navigator.appName;

function gid(a){
    return document.getElementById(a)
}

function upd_protein_cart(e){
alert(e.value);
}

if(typeof(String.prototype.trim) === "undefined")
{
    String.prototype.trim = function() 
    {
        return String(this).replace(/^\s+|\s+$/g, '');
    };
}

