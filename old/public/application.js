function getBuild(buildPath) { 
  console.log('run');
  setTimeout(function() {
    $.get(buildPath + ".js");
  }, 1500);
}
