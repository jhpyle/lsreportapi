var system = require('system');
var casper = require('casper').create(
  // {
  //   verbose: true,
  //   logLevel: "debug",
  //   pageSettings: {
  //     webSecurityEnabled: false
  //   }
  // }
);

var inputs = JSON.parse(system.stdin.readLine())

casper.options.viewportSize = {width: 1024, height: 1280};
casper.options.waitTimeout = 10000;

var url = inputs[0] + "/report/dynamic?load=" + inputs[3]

casper.start(url, function() {
  this.fill("form", {'____login_login': inputs[1], '____login_password': inputs[2]}, false);
});

casper.then(function() {
  this.click('input[type="submit"]');
});

var report_db_id;
var report_session_id;

casper.then(function(){
  report_db_id = this.getElementAttribute('input[type="hidden"][name="load"]', 'value');
  report_session_id = this.getElementAttribute('input[type="hidden"][name="report_session_id"]', 'value');
});

casper.then(function(){
  this.open(inputs[0] + '/report/api/legacy', {
    method: 'POST',
    data: {
      'rpc': "1",
      'extra_params': '["all"]',
      'method': "setPageSize",
      'oid': "2",
      'report_session_id': report_session_id,
      'report_db_id': report_db_id,
      'keep_session_open': "true"
    }
  });
});

casper.then(function(){
  this.open(inputs[0] + '/report/api/legacy', {
    method: 'POST',
    data: {
      'rpc': "1",
      'extra_params': '[]',
      'method': "listDataAjax",
      'oid': "2",
      'report_session_id': report_session_id,
      'report_db_id': report_db_id,
      'keep_session_open': "true"
    }
  });
});

casper.then(function(){
  var resp = JSON.parse(this.getPageContent());
  var theHtml = resp["listHtml"];
  var theHeaders = Array();
  var theResult = this.evaluate(function(html, headers){
    var result = Object();
    var headers = Array();
    result["rows"] = Array();
    var theDiv = document.createElement("div");
    theDiv.innerHTML = html;
    var theList = theDiv.getElementsByTagName("TR");
    for (var i = 0; i < theList.length; ++i){
      var theRow = theList[i];
      if (theRow.className == 'dataheader'){
        if (headers.length == 0){
          var cols = theRow.getElementsByTagName("TH");
          for (var j = 0; j < cols.length; ++j){
            var name = "";
            var spans = cols[j].getElementsByTagName("SPAN");
            var children = spans[0].childNodes;
            for (var k = 0; k < children.length; ++k){
              if (children[k].nodeName == "#text"){
                name += children[k].textContent;
              }
              else if (children[k].nodeName == "BR"){
                name += " ";
              }
              else{
                name += children[k].nodeName;
              }
            }
            headers.push(name);
          }
        }
        continue;
      }
      if (theRow.className == 'datarowtotal' || theRow.className == 'report_page_links' || theRow.className == 'datatitle'){
        continue;
      }
      var cols = theRow.getElementsByTagName("TD");
      var colList = Object();
      for (var j = 0; j < cols.length; ++j){
        colList[headers[j]] = cols[j].textContent.trim();
      }
      result["rows"].push(colList);
    }
    return(result);
  }, {html: theHtml, headers: theHeaders});
  theResult['result'] = 'success';
  //require("utils").dump(theHtml);
  require("utils").dump(theResult);
});

casper.run();
