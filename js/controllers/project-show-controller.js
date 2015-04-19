angular.module('Portfolio').controller('ProjectShowController', function($scope, $routeParams, Project) {
   Project.success(function(data) {
  	$scope.project = data.projects[$routeParams.id];
  }); 
});