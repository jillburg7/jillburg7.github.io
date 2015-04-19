angular.module('Portfolio').directive('portfolioCard', function() {
  return {
    replace: true,
    restrict: "E",
    // scope: {
    //   name: "=",
    //   dateCompleted: "=",
    //   technologiesUsed: "=",
    //   icon: "@",
      // id: "=",
    //   type: "@"
    // },
    templateUrl: '/templates/directives/portfolio-card.html'
  };
});