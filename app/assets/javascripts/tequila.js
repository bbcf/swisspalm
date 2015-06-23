
var curlang = '';
var      me = '';
var certurl = '';
var  keylen = 6;
var tid

function Ajax (url, receiver) {
  this.url = url;
  var  req = init ();
  req.onreadystatechange = processRequest;

  function init () {
    if (window.XMLHttpRequest) {
      return new XMLHttpRequest ();
    } else if (window.ActiveXObject) {
      isIE = true;
      return new ActiveXObject ("Microsoft.XMLHTTP");
    }
  }

  function processRequest () {
    if (req.readyState == 4) {
      receiver (req.status, req.statusText, req.responseText);
    }
  }
  this.send = function () {
    req.open ("GET", url, true);
    req.send (null);
  }
}

function submitlogin () {
  var state = document.getElementById ('state');
  if (state.value == 2) {
    var chooseauth = document.getElementById ('chooseauth');
    if (chooseauth) {
      var auth = chooseauth [chooseauth.selectedIndex].value;
      if (auth != 'basic') {
        document.getElementById ('password').value = '';
      }
    }
    return true;
  }
  if (state.value == 1) {
    var username = document.getElementById ('username');
    if (!username.value) {
      alert ('You must give a username.');
      return false;
    }
    var  userinput = document.getElementById ('userinput');
    var  userlabel = document.getElementById ('userlabel');
    var requestkey = document.getElementById ('requestkey').value;
    userlabel.innerHTML = '<b>' + username.value + '</b>';
    userlabel.style.display = 'inline';
    userinput.style.display = 'none';
    state.value = 2;
    var  url = me + '/getauthdata?requestkey=' + requestkey + '&username=' + username.value;
    var ajax = new Ajax (url, receiveauthdata);
    ajax.send ();
    document.getElementById ('opak').style.display = 'block';
    document.getElementById ('loginbutton').style.display = 'inline';
    return false;
  }
  return false;
}

function receiveauthdata (status, statusText, responseText) {
  document.getElementById ('opak').style.display = 'none';
  if (status != 200) {
    alert ('An unexpected error happened in Tequila : ' +statusText );
    return false;
  }
  var authdata = new Array;
  var lines = responseText.split (/[\r\n]+/);
  for (l in lines) {
    if (match = lines [l].match (   /^basic:\s*(.*)$/))    authdata.basic = match [1];
    if (match = lines [l].match (    /^totp:\s*(.*)$/))     authdata.totp = match [1];
    if (match = lines [l].match (    /^skey:\s*(.*)$/))     authdata.skey = match [1];
    if (match = lines [l].match (    /^salt:\s*(.*)$/))     authdata.salt = match [1];
    if (match = lines [l].match (  /^number:\s*(.*)$/))   authdata.number = match [1];
    if (match = lines [l].match (     /^sms:\s*(.*)$/))      authdata.sms = match [1];
    if (match = lines [l].match (/^question:\s*(.*)$/)) authdata.question = match [1];
    if (match = lines [l].match (    /^cert:\s*(.*)$/))     authdata.cert = match [1];
  }
  var  something = false;
  var chooseauth = document.getElementById ('chooseauth');
  if (chooseauth == null) {
    singlechoice (authdata);
    return false;
  }

  chooseauth.options.length = 0;
  var option = document.createElement ('option');
  option.text  = 'Choose authentication scheme';
  option.value = 'choose';
  chooseauth.add (option, null);

  if (authdata.basic) {
    something = true;
    var option = document.createElement ('option');
    option.text  = 'Basic authentication';
    option.value = 'basic';
    chooseauth.add (option, null);
  }
  if (authdata.totp) {
    something = true;
    var option = document.createElement ('option');
    option.text  = 'TOTP authentication';
    option.value = 'totp';
    chooseauth.add (option, null);
  }
  if (authdata.skey && authdata.number) {
    something = true;
    var option = document.createElement ('option');
    option.text  = 'SKey authentication';
    option.value = 'skey';
    chooseauth.add (option, null);
  }
  if (authdata.sms && authdata.question) {
    something = true;
    var option = document.createElement ('option');
    option.text  = 'SMS authentication';
    option.value = 'sms';
    chooseauth.add (option, null);
  }
  if (authdata.cert) {
    something = true;
    var option = document.createElement ('option');
    option.text  = 'Certificate authentication';
    option.value = 'cert';
    chooseauth.add (option, null);
  }
  var chooseauthtr = document.getElementById ('chooseauthtr');
  chooseauthtr.style.display = 'table-row';

  chooseauth.onchange = function () {
    var chooseauth = document.getElementById ('chooseauth');
    var selected = chooseauth [chooseauth.selectedIndex].value;

    for (var auth in types = ['basic', 'skeynumber', 'skeykey', 'smsanswer', 'smskey']) {
      document.getElementById (types [auth] + 'tr').style.display = 'none';
    }
    if (selected == 'choose') return;
    if (selected == 'basic') {
      document.getElementById ('basictr').style.display = 'table-row';
      return;
    }
    if (selected == 'totp') {
      document.getElementById ('totpkeytr').style.display = 'table-row';
      return;
    }
    if (selected == 'skey') {
      document.getElementById ('skeynumber').innerHTML = '<b>' + authdata.number + '</b>';
      showskey ();
      checkunlock ();
      return;
    }
    if (selected == 'sms') {
      authdata.question.replace (/é/g, '&eacute;');
      authdata.question.replace (/è/g, '&egrave;');
      document.getElementById ('smsquestion').innerHTML     = authdata.question;
      document.getElementById ('smsanswertr').style.display = 'table-row';
      document.getElementById ('smskeytr').style.display    = 'table-row';
      return;
    }
    if (selected == 'cert') {
      var requestkey = document.getElementById ('requestkey').value;
      var form = document.createElement ('form');
      form.setAttribute ('method',  'POST');
      form.setAttribute ('action', certurl);
      var input = document.createElement ('input');
      input.setAttribute ('type', 'hidden');
      input.setAttribute ('name',  requestkey);
      input.setAttribute ('value', requestkey);
      form.appendChild (input);
      document.body.appendChild (form);
      form.submit ();
      return;
    }
  };
  return false;
}

function showskey () {
  document.getElementById ('skeynumbertr').style.display = 'table-row';
  document.getElementById ('skeykeytr').style.display    = 'table-row';
}

function hideskey () {
  document.getElementById ('otpnumbertr').style.display = 'none';
  document.getElementById ('otpkeytr').style.display    = 'none';
}

function showbasic () {
  document.getElementById ('totpkeytr').style.display = 'table-row';
}

function showtotp () {
  document.getElementById ('basictr').style.display = 'table-row';
}

function hidebasic () {
  document.getElementById ('basictr').style.display = 'none';
}

function swapskey () {
  if (document.getElementById ('basictr').style.display == 'none') {
    showbasic ();
    hideskey  ();
  } else {
    showskey  ();
    hidebasic ();
  }
}

function singlechoice (authdata) {
  if (authdata.skey) {
    document.getElementById ('skeynumber').innerHTML       = '<b>' + authdata.number + '</b>';
    document.getElementById ('skeynumbertr').style.display = 'table-row';
    document.getElementById ('skeykeytr').style.display    = 'table-row';
    checkunlock ();
  }
  else
  if (authdata.sms) {
    authdata.question.replace (/é/g, '&eacute;');
    authdata.question.replace (/è/g, '&egrave;');
    document.getElementById ('smsquestion').innerHTML     = authdata.question;
    document.getElementById ('smsanswertr').style.display = 'table-row';
    document.getElementById ('smskeytr').style.display    = 'table-row';
  }
}

function checkunlock () {
  var requestkey = document.getElementById ('requestkey').value;
  if (!requestkey) return;
  var  url = me + '/checkremoteauth?requestkey=' + requestkey;
  var ajax = new Ajax (url,
    function (status, statusText, responseText) {
      console.log ('COUCOU:statusText = ' + statusText + ', responseText = ' + responseText);
      if (status ==   0) return;
      if (status == 504) return;
      if (status != 220) {
	alert ('Error: ' + status + ' ' + statusText);
        return;
      }
      if (responseText.match (/^200 /)) { // OK.
        document.getElementById ('state').value = 1;
        document.getElementById ('loginform').submit ();
        return;
      }
      if (responseText.match (/^450 /)) { // Timeout.
        checkunlock ();
      } else {
        alert ('Error: ' + status + ' ' + responseText);
      }
      return;
    }
  );
  ajax.send ();
}

function submitsms () {
  var usesms = false;
  var  ret = false;
  var user = document.getElementById ('username').value;
  var pass = document.getElementById ('password').value;
  if (!user) {
    alert ('You must give a username.');
    return false;
  }
  if (!pass) {
    if (!strongauth) {
      alert ('You must give a password.');
      return false;
    }
    var  url = me + '/hassms?username=' + user;
    var ajax = new Ajax (url, receivehassms);
    ajax.send ();
    document.getElementById ('opak').style.display = 'block';
    return false;
  }
  document.loginform.submit ();
  return false;
}

function receivesendsms (status, statusText, responseText) {
  document.getElementById ('opak').style.display = 'none';
  if (status == 200) {
    var smsleftmsg = '';
    if (match = statusText.match (/(\d+)$/)) {
      var smsleft = match [1];
      if (smsleft == 0) {
        smsleftmsg = "\nWarning : You don't have any SMS left for today.";
      } else {
        smsleftmsg = "\nYou have " + smsleft + " SMS left for today.";
      }
    }
    alert ('You will soon receive an SMS with the key to use as password.' + smsleftmsg);
  } else
  if (status == 462) {
    alert ('You must give a password.');
  } else {
    alert ('You must give a password.');
  }
}

function swaplanguage (lang) {
  var spans = document.getElementsByTagName ('span');
  for (var i = 0; i < spans.length; i++) {
    if (spans [i] == null) continue;
    var name = spans [i].attributes ['name'].value;
    var  reg = /^([^:]*):(.*)/;
    var filt = reg.exec (name);
    if (filt != null) {
      var clang = filt [1];
      if (clang == lang) {
        spans [i].style.display = 'inline';
      } else {
        spans [i].style.display = 'none';
      }
    }
  }
  curlang = lang;
}









