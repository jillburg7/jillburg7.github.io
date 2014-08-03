$('#mytabs a').click(function (e) {
  e.preventDefault()
  $(this).tab('show')
});

// $('#mytabs a:first').tab('show'); // Select first tab
// $('#mytabs a:last').tab('show'); // Select last tab
