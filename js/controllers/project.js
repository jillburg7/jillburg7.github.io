angular.module('Portfolio').controller('ProjectController', function($scope, Project) {
  Project.success(function(data) {
  	$scope.projects = data.projects;
  });
});