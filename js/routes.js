angular.module('Portfolio').config(function($routeProvider) {
	$routeProvider
		.when('/', {
			redirectTo: '/projects'
			// redirectTo: '/index.html'
		})

		.when('/projects', {
			templateUrl: "/templates/pages/projects.html",
			controller: "ProjectController"
		})

		.when('/about', {
			templateUrl: "/templates/pages/about.html",
			controller: "AboutController"
		})

		.when('/projects/:id', {
			templateUrl: "/templates/pages/show.html",
			controller: "ProjectShowController"
		});

		// .otherwise({redirectTo: '/'});

		// .when('/', {
		//   templateUrl: "",
		//   controller: "Controller"
		// })
});