angular.module('Portfolio').factory('Resume', function ResumeFactory($resource) {
  return $resource('../../data/resume.json', {}, {
    update: {
      method: "PUT"
    }
  });
});