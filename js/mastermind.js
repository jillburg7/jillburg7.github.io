$('#tabs a').click(function (e) {
  e.preventDefault()
  $(this).tab('show')
});

$('#tabs a:first').tab('show'); // Select first tab
$('#tabs a:last').tab('show'); // Select last tab
