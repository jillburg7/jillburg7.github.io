angular.module('Portfolio').factory('Project', function ProjectFactory($http) {
  return $http.get('../../data/projects.json');
});