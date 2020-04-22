component {
	this.name = "FW1CFMigrationsTestingSuite" & hash( getCurrentTemplatePath() );
	variables.testsPath = getDirectoryFromPath( getCurrentTemplatePath() );
	this.mappings = {
		"/tests": variables.testsPath,
		"/testbox": variables.testsPath & "../testbox",
		"/framework": variables.testsPath & "../framework",
		"/resources": variables.testsPath & "/resources",
		"/cfmigrations": variables.testsPath & "../subsystems/cfmigrations",
		"/qb": variables.testsPath & "../subsystems/cfmigrations/modules/qb",
		// This is to fake the subsystem location
		"/tests/subsystems/cfmigrations": variables.testsPath & "../subsystems/cfmigrations"
	};
	this.datasource = "cfmigrations_test";
	this.datasources[ this.datasource ] = {
		class: "org.h2.Driver",
		connectionString: "jdbc:h2:#expandPath( "/resources/database/" & this.datasource )#;MODE=MySQL"
	};
}